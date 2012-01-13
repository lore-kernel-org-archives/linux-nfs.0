Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:19891 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751972Ab2AMOrO (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 13 Jan 2012 09:47:14 -0500
From: Jeff Layton <jlayton@redhat.com>
To: steved@redhat.com
Cc: chuck.lever@oracle.com, linux-nfs@vger.kernel.org
Subject: [PATCH v3] autoconf: only link binaries that need it to libtirpc
Date: Fri, 13 Jan 2012 09:47:10 -0500
Message-Id: <1326466030-29907-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This patch is essentially the same as the previous version, but has
been respun to fix up some merge conflicts with some of Chuck's
recent changes.

When we first added tirpc support, we took a "big hammer" approach, and
had it add libtirpc to $LIBS. That had the effect of making it so that
that library was linked into every binary. That's unnecessary, and
wasteful with memory.

Don't let AC_CHECK_LIB add -ltirpc to $LIBS. Instead, have the autoconf
tests set $(LIBTIRPC) in the makefiles, and have the programs that
need it explicitly include that library. In the event that we're not
using libtirpc, then set $LIBTIRPC to a blank string.

This necessitates a change to the bindresvport_sa check too. Since that
library is no longer included in $LIBS, we need to convert that check
to use AC_CHECK_LIB instead of AC_CHECK_FUNCS.

This patch also fixes a subtle bug. If the library was usable, but the
includes were not, the test would set $enable_tirpc to "no", but
HAVE_LIBTIRPC would still be true. That configuration would likely
fail to build.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 aclocal/ipv6.m4             |    4 +++-
 aclocal/libtirpc.m4         |   15 +++++++++++++--
 tools/rpcgen/Makefile.am    |    1 +
 utils/gssd/Makefile.am      |    4 ++--
 utils/mount/Makefile.am     |    3 ++-
 utils/mountd/Makefile.am    |    2 +-
 utils/nfsd/Makefile.am      |    2 +-
 utils/showmount/Makefile.am |    3 ++-
 utils/statd/Makefile.am     |    4 ++--
 9 files changed, 27 insertions(+), 11 deletions(-)

diff --git a/aclocal/ipv6.m4 b/aclocal/ipv6.m4
index 4e39fbe..75a8582 100644
--- a/aclocal/ipv6.m4
+++ b/aclocal/ipv6.m4
@@ -10,9 +10,11 @@ AC_DEFUN([AC_IPV6], [
     fi
 
     dnl IPv6-enabled networking functions required for IPv6
-    AC_CHECK_FUNCS([getifaddrs getnameinfo bindresvport_sa], ,
+    AC_CHECK_FUNCS([getifaddrs getnameinfo], ,
                    [AC_MSG_ERROR([Missing library functions needed for IPv6.])])
 
+    AC_CHECK_LIB([tirpc], [bindresvport_sa], [:],
+		 [AC_MSG_ERROR([Missing library functions needed for IPv6.])])
   fi
 
 ])dnl
diff --git a/aclocal/libtirpc.m4 b/aclocal/libtirpc.m4
index 9f0fde0..19b8361 100644
--- a/aclocal/libtirpc.m4
+++ b/aclocal/libtirpc.m4
@@ -13,8 +13,8 @@ AC_DEFUN([AC_LIBTIRPC], [
 
   if test "$enable_tirpc" != "no"; then
 
-    dnl look for the library; add to LIBS if found
-    AC_CHECK_LIB([tirpc], [clnt_tli_create], ,
+    dnl look for the library
+    AC_CHECK_LIB([tirpc], [clnt_tli_create], [:],
                  [if test "$enable_tirpc" = "yes"; then
 			AC_MSG_ERROR([libtirpc not found.])
 		  else
@@ -37,4 +37,15 @@ AC_DEFUN([AC_LIBTIRPC], [
 
   fi
 
+  dnl now set $LIBTIRPC accordingly
+  if test "$enable_tirpc" != "no"; then
+    AC_DEFINE([HAVE_LIBTIRPC], 1,
+              [Define to 1 if you have and wish to use libtirpc.])
+    LIBTIRPC="-ltirpc"
+  else
+    LIBTIRPC=""
+  fi
+
+  AC_SUBST(LIBTIRPC)
+
 ])dnl
diff --git a/tools/rpcgen/Makefile.am b/tools/rpcgen/Makefile.am
index 51a2bfa..8a9ec89 100644
--- a/tools/rpcgen/Makefile.am
+++ b/tools/rpcgen/Makefile.am
@@ -12,6 +12,7 @@ rpcgen_SOURCES = rpc_clntout.c rpc_cout.c rpc_hout.c rpc_main.c \
 rpcgen_CFLAGS=$(CFLAGS_FOR_BUILD)
 rpcgen_CPPLAGS=$(CPPFLAGS_FOR_BUILD)
 rpcgen_LDFLAGS=$(LDFLAGS_FOR_BUILD)
+rpcgen_LDADD=$(LIBTIRPC)
 
 MAINTAINERCLEANFILES = Makefile.in
 
diff --git a/utils/gssd/Makefile.am b/utils/gssd/Makefile.am
index 9136189..d29e132 100644
--- a/utils/gssd/Makefile.am
+++ b/utils/gssd/Makefile.am
@@ -40,7 +40,7 @@ gssd_SOURCES = \
 
 gssd_LDADD =	../../support/nfs/libnfs.a \
 		$(RPCSECGSS_LIBS) $(GSSGLUE_LIBS) $(KRBLIBS)
-gssd_LDFLAGS = $(KRBLDFLAGS)
+gssd_LDFLAGS = $(KRBLDFLAGS) $(LIBTIRPC)
 
 gssd_CFLAGS = $(AM_CFLAGS) $(CFLAGS) \
 	      $(RPCSECGSS_CFLAGS) $(GSSGLUE_CFLAGS) $(KRBCFLAGS)
@@ -59,7 +59,7 @@ svcgssd_SOURCES = \
 svcgssd_LDADD = \
 	../../support/nfs/libnfs.a \
 	$(RPCSECGSS_LIBS) $(GSSGLUE_LIBS) $(LIBNFSIDMAP) \
-	$(KRBLIBS)
+	$(KRBLIBS) $(LIBTIRPC)
 
 svcgssd_LDFLAGS = $(KRBLDFLAGS)
 
diff --git a/utils/mount/Makefile.am b/utils/mount/Makefile.am
index 7bc3e2b..7627854 100644
--- a/utils/mount/Makefile.am
+++ b/utils/mount/Makefile.am
@@ -24,7 +24,8 @@ EXTRA_DIST += nfsmount.conf
 endif
 
 mount_nfs_LDADD = ../../support/nfs/libnfs.a \
-		  ../../support/export/libexport.a
+		  ../../support/export/libexport.a \
+		  $(LIBTIRPC)
 
 mount_nfs_SOURCES = $(mount_common)
 
diff --git a/utils/mountd/Makefile.am b/utils/mountd/Makefile.am
index 5a2d1b6..7db968b 100644
--- a/utils/mountd/Makefile.am
+++ b/utils/mountd/Makefile.am
@@ -12,7 +12,7 @@ mountd_SOURCES = mountd.c mount_dispatch.c auth.c rmtab.c cache.c \
 mountd_LDADD = ../../support/export/libexport.a \
 	       ../../support/nfs/libnfs.a \
 	       ../../support/misc/libmisc.a \
-	       $(LIBBSD) $(LIBWRAP) $(LIBNSL) $(LIBBLKID) $(LIBDL)
+	       $(LIBBSD) $(LIBWRAP) $(LIBNSL) $(LIBBLKID) $(LIBDL) $(LIBTIRPC)
 mountd_CPPFLAGS = $(AM_CPPFLAGS) $(CPPFLAGS) \
 		  -I$(top_builddir)/support/include \
 		  -I$(top_srcdir)/support/export
diff --git a/utils/nfsd/Makefile.am b/utils/nfsd/Makefile.am
index c4c6fb0..1536065 100644
--- a/utils/nfsd/Makefile.am
+++ b/utils/nfsd/Makefile.am
@@ -8,7 +8,7 @@ KPREFIX		= @kprefix@
 sbin_PROGRAMS	= nfsd
 
 nfsd_SOURCES = nfsd.c nfssvc.c
-nfsd_LDADD = ../../support/nfs/libnfs.a
+nfsd_LDADD = ../../support/nfs/libnfs.a $(LIBTIRPC)
 
 MAINTAINERCLEANFILES = Makefile.in
 
diff --git a/utils/showmount/Makefile.am b/utils/showmount/Makefile.am
index 077b2c7..4ba5ead 100644
--- a/utils/showmount/Makefile.am
+++ b/utils/showmount/Makefile.am
@@ -7,7 +7,8 @@ sbin_PROGRAMS	= showmount
 showmount_SOURCES = showmount.c
 showmount_LDADD = ../../support/export/libexport.a \
 		  ../../support/nfs/libnfs.a \
-	  	  ../../support/misc/libmisc.a
+		  ../../support/misc/libmisc.a \
+		  $(LIBTIRPC)
 showmount_CPPFLAGS = $(AM_CPPFLAGS) $(CPPFLAGS) \
 		   -I$(top_builddir)/support/export
 
diff --git a/utils/statd/Makefile.am b/utils/statd/Makefile.am
index 1744791..dc2bfc4 100644
--- a/utils/statd/Makefile.am
+++ b/utils/statd/Makefile.am
@@ -15,10 +15,10 @@ BUILT_SOURCES = $(GENFILES)
 statd_LDADD = ../../support/nsm/libnsm.a \
 	      ../../support/nfs/libnfs.a \
 	      ../../support/misc/libmisc.a \
-	      $(LIBWRAP) $(LIBNSL) $(LIBCAP)
+	      $(LIBWRAP) $(LIBNSL) $(LIBCAP) $(LIBTIRPC)
 sm_notify_LDADD = ../../support/nsm/libnsm.a \
 		  ../../support/nfs/libnfs.a \
-		  $(LIBNSL) $(LIBCAP)
+		  $(LIBNSL) $(LIBCAP) $(LIBTIRPC)
 
 EXTRA_DIST = sim_sm_inter.x $(man8_MANS) COPYRIGHT simulate.c
 
-- 
1.7.1

