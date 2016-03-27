#lang info

(define collection "litpub")

(define deps
  '("base"
    "collections"
    "curly-fn"
    "db-lib"
    "envy"
    "hyphenate"
    "markdown"
    "srfi-lite-lib"
    "threading"
    "txexpr"
    "web-server-lib"))
(define build-deps
  '("rackunit-lib"
    "rackunit-spec"))
