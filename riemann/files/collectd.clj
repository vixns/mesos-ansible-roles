(streams
  (where (tagged "collectd")
    (let [og (opsgenie "3522d2b2-b665-4ebf-b3f7-9b3c15bee028" "ops_team")]
      (changed-state {:init "ok"}
        (where (state "ok")
          (with {:tags ["artevod" "Warning"]} (:resolve og))
          (with {:tags ["artevod" "Urgent" "OverwriteQuietHours"]} (:resolve og)))
        (where (state "warning") (with {:tags ["artevod" "Warning"]} (:trigger og)))
        (where (state "critical") (with {:tags ["artevod" "Urgent" "OverwriteQuietHours"]}
(:trigger og)))))))