Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:62365 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1750972Ab1CBG35 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 2 Mar 2011 01:29:57 -0500
Message-ID: <4D6DE40F.2040100@cn.fujitsu.com>
Date: Wed, 02 Mar 2011 14:30:39 +0800
From: Mi Jinlong <mijinlong@cn.fujitsu.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: NFS <linux-nfs@vger.kernel.org>
Subject: [PATCH 06/17] CLNT: test reply too big to cache
References: <4D6DE26C.3010103@cn.fujitsu.com>
In-Reply-To: <4D6DE26C.3010103@cn.fujitsu.com>
Content-Type: text/plain; charset=ISO-2022-JP
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Signed-off-by: Mi Jinlong <mijinlong@cn.fujitsu.com>
---
 nfs4.1/server41tests/st_create_session.py |   21 +++++++++++++++++++++
 1 files changed, 21 insertions(+), 0 deletions(-)

diff --git a/nfs4.1/server41tests/st_create_session.py b/nfs4.1/server41tests/st_create_session.py
index c474ce3..ff55d10 100644
--- a/nfs4.1/server41tests/st_create_session.py
+++ b/nfs4.1/server41tests/st_create_session.py
@@ -455,3 +455,24 @@ def testRepTooBig(t, env):
     # read data rather than ca_maxresponsesize
     res = sess1.compound([op.putfh(fh), op.read(stateid, 0, 500)])
     check(res, NFS4ERR_REP_TOO_BIG)
+
+def testRepTooBigToCache(t, env):
+    """If requester sends a request for which the size of the reply
+       would exceed ca_maxresponsesize_cached, the replier will return
+       NFS4ERR_REP_TOO_BIG_TO_CACHE
+
+    FLAGS: create_session all
+    CODE: CSESS27
+    """
+    c = env.c1.new_client(env.testname(t))
+    # CREATE_SESSION with a small ca_maxresponsesize_cached
+    chan_attrs = channel_attrs4(0,8192,8192,10,128,8,[])
+    res = c.c.compound([op.create_session(c.clientid, c.seqid, 0,
+                                        chan_attrs, chan_attrs,
+                                        123, [])], None)
+    check(res)
+
+    # SEQUENCE with cache this
+    sid = res.resarray[0].csr_sessionid
+    res = c.c.compound([op.sequence(sid, 1, 0, 0, True)])
+    check(res, NFS4ERR_REP_TOO_BIG_TO_CACHE)
-- 
1.7.4.1


