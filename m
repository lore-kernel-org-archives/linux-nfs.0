From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 6/6] configure: fix AC_CACHE_VAL warnings on Fedora 10
Date: Fri, 27 Feb 2009 15:05:40 -0500
Message-ID: <20090227200540.11301.7354.stgit@ingres.1015granger.net>
References: <20090227200511.11301.33720.stgit@ingres.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: steved@redhat.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet11.oracle.com ([148.87.113.123]:56115 "EHLO
	rgminet11.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756477AbZB0UH3 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 27 Feb 2009 15:07:29 -0500
In-Reply-To: <20090227200511.11301.33720.stgit-07a7zB5ZJzbwdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Autoconf 2.63 (and maybe earlier releases) complains about the cache
variable name used in aclocal/libblkid.m4:

configure.ac:217: warning: AC_CACHE_VAL(libblkid_is_recent, ...):
suspicious cache-id, must contain _cv_ to be cached
../../lib/autoconf/general.m4:1974: AC_CACHE_VAL is expanded from...
aclocal/libblkid.m4:2: AC_BLKID_VERS is expanded from...
configure.ac:217: the top level

This addresses
  https://bugzilla.redhat.com/attachment.cgi?bugid=481386 .

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 aclocal/libblkid.m4 |    8 ++++----
 1 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/aclocal/libblkid.m4 b/aclocal/libblkid.m4
index d751a8c..214ef50 100644
--- a/aclocal/libblkid.m4
+++ b/aclocal/libblkid.m4
@@ -1,7 +1,7 @@
 dnl *************************** libblkid needs version 1.40 or later ***********************
 AC_DEFUN([AC_BLKID_VERS], [
   AC_MSG_CHECKING(for suitable libblkid version)
-  AC_CACHE_VAL(libblkid_is_recent,
+  AC_CACHE_VAL(libblkid_cv_is_recent,
    [
     saved_LIBS="$LIBS"
     LIBS=-lblkid
@@ -12,9 +12,9 @@ AC_DEFUN([AC_BLKID_VERS], [
 		int vers = blkid_get_library_version(0, 0);
 		return vers >= 140 ? 0 : 1;
 	}
-       ], libblkid_is_recent=yes, libblkid_is_recent=no,
-       libblkid_is_recent=unknown)
+       ], libblkid_cv_is_recent=yes, libblkid_cv_is_recent=no,
+       libblkid_cv_is_recent=unknown)
     LIBS="$saved_LIBS"
     ])dnl
-  AC_MSG_RESULT($libblkid_is_recent)
+  AC_MSG_RESULT($libblkid_cv_is_recent)
 ])dnl

