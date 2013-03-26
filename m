Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:60810 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751726Ab3CZRX5 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 26 Mar 2013 13:23:57 -0400
Received: from int-mx10.intmail.prod.int.phx2.redhat.com (int-mx10.intmail.prod.int.phx2.redhat.com [10.5.11.23])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id r2QHNurn022298
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-nfs@vger.kernel.org>; Tue, 26 Mar 2013 13:23:56 -0400
Subject: Allow building nfs-utils directly against GSSAPI
From: Simo Sorce <simo@redhat.com>
To: linux-nfs <linux-nfs@vger.kernel.org>
Cc: Steve Dickson <steved@redhat.com>,
        =?ISO-8859-1?Q?G=FCnther?= Deschner <gdeschne@redhat.com>
Content-Type: multipart/mixed; boundary="=-U8cMmHkDRQMh1EJ8P48Q"
Date: Tue, 26 Mar 2013 13:00:02 -0400
Message-ID: <1364317202.2660.132.camel@willson.li.ssimo.org>
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


--=-U8cMmHkDRQMh1EJ8P48Q
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit

Libgssglue is not really useful anymore, it is a sort of middleman that
wraps the actual GSSAPI that is already pluggable/extensible via shared
modules.

In particular libgssglue interferes with the workings of gss-proxy in my
case.

The attached patch makes building against libgssglue optional and
defaults to not build against libgssglue and instead builds directly
against the native GSSAPI.

./configure --enable-gss
will now build against GSSAPI

./configure --enable-gss --with-gssglue
will keep building against libgssglue in case someone still needs it for
whatever reason.

Simo.

-- 
Simo Sorce * Red Hat, Inc * New York

--=-U8cMmHkDRQMh1EJ8P48Q
Content-Disposition: attachment; filename*0=0001-Add-configure-check-for-gss_krb5_free_lucid_sec_cont.pat; filename*1=ch
Content-Type: text/x-patch; name="0001-Add-configure-check-for-gss_krb5_free_lucid_sec_cont.patch"; charset="UTF-8"
Content-Transfer-Encoding: 8bit

>From cde7338379cb424431eddc4f86b14185b89dc87e Mon Sep 17 00:00:00 2001
From: =?UTF-8?q?G=C3=BCnther=20Deschner?= <gdeschner@redhat.com>
Date: Fri, 22 Mar 2013 18:51:58 +0100
Subject: [PATCH 1/3] Add configure check for
 gss_krb5_free_lucid_sec_context().
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit

Signed-off-by: Simo Sorce <simo@redhat.com>
Signed-off-by: Günther Deschner <gdeschner@redhat.com>
---
 aclocal/kerberos5.m4 | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/aclocal/kerberos5.m4 b/aclocal/kerberos5.m4
index 7574e2d3b380b22b63908f8586d22e76a2a5bc5b..ef37e28a11cad7552074b99a7805cd16b227cec8 100644
--- a/aclocal/kerberos5.m4
+++ b/aclocal/kerberos5.m4
@@ -92,6 +92,8 @@ AC_DEFUN([AC_KERBEROS_V5],[
     AC_DEFINE(HAVE_SET_ALLOWABLE_ENCTYPES, 1, [Define this if the Kerberos GSS library supports gss_krb5_set_allowable_enctypes]), ,$KRBLIBS)
   AC_CHECK_LIB($gssapi_lib, gss_krb5_ccache_name,
     AC_DEFINE(HAVE_GSS_KRB5_CCACHE_NAME, 1, [Define this if the Kerberos GSS library supports gss_krb5_ccache_name]), ,$KRBLIBS)
+  AC_CHECK_LIB($gssapi_lib, gss_krb5_free_lucid_sec_context,
+    AC_DEFINE(HAVE_GSS_KRB5_FREE_LUCID_SEC_CONTEXT, 1, [Define this if the Kerberos GSS library supports gss_krb5_free_lucid_sec_context]), ,$KRBLIBS)
 
   dnl Check for newer error message facility
   AC_CHECK_LIB($gssapi_lib, krb5_get_error_message,
-- 
1.8.1.4


--=-U8cMmHkDRQMh1EJ8P48Q
Content-Disposition: attachment; filename="0002-Provide-macros-for-non-standard-gss-symbols.patch"
Content-Type: text/x-patch; name="0002-Provide-macros-for-non-standard-gss-symbols.patch"; charset="UTF-8"
Content-Transfer-Encoding: 7bit

>From 67505e175e97efec5e662a23deb3eedff08c3d6e Mon Sep 17 00:00:00 2001
From: Simo Sorce <simo@redhat.com>
Date: Tue, 26 Mar 2013 12:04:06 -0400
Subject: [PATCH 2/3] Provide macros for non-standard gss symbols

libgsglue uses non standard name for mechanism specific extensions to gssapi
which normally have gss_krb5_* names.
Provide symbol substitution headers so that nfs-utils can be compiled both
against libgssglue and the native GSSAPI implementation.

Signed-off-by: Simo Sorce <simo@redhat.com>
---
 utils/gssd/gss_util.h | 10 ++++++++++
 1 file changed, 10 insertions(+)

diff --git a/utils/gssd/gss_util.h b/utils/gssd/gss_util.h
index 67b3077a8d252d31346fce6fdbd795a0c0c28287..aa9f77806075f9ab67a7763a75a010369ba2d1b9 100644
--- a/utils/gssd/gss_util.h
+++ b/utils/gssd/gss_util.h
@@ -42,4 +42,14 @@ void pgsserr(char *msg, u_int32_t maj_stat, u_int32_t min_stat,
 	const gss_OID mech);
 int gssd_check_mechs(void);
 
+#ifndef HAVE_LIBGSSGLUE
+#include <gssapi/gssapi_krb5.h>
+#define gss_free_lucid_sec_context(min, ctx, ret) \
+		gss_krb5_free_lucid_sec_context(min, ret)
+
+#define gss_export_lucid_sec_context gss_krb5_export_lucid_sec_context
+#define gss_set_allowable_enctypes(min, cred, oid, num, types) \
+		gss_krb5_set_allowable_enctypes(min, cred, num, types)
+#endif
+
 #endif /* _GSS_UTIL_H_ */
-- 
1.8.1.4


--=-U8cMmHkDRQMh1EJ8P48Q
Content-Disposition: attachment; filename="0003-Switch-to-use-standard-GSSAPI-by-default.patch"
Content-Type: text/x-patch; name="0003-Switch-to-use-standard-GSSAPI-by-default.patch"; charset="UTF-8"
Content-Transfer-Encoding: 7bit

>From 34ce971b090b50b0f6a18754f106ad8d2e90e9e2 Mon Sep 17 00:00:00 2001
From: Simo Sorce <simo@redhat.com>
Date: Tue, 26 Mar 2013 11:11:41 -0400
Subject: [PATCH 3/3] Switch to use standard GSSAPI by default

Make libgssglue configurable still but disabled by default.
There is no reason to use libgssglue anymore, and modern gssapi
supports all needed features for nfs-utils.

Signed-off-by: Simo Sorce <simo@redhat.com>
---
 aclocal/kerberos5.m4   |  4 ++++
 aclocal/rpcsec_vers.m4 |  7 ++++++-
 configure.ac           |  9 +++++++++
 utils/gssd/Makefile.am | 12 ++++++------
 4 files changed, 25 insertions(+), 7 deletions(-)

diff --git a/aclocal/kerberos5.m4 b/aclocal/kerberos5.m4
index ef37e28a11cad7552074b99a7805cd16b227cec8..0bf35d3fddb57a0b977a87f90063cf4500ce377d 100644
--- a/aclocal/kerberos5.m4
+++ b/aclocal/kerberos5.m4
@@ -32,6 +32,8 @@ AC_DEFUN([AC_KERBEROS_V5],[
     if test "$K5CONFIG" != ""; then
       KRBCFLAGS=`$K5CONFIG --cflags`
       KRBLIBS=`$K5CONFIG --libs`
+      GSSKRB_CFLAGS=`$K5CONFIG --cflags gssapi`
+      GSSKRB_LIBS=`$K5CONFIG --libs gssapi`
       K5VERS=`$K5CONFIG --version | head -n 1 | awk '{split($(4),v,"."); if (v@<:@"3"@:>@ == "") v@<:@"3"@:>@ = "0"; print v@<:@"1"@:>@v@<:@"2"@:>@v@<:@"3"@:>@ }'`
       AC_DEFINE_UNQUOTED(KRB5_VERSION, $K5VERS, [Define this as the Kerberos version number])
       if test -f $dir/include/gssapi/gssapi_krb5.h -a \
@@ -113,5 +115,7 @@ AC_DEFUN([AC_KERBEROS_V5],[
   AC_SUBST([KRBCFLAGS])
   AC_SUBST([KRBLDFLAGS])
   AC_SUBST([K5VERS])
+  AC_SUBST([GSSKRB_CFLAGS])
+  AC_SUBST([GSSKRB_LIBS])
 
 ])
diff --git a/aclocal/rpcsec_vers.m4 b/aclocal/rpcsec_vers.m4
index 8218372ceaeef3591a064c5bd906fffade0cd578..11d2f18cb241c51c31c5921a342e5ec935e7de84 100644
--- a/aclocal/rpcsec_vers.m4
+++ b/aclocal/rpcsec_vers.m4
@@ -1,7 +1,12 @@
 dnl Checks librpcsec version
 AC_DEFUN([AC_RPCSEC_VERSION], [
 
-  PKG_CHECK_MODULES([GSSGLUE], [libgssglue >= 0.3])
+  AC_ARG_WITH([gssglue],
+	[AC_HELP_STRING([--with-gssglue], [Use libgssglue for GSS support])])
+  if test x"$with_gssglue" = x"yes"; then
+    PKG_CHECK_MODULES([GSSGLUE], [libgssglue >= 0.3])
+    AC_CHECK_LIB([gssglue], [gss_set_allowable_enctypes])
+  fi
 
   dnl TI-RPC replaces librpcsecgss
   if test "$enable_tirpc" = no; then
diff --git a/configure.ac b/configure.ac
index cc7f3b4b4933c218d2e4cab7369ba5c1afc4e4d7..3d7ab0a2669d33c3cece1844b7eb53f2c1e3f68a 100644
--- a/configure.ac
+++ b/configure.ac
@@ -344,6 +344,15 @@ if test "$enable_gss" = yes; then
   dnl but we need to make sure we get the right version
   if test "$enable_gss" = yes; then
     AC_RPCSEC_VERSION
+    if test x"$GSSGLUE_LIBS" != x""; then
+      GSSAPI_CFLAGS=$GSSGLUE_CFLAGS
+      GSSAPI_LIBS=$GSSGLUE_LIBS
+    else
+      GSSAPI_CFLAGS=$GSSKRB_CFLAGS
+      GSSAPI_LIBS=$GSSKRB_LIBS
+    fi
+    AC_SUBST([GSSAPI_CFLAGS])
+    AC_SUBST([GSSAPI_LIBS])
   fi
 fi
 
diff --git a/utils/gssd/Makefile.am b/utils/gssd/Makefile.am
index 2365704c5db9b15d17f42b75adcb17f07f7e216f..a300da2b042baf9b14b77899d6419461a2e615d5 100644
--- a/utils/gssd/Makefile.am
+++ b/utils/gssd/Makefile.am
@@ -38,11 +38,11 @@ gssd_SOURCES = \
 	write_bytes.h
 
 gssd_LDADD =	../../support/nfs/libnfs.a \
-		$(RPCSECGSS_LIBS) $(GSSGLUE_LIBS) $(KRBLIBS)
+		$(RPCSECGSS_LIBS) $(KRBLIBS) $(GSSAPI_LIBS)
 gssd_LDFLAGS = $(KRBLDFLAGS) $(LIBTIRPC)
 
 gssd_CFLAGS = $(AM_CFLAGS) $(CFLAGS) \
-	      $(RPCSECGSS_CFLAGS) $(GSSGLUE_CFLAGS) $(KRBCFLAGS)
+	      $(RPCSECGSS_CFLAGS) $(KRBCFLAGS) $(GSSAPI_CFLAGS)
 
 svcgssd_SOURCES = \
 	$(COMMON_SRCS) \
@@ -57,18 +57,18 @@ svcgssd_SOURCES = \
 
 svcgssd_LDADD = \
 	../../support/nfs/libnfs.a \
-	$(RPCSECGSS_LIBS) $(GSSGLUE_LIBS) $(LIBNFSIDMAP) \
-	$(KRBLIBS) $(LIBTIRPC)
+	$(RPCSECGSS_LIBS) $(LIBNFSIDMAP) \
+	$(KRBLIBS) $(GSSAPI_LIBS) $(LIBTIRPC)
 
 svcgssd_LDFLAGS = $(KRBLDFLAGS)
 
 svcgssd_CFLAGS = $(AM_CFLAGS) $(CFLAGS) \
-		 $(RPCSECGSS_CFLAGS) $(GSSGLUE_CFLAGS) $(KRBCFLAGS)
+		 $(RPCSECGSS_CFLAGS) $(KRBCFLAGS) $(GSSAPI_CFLAGS)
 
 gss_clnt_send_err_SOURCES = gss_clnt_send_err.c
 
 gss_clnt_send_err_CFLAGS = $(AM_CFLAGS) $(CFLAGS) \
-		 $(RPCSECGSS_CFLAGS) $(GSSGLUE_CFLAGS) $(KRBCFLAGS)
+		 $(RPCSECGSS_CFLAGS) $(KRBCFLAGS) $(GSSAPI_CFLAGS)
 
 MAINTAINERCLEANFILES = Makefile.in
 
-- 
1.8.1.4


--=-U8cMmHkDRQMh1EJ8P48Q--

