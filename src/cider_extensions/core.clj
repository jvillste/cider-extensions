(ns cider-extensions.core
  (:require
   [clojure.test :refer [deftest is]]))

(def ^:private a-map {:map {:string "hello"}
                      :number 1
                      :vector [{:number 2}]})

(defn value-string-preview [string-value]
  (subs string-value
        0 (min 200 (count string-value))))

(defn select-keys-autocompletions [sexp]
  (when (and (list? sexp)
             (= 'select-keys (first sexp)))
    (let [value (eval (second sexp))]
      (when (map? value)
        (for [key (->> (keys value)
                       (sort-by  pr-str))]
          (list (str key " -> "
                     (value-string-preview (pr-str (get value key))))
                (pr-str key)))))))

(deftest test-select-keys-autocompletions
  (binding [*ns* (find-ns 'cider-extensions.core)]
    (is (= '((":map -> {:string \"hello\"}" ":map")
             (":number -> 1" ":number")
             (":vector -> [{:number 2}]" ":vector"))
           (select-keys-autocompletions '(select-keys a-map))))

    (is (= '((":map -> {:string \"hello\"}" ":map")
             (":number -> 1" ":number")
             (":vector -> [{:number 2}]" ":vector"))
           (select-keys-autocompletions '(select-keys a-map []))))

    (is (= nil
           (select-keys-autocompletions '(select-keys))))))

(defn threading-macro-autocompletions [sexp]
  (when (and (list? sexp)
             (#{'-> '->>} (first sexp)))
    (let [value (eval sexp)]
      (if (map? value)
        (for [key (->> (keys value)
                       (sort-by  pr-str))]
          (let [string-value (pr-str (eval (into (list)
                                                 (reverse (concat sexp [key])))))]
            (list (str key " -> "
                       (value-string-preview string-value))
                  (pr-str key))))
        (pr-str value)))))

(deftest test-threading-macro-autocompletions
  (binding [*ns* (find-ns 'cider-extensions.core)]
    (is (= '((":map -> {:string \"hello\"}" ":map")
             (":number -> 1" ":number")
             (":vector -> [{:number 2}]" ":vector"))
           (threading-macro-autocompletions '(-> a-map))))

    (is (= "1"
           (threading-macro-autocompletions '(-> a-map :number))))

    (is (= '((":string -> \"hello\"" ":string"))
           (threading-macro-autocompletions '(-> a-map :map))))

    (is (= "\"hello\""
           (threading-macro-autocompletions '(-> a-map :map :string))))

    (is (= nil
           (threading-macro-autocompletions "(:keyword)")))

    (is (= "[{:number 2}]"
           (threading-macro-autocompletions '(-> a-map :vector))))

    (is (= "2"
           (threading-macro-autocompletions '(-> a-map :vector first :number))))))

(defn keyword-autocompletions [sexp]
  (when (and (list? sexp)
             (= 1 (count sexp)))
    (let [value (eval (first sexp))]
      (when (map? value)
        (for [key (->> (keys value)
                       (filter keyword?)
                       (sort-by name))]
          (let [string-value (pr-str (get value key))]
            (list (str key " -> "
                       (value-string-preview string-value))
                  (pr-str key))))))))

(deftest test-keyword-autocompletions
  (binding [*ns* (find-ns 'cider-extensions.core)]
    (is (= '((":map -> {:string \"hello\"}" ":map")
             (":number -> 1" ":number")
             (":vector -> [{:number 2}]" ":vector"))
           (keyword-autocompletions '(a-map))))))

(defn autocompletions [first-level-sexp second-level-sexp]
  (or (threading-macro-autocompletions first-level-sexp)
      (select-keys-autocompletions second-level-sexp)
      (keyword-autocompletions first-level-sexp)))

(deftest test-autocompletions
  (binding [*ns* (find-ns 'cider-extensions.core)]
    (is (= '((":map -> {:string \"hello\"}" ":map")
             (":number -> 1" ":number")
             (":vector -> [{:number 2}]" ":vector"))
           (autocompletions '(-> a-map) '())))

    (is (= '((":map -> {:string \"hello\"}" ":map")
             (":number -> 1" ":number")
             (":vector -> [{:number 2}]" ":vector"))
           (autocompletions '() '(select-keys a-map []))))

    (is (= '((":map -> {:string \"hello\"}" ":map")
             (":number -> 1" ":number")
             (":vector -> [{:number 2}]" ":vector"))
           (autocompletions '(a-map) '())))))
