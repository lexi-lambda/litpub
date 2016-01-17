#lang racket/base

(require db/base
         db/postgresql
         net/url
         racket/match
         racket/string
         (prefix-in env: "environment.rkt"))

(provide connection)

(define db-url (string->url env:database-url))
(match-define (url _ username/password host port _ (list (path/param database _)) _ _) db-url)
(define-values [username password]
  (match (string-split username/password ":")
    [(list username)          (values username #f)]
    [(list username password) (values username password)]))

(define (connect)
  (postgresql-connect #:user username
                      #:password password
                      #:database database
                      #:server host
                      #:port port))

(define connection (virtual-connection (connection-pool connect)))
