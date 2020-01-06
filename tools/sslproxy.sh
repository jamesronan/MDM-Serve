sudo ncat -lk --ssl-cert test-cert.pem --ssl-key test-key.pem --sh-exec "ncat localhost 3000" 0.0.0.0 443
