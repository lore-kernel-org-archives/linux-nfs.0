Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cn.fujitsu.com ([222.73.24.84]:61000 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1751901Ab1J1JxG (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 28 Oct 2011 05:53:06 -0400
Message-ID: <4EAA7C9C.6050601@cn.fujitsu.com>
Date: Fri, 28 Oct 2011 17:57:48 +0800
From: Mi Jinlong <mijinlong@cn.fujitsu.com>
MIME-Version: 1.0
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: NFS <linux-nfs@vger.kernel.org>
Subject: [PATCH 1/3] 4.1 CLNT: Create session before using at OPEN6
Content-Type: text/plain; charset=ISO-2022-JP
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

4.1 CLNT: Create session before using at OPEN6

Signed-off-by: Mi Jinlong <mijinlong@cn.fujitsu.com>
---
 nfs4.1/server41tests/st_open.py |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/nfs4.1/server41tests/st_open.py b/nfs4.1/server41tests/st_open.py
index 2aa3ec4..bd995a5 100644
--- a/nfs4.1/server41tests/st_open.py
+++ b/nfs4.1/server41tests/st_open.py
@@ -192,7 +192,7 @@ def testEXCLUSIVE4AtNameAttribute(t, env):
     FLAGS: open all
     CODE: OPEN6
     """
-    sess1 = env.c1.new_client(env.testname(t))
+    sess1 = env.c1.new_client_session(env.testname(t))
 
     res = create_file(sess1, env.testname(t), mode=EXCLUSIVE4_1)
     check(res)
-- 
1.7.5.1


