#lang curly-fn racket/base

;; This module is ported from Ruby’s Rack::Request. It deduces a client’s ip through forwarding
;; proxies.

(require racket/function
         racket/list
         racket/string
         threading
         web-server/http/request-structs)

(provide client-ip)

(define (client-ip req)
  (let* ([raw-headers (request-headers/raw req)]
         [remote-addrs (and~>> (headers-assq #"REMOTE_ADDR" raw-headers)
                               header-value
                               bytes->string/utf-8
                               split-ip-addresses
                               (filter (negate trusted-proxy?)))])
    (or (and remote-addrs
             (not (empty? remote-addrs))
             (first remote-addrs))
        (let ([forwarded-ips (and~>> (headers-assq* #"X-Forwarded-For" raw-headers)
                                     header-value
                                     bytes->string/utf-8
                                     split-ip-addresses
                                     (filter (negate trusted-proxy?)))])
          (or (and forwarded-ips
                   (not (empty? forwarded-ips))
                   (last forwarded-ips))
              (request-client-ip req))))))

(define (split-ip-addresses ips)
  (regexp-split #px"(,|\\s)+" (string-trim ips)))

(define trusted-proxy?
  (disjoin #{string=? "127.0.0.1"}
           #{string=? "::1"}
           #{string-ci=? "localhost"}
           #{string-ci=? "unix"}
           #{regexp-match? #px"^(10|172\\.(1[6-9]|2[0-9]|30|31)|192\\.168)\\."}
           #{regexp-match? #px"(?i:^fd[0-9a-f]{2}:.+)"}
           #{regexp-match? #px"(?i:^unix:)"}))

(module+ test
  (require net/url
           racket/promise
           rackunit)

  (check-true (trusted-proxy? "127.0.0.1"))
  (check-true (trusted-proxy? "10.0.0.1"))
  (check-true (trusted-proxy? "172.16.0.1"))
  (check-true (trusted-proxy? "172.20.0.1"))
  (check-true (trusted-proxy? "172.30.0.1"))
  (check-true (trusted-proxy? "172.31.0.1"))
  (check-true (trusted-proxy? "192.168.0.1"))
  (check-true (trusted-proxy? "::1"))
  (check-true (trusted-proxy? "fd00::"))
  (check-true (trusted-proxy? "localhost"))
  (check-true (trusted-proxy? "unix"))
  (check-true (trusted-proxy? "unix:/tmp/sock"))

  (check-false (trusted-proxy? "unix.example.org"))
  (check-false (trusted-proxy? "example.org\n127.0.0.1"))
  (check-false (trusted-proxy? "127.0.0.1\nexample.org"))
  (check-false (trusted-proxy? "11.0.0.1"))
  (check-false (trusted-proxy? "172.15.0.1"))
  (check-false (trusted-proxy? "172.32.0.1"))
  (check-false (trusted-proxy? "2001:470:1f0b:18f8::1"))

  (define (req headers [ip ""])
    (let ([headers* (map #{header (car %) (cdr %)} headers)])
      (request #"GET" (string->url "http://example.com") headers* (delay #f) #f "" 0 ip)))

  (check-equal? (client-ip (req '((#"REMOTE_ADDR" . #"1.2.3.4")
                                  (#"X-Forwarded-For" . #"3.4.5.6"))))
                "1.2.3.4")
  (check-equal? (client-ip (req '((#"REMOTE_ADDR" . #"1.2.3.4")
                                  (#"X-Forwarded-For" . #"unknown"))))
                "1.2.3.4")
  (check-equal? (client-ip (req '((#"REMOTE_ADDR" . #"127.0.0.1")
                                  (#"X-Forwarded-For" . #"3.4.5.6"))))
                "3.4.5.6")

  (check-equal? (client-ip (req '((#"REMOTE_ADDR" . #"unix")
                                  (#"X-Forwarded-For" . #"3.4.5.6"))))
                "3.4.5.6")
  (check-equal? (client-ip (req '((#"REMOTE_ADDR" . #"unix:/tmp/foo")
                                  (#"X-Forwarded-For" . #"3.4.5.6"))))
                "3.4.5.6")

  (define-check (check-ip/forwarded-for input expected)
    (check-equal? (client-ip (req `((#"X-Forwarded-For" . ,input)))) expected))

  (check-ip/forwarded-for #"unknown,3.4.5.6" "3.4.5.6")
  (check-ip/forwarded-for #"192.168.0.1,3.4.5.6" "3.4.5.6")
  (check-ip/forwarded-for #"10.0.0.1,3.4.5.6" "3.4.5.6")
  (check-ip/forwarded-for #"10.0.0.1, 10.0.0.1, 3.4.5.6" "3.4.5.6")
  (check-ip/forwarded-for #"127.0.0.1, 3.4.5.6" "3.4.5.6")
  (check-ip/forwarded-for #"unknown,192.168.0.1" "unknown")
  (check-ip/forwarded-for #"other,unknown,192.168.0.1" "unknown")
  (check-ip/forwarded-for #"unknown,localhost,192.168.0.1" "unknown")
  (check-ip/forwarded-for #"9.9.9.9, 3.4.5.6, 10.0.0.1, 172.31.4.4" "3.4.5.6")
  (check-ip/forwarded-for #"8.8.8.8, 9.9.9.9" "9.9.9.9")
  
  (check-ip/forwarded-for #"::1,2620:0:1c00:0:812c:9583:754b:ca11"
                          "2620:0:1c00:0:812c:9583:754b:ca11")
  (check-ip/forwarded-for #"2620:0:1c00:0:812c:9583:754b:ca11,::1"
                          "2620:0:1c00:0:812c:9583:754b:ca11")
  (check-ip/forwarded-for #"fd5b:982e:9130:247f:0000:0000:0000:0000,2620:0:1c00:0:812c:9583:754b:ca11"
                          "2620:0:1c00:0:812c:9583:754b:ca11")
  (check-ip/forwarded-for #"2620:0:1c00:0:812c:9583:754b:ca11,fd5b:982e:9130:247f:0000:0000:0000:0000"
                          "2620:0:1c00:0:812c:9583:754b:ca11")
  (check-ip/forwarded-for #"8.8.8.8, fe80::202:b3ff:fe1e:8329" "fe80::202:b3ff:fe1e:8329")
  

  (check-equal? (client-ip (req '((#"X-Forwarded-For" . #"1.1.1.1, 127.0.0.1"))
                                "1.1.1.1"))
                "1.1.1.1"))
