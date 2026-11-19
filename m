Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=209.85.161.42
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1795124465;
	b=4Owx48C22IGB1lBjc15GBI8zbiOROP2G325ZWDKzTwkG0lNH9C9h2uXQNsV0NDJ5/Wv4
	 Pen+jkgIHrRHA6nqcFR/n6Lewzy5Dif5zB46Bybvg/ZAyegx9BcWU0ndi7P3ckf75gv+3
	 UdTGA5RVmcokt12WSemknD8a+2Ywlb77kZzgfzkC08fI7BpjJ2dnyCbyBIy2T2fY43HXH
	 KwkGvam59uUAfaqlqdmfZhgSk09YfPBpumTQRXPASoKK3SCroxaepmZ5yR5IBPMLcaDnB
	 p0HvvRYEzbD9tZ0ROTwUf3W36OK75wnKxoEmifR2wnRrhKSzoJoLsCO42bCbMNa1Tfg==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1795124465;
	h=DMARC-Filter:Received:DKIM-Signature:X-Google-DKIM-Signature:
	 X-Gm-Message-State:X-Gm-Gg:X-Received:Received:From:
	 X-Google-Original-From:To:Cc:Subject:Date:Message-ID:X-Mailer:
	 In-Reply-To:References:MIME-Version:Content-Transfer-Encoding;
	bh=GfhNxDcLM+wiYA5mIHDmmk4xPrxriBFxLTmRavpWgMI=;
	b=St0rH3nNOnyKSP/sI0nl8jFPHpK/jMD7VsvVarywY3L7BL0DRdFumCzzAIO7m1DOh4LS
	 +j0MI0KNFfeu1PYMAH2Eb5cu8z6ChuV7F9VdgXlEe4143S9YzeGfXfPNKnPsW2LMnw870
	 F+gWzZFM9D64qOnS7t0WxlfMVf5fnzNPVxsJE2skfZ1zLBqOZ98pbeDww6DaSnJchw6Yj
	 0mhKagKF4CXn5LJCl27FDTNu4WSaaJalsnfxZJy4ABHfS2agBzwi0e+8FTlg0ZvwKqbld
	 aDbV+Eue/WJ6ZFkQPWQU+tBfroOYL5XGrfJa2+LAIawAS8/z2Q8iv3iOoF+ly2Nq9yA==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=hammerspace.com;
	spf=pass smtp.mailfrom=hammerspace.com;
	dkim=pass header.d=hammerspace.com header.i=@hammerspace.com header.a=rsa-sha256 header.s=google header.b=bS5ioln5;
	arc=none smtp.remote-ip=209.85.161.42
Received: from mail-oo1-f42.google.com (mail-oo1-f42.google.com [209.85.161.42])
	(using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128/128 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 56A05606A332
	for <linux-nfs@vger.kernel.org>; Thu, 19 Nov 2026 21:41:05 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 56A05606A332
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.a=rsa-sha256 header.s=google header.b=bS5ioln5
Received: by mail-oo1-f42.google.com with SMTP id 006d021491bc7-71acdd32a53so91432eaf.3
        for <linux-nfs@vger.kernel.org>; Thu, 19 Nov 2026 13:41:05 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=hammerspace.com; s=google; t=1795124464; x=1795729264; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=GfhNxDcLM+wiYA5mIHDmmk4xPrxriBFxLTmRavpWgMI=;
        b=bS5ioln5jMR3Mml4B741R7PNgDkJn/NqxZjM8v1MBKmrp20fQZUiNI1Jpy13UnG2TH
         TfxjceReQ9rXRPSBDmtn1GoncKDhVF5bI5JgK9FWSb7ez9BKTHL3fAQRSi9T6T8+CLNR
         UzstoUWJEntxNBoc3c8s0w4lMpluNKa08pUIC7CBfwfvUI1StHASi5BI8y5l/KxSJkNG
         /a8ZZ5xUiSqAO+VyH958KPNTDGGkIGLtClAX7AKSq9gGf0qdWrD3B5z1/ZXZheQjhvl/
         JUsPwUbEN83+u6mKUZH5/ADzWCX8N3c32CXULuP4ma8ZSbFznZR9vxyHt0XLIxU6sM9K
         WD8w==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1795124464; x=1795729264;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:x-gm-gg:x-gm-message-state:from
         :to:cc:subject:date:message-id:reply-to:content-type;
        bh=GfhNxDcLM+wiYA5mIHDmmk4xPrxriBFxLTmRavpWgMI=;
        b=pO/RzWbJNA5p6FkT7Hcf91LeHjRIBeJuAUSbMZ+713peZbsjiCj3Jcxgfc23HZRFmD
         p0NaTxABAtlAEW4N0SfEm2mRmQ9BhOUTdmujrfD3pzNmMYwEczGJp4aqDudVXxErdAYR
         p3V8VujY4AFzBGBYc0NDfF0gks08rJ7sRwImvU2pXRhICrYYKwmeJaRX/xkiCBhAIf8e
         Z9f8YqZ4muJZd1i/68aC8bPEToGXGkE+ejfDiNb7mcV/TGn8NVMqpJyj+D/Uobw6qDVR
         Evdn7XfvfkvN8Y3bCfaLOB4qTsVa6vrm3PQSwaEUpkGNJR7w7wvzvYTvggKjONr64zxd
         w59g==
X-Gm-Message-State: APuU4Z9H3JHiHOG1qUHvdSTFa7Fd94/OZ/u9zgkFlRWg3BMCbwY5UwC7
	vtTHmY5pSsQrnsXxtSingrdb3GHh5BpR2VSJSzJ5LUYWNE+Gq9QthgJj6/v72azp5txv+2tmUDS
	hZf6r
X-Gm-Gg: AYBFou0WaAILUMw9to+DsA2oy+A3U6gsK6x5aOjEmgoaDcZBlcLpqrw3fJfbFGk7VGJ
	2eRvXV5+BozJk4lm3xGzWZ0U8m1ZQ45nNRIQN7YcOLBEnGiOKjid9/FT4J2Mb49SYdwFl9HQaHv
	FIVP+hzx/DTIT6noMpcazafBvRL5NFAtg+XrEzTqmEpyIOrMmRzpgAvGUbPjA2sVw4QAK/b1vZW
	id5Tur+pmSyPNeEj0qkzJeQtlEyuqbnY/FUeCZDPLSXsfDrlFTZt0t6sPc5tcrPZGB+fAUN8sBW
	xJZAQaUPpkXEZ6in+VxkgXO2DPjPkRLrNiXK4fyfmmRt0b9H9xowqvtrTRj39shrg2XTdqBkQ7P
	6pB8g87PupnUbVibdiUwRiLL44TFheiloD/RIOtG/d1wq8Ahutbzhqcp7EWR7yE2gCbHKHhIOPD
	xQGqXg0+zIwJYGXsR5Cp6S724EpQ2EU6ISQY7Qbi3XcCsatVPDtRzPszatvAH2O6KoMrudqCesy
	zToXO6OQMAVYazXpMzawE4whM9fK/7iz48MBv36aBkRiwFThKyplZBNT4w5w8gPr734OMsh2E9T
	JhHvP9vB9nmTLTvZBKAYtL5bwZE6scd9TeEcaZjcL/NpWlcZPW0SiBitM2Gy4PRPDHXS
X-Received: by 2002:a05:6820:a788:b0:6d9:8a4a:7114 with SMTP id 006d021491bc7-71b394b85femr802260eaf.48.1795124464038;
        Thu, 19 Nov 2026 13:41:04 -0800 (PST)
Received: from bcodding.csb.hammerspace.com ([12.117.181.174])
        by smtp.gmail.com with ESMTPSA id 46e09a7af769-8631670c44dsm642217a34.0.2026.11.19.13.41.03
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Thu, 19 Nov 2026 13:41:03 -0800 (PST)
From: Benjamin Coddington <ben.coddington@hammerspace.com>
X-Google-Original-From: Benjamin Coddington <bcodding@hammerspace.com>
To: calum.mackay@oracle.com
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH pynfs 2/2] rpc: fail pending calls when a connection closes
Date: Thu, 19 Nov 2026 16:41:00 -0500
Message-ID: <321bafdaeb10b06827a352043556600197b49ad6.1795124374.git.bcodding@hammerspace.com>
X-Mailer: git-send-email 2.53.0
In-Reply-To: <cover.1795124374.git.bcodding@hammerspace.com>
References: <cover.1795124374.git.bcodding@hammerspace.com>
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

When the server closed a connection, _event_close() closed the pipe
but left callers waiting on replies until their timeout. A later call
on that pipe made _buzz_write_ready() add the closed socket's fileno()
of -1 to the write list, and select() raised ValueError, killing the
polling thread. Every call and connect after that hung until timeout.

Add RPCConnectionClosed. On close, mark the pipe inactive and fail its
pending calls with it. send_call() raises it on an inactive pipe, and
_buzz_write_ready() drops records for one. DeferredData.fill() now
ignores fills after the first, so a reply that arrives during close is
not overwritten.

In the polling loop, skip fds closed earlier in the same pass, and log
alarm command errors instead of closing the alarm socket.

Signed-off-by: Benjamin Coddington <bcodding@hammerspace.com>
---
 rpc/rpc.py | 42 +++++++++++++++++++++++++++++++++++-------
 1 file changed, 35 insertions(+), 7 deletions(-)

diff --git a/rpc/rpc.py b/rpc/rpc.py
index 4d0cc2d01a20..a7a053262d06 100644
--- a/rpc/rpc.py
+++ b/rpc/rpc.py
@@ -34,6 +34,9 @@ class RPCError(Exception):
 class RPCTimeout(RPCError):
     pass
 
+class RPCConnectionClosed(RPCError):
+    pass
+
 class RPCAcceptError(RPCError):
     def __init__(self, a):
         self.verf = a.verf
@@ -141,6 +144,7 @@ class DeferredData(object):
     """
     def __init__(self, msg=None):
         self._filled = threading.Event()
+        self._lock = threading.Lock()
         self.data = None
         self._exception = None
         self.msg = msg # Data that thread calling fill might need
@@ -157,10 +161,14 @@ class DeferredData(object):
         """Fill with data, and flag that this has been done.
 
         Caller should no longer reference the object afterwards.
+        Only the first fill takes effect.
         """
-        self._exception = exception
-        self.data = data
-        self._filled.set()
+        with self._lock:
+            if self._filled.is_set():
+                return
+            self._exception = exception
+            self.data = data
+            self._filled.set()
 
 class Alarm(object):
     """A method of notifying select loop that there is data waiting"""
@@ -370,6 +378,14 @@ class RpcPipe(Pipe):
     def is_active(self):
         return self._active
 
+    def fail_pending(self, exc):
+        """Mark pipe closed and fail every call still waiting on a reply."""
+        with self._lock:
+            self._active = False
+            pending = list(self._pending.values())
+        for defer in pending:
+            defer.fill(exception=exc)
+
     def listen(self, xid, timeout=None):
         """Wait for a reply to a CALL."""
         self._pending[xid].wait(timeout)
@@ -400,7 +416,10 @@ class RpcPipe(Pipe):
         msg = rpc_msg(xid, rpc_msg_body(CALL, body))
         data = sec.secure_data(cred, data)
         # Store info needed be receiving thread to match and verify reply
-        self._pending[xid] = DeferredData((cred, sec))
+        with self._lock:
+            if not self._active:
+                raise RPCConnectionClosed("connection closed")
+            self._pending[xid] = DeferredData((cred, sec))
         self.rpc_send(msg, data)
         return xid
 
@@ -477,6 +496,9 @@ class ConnectionHandler(object):
 
     def _buzz_write_ready(self, pipe):
         """Pipe has data ready to be sent out"""
+        if not pipe.is_active():
+            # Closed by _event_close(); its fileno() is now -1
+            return
         pipe.pop_record(self.wsize)
         self.writelist.add(pipe.fileno())
 
@@ -512,11 +534,16 @@ class ConnectionHandler(object):
                 log_p.warn(1, "polling error from %i" % fd)
                 # STUB - now what?
             for fd in w:
+                if fd not in self.sockets:
+                    continue
                 try:
                     self._event_write(fd)
                 except socket.error as e:
                     self._event_close(fd)
             for fd in r:
+                if fd not in self.sockets:
+                    # Closed earlier in this pass
+                    continue
                 if fd in self.listeners:
                     try:
                         self._event_connect_incoming(fd)
@@ -529,7 +556,7 @@ class ConnectionHandler(object):
                         try:
                             switch[c](data)
                         except socket.error as e:
-                            self._event_close(fd)
+                            log_p.error("alarm command %i failed: %s" % (c, e))
                 else:
                     try:
                         data = self.sockets[fd].recv_records(self.rsize)
@@ -578,8 +605,9 @@ class ConnectionHandler(object):
         self.writelist -= temp
         self.readlist -= temp
         self.errlist -= temp
-        self.sockets[fd].clear_active()
-        self.sockets[fd].close()
+        pipe = self.sockets[fd]
+        pipe.fail_pending(RPCConnectionClosed("connection closed"))
+        pipe.close()
         del self.sockets[fd]
 
     def _event_write(self, fd):
-- 
2.53.0

