; -*- mode: clojure; -*-
; vim: filetype=clojure:ts=2:sw=2

(streams 
    (where (tagged "nginx") (batch 200 5 (es-sink "http-request")))
    (where (or (tagged "docker") (tagged "syslog")) (batch 200 5 (es-sink "syslog"))))