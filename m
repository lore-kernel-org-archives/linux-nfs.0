Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:53370 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S934506Ab3CZOli (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 26 Mar 2013 10:41:38 -0400
Subject: Allow building libtirpc directly against GSSAPI
From: Simo Sorce <simo@redhat.com>
To: libtirpc-devel@lists.sourceforge.net
Cc: linux-nfs <linux-nfs@vger.kernel.org>, Steve Dickson <steved@redhat.com>
Content-Type: multipart/mixed; boundary="=-VfIvoI4VNX7alSU5MyAN"
Date: Tue, 26 Mar 2013 10:41:28 -0400
Message-ID: <1364308888.2660.119.camel@willson.li.ssimo.org>
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


--=-VfIvoI4VNX7alSU5MyAN
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

--=-VfIvoI4VNX7alSU5MyAN
Content-Disposition: attachment; filename="0001-Switch-to-use-standard-GSSAPI-by-default.patch"
Content-Type: text/x-patch; name="0001-Switch-to-use-standard-GSSAPI-by-default.patch"; charset="UTF-8"
Content-Transfer-Encoding: 7bit

>From 8518f6857b928e9ec615f9ca5f79f98d13db4f6d Mon Sep 17 00:00:00 2001
From: Simo Sorce <simo@redhat.com>
Date: Tue, 26 Mar 2013 10:15:56 -0400
Subject: [PATCH] Switch to use standard GSSAPI by default

Make libgssglue configurable still but disabled by default.
There is no reason to use libgssglue anymore, and modern gssapi
supports all needed features for libtirpc and its dependencies.
---
 configure.ac    | 23 +++++++++++++++++++----
 src/Makefile.am |  4 ++--
 2 files changed, 21 insertions(+), 6 deletions(-)

diff --git a/configure.ac b/configure.ac
index 40dce96..4a4adba 100644
--- a/configure.ac
+++ b/configure.ac
@@ -5,15 +5,30 @@ AC_CONFIG_SRCDIR([src/auth_des.c])
 AC_CONFIG_MACRO_DIR([m4])
 
 AC_ARG_ENABLE(gss,[  --enable-gss            Turn on gss api], [case "${enableval}" in
-        yes) gss=true ; AC_CHECK_LIB([gssapi],[gss_init_sec_context]) ;;
+        yes) gss=true ;;
         no)  gss=false ;;
         *) AC_MSG_ERROR(bad value ${enableval} for --enable-gss) ;;
       esac],[gss=false])
 AM_CONDITIONAL(GSS, test x$gss = xtrue)
+AC_ARG_WITH(gssglue,
+		[  --with-gssglue        Use libgssglue],
+		 [case "${enableval}" in
+		  yes) gssglue=true ;;
+		  no)  gssglue=false ;;
+		  *) AC_MSG_ERROR(bad value ${enableval} for --with-gssglue) ;;
+		  esac],
+		[gssglue=false])
+AM_CONDITIONAL(USEGSSGLUE, test x$gssglue = xtrue)
 if test x$gss = xtrue; then
-	AC_DEFINE(HAVE_LIBGSSAPI, 1, [])
-	PKG_CHECK_MODULES(GSSGLUE, libgssglue, [],
-	AC_MSG_ERROR([Unable to locate information required to use libgssglue.]))
+	if test x$gssglue = xtrue; then
+		PKG_CHECK_MODULES(GSSAPI, libgssglue, [],
+		AC_MSG_ERROR([Unable to locate information required to use libgssglue.]))
+	else
+		GSSAPI_CFLAGS=`krb5-config --cflags gssapi`
+		GSSAPI_LIBS=`krb5-config --libs gssapi`
+		AC_SUBST([GSSAPI_CFLAGS])
+		AC_SUBST([GSSAPI_LIBS])
+	fi
 fi
 AC_ARG_ENABLE(ipv6,
 	[AC_HELP_STRING([--disable-ipv6], [Disable IPv6 support @<:@default=no@:>@])],
diff --git a/src/Makefile.am b/src/Makefile.am
index 66350f5..2dd7768 100644
--- a/src/Makefile.am
+++ b/src/Makefile.am
@@ -58,8 +58,8 @@ libtirpc_la_SOURCES += xdr.c xdr_rec.c xdr_array.c xdr_float.c xdr_mem.c xdr_ref
 ## Secure-RPC
 if GSS
     libtirpc_la_SOURCES += auth_gss.c authgss_prot.c svc_auth_gss.c
-    libtirpc_la_LDFLAGS += $(GSSGLUE_LIBS)
-    libtirpc_la_CFLAGS = -DHAVE_RPCSEC_GSS $(GSSGLUE_CFLAGS)
+    libtirpc_la_LDFLAGS += $(GSSAPI_LIBS)
+    libtirpc_la_CFLAGS = -DHAVE_RPCSEC_GSS $(GSSAPI_CFLAGS)
 endif
 
 ## libtirpc_a_SOURCES += key_call.c key_prot_xdr.c getpublickey.c
-- 
1.8.1.4


--=-VfIvoI4VNX7alSU5MyAN--

