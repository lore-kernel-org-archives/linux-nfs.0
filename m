Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qk0-f174.google.com ([209.85.220.174]:36336 "EHLO
	mail-qk0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751036AbbJTQBK (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 20 Oct 2015 12:01:10 -0400
Received: by qkca6 with SMTP id a6so9573976qkc.3
        for <linux-nfs@vger.kernel.org>; Tue, 20 Oct 2015 09:01:09 -0700 (PDT)
From: Jeff Layton <jlayton@poochiereds.net>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 1/2] nfs41: add some READ/WRITE tests for special stateids
Date: Tue, 20 Oct 2015 12:01:00 -0400
Message-Id: <1445356861-13860-1-git-send-email-jeff.layton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Jeff Layton <jeff.layton@primarydata.com>
---
 nfs4.1/server41tests/st_open.py | 26 ++++++++++++++++++++++++++
 1 file changed, 26 insertions(+)

diff --git a/nfs4.1/server41tests/st_open.py b/nfs4.1/server41tests/st_open.py
index 24f051e75e8f..235212cccaed 100644
--- a/nfs4.1/server41tests/st_open.py
+++ b/nfs4.1/server41tests/st_open.py
@@ -9,6 +9,7 @@ from xdrdef.nfs4_type import open_to_lock_owner4
 import nfs_ops
 op = nfs_ops.NFS4ops()
 import threading
+import nfs4lib
 
 def expect(res, seqid):
     """Verify that open result has expected stateid.seqid"""
@@ -77,6 +78,31 @@ def testReadWrite(t, env):
     if res.resarray[-1].data != desired:
         fail("Expected %r, got %r" % (desired, res.resarray[-1].data))
 
+def testAnonReadWrite(t, env):
+    """Do a simple READ and WRITE using anonymous stateid
+
+    FLAGS: open all
+    CODE: OPEN31
+    """
+    sess1 = env.c1.new_client_session(env.testname(t))
+    owner = open_owner4(0, "My Open Owner")
+    res = create_file(sess1, env.testname(t))
+    check(res)
+    expect(res, seqid=1)
+    fh = res.resarray[-1].object
+    data = "write test data"
+    stateid = res.resarray[-2].stateid
+    res = close_file(sess1, fh, stateid=stateid)
+    res = sess1.compound([op.putfh(fh), op.write(nfs4lib.state00, 5, FILE_SYNC4, data)])
+    check(res)
+    res = sess1.compound([op.putfh(fh), op.read(nfs4lib.state00, 0, 1000)])
+    check(res)
+    if not res.resarray[-1].eof:
+        fail("EOF not set on read")
+    desired = "\0"*5 + data
+    if res.resarray[-1].data != desired:
+        fail("Expected %r, got %r" % (desired, res.resarray[-1].data))
+
 def testEXCLUSIVE4AtNameAttribute(t, env):
     """If the file does exist,but the stored verifier does not match,
        then an error of NFS4ERR_EXIST is returned from server.
-- 
2.4.3

