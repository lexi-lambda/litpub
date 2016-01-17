#lang racket/base

(require racket/runtime-path
         racket/unit
         web-server/configuration/responders
         web-server/servlet-env
         (prefix-in env: "environment.rkt")
         "route-sig.rkt"
         "route-unit.rkt"
         "handler/error-sig.rkt"
         "handler/error-unit.rkt"
         "handler/story-unit.rkt")

(define-values/invoke-unit/infer
  (export route^
          (prefix errors: error^))
  (link route@ error@ story@))

(define-runtime-path public-path "public")

(serve/servlet server-dispatch
               #:port env:port
               #:launch-browser? #f
               #:listen-ip #f
               #:servlet-regexp #rx""
               #:extra-files-paths (list public-path)
               #:file-not-found-responder errors:not-found
               #:servlet-responder (case env:server-env
                                     [(development) servlet-error-responder]
                                     [(production)  errors:internal-server-error]
                                     [else          (error "unknown environment ~v" env:server-env)]))
