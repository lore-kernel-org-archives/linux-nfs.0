Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:62225 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1751154Ab1CBG3R (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 2 Mar 2011 01:29:17 -0500
Message-ID: <4D6DE3E7.4090105@cn.fujitsu.com>
Date: Wed, 02 Mar 2011 14:29:59 +0800
From: Mi Jinlong <mijinlong@cn.fujitsu.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: NFS <linux-nfs@vger.kernel.org>
Subject: [PATCH 05/17] CLNT: test reply too big
References: <4D6DE26C.3010103@cn.fujitsu.com>
In-Reply-To: <4D6DE26C.3010103@cn.fujitsu.com>
Content-Type: text/plain; charset=ISO-2022-JP
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0


Signed-off-by: Mi Jinlong <mijinlong@cn.fujitsu.com>
---
 nfs4.1/server41tests/st_create_session.py |   30 ++++++++++++++++++++++++++++-
 1 files changed, 29 insertions(+), 1 deletions(-)

diff --git a/nfs4.1/server41tests/st_create_session.py b/nfs4.1/server41tests/st_create_session.py
index 1b8b119..c474ce3 100644
--- a/nfs4.1/server41tests/st_create_session.py
+++ b/nfs4.1/server41tests/st_create_session.py
@@ -1,6 +1,6 @@
 from nfs4_const import *
 import nfs4_ops as op
-from environment import check, fail
+from environment import check, fail, create_file, open_file
 from nfs4_type import *
 import random
 import nfs4lib
@@ -427,3 +427,31 @@ def testTooSmallMaxRS(t, env):
                                         chan_attrs, chan_attrs,
                                         123, [])], None)
     check(res, NFS4ERR_TOOSMALL)
+
+def testRepTooBig(t, env):
+    """If requester sends a request for which the size of the reply
+       would exceed ca_maxresponsesize, the replier will return
+       NFS4ERR_REP_TOO_BIG
+
+    FLAGS: create_session all
+    CODE: CSESS26
+    """
+    name = env.testname(t)
+    c1 = env.c1.new_client(name)
+    # create session with a small ca_maxresponsesize
+    chan_attrs = channel_attrs4(0,8192,50,8192,128,8,[])
+    sess1 = c1.create_session(fore_attrs=chan_attrs)
+    owner = "owner_%s" % name
+    path = sess1.c.homedir + [name]
+    res = create_file(sess1, owner, path, access=OPEN4_SHARE_ACCESS_BOTH)
+    check(res)
+
+    # write some data to file
+    fh = res.resarray[-1].object
+    stateid = res.resarray[-2].stateid
+    res = sess1.compound([op.putfh(fh), op.write(stateid, 5, FILE_SYNC4, "write test data " * 10)])
+    check(res)
+
+    # read data rather than ca_maxresponsesize
+    res = sess1.compound([op.putfh(fh), op.read(stateid, 0, 500)])
+    check(res, NFS4ERR_REP_TOO_BIG)
-- 
1.7.4.1


