(ns cider-extensions.core
  (:require
   [clojure.test :refer [deftest is]]))

(def ^:private a-map {:map {:string "hello"}
                      :number 1
                      :vector [{:number 2}]})

(defn thread-first-completions [sexp]
  (when (and (list? sexp)
             (= '-> (first sexp)))
    (let [value (eval sexp)]
      (if (map? value)
        (for [key (keys value)]
          (let [string-value (pr-str (eval (into (list)
                                                 (reverse (concat sexp [key])))))]
            (list (str key " -> "
                       (subs string-value
                             0 (min 200 (count string-value))))
                  (pr-str key))))
        (pr-str value)))))

(deftest test-thread-first-completions
  (is (= '((":map -> {:string \"hello\"}" ":map")
           (":number -> 1" ":number")
           (":vector -> [{:number 1} {:number 2}]" ":vector"))
         (thread-first-completions '(-> a-map))))

  (is (= "1"
         (thread-first-completions '(-> a-map :number))))

  (is (= '((":string -> \"hello\"" ":string"))
         (thread-first-completions '(-> a-map :map))))

  (is (= "\"hello\""
         (thread-first-completions '(-> a-map :map :string))))

  (is (= nil
         (thread-first-completions :keyword)))

  (is (= "[{:number 2}]"
         (thread-first-completions '(-> a-map :vector))))

  (is (= "2"
         (thread-first-completions '(-> a-map :vector first :number)))))
