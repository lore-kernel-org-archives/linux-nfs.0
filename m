Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-wi0-f172.google.com ([209.85.212.172]:38449 "EHLO
	mail-wi0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934204AbbDXA1u (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 23 Apr 2015 20:27:50 -0400
Received: by wiun10 with SMTP id n10so3116164wiu.1
        for <linux-nfs@vger.kernel.org>; Thu, 23 Apr 2015 17:27:49 -0700 (PDT)
From: Bernhard Reutner-Fischer <rep.dot.nop@gmail.com>
To: libtirpc-devel@lists.sourceforge.net
Cc: Bernhard Reutner-Fischer <rep.dot.nop@gmail.com>,
        Steve Dickson <SteveD@redhat.com>, linux-nfs@vger.kernel.org
Subject: [PATCH v2 4/7] configure.ac: Allow for disabling NIS
Date: Fri, 24 Apr 2015 02:27:39 +0200
Message-Id: <1429835262-16861-5-git-send-email-rep.dot.nop@gmail.com>
In-Reply-To: <1429835262-16861-1-git-send-email-rep.dot.nop@gmail.com>
References: <1429835262-16861-1-git-send-email-rep.dot.nop@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Yellow Pages might not be available, provide a config knob to disable
it.

Signed-off-by: Bernhard Reutner-Fischer <rep.dot.nop@gmail.com>
---
 configure.ac    | 17 +++++++++++++++++
 src/Makefile.am |  5 ++++-
 src/auth_des.c  | 15 +++++++++++++++
 src/auth_time.c |  3 ++-
 4 files changed, 38 insertions(+), 2 deletions(-)

diff --git a/configure.ac b/configure.ac
index 80dec85..3ebde36 100644
--- a/configure.ac
+++ b/configure.ac
@@ -39,6 +39,23 @@ AC_CHECK_LIB([pthread], [pthread_create])
 AC_CHECK_LIB([nsl], [yp_get_default_domain])
 AC_CHECK_FUNCS([getrpcbyname getrpcbynumber])
 
+AC_ARG_ENABLE([nis],
+	[AC_HELP_STRING([--disable-nis],
+		[Disable Yellow Pages (NIS) support @<:@default=no@:>@])],
+	[],[enable_nis=yes])
+if test "x$enable_nis" != xno; then
+	AC_CHECK_HEADERS([rpcsvc/nis.h])
+	if test "x$ac_cv_header_rpcsvc_nis_h" != xyes; then
+		AC_WARN([NIS enabled but no rpcsvc/nis.h header found])
+		AC_WARN([Turning off NIS / YP support])
+		enable_nis="no"
+	fi
+fi
+if test "x$enable_nis" != xno; then
+	AC_DEFINE([YP], [1], [Define to 1 if NIS is available])
+fi
+AM_CONDITIONAL([YP], [test "x$enable_nis" != xno])
+
 AC_CONFIG_FILES([Makefile src/Makefile man/Makefile doc/Makefile])
 AC_OUTPUT(libtirpc.pc)
 
diff --git a/src/Makefile.am b/src/Makefile.am
index 38d0c3d..2ba4444 100644
--- a/src/Makefile.am
+++ b/src/Makefile.am
@@ -52,7 +52,7 @@ libtirpc_la_SOURCES = auth_none.c auth_unix.c authunix_prot.c bindresvport.c cln
         rpc_callmsg.c rpc_generic.c rpc_soc.c rpcb_clnt.c rpcb_prot.c \
         rpcb_st_xdr.c svc.c svc_auth.c svc_dg.c svc_auth_unix.c svc_auth_none.c \
         svc_generic.c svc_raw.c svc_run.c svc_simple.c svc_vc.c getpeereid.c \
-        auth_time.c debug.c
+        debug.c
 
 ## XDR
 libtirpc_la_SOURCES += xdr.c xdr_rec.c xdr_array.c xdr_float.c xdr_mem.c xdr_reference.c xdr_stdio.c
@@ -70,6 +70,9 @@ if AUTHDES
     libtirpc_la_CFLAGS += -DHAVE_AUTHDES
 endif
 
+if YP
+    libtirpc_la_SOURCES += auth_time.c
+endif
 
 ## libtirpc_a_SOURCES += key_call.c key_prot_xdr.c getpublickey.c
 ## libtirpc_a_SOURCES += netname.c netnamer.c rpcdname.c \
diff --git a/src/auth_des.c b/src/auth_des.c
index f8749b0..f971481 100644
--- a/src/auth_des.c
+++ b/src/auth_des.c
@@ -47,7 +47,9 @@
 #include <rpc/xdr.h>
 #include <sys/socket.h>
 #undef NIS
+#ifdef HAVE_RPCSVC_NIS_H
 #include <rpcsvc/nis.h>
+#endif
 
 #if defined(LIBC_SCCS) && !defined(lint)
 #endif
@@ -66,8 +68,13 @@ extern bool_t xdr_authdes_cred( XDR *, struct authdes_cred *);
 extern bool_t xdr_authdes_verf( XDR *, struct authdes_verf *);
 extern int key_encryptsession_pk( char *, netobj *, des_block *);
 
+#ifdef YP
 extern bool_t __rpc_get_time_offset(struct timeval *, nis_server *, char *,
 	char **, char **);
+#else
+# define __rpc_get_time_offset(__a,__b,__c,__d, __e) (1) /* always valid */
+# define nis_server char
+#endif
 
 /* 
  * DES authenticator operations vector
@@ -101,7 +108,9 @@ struct ad_private {
 	u_char ad_pkey[1024];		/* Server's actual public key */
 	char *ad_netid;			/* Timehost netid */
 	char *ad_uaddr;			/* Timehost uaddr */
+#ifdef YP
 	nis_server *ad_nis_srvr;	/* NIS+ server struct */
+#endif
 };
 
 AUTH *authdes_pk_seccreate(const char *, netobj *, u_int, const char *,
@@ -169,7 +178,9 @@ authdes_pk_seccreate(const char *servername, netobj *pkey, u_int window,
 	ad->ad_timehost = NULL;
 	ad->ad_netid = NULL;
 	ad->ad_uaddr = NULL;
+#ifdef YP
 	ad->ad_nis_srvr = NULL;
+#endif
 	ad->ad_timediff.tv_sec = 0;
 	ad->ad_timediff.tv_usec = 0;
 	memcpy(ad->ad_pkey, pkey->n_bytes, pkey->n_len);
@@ -192,9 +203,11 @@ authdes_pk_seccreate(const char *servername, netobj *pkey, u_int window,
 		}
 		memcpy(ad->ad_timehost, timehost, strlen(timehost) + 1);
 		ad->ad_dosync = TRUE;
+#ifdef YP
 	} else if (srvr != NULL) {
 		ad->ad_nis_srvr = srvr;	/* transient */
 		ad->ad_dosync = TRUE;
+#endif
 	} else {
 		ad->ad_dosync = FALSE;
 	}
@@ -222,7 +235,9 @@ authdes_pk_seccreate(const char *servername, netobj *pkey, u_int window,
 	if (!authdes_refresh(auth, NULL)) {
 		goto failed;
 	}
+#ifdef YP
 	ad->ad_nis_srvr = NULL; /* not needed any longer */
+#endif
 	auth_get(auth);		/* Reference for caller */
 	return (auth);
 
diff --git a/src/auth_time.c b/src/auth_time.c
index 10e58eb..e47ece8 100644
--- a/src/auth_time.c
+++ b/src/auth_time.c
@@ -45,8 +45,9 @@
 //#include <clnt_soc.h>
 #include <sys/select.h>
 #undef NIS
+#ifdef HAVE_RPCSVC_NIS_H
 #include <rpcsvc/nis.h>
-
+#endif
 
 #ifdef TESTING
 #define	msg(x)	printf("ERROR: %s\n", x)
-- 
2.1.4

