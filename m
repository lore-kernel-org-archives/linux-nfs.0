Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ie0-f178.google.com ([209.85.223.178]:57018 "EHLO
	mail-ie0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751894AbaFEN4C (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 5 Jun 2014 09:56:02 -0400
Received: by mail-ie0-f178.google.com with SMTP id rl12so870381iec.23
        for <linux-nfs@vger.kernel.org>; Thu, 05 Jun 2014 06:56:02 -0700 (PDT)
From: Weston Andros Adamson <dros@primarydata.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org, Weston Andros Adamson <dros@primarydata.com>
Subject: [PATCH pynfs v2 15/16] rpc: on socket error, close and mark pipe inactive
Date: Thu,  5 Jun 2014 09:55:43 -0400
Message-Id: <1401976544-36374-16-git-send-email-dros@primarydata.com>
In-Reply-To: <1401976544-36374-1-git-send-email-dros@primarydata.com>
References: <1401976544-36374-1-git-send-email-dros@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

call _event_close() on socket errors instead of tracing back and mark the
pipe as inactive so callers can reconnect as needed.

Signed-off-by: Weston Andros Adamson <dros@primarydata.com>
---
 rpc/rpc.py | 26 +++++++++++++++++++++++---
 1 file changed, 23 insertions(+), 3 deletions(-)

diff --git a/rpc/rpc.py b/rpc/rpc.py
index 250e945..4801883 100644
--- a/rpc/rpc.py
+++ b/rpc/rpc.py
@@ -351,6 +351,7 @@ class RpcPipe(Pipe):
         self._pending = {} # {xid:defer}
         self._lock = threading.Lock() # Protects fields below
         self._xid = 0
+        self.set_active()
 
     def _get_xid(self):
         with self._lock:
@@ -358,6 +359,15 @@ class RpcPipe(Pipe):
             self._xid = inc_u32(out)
         return out
 
+    def set_active(self):
+        self._active = True
+
+    def clear_active(self):
+        self._active = False
+
+    def is_active(self):
+        return self._active
+
     def listen(self, xid, timeout=None):
         """Wait for a reply to a CALL."""
         self._pending[xid].wait(timeout)
@@ -500,15 +510,24 @@ class ConnectionHandler(object):
                 log_p.warn(1, "polling error from %i" % fd)
                 # STUB - now what?
             for fd in w:
-                self._event_write(fd)
+                try:
+                    self._event_write(fd)
+                except socket.error, e:
+                    self._event_close(fd)
             for fd in r:
                 if fd in self.listeners:
-                    self._event_connect_incoming(fd)
+                    try:
+                        self._event_connect_incoming(fd)
+                    except socket.error, e:
+                        self._event_close(fd)
                 elif fd == self._alarm_poll.fileno():
                     commands = self._alarm_poll.recv(self.rsize)
                     for c in commands:
                         data = self._alarm.pop()
-                        switch[c](data)
+                        try:
+                            switch[c](data)
+                        except socket.error, e:
+                            self._event_close(fd)
                 else:
                     try:
                         data = self.sockets[fd].recv_records(self.rsize)
@@ -557,6 +576,7 @@ class ConnectionHandler(object):
         self.writelist -= temp
         self.readlist -= temp
         self.errlist -= temp
+        self.sockets[fd].clear_active()
         self.sockets[fd].close()
         del self.sockets[fd]
 
-- 
1.8.5.2 (Apple Git-48)

