Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cn.fujitsu.com ([222.73.24.84]:60353 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1752506Ab1J1JyE (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 28 Oct 2011 05:54:04 -0400
Message-ID: <4EAA7CCD.8020309@cn.fujitsu.com>
Date: Fri, 28 Oct 2011 17:58:37 +0800
From: Mi Jinlong <mijinlong@cn.fujitsu.com>
MIME-Version: 1.0
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: NFS <linux-nfs@vger.kernel.org>
Subject: [PATCH 2/3] 4.1 CLNT: Send reclaim complete before create file at
 CSESS26
Content-Type: text/plain; charset=ISO-2022-JP
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Send reclaim complete before create file at CSESS26

Signed-off-by: Mi Jinlong <mijinlong@cn.fujitsu.com>
---
 nfs4.1/server41tests/st_create_session.py |    4 +++-
 1 files changed, 3 insertions(+), 1 deletions(-)

diff --git a/nfs4.1/server41tests/st_create_session.py b/nfs4.1/server41tests/st_create_session.py
index f8f59f6..2f351a6 100644
--- a/nfs4.1/server41tests/st_create_session.py
+++ b/nfs4.1/server41tests/st_create_session.py
@@ -455,8 +455,10 @@ def testRepTooBig(t, env):
     name = env.testname(t)
     c1 = env.c1.new_client(name)
     # create session with a small ca_maxresponsesize
-    chan_attrs = channel_attrs4(0,8192,50,8192,128,8,[])
+    chan_attrs = channel_attrs4(0,8192,500,8192,128,8,[])
     sess1 = c1.create_session(fore_attrs=chan_attrs)
+    sess1.compound([op.reclaim_complete(FALSE)])
+
     owner = "owner_%s" % name
     path = sess1.c.homedir + [name]
     res = create_file(sess1, owner, path, access=OPEN4_SHARE_ACCESS_BOTH)
-- 
1.7.5.1


