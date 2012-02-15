Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:33954 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751589Ab2BOWpW (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 15 Feb 2012 17:45:22 -0500
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 3/5] 4.1 server tests: don't run pnfs tests by default
Date: Wed, 15 Feb 2012 17:45:18 -0500
Message-Id: <1329345920-16608-4-git-send-email-bfields@redhat.com>
In-Reply-To: <1329345920-16608-1-git-send-email-bfields@redhat.com>
References: <1329345920-16608-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@redhat.com>

I'd rather the pynfs tests have clean results by default against a
correct 4.1 server.  And it's correct for such a server not to implement
optional features.  So leave pnfs tests off by default; you can still
get them by asking for "pnfs" tests.

Also, flags for individual pnfs operations seemed mild overkill for now,
given how few tests we have.

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 nfs4.1/server41tests/st_current_stateid.py |    2 +-
 nfs4.1/server41tests/st_getdevicelist.py   |   16 ++++++++--------
 2 files changed, 9 insertions(+), 9 deletions(-)

diff --git a/nfs4.1/server41tests/st_current_stateid.py b/nfs4.1/server41tests/st_current_stateid.py
index aeaa8b1..7804900 100644
--- a/nfs4.1/server41tests/st_current_stateid.py
+++ b/nfs4.1/server41tests/st_current_stateid.py
@@ -119,7 +119,7 @@ def testOpenLayoutGet(t, env):
     """test current state id processing by having OPEN and LAYOUTGET
        in a single compound
 
-    FLAGS: currentstateid all
+    FLAGS: currentstateid pnfs
     CODE: CSID7
     """
     sess = env.c1.new_client_session(env.testname(t),
diff --git a/nfs4.1/server41tests/st_getdevicelist.py b/nfs4.1/server41tests/st_getdevicelist.py
index 8d53633..7a10c6c 100644
--- a/nfs4.1/server41tests/st_getdevicelist.py
+++ b/nfs4.1/server41tests/st_getdevicelist.py
@@ -10,7 +10,7 @@ from nfs4lib import state00
 def testGetDevList(t, env):
     """Check devlist
 
-    FLAGS: getdevicelist all
+    FLAGS: pnfs
     CODE: GETDLIST1
     """
     # Make sure E_ID returns MDS capabilities
@@ -36,7 +36,7 @@ def testGetDevList(t, env):
 def testGetDevInfo(t, env):
     """Check devlist
 
-    FLAGS: getdevicelist all
+    FLAGS: pnfs
     DEPEND: GETDLIST1
     CODE: GETDINFO1
     """
@@ -73,7 +73,7 @@ def testGetDevInfo(t, env):
 ## def xxxtestLayout(t, env):
 ##     """Verify layout handling
 
-##     FLAGS: layout all
+##     FLAGS: pnfs
 ##     CODE: GETLAYOUT1
 ##     """
 ##     # Make sure E_ID returns MDS capabilities
@@ -105,7 +105,7 @@ def testGetDevInfo(t, env):
 def testGetLayout(t, env):
     """Verify layout handling
 
-    FLAGS: getlayout all
+    FLAGS: pnfs
     CODE: GETLAYOUT1
     """
     # Make sure E_ID returns MDS capabilities
@@ -187,7 +187,7 @@ def testLayoutReturnFile(t, env):
     """
     Return a file's layout
     
-    FLAGS: layoutreturn all
+    FLAGS: pnfs
     DEPEND: GETLAYOUT1
     CODE: LAYOUTRET1
     """
@@ -220,7 +220,7 @@ def testLayoutReturnFsid(t, env):
     """
     Return all of a filesystem's layouts
     
-    FLAGS: layoutreturn all
+    FLAGS: pnfs
     DEPEND: GETLAYOUT1
     CODE: LAYOUTRET2
     """
@@ -252,7 +252,7 @@ def testLayoutReturnAll(t, env):
     """
     Return all of a client's layouts
     
-    FLAGS: layoutreturn all
+    FLAGS: pnfs
     DEPEND: GETLAYOUT1
     CODE: LAYOUTRET3
     """
@@ -283,7 +283,7 @@ def testLayoutCommit(t, env):
     """
     Do some commits
 
-    FLAGS: layoutcommit all
+    FLAGS: pnfs
     CODE: LAYOUTCOMMIT1
     """
     # Make sure E_ID returns MDS capabilities
-- 
1.7.5.4

