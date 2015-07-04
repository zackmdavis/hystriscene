(import asyncio)
(import sys)

(defasync client-reader [reader]
  (while true
    (setv incoming (await (.readline reader)))
    (if-not incoming
            (break))
    (print incoming)))

(defasync silent-client []
  (setv [reader writer] (await (asyncio.open_connection "127.0.0.1" 8000)))
  (await (.readline reader))
  (.write writer (.encode "Observer\n"))
  (while true
    (await (client-reader reader))))

(defmain [&rest args]
  (let [[loop (asyncio.get-event-loop)]]
    (.run-until-complete loop (silent-client))
    (try (.run-forever loop)
         (finally (.close loop)))))
