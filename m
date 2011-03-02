Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:54584 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1751154Ab1CBG1y (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 2 Mar 2011 01:27:54 -0500
Message-ID: <4D6DE38D.8050003@cn.fujitsu.com>
Date: Wed, 02 Mar 2011 14:28:29 +0800
From: Mi Jinlong <mijinlong@cn.fujitsu.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: NFS <linux-nfs@vger.kernel.org>
Subject: [PATCH 03/17] CLNT: check the csr_sequence at CREATE_SESSION
References: <4D6DE26C.3010103@cn.fujitsu.com> <4D6DE34A.2020404@cn.fujitsu.com>
In-Reply-To: <4D6DE34A.2020404@cn.fujitsu.com>
Content-Type: text/plain; charset=ISO-2022-JP
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Signed-off-by: Mi Jinlong <mijinlong@cn.fujitsu.com>
---
 nfs4.1/nfs4client.py                      |    1 +
 nfs4.1/server41tests/st_create_session.py |   15 +++++++++++++++
 2 files changed, 16 insertions(+), 0 deletions(-)

diff --git a/nfs4.1/nfs4client.py b/nfs4.1/nfs4client.py
index b517c27..9786bf3 100644
--- a/nfs4.1/nfs4client.py
+++ b/nfs4.1/nfs4client.py
@@ -404,6 +404,7 @@ class SendChannel(object):
 class SessionRecord(object):
     def __init__(self, csr, client):
         self.sessionid = csr.csr_sessionid
+        self.seqid = csr.csr_sequence
         self.client = client
         self.c = client.c
         self.cred = client.cred
diff --git a/nfs4.1/server41tests/st_create_session.py b/nfs4.1/server41tests/st_create_session.py
index 1d02a50..4185aa8 100644
--- a/nfs4.1/server41tests/st_create_session.py
+++ b/nfs4.1/server41tests/st_create_session.py
@@ -396,3 +396,18 @@ def testNotOnlyOp(t, env):
                                         chan_attrs, chan_attrs,
                                         123, []), op.putrootfh()], None)
     check(res, NFS4ERR_NOT_ONLY_OP)
+
+def testCsr_sequence(t, env):
+    """The corresponding result of csa_sequence is csr_sequence,
+       which MUST be equal to csa_sequence.
+
+    FLAGS: create_session all
+    CODE: CSESS24
+    """
+    c = env.c1.new_client(env.testname(t))
+    # CREATE_SESSION
+    chan_attrs = channel_attrs4(0,8192,8192,8192,128,8,[])
+    csa_sequence = c.seqid
+    sess1 = c.create_session(fore_attrs=chan_attrs)
+    if not nfs4lib.test_equal(sess1.seqid, csa_sequence, "int"):
+        fail("Server returns bad csr_sequence which not equal to csa_sequence")
-- 
1.7.4.1



