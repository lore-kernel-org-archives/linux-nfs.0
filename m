Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-pd0-f170.google.com ([209.85.192.170]:63933 "EHLO
	mail-pd0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753213Ab3LWJgP (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 23 Dec 2013 04:36:15 -0500
Received: by mail-pd0-f170.google.com with SMTP id g10so4997643pdj.1
        for <linux-nfs@vger.kernel.org>; Mon, 23 Dec 2013 01:36:15 -0800 (PST)
Message-ID: <52B80409.5000302@gmail.com>
Date: Mon, 23 Dec 2013 17:36:09 +0800
From: Kinglong Mee <kinglongmee@gmail.com>
MIME-Version: 1.0
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: linux-nfs@vger.kernel.org
Subject: [PATCH] nfs4.1: add test case for ca_maxrequestsize and bad backchannel
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

CSESS28: test too small maxrequestsize.
CSESS29: test a bug in nfsd by sending many bad backchannel request.

Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>
---
 nfs4.1/server41tests/st_create_session.py | 41 +++++++++++++++++++++++++++++++
 1 file changed, 41 insertions(+)

diff --git a/nfs4.1/server41tests/st_create_session.py b/nfs4.1/server41tests/st_create_session.py
index 554aa5b..4579fdc 100644
--- a/nfs4.1/server41tests/st_create_session.py
+++ b/nfs4.1/server41tests/st_create_session.py
@@ -498,3 +498,44 @@ def testRepTooBigToCache(t, env):
     sid = res.resarray[0].csr_sessionid
     res = c.c.compound([op.sequence(sid, 1, 0, 0, True)])
     check(res, NFS4ERR_REP_TOO_BIG_TO_CACHE)
+
+def testTooSmallMaxReq(t, env):
+    """If client selects a value for ca_maxrequestsize such that
+       a replier on a channel could never send a request,
+       server SHOULD return NFS4ERR_TOOSMALL
+
+    FLAGS: create_session all
+    CODE: CSESS28
+    """
+    c = env.c1.new_client(env.testname(t))
+    # CREATE_SESSION with too small ca_maxrequestsize
+    chan_attrs = channel_attrs4(0,20,8192,8192,128,8,[])
+    res = c.c.compound([op.create_session(c.clientid, c.seqid, 0,
+                                          chan_attrs, chan_attrs,
+                                          123, [])], None)
+    check(res, NFS4ERR_TOOSMALL)
+
+def testDRCMemLeak(t, env):
+    """Test whether the replier put drc mem after checking back
+       channel attrs failed.
+
+    FLAGS: create_session all
+    CODE: CSESS29
+    """
+    c = env.c1.new_client(env.testname(t))
+    fchan_attrs = channel_attrs4(0,8192,8192,8192,128,8,[])
+    # CREATE_SESSION with too small ca_maxrequestsize and ca_maxops
+    bchan_attrs = channel_attrs4(0,10,8192,8192,128,1,[])
+
+    N = 10000 # number of clients to create, all will denied with TOOSMALL
+    for i in range(N):
+        res = c.c.compound([op.create_session(c.clientid, c.seqid, 0,
+                                              fchan_attrs, bchan_attrs,
+                                              123, [])], None)
+        check(res, NFS4ERR_TOOSMALL)
+
+    bchan_attrs = channel_attrs4(0,8192,8192,8192,128,8,[])
+    res = c.c.compound([op.create_session(c.clientid, c.seqid, 0,
+                                          fchan_attrs, bchan_attrs,
+                                          123, [])], None)
+    check(res, NFS4_OK)
-- 
1.8.4.2
