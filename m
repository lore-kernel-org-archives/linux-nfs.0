Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=209.85.210.52
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1795124464;
	b=N5f2dnjkjRqX+OF8W7gsE6sULdU463o7U2Rf+4ZcEkWeS6u4dJi1NzgIO3c/vb8beENE
	 Na8JgjvRQYXTBEZYWP7LMyTGjKqMdx4PpJ1u9JCNHYuh+FqeyJ82v4KTn7BQyj83blLys
	 3/w3/xZ9hvWkIfrwk7mJi6p/HYFmmudA19F+iAiUR5EXQOrbuet8YVd/ZBRRptH4GxLQo
	 7W4y4coWYXYjZQ6QJVis8L7AAfblFLTOmkiWBoqPm9aA52aCOKQ/gkLpnzrtmukbm2/nn
	 8bzy+hYj5mxBN6alj8E8wB7HN2RVaNZFtMhVjkEuurX2LbxIFxitKRZPa+8N9eSHnQA==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1795124464;
	h=DMARC-Filter:Received:DKIM-Signature:X-Google-DKIM-Signature:
	 X-Gm-Message-State:X-Gm-Gg:X-Received:Received:From:
	 X-Google-Original-From:To:Cc:Subject:Date:Message-ID:X-Mailer:
	 In-Reply-To:References:MIME-Version:Content-Transfer-Encoding;
	bh=elz+w+RWbFgA9INKhpbkrvofnNPhZgGUILnYiWHTL7g=;
	b=FDObuUCKTvUO/PefInGanC4+7K7UB+B5QdJ0ZgeFj2j9LXC3NsIlIf85gsfGqwLMkOUz
	 JJ22p38zDsx22T9ynQGHqojLRXTeubaZmwNLFUA8qUXiUs0aHupv1UI0Sj6gYTBfxmbnn
	 GCfmc7Pi0axjlgro2Dr7JR6NXA+J7CY8yUjuJGbWYLVkJ0eZu/L2+ujVD2iezaS1WoMtc
	 nuxR75rUpycO2Zdh4pxryg8c7rkbkPwtoh7u+c3PAdzNQfFT4MIo1ZjlS+MUgZhDuuBZn
	 Ulpuw1okQbm+AIfFNwoFchVuSbXKgPOFn7wHkB7SONSd3vrw17Aa/oImDcX6eUROxGg==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=hammerspace.com;
	spf=pass smtp.mailfrom=hammerspace.com;
	dkim=pass header.d=hammerspace.com header.i=@hammerspace.com header.a=rsa-sha256 header.s=google header.b=j4oTATMx;
	arc=none smtp.remote-ip=209.85.210.52
Received: from mail-ot1-f52.google.com (mail-ot1-f52.google.com [209.85.210.52])
	(using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128/128 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 765CC606A331
	for <linux-nfs@vger.kernel.org>; Thu, 19 Nov 2026 21:41:04 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 765CC606A331
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.a=rsa-sha256 header.s=google header.b=j4oTATMx
Received: by mail-ot1-f52.google.com with SMTP id 46e09a7af769-862b090e3c3so126702a34.2
        for <linux-nfs@vger.kernel.org>; Thu, 19 Nov 2026 13:41:04 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=hammerspace.com; s=google; t=1795124463; x=1795729263; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=elz+w+RWbFgA9INKhpbkrvofnNPhZgGUILnYiWHTL7g=;
        b=j4oTATMxcESb6gvIR3gtr2b6zzVbd+x73JiBLyhnfL2RofproLU+H6uVo2GrInDpXe
         43x3/7jabGnxnmBAvujrRgMZppkAHMeE/W55nvQJZgltyODD5aDbt8LJPQVRUgVbTumz
         90VrWydmhhryoOM3J7sMdPidrDhUdRbH+edhhm8qybUVtUEaawu+yCWM4JwQ6mQJgTPC
         VQQpJoLjdVSRuGJSUaX276TyTCxrcb+06tBpQB6Kih6ZABDMTQh/tN3EjTp4bmg54C6a
         P7LycO02BENRVvEEnzdUnzSZQari6IFlEEWRugmxEJiUMCZlMAx03s9GIAKuZ4ZqjBgA
         aztg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1795124463; x=1795729263;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:x-gm-gg:x-gm-message-state:from
         :to:cc:subject:date:message-id:reply-to:content-type;
        bh=elz+w+RWbFgA9INKhpbkrvofnNPhZgGUILnYiWHTL7g=;
        b=y22qIzhhSV1mr/H7PbYcB5g4tLR1qaAxoD+KqtfMUAVUNua9AIwD0FSSPUfGNFIeCJ
         rCoxc+OtrXE42FspXNipE+NvKS10WP0bXTP8WSeSpVwNjAtbfGnLkwrsJLoE8NWgA4U1
         heNSaSH5kzTWmZc6yt6WQ3per+kaAIGo1POsdViC0wCV/kXVVRtOX4voe8RuhdeAviVY
         h21EkN3uU9Ixo134a5i3Usz1gS8vpyrB+kSg3rFPxBmfZ0j2TV1oDGiXFvSrReqs+UjE
         Hi4FhVODAgOiL36fz0hobGGNCC5nHulJxDLwf7Gmfb2IRz2rzYMh1qSjiYFCzs4gd3zS
         GMug==
X-Gm-Message-State: APuU4Z9sxdXYRS/2BYXlef9ptNaf5QOCSkTnVoZA/avSZJotwl0EfoJ0
	ox8T13sexKtDkqitY7snNHxbpWttTDIQUD6EyIGxGzZQkcZpbu5G9CUbPkVPFFvomA5SL2kifBH
	XUWPH
X-Gm-Gg: AYBFou2vfZ4c8C5VhNk3Zrm3h8k+H2GfdCVozf0jYf5KG1eurTxQws7p8oRVJ3o9SMu
	dvC5U3T8sLuk4hAaWY3L4GmBxONIedzhjMReMrgJIqAUWLgvYUXG4sv0K2f3sxKoz66p2L36iru
	hoeoBXz7fkdcgtnHVOp0DycOQ4oiHLMkRVb/Lfh+ddnJR5idT/TCaTH6iIQNEDL+8hzqYVs40Mk
	CRjHu21bzApiaeNe9YrJAqGXU94Bz+eSN60XJLE01Nh3qGBlWh1KHpGxQlkB29kcZVqT2Cx6T3T
	ux2kFuMs69UIJtuch89GWcDIZzwTE22v6Y/7qQcpPbD5vF7aG4rYp/GECjSRR8Jfv/hfXkMNgNc
	WkSchcqKycrQODUvtTFWTOavNG43bDff4t4GEeXewKK6EOHvDv4r0C1N3xa0GYWEYoH7bOnKv1Y
	6wLAxZLdZ9vlxafotdY5y8ZWbF6NbNUhY+liUhz/dn+9xdNpFe7XyuhrDThmhwHMJMWoVJpOR1L
	gy5lkt+UdFJB2/TPKHtXzWr7XbDBjdlM5HMFPcK1rA5VGAE5R+8vKp6gu1NnCBrsQfCyO8d+Wc5
	TC8Vyv8BwYP7HUBIkZnrmYhc/hOlM5ZAA66lCV5Iass60//PbV2tQIgxj4AASGYeWP7r
X-Received: by 2002:a05:6830:2306:b0:862:c685:849a with SMTP id 46e09a7af769-8631507f9a4mr1685509a34.0.1795124463228;
        Thu, 19 Nov 2026 13:41:03 -0800 (PST)
Received: from bcodding.csb.hammerspace.com ([12.117.181.174])
        by smtp.gmail.com with ESMTPSA id 46e09a7af769-8631670c44dsm642217a34.0.2026.11.19.13.41.02
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Thu, 19 Nov 2026 13:41:03 -0800 (PST)
From: Benjamin Coddington <ben.coddington@hammerspace.com>
X-Google-Original-From: Benjamin Coddington <bcodding@hammerspace.com>
To: calum.mackay@oracle.com
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH pynfs 1/2] rpc: skip secure ports in TIME_WAIT and report connect errors
Date: Thu, 19 Nov 2026 16:40:59 -0500
Message-ID: <1976e7eb2330cc82401ec47b57e6fca1bc8498e7.1795124374.git.bcodding@hammerspace.com>
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

connect() set SO_REUSEADDR on client sockets, so bindsocket() could
bind a secure port whose previous connection to the same server was
still in TIME_WAIT. connect() then failed with EADDRNOTAVAIL, and the
bare except closed the socket and fell through to setblocking() on it,
replacing the real error with EBADF.

Drop SO_REUSEADDR. Linux lets bind() take a port held by a TIME_WAIT
socket only when both sockets set SO_REUSEADDR, so without it bind()
fails with EADDRINUSE and bindsocket() moves on to the next port. If
connect() still fails with EADDRNOTAVAIL on a secure port, retry from
the next port. Raise the last connect error when no attempt succeeds.

Signed-off-by: Benjamin Coddington <bcodding@hammerspace.com>
---
 rpc/rpc.py | 38 ++++++++++++++++++++++++--------------
 1 file changed, 24 insertions(+), 14 deletions(-)

diff --git a/rpc/rpc.py b/rpc/rpc.py
index 84088f6651a6..4d0cc2d01a20 100644
--- a/rpc/rpc.py
+++ b/rpc/rpc.py
@@ -6,7 +6,7 @@ import struct
 import threading
 import logging
 from collections import deque as Deque
-from errno import EINPROGRESS, EWOULDBLOCK, EADDRINUSE
+from errno import EINPROGRESS, EWOULDBLOCK, EADDRINUSE, EADDRNOTAVAIL
 
 from . import rpc_pack
 from .rpc_const import *
@@ -812,21 +812,31 @@ class ConnectionHandler(object):
         """
         log_t.info("Called connect(%r)" % (address,))
         host, port = address
+        s = None
         err = None
         for res in socket.getaddrinfo(host, port, 0, socket.SOCK_STREAM):
             af, socktype, proto, cannonname, sa = res
-            sock = None
-            try:
-                s = socket.socket(af, socktype, proto)
-                s.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
-                if secure:
-                    self.bindsocket(s)
-                s.connect(sa)
-                err = None
+            lport = 1
+            while s is None:
+                try:
+                    s = socket.socket(af, socktype, proto)
+                    if secure:
+                        lport = self.bindsocket(s, lport)
+                    s.connect(sa)
+                except OSError as e:
+                    err = e
+                    if s is not None:
+                        s.close()
+                        s = None
+                    # A local port in TIME_WAIT with this peer can still bind
+                    if secure and e.errno == EADDRNOTAVAIL and lport < 1023:
+                        lport += 1
+                        continue
+                    break
+            if s is not None:
                 break
-            except:
-                if s is not None:
-                    s.close()
+        if s is None:
+            raise err or OSError("no addresses for %r" % (host,))
 
         s.setblocking(0)
         pipe = RpcPipe(s, self._alarm)
@@ -838,13 +848,13 @@ class ConnectionHandler(object):
         return pipe
 
     def bindsocket(self, s, port=1):
-        """Scan up through ports, looking for one we can bind to"""
+        """Scan up through ports, returning the first one we can bind to"""
         # This is necessary when we need to use a 'secure' port
         using = port
         while 1:
             try:
                 s.bind(('', using))
-                return
+                return using
             except OSError as why:
                 if why.errno == EADDRINUSE:
                     using += 1
-- 
2.53.0

