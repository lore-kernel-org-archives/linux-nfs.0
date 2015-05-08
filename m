Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:40795 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752346AbbEHIRU (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 8 May 2015 04:17:20 -0400
Date: Fri, 8 May 2015 10:17:17 +0200
From: Thorsten Kukuk <kukuk@suse.de>
To: Steve Dickson <SteveD@redhat.com>, libtirpc-devel@lists.sourceforge.net,
        linux-nfs@vger.kernel.org
Subject: Re: [PATCH V2] Fix Build w/gssapi disabled
Message-ID: <20150508081717.GA16376@suse.de>
References: <1430983149-22199-1-git-send-email-vapier@gentoo.org>
 <20150507115248.GA20243@suse.de>
 <554B86E2.8090908@RedHat.com>
 <20150507163326.GA6156@suse.de>
 <554B98E9.4040601@RedHat.com>
 <20150507181206.GA7810@suse.de>
 <554BC53C.5080807@RedHat.com>
 <554BC730.3000004@RedHat.com>
 <554BC9F3.6020005@RedHat.com>
 <20150508020322.GF30924@vapier>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
In-Reply-To: <20150508020322.GF30924@vapier>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, May 07, Mike Frysinger wrote:

> it is dangerous to export raw HAVE_xxx defines -- it can break packages that
> use autotools themselves.  they need an appropriate prefix like RPC_xxx or
> TIRPC_xxx.


For this and to solve the different size of the struct, I created
a new patch on top of current git. I only had to rearange the structs
a little bit, since they don't use any kerberos specific variables,
only standard C:

diff --git a/configure.ac b/configure.ac
index 290c635..5d11a69 100644
--- a/configure.ac
+++ b/configure.ac
@@ -10,7 +10,7 @@ AC_ARG_ENABLE(gssapi,
 AM_CONDITIONAL(GSS, test "x$enable_gssapi" = xyes)
 
 if test "x$enable_gssapi" = xyes; then
-	AC_DEFINE([HAVE_GSSAPI], [1], [Define to 1 if GSSAPI is enabled])
+	AC_DEFINE([TIRPC_GSSAPI], [1], [Define to 1 if GSSAPI is enabled])
 	GSSAPI_CFLAGS=`krb5-config --cflags gssapi`
 	GSSAPI_LIBS=`krb5-config --libs gssapi`
 	AC_SUBST([GSSAPI_CFLAGS])
@@ -22,7 +22,7 @@ AC_ARG_ENABLE(authdes,
       [],[enable_authdes=no])
 AM_CONDITIONAL(AUTHDES, test "x$enable_authdes" = xyes)
 if test "x$enable_authdes" = xyes; then
-	AC_DEFINE([HAVE_AUTHDES], [1],
+	AC_DEFINE([TIRPC_AUTHDES], [1],
 		  [Define to 1 if DES authentication is enabled])
 	CFLAG_AUTHDES="-DHAVE_AUTHDES=1"
 	AC_SUBST([CFLAG_AUTHDES])
diff --git a/tirpc/rpc/auth.h b/tirpc/rpc/auth.h
index f7fa16c..6cf512a 100644
--- a/tirpc/rpc/auth.h
+++ b/tirpc/rpc/auth.h
@@ -164,7 +164,7 @@ union des_block {
 };
 typedef union des_block des_block;
 
-#ifdef HAVE_AUTHDES
+#ifdef TIRPC_AUTHDES
 #ifdef __cplusplus
 extern "C" {
 #endif
@@ -172,7 +172,7 @@ extern bool_t xdr_des_block(XDR *, des_block *);
 #ifdef __cplusplus
 }
 #endif
-#endif /* HAVE_AUTHDES */
+#endif /* TIRPC_AUTHDES */
 
 /*
  * Authentication info.  Opaque to client.
@@ -320,7 +320,7 @@ extern AUTH *authnone_create(void);		/* takes no parameters */
 }
 #endif
 
-#ifdef HAVE_AUTHDES
+#ifdef TIRPC_AUTHDES
 /*
  * DES style authentication
  * AUTH *authsecdes_create(servername, window, timehost, ckey)
@@ -338,7 +338,7 @@ extern AUTH *authdes_seccreate (const char *, const u_int, const  char *,
 #ifdef __cplusplus
 }
 #endif
-#endif /* HAVE_AUTHDES */
+#endif /* TIRPC_AUTHDES */
 
 #ifdef __cplusplus
 extern "C" {
@@ -362,9 +362,9 @@ extern int host2netname(char *, const char *, const char *);
 extern int user2netname(char *, const uid_t, const char *);
 extern int netname2user(char *, uid_t *, gid_t *, int *, gid_t *);
 extern int netname2host(char *, char *, const int);
-#ifdef HAVE_AUTHDES
+#ifdef TIRPC_AUTHDES
 extern void passwd2des ( char *, char * );
-#endif /* HAVE_AUTHDES */
+#endif /* TIRPC_AUTHDES */
 #ifdef __cplusplus
 }
 #endif
diff --git a/tirpc/rpc/rpc.h b/tirpc/rpc/rpc.h
index 8f37454..942959a 100644
--- a/tirpc/rpc/rpc.h
+++ b/tirpc/rpc/rpc.h
@@ -54,15 +54,15 @@
 #include <rpc/rpc_msg.h>	/* protocol for rpc messages */
 #include <rpc/auth_unix.h>	/* protocol for unix style cred */
 
-#ifdef HAVE_AUTHDES
+#ifdef TIRPC_AUTHDES
 /*
  *  Uncomment-out the next line if you are building the rpc library with
  *  DES Authentication (see the README file in the secure_rpc/ directory).
  */
 #include <rpc/auth_des.h>	/* protocol for des style cred */
-#endif /* HAVE_AUTHDES */
+#endif /* TIRPC_AUTHDES */
 
-#ifdef HAVE_GSSAPI
+#ifdef TIRPC_GSSAPI
 #include <rpc/auth_gss.h>   /* RPCSEC_GSS */
 #endif
 
diff --git a/tirpc/rpc/rpcsec_gss.h b/tirpc/rpc/rpcsec_gss.h
index 217fc0d..767988c 100644
--- a/tirpc/rpc/rpcsec_gss.h
+++ b/tirpc/rpc/rpcsec_gss.h
@@ -50,6 +50,19 @@ typedef struct {
 } *rpc_gss_principal_t;
 
 typedef struct {
+	u_int			version;
+	char			*mechanism;
+	char			*qop;
+	rpc_gss_principal_t	client_principal;
+	char			*svc_principal;
+	rpc_gss_service_t	service;
+} rpc_gss_rawcred_t;
+
+#ifdef TIRPC_GSSAPI
+
+#include <gssapi/gssapi.h>
+
+typedef struct {
 	int			req_flags;
 	int			time_req;
 	gss_cred_id_t		my_cred;
@@ -68,15 +81,6 @@ typedef struct {
 } rpc_gss_options_ret_t;
 
 typedef struct {
-	u_int			version;
-	char			*mechanism;
-	char			*qop;
-	rpc_gss_principal_t	client_principal;
-	char			*svc_principal;
-	rpc_gss_service_t	service;
-} rpc_gss_rawcred_t;
-
-typedef struct {
 	uid_t			uid;
 	gid_t			gid;
 	short			gidlen;
@@ -129,4 +133,6 @@ bool_t	rpc_gss_mech_to_oid(char *, rpc_gss_OID *);
 bool_t	rpc_gss_qop_to_num(char *, char *, u_int *);
 __END_DECLS
 
+#endif /* TIRPC_GSSAPI */
+
 #endif	/* !_TIRPC_RPCSEC_GSS_H */
diff --git a/tirpc/rpc/svc_auth.h b/tirpc/rpc/svc_auth.h
index dbd8cc9..f91bf01 100644
--- a/tirpc/rpc/svc_auth.h
+++ b/tirpc/rpc/svc_auth.h
@@ -42,9 +42,6 @@
 #define _RPC_SVC_AUTH_H
 
 #include <tirpc-features.h>
-
-#ifdef HAVE_GSSAPI
-
 #include <rpc/rpcsec_gss.h>
 
 typedef struct {
@@ -55,8 +52,6 @@ typedef struct {
 	u_int			seq_num;
 } svc_rpc_gss_parms_t;
 
-#endif /* HAVE_GSSAPI */
-
 /*
  * Interface to server-side authentication flavors.
  */
@@ -69,10 +64,8 @@ typedef struct SVCAUTH {
 		int     (*svc_ah_destroy)(struct SVCAUTH *);
 		} *svc_ah_ops;
 	caddr_t svc_ah_private;
-#ifdef HAVE_GSSAPI
 	svc_rpc_gss_parms_t svc_gss_params;
 	rpc_gss_rawcred_t raw_cred;
-#endif
 } SVCAUTH;
 
 #define SVCAUTH_WRAP(auth, xdrs, xfunc, xwhere) \
diff --git a/tirpc/tirpc-features.h.in b/tirpc/tirpc-features.h.in
index 72e18bc..39fa64e 100644
--- a/tirpc/tirpc-features.h.in
+++ b/tirpc/tirpc-features.h.in
@@ -2,9 +2,9 @@
 #define _TIRPC_FEATURES_H
 
 /* Define to 1 if DES authentication is enabled */
-#undef HAVE_AUTHDES
+#undef TIRPC_AUTHDES
 
 /* Define to 1 if GSSAPI is enabled */
-#undef HAVE_GSSAPI
+#undef TIRPC_GSSAPI
 
 #endif /* _TIRPC_FEATURES_H */




-- 
Thorsten Kukuk, Senior Architect SLES & Common Code Base
SUSE LINUX GmbH, Maxfeldstr. 5, 90409 Nuernberg, Germany
GF: Felix Imendörffer, Jane Smithard, Jennifer Guild, Dilip Upmanyu, Graham Norton, HRB 21284 (AG Nürnberg)
