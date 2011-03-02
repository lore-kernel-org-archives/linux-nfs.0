Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:64179 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1753014Ab1CBG2k (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 2 Mar 2011 01:28:40 -0500
Message-ID: <4D6DE3C1.4010301@cn.fujitsu.com>
Date: Wed, 02 Mar 2011 14:29:21 +0800
From: Mi Jinlong <mijinlong@cn.fujitsu.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: NFS <linux-nfs@vger.kernel.org>
Subject: [PATCH 04/17] CLNT: test with ca_maxresponsesize is too small
References: <4D6DE26C.3010103@cn.fujitsu.com>
In-Reply-To: <4D6DE26C.3010103@cn.fujitsu.com>
Content-Type: text/plain; charset=ISO-2022-JP
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Signed-off-by: Mi Jinlong <mijinlong@cn.fujitsu.com>
---
 nfs4.1/server41tests/st_create_session.py |   16 ++++++++++++++++
 1 files changed, 16 insertions(+), 0 deletions(-)

diff --git a/nfs4.1/server41tests/st_create_session.py b/nfs4.1/server41tests/st_create_session.py
index 4185aa8..1b8b119 100644
--- a/nfs4.1/server41tests/st_create_session.py
+++ b/nfs4.1/server41tests/st_create_session.py
@@ -411,3 +411,19 @@ def testCsr_sequence(t, env):
     sess1 = c.create_session(fore_attrs=chan_attrs)
     if not nfs4lib.test_equal(sess1.seqid, csa_sequence, "int"):
         fail("Server returns bad csr_sequence which not equal to csa_sequence")
+
+def testTooSmallMaxRS(t, env):
+    """If client selects a value for ca_maxresponsesize such that
+       a replier on a channel could never send a response,
+       server SHOULD return NFS4ERR_TOOSMALL
+
+    FLAGS: create_session all
+    CODE: CSESS25
+    """
+    c = env.c1.new_client(env.testname(t))
+    # CREATE_SESSION with too small ca_maxresponsesize
+    chan_attrs = channel_attrs4(0,8192,0,8192,128,8,[])
+    res = c.c.compound([op.create_session(c.clientid, c.seqid, 0,
+                                        chan_attrs, chan_attrs,
+                                        123, [])], None)
+    check(res, NFS4ERR_TOOSMALL)
-- 
1.7.4.1



