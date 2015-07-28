Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pd0-f169.google.com ([209.85.192.169]:35793 "EHLO
	mail-pd0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752434AbbG1Lqw (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 28 Jul 2015 07:46:52 -0400
Received: by pdrg1 with SMTP id g1so69684658pdr.2
        for <linux-nfs@vger.kernel.org>; Tue, 28 Jul 2015 04:46:51 -0700 (PDT)
Message-ID: <55B76B9D.2090103@gmail.com>
Date: Tue, 28 Jul 2015 19:46:37 +0800
From: Kinglong Mee <kinglongmee@gmail.com>
MIME-Version: 1.0
To: "J. Bruce Fields" <bfields@fieldses.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
CC: tigran.mkrtchyan@desy.de, kinglongmee@gmail.com
Subject: [PATCH 4/4] 4.1 create_session: Skip test of CB_NULL for nfs4.1
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>
---
 nfs4.1/server41tests/st_create_session.py | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/nfs4.1/server41tests/st_create_session.py b/nfs4.1/server41tests/st_create_session.py
index b42e0ab..4c56bb4 100644
--- a/nfs4.1/server41tests/st_create_session.py
+++ b/nfs4.1/server41tests/st_create_session.py
@@ -333,7 +333,7 @@ def testManyClients(t, env):
 def testCallbackProgram(t, env):
     """Check server can handle random transient program number
 
-    FLAGS: create_session all
+    FLAGS:
     CODE: CSESS20
     """
     cb_occurred = threading.Event()
@@ -360,7 +360,7 @@ def testCallbackProgram(t, env):
 def testCallbackVersion(t, env):
     """Check server sends callback program with a version listed in nfs4client.py
 
-    FLAGS: create_session all
+    FLAGS:
     CODE: CSESS21
     """
     cb_occurred = threading.Event()
-- 
2.4.3

