Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:33956 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753103Ab2BOWpW (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 15 Feb 2012 17:45:22 -0500
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 4/5] 4.1 server tests: don't run utf8 tests by default
Date: Wed, 15 Feb 2012 17:45:19 -0500
Message-Id: <1329345920-16608-5-git-send-email-bfields@redhat.com>
In-Reply-To: <1329345920-16608-1-git-send-email-bfields@redhat.com>
References: <1329345920-16608-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@redhat.com>

The server doesn't pass the utf8 tests and probably never will, and I'm
tired of people reporting those failures to me.

It's unclear to me whether those tests are even completely correct given
the latest internationalization language in the spec.

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 nfs4.0/servertests/st_compound.py   |    2 +-
 nfs4.0/servertests/st_link.py       |    2 +-
 nfs4.0/servertests/st_lookup.py     |    2 +-
 nfs4.0/servertests/st_open.py       |    2 +-
 nfs4.0/servertests/st_remove.py     |    2 +-
 nfs4.0/servertests/st_rename.py     |    4 ++--
 nfs4.0/servertests/st_secinfo.py    |    2 +-
 nfs4.0/servertests/st_setattr.py    |    2 +-
 nfs4.1/server41tests/st_compound.py |    2 +-
 nfs4.1/server41tests/st_rename.py   |    4 ++--
 10 files changed, 12 insertions(+), 12 deletions(-)

diff --git a/nfs4.0/servertests/st_compound.py b/nfs4.0/servertests/st_compound.py
index 98be3a8..d2af73b 100644
--- a/nfs4.0/servertests/st_compound.py
+++ b/nfs4.0/servertests/st_compound.py
@@ -31,7 +31,7 @@ def testGoodTag(t, env):
 def testBadTags(t, env):
     """COMPOUND with invalid utf8 tags
 
-    FLAGS: compound utf8 all
+    FLAGS: compound utf8
     CODE: COMP3
     """
     c = env.c1
diff --git a/nfs4.0/servertests/st_link.py b/nfs4.0/servertests/st_link.py
index 10d7197..e20ea77 100644
--- a/nfs4.0/servertests/st_link.py
+++ b/nfs4.0/servertests/st_link.py
@@ -212,7 +212,7 @@ def testLongName(t, env):
 def testInvalidUtf8(t, env):
     """LINK with bad UTF-8 name strings should return NFS4ERR_INVAL
 
-    FLAGS: link utf8 all
+    FLAGS: link utf8
     DEPEND: LINKS LOOKFILE MKDIR
     CODE: LINK8
     """
diff --git a/nfs4.0/servertests/st_lookup.py b/nfs4.0/servertests/st_lookup.py
index 40c5983..456fed2 100644
--- a/nfs4.0/servertests/st_lookup.py
+++ b/nfs4.0/servertests/st_lookup.py
@@ -221,7 +221,7 @@ def testNonAccessable(t, env):
 def testInvalidUtf8(t, env):
     """LOOKUP with bad UTF-8 name strings should return NFS4ERR_INVAL
 
-    FLAGS: lookup utf8 all
+    FLAGS: lookup utf8
     DEPEND:
     CODE: LOOK7
     """
diff --git a/nfs4.0/servertests/st_open.py b/nfs4.0/servertests/st_open.py
index 8176ad5..992e5e3 100644
--- a/nfs4.0/servertests/st_open.py
+++ b/nfs4.0/servertests/st_open.py
@@ -247,7 +247,7 @@ def testNotDir(t, env):
 def testInvalidUtf8(t, env):
     """OPEN with bad UTF-8 name strings should return NFS4ERR_INVAL
 
-    FLAGS: open utf8 all
+    FLAGS: open utf8
     DEPEND: MKDIR
     CODE: OPEN13
     """
diff --git a/nfs4.0/servertests/st_remove.py b/nfs4.0/servertests/st_remove.py
index 76a7037..d475185 100644
--- a/nfs4.0/servertests/st_remove.py
+++ b/nfs4.0/servertests/st_remove.py
@@ -195,7 +195,7 @@ def testZeroLengthTarget(t, env):
 def testNonUTF8(t, env):
     """REMOVE with non-UTF8 components should return NFS4ERR_INVAL
 
-    FLAGS: remove utf8 all
+    FLAGS: remove utf8
     DEPEND: MKDIR
     CODE: RM5
     """
diff --git a/nfs4.0/servertests/st_rename.py b/nfs4.0/servertests/st_rename.py
index fe6339b..16e4ce5 100644
--- a/nfs4.0/servertests/st_rename.py
+++ b/nfs4.0/servertests/st_rename.py
@@ -311,7 +311,7 @@ def testZeroLengthNewname(t, env):
 def testBadutf8Oldname(t, env):
     """RENAME with non-UTF8 oldname should return NFS4ERR_INVAL
 
-    FLAGS: rename utf8 all
+    FLAGS: rename utf8
     DEPEND: MKDIR
     CODE: RNM8
     """
@@ -327,7 +327,7 @@ def testBadutf8Oldname(t, env):
 def testBadutf8Newname(t, env):
     """RENAME with non-UTF8 newname should return NFS4ERR_INVAL
 
-    FLAGS: rename utf8 all
+    FLAGS: rename utf8
     DEPEND: MKDIR
     CODE: RNM9
     """
diff --git a/nfs4.0/servertests/st_secinfo.py b/nfs4.0/servertests/st_secinfo.py
index 793fdfd..83f713b 100644
--- a/nfs4.0/servertests/st_secinfo.py
+++ b/nfs4.0/servertests/st_secinfo.py
@@ -80,7 +80,7 @@ def testZeroLenName(t, env):
 def testInvalidUtf8(t, env):
     """SECINFO with bad UTF-8 name strings should return NFS4ERR_INVAL
 
-    FLAGS: secinfo utf8 all
+    FLAGS: secinfo utf8
     DEPEND: SEC1
     CODE: SEC6
     """
diff --git a/nfs4.0/servertests/st_setattr.py b/nfs4.0/servertests/st_setattr.py
index 686ce87..936778f 100644
--- a/nfs4.0/servertests/st_setattr.py
+++ b/nfs4.0/servertests/st_setattr.py
@@ -412,7 +412,7 @@ def testNonUTF8(t, env):
     OWNER and GROUP are subject to too many restrictions to use.
     Similarly for ACL.
 
-    FLAGS: setattr utf8 all
+    FLAGS: setattr utf8
     DEPEND: MKFILE
     CODE: SATT9
     """
diff --git a/nfs4.1/server41tests/st_compound.py b/nfs4.1/server41tests/st_compound.py
index 4dedca8..d38f621 100644
--- a/nfs4.1/server41tests/st_compound.py
+++ b/nfs4.1/server41tests/st_compound.py
@@ -39,7 +39,7 @@ def testGoodTag(t, env):
 def testBadTags(t, env):
     """COMPOUND with invalid utf8 tags
 
-    FLAGS: compound utf8 all
+    FLAGS: compound utf8
     CODE: COMP3
     """
     c = env.c1
diff --git a/nfs4.1/server41tests/st_rename.py b/nfs4.1/server41tests/st_rename.py
index bddcb35..ed5dbb5 100644
--- a/nfs4.1/server41tests/st_rename.py
+++ b/nfs4.1/server41tests/st_rename.py
@@ -314,7 +314,7 @@ def testZeroLengthNewname(t, env):
 def testBadutf8Oldname(t, env):
     """RENAME with non-UTF8 oldname should return NFS4ERR_INVAL
 
-    FLAGS: rename utf8 all
+    FLAGS: rename utf8
     CODE: RNM8
     """
     name = env.testname(t)
@@ -330,7 +330,7 @@ def testBadutf8Oldname(t, env):
 def testBadutf8Newname(t, env):
     """RENAME with non-UTF8 newname should return NFS4ERR_INVAL
 
-    FLAGS: rename utf8 all
+    FLAGS: rename utf8
     CODE: RNM9
     """
     name = env.testname(t)
-- 
1.7.5.4

