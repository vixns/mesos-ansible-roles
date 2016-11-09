; -*- mode: clojure; -*-
; vim: filetype=clojure:ts=2:sw=2

(defn- string-to-date-long [s] (/ (clj-time.coerce/to-long (clj-time.coerce/from-string s)) 1000))
(defn- logback-to-state [s] (case s "[DEBUG]" "debug" default nil))

(defn- logback-logs-decode [v]
  (try
    (let [msg (apply str (map #(char (bit-and % 255)) v))
          parsed (clojure.string/split msg #" ")
          ;2016-04-22 15:04:09,120 a066b4389686 vodservices [DEBUG] fr.artestudio.vodservices.servlet.EZDRMFacadeServlet Init edutheque http://edutheque.arte.tv/api/drm/grant
          t (string-to-date-long (clojure.string/join "T" (take 2 parsed)))
          e { :host (parsed 2)
              :service (parsed 3)
              :time t
              :state (logback-to-state (parsed 4))
              :tags [ "logback" ]
              :endpoint (parsed 5)
              :description (clojure.string/join " " (drop 6 parsed))}]
      (riemann.common/event e))
    (catch Exception e (event {:time (clj-time.coerce/to-long (clj-time.core/now))
                               :state "critical"
                               :description (str (.getMessage e))}))))

(kafka/kafka-consumer {
                       :topic "vodservices-prod"
                       :zookeeper.connect zookeeper-uri
                       :group.id "riemann.group"
                       :auto.offset.reset "smallest"
                       :auto.commit.enable "true"}
                      logback-logs-decode)


(let [index (index)] 
  (streams
    (where (tagged "logback")
        (batch 200 5 (es-sink "logback"))
        (with {:ttl 600 :metric 1} index))))