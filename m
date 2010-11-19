Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from 4dicksons.org ([207.22.49.45]:45413 "EHLO
	Dobby.Home.4dicksons.org" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1755909Ab0KSRjG (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 19 Nov 2010 12:39:06 -0500
Received: from tophat.home.4dicksons.org ([192.168.62.20])
	by Dobby.Home.4dicksons.org with esmtp (Exim 4.63)
	(envelope-from <steved@redhat.com>)
	id 1PJUvR-0005fG-3h
	for linux-nfs@vger.kernel.org; Fri, 19 Nov 2010 12:39:05 -0500
From: Steve Dickson <steved@redhat.com>
To: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: [PATCH 2/2] Enable nfsidmap to compile
Date: Fri, 19 Nov 2010 12:39:03 -0500
Message-Id: <1290188343-10579-3-git-send-email-steved@redhat.com>
In-Reply-To: <1290188343-10579-1-git-send-email-steved@redhat.com>
References: <1290188343-10579-1-git-send-email-steved@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

Only enable the compilation of nfsidmap when libnfsidmap support it.

Signed-off-by: Steve Dickson <steved@redhat.com>
---
 aclocal/libnfsidmap.m4 |    4 ++++
 configure.ac           |    3 +++
 utils/Makefile.am      |    3 +++
 3 files changed, 10 insertions(+), 0 deletions(-)

diff --git a/aclocal/libnfsidmap.m4 b/aclocal/libnfsidmap.m4
index cfcde2f..e636604 100644
--- a/aclocal/libnfsidmap.m4
+++ b/aclocal/libnfsidmap.m4
@@ -14,4 +14,8 @@ AC_DEFUN([AC_LIBNFSIDMAP], [
                [AC_DEFINE([HAVE_NFS4_SET_DEBUG], 1,
                           [Define to 1 if you have the `nfs4_set_debug' function.])])
 
+  dnl only enable nfsidmap when libnfsidmap supports it
+  AC_CHECK_LIB([nfsidmap], [nfs4_owner_to_uid], [enable_nfsidmap=1],
+               [enable_nfsidmap=0])
+
 ])dnl
diff --git a/configure.ac b/configure.ac
index b39dbcd..92833e3 100644
--- a/configure.ac
+++ b/configure.ac
@@ -247,6 +247,9 @@ if test "$enable_nfsv4" = yes; then
   dnl check for nfsidmap libraries and headers
   AC_LIBNFSIDMAP
 
+  dnl enable nfsidmap when its support by libnfsidmap
+  AM_CONDITIONAL(CONFIG_NFSIDMAP, [test "$enable_nfsidmap" = "yes"])
+
   dnl check for the keyutils libraries and headers
   AC_KEYUTILS
 
diff --git a/utils/Makefile.am b/utils/Makefile.am
index 8665183..a0ea116 100644
--- a/utils/Makefile.am
+++ b/utils/Makefile.am
@@ -4,6 +4,9 @@ OPTDIRS =
 
 if CONFIG_NFSV4
 OPTDIRS += idmapd
+if CONFIG_NFSIDMAP
+OPTDIRS += nfsidmap
+endif
 endif
 
 if CONFIG_GSS
-- 
1.7.3.2

