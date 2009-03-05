From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 9/9] nfs-utils: clean up handling of libgssglue in gssd
	Makefile
Date: Thu, 05 Mar 2009 12:42:34 -0500
Message-ID: <20090305174234.30471.62999.stgit@ingres.1015granger.net>
References: <20090305173533.30471.41413.stgit@ingres.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: steved@redhat.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from acsinet12.oracle.com ([141.146.126.234]:18149 "EHLO
	acsinet12.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754231AbZCERnL (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 5 Mar 2009 12:43:11 -0500
In-Reply-To: <20090305173533.30471.41413.stgit-07a7zB5ZJzbwdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Jeff Layton <jlayton@redhat.com>

Make the pkgconfig check for libgssglue conditional on tirpc being
enabled. When it's disabled, the pkgconfig check for librpcsecgss will
pull in the gssglue lib and include dir automatically.

Also, make sure we include GSSGLUE_CFLAGS and the GSSGLUE_LIBS to the
appropriate places in utils/gssd/Makefile.am so that we pick up
the gssglue libs when tirpc is enabled.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 aclocal/rpcsec_vers.m4 |    6 +++---
 utils/gssd/Makefile.am |   10 +++++-----
 2 files changed, 8 insertions(+), 8 deletions(-)

diff --git a/aclocal/rpcsec_vers.m4 b/aclocal/rpcsec_vers.m4
index 5d13db3..e59c0aa 100644
--- a/aclocal/rpcsec_vers.m4
+++ b/aclocal/rpcsec_vers.m4
@@ -1,12 +1,12 @@
 dnl Checks librpcsec version
 AC_DEFUN([AC_RPCSEC_VERSION], [
 
-  dnl TI-RPC replaces librpcsecgss
+  dnl TI-RPC replaces librpcsecgss, but we still need libgssglue
   if test "$enable_tirpc" = no; then
     PKG_CHECK_MODULES([RPCSECGSS], [librpcsecgss >= 0.16], ,
                       [AC_MSG_ERROR([Unable to locate information required to use librpcsecgss.  If you have pkgconfig installed, you might try setting environment variable PKG_CONFIG_PATH to /usr/local/lib/pkgconfig])])
+  else
+    PKG_CHECK_MODULES([GSSGLUE], [libgssglue >= 0.1])
   fi
 
-  PKG_CHECK_MODULES([GSSGLUE], [libgssglue >= 0.1])
-
 ])dnl
diff --git a/utils/gssd/Makefile.am b/utils/gssd/Makefile.am
index e42b339..95a2bd0 100644
--- a/utils/gssd/Makefile.am
+++ b/utils/gssd/Makefile.am
@@ -39,11 +39,11 @@ gssd_SOURCES = \
 	write_bytes.h
 
 gssd_LDADD =	../../support/nfs/libnfs.a \
-		$(RPCSECGSS_LIBS) $(KRBLIBS)
+		$(RPCSECGSS_LIBS) $(GSSGLUE_LIBS) $(KRBLIBS)
 gssd_LDFLAGS = $(KRBLDFLAGS)
 
 gssd_CFLAGS = $(AM_CFLAGS) $(CFLAGS) \
-	      $(RPCSECGSS_CFLAGS) $(KRBCFLAGS)
+	      $(RPCSECGSS_CFLAGS) $(GSSGLUE_CFLAGS) $(KRBCFLAGS)
 
 svcgssd_SOURCES = \
 	$(COMMON_SRCS) \
@@ -56,18 +56,18 @@ svcgssd_SOURCES = \
 
 svcgssd_LDADD = \
 	../../support/nfs/libnfs.a \
-	$(RPCSECGSS_LIBS) -lnfsidmap \
+	$(RPCSECGSS_LIBS) $(GSSGLUE_LIBS) -lnfsidmap \
 	$(KRBLIBS)
 
 svcgssd_LDFLAGS = $(KRBLDFLAGS)
 
 svcgssd_CFLAGS = $(AM_CFLAGS) $(CFLAGS) \
-		 $(RPCSECGSS_CFLAGS) $(KRBCFLAGS)
+		 $(RPCSECGSS_CFLAGS) $(GSSGLUE_CFLAGS) $(KRBCFLAGS)
 
 gss_clnt_send_err_SOURCES = gss_clnt_send_err.c
 
 gss_clnt_send_err_CFLAGS = $(AM_CFLAGS) $(CFLAGS) \
-		 $(RPCSECGSS_CFLAGS) $(KRBCFLAGS)
+		 $(RPCSECGSS_CFLAGS) $(GSSGLUE_CFLAGS) $(KRBCFLAGS)
 
 MAINTAINERCLEANFILES = Makefile.in
 

