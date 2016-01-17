#lang racket/base

(require racket/runtime-path
         web-server/servlet-env
         (prefix-in env: "environment.rkt")
         (prefix-in errors: "handler/error.rkt")
         "route.rkt")

(define-runtime-path public-path "public")

(serve/servlet server-dispatch
               #:port env:port
               #:launch-browser? #f
               #:listen-ip #f
               #:servlet-regexp #rx""
               #:extra-files-paths (list public-path)
               #:file-not-found-responder errors:not-found)
