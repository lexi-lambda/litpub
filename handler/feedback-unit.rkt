#lang racket/unit

(require data/collection
         net/uri-codec
         threading
         web-server/http
         "../model.rkt"
         "../template.rkt"
         "../util/client-ip.rkt"
         
         "../route-sig.rkt"
         "story-sig.rkt"
         "feedback-sig.rkt")

(import route^ (prefix stories: story^))
(export feedback^)

(define (form req)
  (response/xexpr
   (page "Give Feedback"
         `((div [[class "content"]]
                (a [[class "pull-gutter"] [href ,(server-url stories:index)]] "← Index")
                (h1 "Feedback")
                (p "Have anything to say about the site or its content? Let me know here. If you "
                   "want a response, leave an email address or other handle, and I’ll get back to "
                   "you. Otherwise, feel free to be anonymous.")
                (form [[method "post"] [class "content-form"] [action ,(server-url submit)]]
                      (textarea [[name "body"] [placeholder "Type anything you want here..."]])
                      (button [[type "submit"] [class "content-button"]] "Submit")))))))

(define (submit req)
  (let* ([ip (client-ip req)]
         [data (~> (request-post-data/raw req)
                   bytes->string/utf-8
                   form-urlencoded->alist)]
         [body (ref data 'body)])
    (create-user-feedback! ip body)
    (response/xexpr
     (page "Feedback Submitted"
           `((div [[class "content"]]
                  (a [[class "pull-gutter"] [href ,(server-url stories:index)]] "← Index")
                  (h1 "Thank You For Your Feedback")
                  (p "Your feedback has been received! Thank you for your time. If you included any "
                     "identifying information, I’ll try and get back to you. Otherwise, just know "
                     "your voice will be heard.")
                  (p "In the meantime, you can "
                     (a [[href ,(server-url stories:index)]] "Return to the story index") ".")))))))
