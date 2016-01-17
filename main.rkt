#lang racket/base

(require data/collection
         db/base
         hyphenate
         (only-in markdown parse-markdown)
         racket/function
         racket/match
         racket/runtime-path
         txexpr
         web-server/dispatch
         web-server/http
         web-server/servlet-env
         (prefix-in env: "environment.rkt")
         (prefix-in t: "template.rkt")
         "model.rkt")

(define-values [server-dispatch server-url]
  (dispatch-rules
   [("") stories:list]
   [("stories" (integer-arg) (string-arg)) stories:show]))

(define (story-slug story)
  (regexp-replace* #rx"[^a-z]+" (string-downcase (story-title story)) "-"))

(define (hang-open-quotes xexprs)
  (for/list ([xexpr (in xexprs)])
    (if (equal? 'p (get-tag xexpr))
        (let loop ([xexpr xexpr])
          (let* ([elems (get-elements xexpr)])
            (if (empty? elems)
                xexpr
                (let ([first-elem (first elems)])
                  (txexpr (get-tag xexpr)
                          (get-attrs xexpr)
                          (cond [(equal? 'ldquo first-elem)
                                 (cons '(span [[class "hanging-double-quote"]] ldquo) (rest elems))]
                                [(list? first-elem) (cons (loop first-elem) (rest elems))]
                                [else (get-elements xexpr)]))))))
        xexpr)))

(define (errors:not-found req)
  (response/xexpr #:code 404 #:message #"Not Found"
                  `(html (body (h1 "404 Not Found")))))

(define (stories:list req)
  (define (list-stories stories)
    `(ul . ,(for/list ([story (in stories)])
              `(li (a [[href ,(server-url stories:show (story-id story) (story-slug story))]]
                      ,(story-title story))))))
  (let ([all-stories (query-stories)])
    (response/xexpr
     (t:page "Stories"
             `((div [[class "content"]]
                    (h1 "Stories")
                    ,(list-stories (filter (negate story-draft?) all-stories))
                    (h2 "Drafts & Works in Progress")
                    ,(list-stories (filter story-draft? all-stories))))))))

(define (stories:show req id slug)
  (define story (query-story id))
  (cond
    [(not story) (errors:not-found req)]
    [(equal? slug (story-slug story))
     (response/xexpr
      (t:page (story-title story)
              `((div [[class "content"]]
                     (h1 ,(story-title story))
                     ,@(hang-open-quotes (map hyphenate (parse-markdown (story-body story))))))))]
    [else (redirect-to (server-url stories:show id (story-slug story)))]))

(define-runtime-path public-path "public")

(serve/servlet server-dispatch
               #:port env:port
               #:launch-browser? #f
               #:listen-ip #f
               #:servlet-regexp #rx""
               #:extra-files-paths (list public-path)
               #:file-not-found-responder errors:not-found)
