Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:37783 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751583AbbEGLwt (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 7 May 2015 07:52:49 -0400
Date: Thu, 7 May 2015 13:52:48 +0200
From: Thorsten Kukuk <kukuk@suse.de>
To: Mike Frysinger <vapier@gentoo.org>
Cc: libtirpc-devel@lists.sourceforge.net, linux-nfs@vger.kernel.org
Subject: Re: [Libtirpc-devel] [PATCH libtirpc] fix build w/gssapi disabled
Message-ID: <20150507115248.GA20243@suse.de>
References: <1430983149-22199-1-git-send-email-vapier@gentoo.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
In-Reply-To: <1430983149-22199-1-git-send-email-vapier@gentoo.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


Hi,

On Thu, May 07, Mike Frysinger wrote:

> Starting with commit d5259e751111cb108c784b044296185f543fc0be (Add header
> definitions for rpc_gss_*() APIs), the gss headers were pulled in all the
> time leading to build failures like so:
>   CC       libtirpc_la-bindresvport.lo
> In file included from ../tirpc/rpc/svc_auth.h:44:0,
>                  from ../tirpc/rpc/rpc.h:68,
>                  from bindresvport.c:46:
> ../tirpc/rpc/rpcsec_gss.h:38:27: fatal error: gssapi/gssapi.h: No such file or directory

Here is my proof of concept how I think we should solve this.
But there is one part of your patch I have no solution for:

> --- a/tirpc/rpc/svc_auth.h
> +++ b/tirpc/rpc/svc_auth.h
[...]
> @@ -63,8 +67,10 @@ typedef struct SVCAUTH {
>  		int     (*svc_ah_destroy)(struct SVCAUTH *);
>  		} *svc_ah_ops;
>  	caddr_t svc_ah_private;
> +#ifdef HAVE_RPCSEC_GSS
>  	svc_rpc_gss_parms_t svc_gss_params;
>  	rpc_gss_rawcred_t raw_cred;
> +#endif
>  } SVCAUTH;

You are changeing the size of a struct here. I'm not sure
if this will work, if an application is compiled with headers
where it is disabled and then runs with a tirpc where it is
enabled. Or the other way around.
Does somebody have an idea how to solve that?

Else here is my patch:

diff --git a/Makefile.am b/Makefile.am
index 2bf725c..2bce3b0 100644
--- a/Makefile.am
+++ b/Makefile.am
@@ -4,9 +4,11 @@ ACLOCAL_AMFLAGS = -I m4
 noinst_HEADERS	       = tirpc/reentrant.h \
 			 tirpc/getpeereid.h \
 			 tirpc/libc_private.h \
-			 tirpc/un-namespace.h
+			 tirpc/un-namespace.h \
+			 tirpc/tirpc-features.h.in
 
 nobase_include_HEADERS = tirpc/netconfig.h \
+			 tirpc/tirpc-features.h \
 			 tirpc/rpcsvc/crypt.x \
 			 tirpc/rpcsvc/crypt.h \
 			 tirpc/rpc/xdr.h \
diff --git a/configure.ac b/configure.ac
index 711b054..290c635 100644
--- a/configure.ac
+++ b/configure.ac
@@ -10,6 +10,7 @@ AC_ARG_ENABLE(gssapi,
 AM_CONDITIONAL(GSS, test "x$enable_gssapi" = xyes)
 
 if test "x$enable_gssapi" = xyes; then
+	AC_DEFINE([HAVE_GSSAPI], [1], [Define to 1 if GSSAPI is enabled])
 	GSSAPI_CFLAGS=`krb5-config --cflags gssapi`
 	GSSAPI_LIBS=`krb5-config --libs gssapi`
 	AC_SUBST([GSSAPI_CFLAGS])
@@ -41,7 +42,7 @@ AC_ARG_ENABLE(symvers,
 AM_CONDITIONAL(SYMVERS, test "x$enable_symvers" = xyes)
 
 AC_PROG_CC
-AC_CONFIG_HEADERS([config.h])
+AC_CONFIG_HEADERS([config.h tirpc/tirpc-features.h])
 AC_PROG_LIBTOOL
 AC_HEADER_DIRENT
 AC_PREFIX_DEFAULT(/usr)
diff --git a/tirpc/rpc/rpc.h b/tirpc/rpc/rpc.h
index 1dbb391..8f37454 100644
--- a/tirpc/rpc/rpc.h
+++ b/tirpc/rpc/rpc.h
@@ -35,6 +35,8 @@
 #ifndef _TIRPC_RPC_H
 #define _TIRPC_RPC_H
 
+#include <tirpc-features.h>
+
 #include <rpc/types.h>		/* some typedefs */
 #include <sys/socket.h>
 #include <netinet/in.h>
@@ -60,7 +62,7 @@
 #include <rpc/auth_des.h>	/* protocol for des style cred */
 #endif /* HAVE_AUTHDES */
 
-#ifdef HAVE_RPCSEC_GSS
+#ifdef HAVE_GSSAPI
 #include <rpc/auth_gss.h>   /* RPCSEC_GSS */
 #endif
 
diff --git a/tirpc/rpc/svc_auth.h b/tirpc/rpc/svc_auth.h
index 44b38bf..b308d2b 100644
--- a/tirpc/rpc/svc_auth.h
+++ b/tirpc/rpc/svc_auth.h
@@ -41,6 +41,10 @@
 #ifndef _RPC_SVC_AUTH_H
 #define _RPC_SVC_AUTH_H
 
+#include <tirpc-features.h>
+
+#ifdef HAVE_GSSAPI
+
 #include <rpc/rpcsec_gss.h>
 
 typedef struct {
@@ -51,6 +55,8 @@ typedef struct {
 	u_int			seq_num;
 } svc_rpc_gss_parms_t;
 
+#endif /* HAVE_GSSAPI */
+
 /*
  * Interface to server-side authentication flavors.
  */
diff --git a/tirpc/tirpc-features.h.in b/tirpc/tirpc-features.h.in
index e69de29..72e18bc 100644
--- a/tirpc/tirpc-features.h.in
+++ b/tirpc/tirpc-features.h.in
@@ -0,0 +1,10 @@
+#ifndef _TIRPC_FEATURES_H
+#define _TIRPC_FEATURES_H
+
+/* Define to 1 if DES authentication is enabled */
+#undef HAVE_AUTHDES
+
+/* Define to 1 if GSSAPI is enabled */
+#undef HAVE_GSSAPI
+
+#endif /* _TIRPC_FEATURES_H */


-- 
Thorsten Kukuk, Senior Architect SLES & Common Code Base
SUSE LINUX GmbH, Maxfeldstr. 5, 90409 Nuernberg, Germany
GF: Felix Imendörffer, Jane Smithard, Jennifer Guild, Dilip Upmanyu, Graham Norton, HRB 21284 (AG Nürnberg)
