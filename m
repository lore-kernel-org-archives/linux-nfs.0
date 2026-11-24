Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=209.85.128.51
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1795554606;
	b=BXQ0UbnAeWuAdgAj//erc9GFkMg3FCofULW+pOCEH35r6FKBGunytJfnOEfZ/yKR2qTH
	 XvTlqYFD9pnsGpIuWD+DsvL4vzoJF0oTR+EtMMbxTBy05MYY5zI6fpf8Wbd9xap4Pu4To
	 GTCQrw6Nab/i74c1C5jaLldRJ1J2zrkeZRd0RadiFJ7abm0egOknWwkwLVe8CDEKCHgtn
	 ooYRUJH6bzRgWsNOSB8i9nx8ZhETj5M8KelEz6hvkEMI9b0M97m/wOgp9kHVsGxK6Jc74
	 rKX0Tek7N093vU9eTsXDN1xEnt24fgQ6UEepzAKj8BiPgysnvpFAYcqdMDPULxUeB3A==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1795554606;
	h=DMARC-Filter:Received:DKIM-Signature:X-Google-DKIM-Signature:
	 X-Gm-Message-State:X-Gm-Gg:X-Received:Received:From:To:Cc:Subject:
	 Date:Message-Id:X-Mailer:MIME-Version:Content-Transfer-Encoding;
	bh=ipBrVNHrsmIp13TO97tx3xWjk4Xi2D08gxSqs64fS+g=;
	b=Fr2q4ZDdHHfR+K60FAGsjYKSS5uCz/UsKHYFcnJvKyrJ+62U3nK8rzkLLsSO8ti9S4KP
	 Ni8B+kni0nK7dA6DE0iw7tN+EPdLNLBRw6Cn5Apl79mOWekfJM6j04D8+rNNELokqaLNY
	 Ao/tx+CbPGBGH2aFl7IjZIV357I9QMtjgFwbX3aV4dVAhIoQ1K5Hyoti3IqvlkRuxBtuF
	 EJbiAzNCtb1m8A2ENTV9nw64y4IfFVk8PHlaL9PvUIvqyyDaEIj1jJR4+dQ4wnEQfNMX7
	 3mT8JnTZXZfmZ92sIknrc+PxWs8DHGZDsr3WAvXMTYSWiwsQ2XbpojFrCjGegQFo36g==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=gmail.com;
	spf=pass smtp.mailfrom=gmail.com;
	dkim=pass header.d=gmail.com header.i=@gmail.com header.a=rsa-sha256 header.s=20260707 header.b=C5tdZOfn;
	arc=none smtp.remote-ip=209.85.128.51
Received: from mail-wm1-f51.google.com (mail-wm1-f51.google.com [209.85.128.51])
	(using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128/128 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 4124E606A323
	for <linux-nfs@vger.kernel.org>; Tue, 24 Nov 2026 21:10:06 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 4124E606A323
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.a=rsa-sha256 header.s=20260707 header.b=C5tdZOfn
Received: by mail-wm1-f51.google.com with SMTP id 5b1f17b1804b1-4bb606491faso27532995e9.3
        for <linux-nfs@vger.kernel.org>; Tue, 24 Nov 2026 13:10:06 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20260707; t=1795554604; x=1796159404; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:from:to:cc:subject:date:message-id:reply-to:content-type;
        bh=ipBrVNHrsmIp13TO97tx3xWjk4Xi2D08gxSqs64fS+g=;
        b=C5tdZOfnPdCQZwm+MSmd+lAHVmMXJgC/N3h6nSUTY8Q3u9TPeA2VmXvd6FYeIK9Ssl
         AY88p1vCKEsjF0vP/zXSnCQjD9a7+5ZQRvzeeu84BWgB6GLQWm7pYRUcjzba8re1tMAg
         3cQupSy27FJGDqJMwqxSlrK1coWArxwdXvibzWngLPfhBZ2t/OJWYkOwc+Ii9wbf7SDm
         pUNjGpiBcAXux3jhD+gq9sB4XP3TyMGOjNa1a8tA0HtrEJQcp8w6J5uz7i7/z+jBhfS4
         39s8yla6YZICpxSeORzUTokWcvnw23VDAa6wtxyCMopDDuk7WAYaf/E5sRw+WgyJhgxC
         GHiA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1795554604; x=1796159404;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:x-gm-gg:x-gm-message-state:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=ipBrVNHrsmIp13TO97tx3xWjk4Xi2D08gxSqs64fS+g=;
        b=PbDEFblHZxn0JCnJH8a2zHgJrxrlwO/HptFG94Z4GdpFtyVXmXzcSo8MaK/fALGaxl
         ubu17e1UkWk++z0Cli2ttEUbm0IhSzZcUjhYD6oSM4HEi1hqBIggKgyfcGURr5hMaMlY
         pZz6ii6z5EFphlrFjW/IFa1oqGxj91C+zqcXNHqXH6yEzqLW/861RRy4YHGe1Mubxtvv
         EoUNHRw2BXffJBx9j7NwECYJRHoa5OdnMCNk1A9FQxeIm1w21D9pFC6uZX3S3y+9c3bs
         7caVKEiTTmQEH2Q6VaFNQLu5KXAFGTkmr+3a/WLT6z/dTiN2oCsSakkpsmshw8Ix2+1m
         ZHSw==
X-Gm-Message-State: APuU4Z9eMQNz/YAq0bgCaFrEID7NVoRaOHjZW94KpZGftjmhShtbatLa
	q9N2WnYRo/ZWkKeSYX0EclzRgUN9lWGbkRTAgGRKkqaR1Lh6A3jtmtLtQSCqAwwy
X-Gm-Gg: AZFdTZcmnVHdoNjVaBg1jLaSJHedHC6Q1R3PhUUscsyPfyyT3JpAjMczpwUWSjjJppS
	wVyUh5a37BNsMDD2UOE22bLjo0z+uVbUkK0vQp0jkHh9w/uclA0MSykgGtl6ahV62A+he9XZeIT
	7K7HgvaAeUEIiRL3t829jJSPGBxFiH4XuhXAhH1VEHdFh5dh1xI5DvDbX+UkWbgauWqrEIkYf1z
	37psAmW7eQG2F2PilJF7BvaWzIBJ7ApImFmiVI4PGvi6tPj+q8EQ9wldK47yhVeMS1RV57qj1Cn
	iOC27IBb9f+6EWQZGp5SEkwCRUIJW/NqsEkbQyv4Ur+Gf6fKHabIiRM+YkTEtanoa5rBRtT804N
	d5m3gbhAQG37+SjzdK+kMAyjr7co2iBsNCr6fhOr4kzIId4VbWF5OA11VXq1V9/b5G3A58Lgl4f
	ohuswm+fgdfOwXYWTisKNn+vP53KdQXPVcqMq1v5WdFvvyl/K+GjmAK+lcI4ZL6O2t3Vo3vnZnR
	0pGyPCsJxjuTk4Z1+QTrKSCxzxW9DNJipjzdXOHGnIalvvGRa4OvxUT8HheDDDTUkeX3FTxnYLV
	dqOkc3FuPaz0I4lBkzPyTRG2JXN0BjYT5B8k
X-Received: by 2002:a05:600c:1384:b0:4a2:1612:6367 with SMTP id 5b1f17b1804b1-4bb88816c44mr331683495e9.15.1795554604452;
        Tue, 24 Nov 2026 13:10:04 -0800 (PST)
Received: from localhost.localdomain ([5.43.207.246])
        by smtp.gmail.com with ESMTPSA id ffacd0b85a97d-4ab6a67f204sm35342994f8f.21.2026.11.24.13.10.02
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Tue, 24 Nov 2026 13:10:03 -0800 (PST)
From: Rida Shamasneh <ridahani@gmail.com>
To: calum.mackay@cdmnet.org,
	jlayton@kernel.org,
	cel@kernel.org
Cc: linux-nfs@vger.kernel.org,
	Rida Shamasneh <ridahani@gmail.com>
Subject: [PATCH] rpc: do not format a whole reply for the debug log
Date: Tue, 24 Nov 2026 23:09:45 +0200
Message-Id: <20261124210945.242250-1-ridahani@gmail.com>
X-Mailer: git-send-email 2.25.1
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

_event_rpc_record built the text of its debug messages, %r of the whole
record and of its data, before the logging module could say it was not
wanted. For a 900 KB reply that is a string of 2.6 million characters
each, twice per reply, several times the cost of the READ itself.
The same went for the poll loop, which formatted its sets of sockets at
every pass, and for send_reply.

Pass the arguments to the logger instead, so they are formatted only if
the message is emitted.

Time for one READ of 900 KB over TCP: 48.8 ms to 17.2 ms.

Signed-off-by: Rida Shamasneh <ridahani@gmail.com>
---
 rpc/rpc.py | 19 ++++++++++---------
 1 file changed, 10 insertions(+), 9 deletions(-)

diff --git a/rpc/rpc.py b/rpc/rpc.py
index 84088f6..2f20b70 100644
--- a/rpc/rpc.py
+++ b/rpc/rpc.py
@@ -385,7 +385,7 @@ class RpcPipe(Pipe):
         self.push_record(header + data)
 
     def send_reply(self, xid, body, proc_response=""):
-        log_t.debug("send_reply\nbody = %r\ndata=%r" % (body, proc_response))
+        log_t.debug("send_reply\nbody = %r\ndata=%r", body, proc_response)
         msg = rpc_msg(xid, rpc_msg_body(REPLY, rbody=body))
         self.rpc_send(msg, proc_response)
 
@@ -504,10 +504,10 @@ class ConnectionHandler(object):
                   }
         while not self._stopped:
             log_p.debug("Calling select")
-            log_p.log(5, "Sleeping for: %s, %s, %s" %
-                 (self.readlist, self.writelist, self.errlist))
+            log_p.log(5, "Sleeping for: %s, %s, %s",
+                      self.readlist, self.writelist, self.errlist)
             r,w,e = select.select(self.readlist, self.writelist, self.errlist)
-            log_p.log(5, "Woke with: %s, %s, %s" % (r, w, e))
+            log_p.log(5, "Woke with: %s, %s, %s", r, w, e)
             for fd in e:
                 log_p.warn(1, "polling error from %i" % fd)
                 # STUB - now what?
@@ -596,7 +596,7 @@ class ConnectionHandler(object):
         s = self.sockets[fd]
         for r in records:
             log_p.log(5, "Received record from %i" % fd)
-            log_p.log(2, repr(r))
+            log_p.log(2, "%r", r)
             t = threading.Thread(target=self._event_rpc_record, args=(r, s))
             t.setDaemon(True)
             t.start()
@@ -606,7 +606,7 @@ class ConnectionHandler(object):
 
         This is run in its own thread.
         """
-        log_t.log(5, "_event_rpc_record thread receives %r" % record)
+        log_t.log(5, "_event_rpc_record thread receives %r", record)
         # log_t.info("_event_rpc_record thread receives %r" % record)
         try:
             p = FancyRPCUnpacker(record)
@@ -619,8 +619,9 @@ class ConnectionHandler(object):
             log_t.debug("unpacking raised the following error", exc_info=True)
             self._notify_drop()
             return # Drop incorrectly encoded packets
-        log_t.debug("MSG = %s" % str(msg))
-        log_t.debug("data = %r" % msg_data)
+        # not formatted here: a reply can be megabytes of data
+        log_t.debug("MSG = %s", msg)
+        log_t.debug("data = %r", msg_data)
         if msg.mtype == REPLY:
             self._event_rpc_reply(msg, msg_data, pipe)
         elif msg.mtype == CALL:
@@ -699,7 +700,7 @@ class ConnectionHandler(object):
             if not isinstance(result, bytes):
                 raise TypeError("Expected bytes, got %s" % type(result))
             # status, result = method(msg_data, call_info)
-            log_t.debug("Called method, got %r, %r" % (status, result))
+            log_t.debug("Called method, got %r, %r", status, result)
         except rpclib.RPCDrop:
             # Silently drop the request
             self._notify_drop()
-- 
2.25.1

