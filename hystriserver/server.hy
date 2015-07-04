(import asyncio)

(defasync replhy-server []
  (print "Hystriscene Chat Server starting on localhost:8000!")

  (setv clients [])

  (defasync handle-connection [reader writer]
    (.write writer (bytes "What is your username?\n" "utf8"))
    (setv username (.strip (await (.read reader 40))))
    (.append clients (, reader writer username))
    (for [client clients]
      (setv client-writer (. client [1]))
      (.write client-writer (bytes (.format "{} joined the room!\n" username)
                                   "utf8")))
    (print clients)
    (while true
      (setv data (await (.read reader 8192)))
      (if-not data
              (break))

      (setv message (bytes (.format "{}: {}\n" username data) "utf8"))

      (for [client clients]
        (setv client-writer (. client [1]))
        (.write client-writer message))))

  (await (asyncio.start-server handle-connection "localhost" 8000)))

(defmain [&rest args]
  (let [[loop (asyncio.get-event-loop)]]
    (.run-until-complete loop (replhy-server))
    (try (.run-forever loop)
         (finally (.close loop)))))
