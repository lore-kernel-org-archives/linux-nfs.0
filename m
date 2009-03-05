From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 4/9] configure: pull common nfsidmap and event checks into
	aclocal/
Date: Thu, 05 Mar 2009 12:42:07 -0500
Message-ID: <20090305174207.30471.33483.stgit@ingres.1015granger.net>
References: <20090305173533.30471.41413.stgit@ingres.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: steved@redhat.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from acsinet11.oracle.com ([141.146.126.233]:54107 "EHLO
	acsinet11.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754753AbZCERmx (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 5 Mar 2009 12:42:53 -0500
In-Reply-To: <20090305173533.30471.41413.stgit-07a7zB5ZJzbwdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Clean up: Create an aclocal script for the nfsidmap library and
headers checks used for both --enable-gss and --enable-nfsv4.
Move libevent checks out too.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 Makefile.am            |    4 +++-
 aclocal/libevent.m4    |   11 +++++++++++
 aclocal/libnfsidmap.m4 |   17 +++++++++++++++++
 configure.ac           |   20 ++++++++++----------
 4 files changed, 41 insertions(+), 11 deletions(-)
 create mode 100644 aclocal/libevent.m4
 create mode 100644 aclocal/libnfsidmap.m4

diff --git a/Makefile.am b/Makefile.am
index cfe2d37..6541fb7 100644
--- a/Makefile.am
+++ b/Makefile.am
@@ -41,7 +41,9 @@ EXTRA_DIST = \
 	aclocal/nfs-utils.m4 \
 	aclocal/kerberos5.m4 \
 	aclocal/tcp-wrappers.m4 \
-	aclocal/libtirpc.m4
+	aclocal/libtirpc.m4 \
+	aclocal/libevent.m4 \
+	aclocal/libnfsidmap.m4
 
 ACLOCAL_AMFLAGS = -I aclocal
 
diff --git a/aclocal/libevent.m4 b/aclocal/libevent.m4
new file mode 100644
index 0000000..3c962b3
--- /dev/null
+++ b/aclocal/libevent.m4
@@ -0,0 +1,11 @@
+dnl Checks for libevent
+AC_DEFUN([AC_LIBEVENT], [
+
+  dnl Check for libevent, but do not add -levent to LIBS
+  AC_CHECK_LIB([event], [event_dispatch], [libevent=1],
+               [AC_MSG_ERROR([libevent not found.])])
+
+  AC_CHECK_HEADERS([event.h], ,
+                   [AC_MSG_ERROR([libevent headers not found.])])
+
+])dnl
diff --git a/aclocal/libnfsidmap.m4 b/aclocal/libnfsidmap.m4
new file mode 100644
index 0000000..cfcde2f
--- /dev/null
+++ b/aclocal/libnfsidmap.m4
@@ -0,0 +1,17 @@
+dnl Checks for libnfsidmap
+dnl
+AC_DEFUN([AC_LIBNFSIDMAP], [
+
+  dnl Check for libnfsidmap, but do not add -lnfsidmap to LIBS
+  AC_CHECK_LIB([nfsidmap], [nfs4_init_name_mapping], [libnfsidmap=1],
+               [AC_MSG_ERROR([libnfsidmap not found.])])
+
+  AC_CHECK_HEADERS([nfsidmap.h], ,
+                   [AC_MSG_ERROR([libnfsidmap headers not found.])])
+
+  dnl nfs4_set_debug() doesn't appear in all versions of libnfsidmap
+  AC_CHECK_LIB([nfsidmap], [nfs4_set_debug],
+               [AC_DEFINE([HAVE_NFS4_SET_DEBUG], 1,
+                          [Define to 1 if you have the `nfs4_set_debug' function.])])
+
+])dnl
diff --git a/configure.ac b/configure.ac
index becbb7c..0d5f5a6 100644
--- a/configure.ac
+++ b/configure.ac
@@ -197,10 +197,12 @@ AC_CHECK_FUNC([getservbyname], , ,
 AC_CHECK_LIB([crypt], [crypt], [LIBCRYPT="-lcrypt"])
 
 if test "$enable_nfsv4" = yes; then
-    AC_CHECK_LIB(event, event_dispatch, [libevent=1], AC_MSG_ERROR([libevent needed for nfsv4 support]))
-    AC_CHECK_LIB(nfsidmap, nfs4_init_name_mapping, [libnfsidmap=1], AC_MSG_ERROR([libnfsidmap needed for nfsv4 support]))
-    AC_CHECK_HEADERS(event.h, ,AC_MSG_ERROR([libevent needed for nfsv4 support]))
-    AC_CHECK_HEADERS(nfsidmap.h, ,AC_MSG_ERROR([libnfsidmap needed for nfsv4 support]))
+  dnl check for libevent libraries and headers
+  AC_LIBEVENT
+
+  dnl check for nfsidmap libraries and headers
+  AC_LIBNFSIDMAP
+
     dnl librpcsecgss already has a dependency on libgssapi,
     dnl but we need to make sure we get the right version
     if test "$enable_gss" = yes; then
@@ -239,12 +241,10 @@ AC_SUBST(LIBBLKID)
 
 if test "$enable_gss" = yes; then
   dnl 'gss' also depends on nfsidmap.h - at least for svcgssd_proc.c
-  AC_CHECK_HEADERS(nfsidmap.h, ,AC_MSG_ERROR([libnfsidmap needed for gss support]))
-  AC_CHECK_HEADERS(spkm3.h, ,AC_MSG_WARN([could not locate SPKM3 header; will not have SPKM3 support]))
-  dnl the nfs4_set_debug function doesn't appear in all version of the library
-  AC_CHECK_LIB(nfsidmap, nfs4_set_debug,
-	       AC_DEFINE(HAVE_NFS4_SET_DEBUG,1,
-			 [Whether nfs4_set_debug() is present in libnfsidmap]),)
+  AC_LIBNFSIDMAP
+
+  AC_CHECK_HEADERS([spkm3.h], ,
+                   [AC_MSG_WARN([Could not locate SPKM3 header; will not have SPKM3 support])])
 
   dnl Check for Kerberos V5
   AC_KERBEROS_V5

