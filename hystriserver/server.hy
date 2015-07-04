(import asyncio)

(defasync server []
  (setv clients [])

  (defasync handle-connection [reader writer]
    (.write writer (.encode "What is your username?\n"))
    (setv username (.strip (await (.read reader 40))))
    (.append clients (, reader writer username))
    (for [client clients]
      (setv client-writer (. client [1]))
      (.write client-writer (bytes (.format "{} joined the room!\n" username)
                                   "utf8")))
    (print clients)
    (while true
      (setv incoming (await (.readline reader)))
      (if-not incoming
              (break))

      (setv message (.encode (.format "{}: {}\n" username incoming)))

      (for [client clients]
        (setv client-writer (. client [1]))
        (.write client-writer message))))

  (print "Hystriscene Chat Server starting on localhost:8000!")
  (await (asyncio.start-server handle-connection "localhost" 8000)))

(defmain [&rest args]
  (let [[loop (asyncio.get-event-loop)]]
    (.run-until-complete loop (server))
    (try (.run-forever loop)
         (finally (.close loop)))))
