Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-wi0-f182.google.com ([209.85.212.182]:38454 "EHLO
	mail-wi0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934223AbbDXA1v (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 23 Apr 2015 20:27:51 -0400
Received: by wiun10 with SMTP id n10so3116302wiu.1
        for <linux-nfs@vger.kernel.org>; Thu, 23 Apr 2015 17:27:50 -0700 (PDT)
From: Bernhard Reutner-Fischer <rep.dot.nop@gmail.com>
To: libtirpc-devel@lists.sourceforge.net
Cc: Bernhard Reutner-Fischer <rep.dot.nop@gmail.com>,
        Steve Dickson <SteveD@redhat.com>, linux-nfs@vger.kernel.org
Subject: [PATCH v2 5/7] configure.ac: Allow for disabling auth DES
Date: Fri, 24 Apr 2015 02:27:40 +0200
Message-Id: <1429835262-16861-6-git-send-email-rep.dot.nop@gmail.com>
In-Reply-To: <1429835262-16861-1-git-send-email-rep.dot.nop@gmail.com>
References: <1429835262-16861-1-git-send-email-rep.dot.nop@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

DES encryption might not be available.

Signed-off-by: Bernhard Reutner-Fischer <rep.dot.nop@gmail.com>
---
 Makefile.am      | 12 ++++++++----
 configure.ac     |  7 ++++++-
 libtirpc.pc.in   |  2 +-
 src/Makefile.am  |  1 -
 src/rpc_soc.c    |  2 +-
 tirpc/rpc/auth.h | 10 ++++++++++
 tirpc/rpc/rpc.h  |  2 ++
 7 files changed, 28 insertions(+), 8 deletions(-)

diff --git a/Makefile.am b/Makefile.am
index 9b812eb..e588ae0 100644
--- a/Makefile.am
+++ b/Makefile.am
@@ -27,17 +27,21 @@ nobase_include_HEADERS = tirpc/netconfig.h \
 			 tirpc/rpc/pmap_prot.h \
 			 tirpc/rpc/pmap_clnt.h \
 			 tirpc/rpc/nettype.h \
-			 tirpc/rpc/des.h \
-			 tirpc/rpc/des_crypt.h \
 			 tirpc/rpc/clnt_stat.h \
 			 tirpc/rpc/clnt_soc.h \
 			 tirpc/rpc/clnt.h \
 			 tirpc/rpc/auth_unix.h \
 			 tirpc/rpc/auth_kerb.h \
 			 tirpc/rpc/auth.h \
-			 tirpc/rpc/auth_gss.h \
+			 tirpc/rpc/auth_gss.h
+
+if AUTHDES
+nobase_include_HEADERS += \
+			 tirpc/rpc/des.h \
+			 tirpc/rpc/des_crypt.h \
 			 tirpc/rpc/auth_des.h
-    
+endif
+
 pkgconfigdir=$(libdir)/pkgconfig
 pkgconfig_DATA = libtirpc.pc
 
diff --git a/configure.ac b/configure.ac
index 3ebde36..bcc794e 100644
--- a/configure.ac
+++ b/configure.ac
@@ -20,6 +20,12 @@ AC_ARG_ENABLE(authdes,
 	[AC_HELP_STRING([--disable-authdes], [Disable DES authentication @<:@default=no@:>@])],
       [],[enable_authdes=yes])
 AM_CONDITIONAL(AUTHDES, test x$enable_authdes = xyes)
+if test x$enable_authdes = xyes; then
+	AC_DEFINE([HAVE_AUTHDES], [1],
+		  [Define to 1 if DES authentication is enabled])
+	CFLAG_AUTHDES="-DHAVE_AUTHDES=1"
+	AC_SUBST([CFLAG_AUTHDES])
+fi
 
 AC_ARG_ENABLE(ipv6,
 	[AC_HELP_STRING([--disable-ipv6], [Disable IPv6 support @<:@default=no@:>@])],
@@ -59,4 +65,3 @@ AM_CONDITIONAL([YP], [test "x$enable_nis" != xno])
 AC_CONFIG_FILES([Makefile src/Makefile man/Makefile doc/Makefile])
 AC_OUTPUT(libtirpc.pc)
 
-
diff --git a/libtirpc.pc.in b/libtirpc.pc.in
index 38034c5..ebbc66f 100644
--- a/libtirpc.pc.in
+++ b/libtirpc.pc.in
@@ -9,4 +9,4 @@ Requires:
 Version: @PACKAGE_VERSION@
 Libs: -L@libdir@ -ltirpc
 Libs.private: -lpthread
-Cflags: -I@includedir@/tirpc
+Cflags: -I@includedir@/tirpc @CFLAG_AUTHDES@
diff --git a/src/Makefile.am b/src/Makefile.am
index 2ba4444..081c2bd 100644
--- a/src/Makefile.am
+++ b/src/Makefile.am
@@ -67,7 +67,6 @@ endif
 ## DES authentication
 if AUTHDES
     libtirpc_la_SOURCES += auth_des.c authdes_prot.c
-    libtirpc_la_CFLAGS += -DHAVE_AUTHDES
 endif
 
 if YP
diff --git a/src/rpc_soc.c b/src/rpc_soc.c
index 6574323..1e2f4d6 100644
--- a/src/rpc_soc.c
+++ b/src/rpc_soc.c
@@ -520,7 +520,7 @@ clnt_broadcast(prog, vers, proc, xargs, argsp, xresults, resultsp, eachresult)
 	    (resultproc_t) rpc_wrap_bcast, "udp");
 }
 
-#if HAVE_AUTHDES
+#ifdef HAVE_AUTHDES
 /*
  * Create the client des authentication object. Obsoleted by
  * authdes_seccreate().
diff --git a/tirpc/rpc/auth.h b/tirpc/rpc/auth.h
index 434d35c..1b6c699 100644
--- a/tirpc/rpc/auth.h
+++ b/tirpc/rpc/auth.h
@@ -163,6 +163,8 @@ union des_block {
 	char c[8];
 };
 typedef union des_block des_block;
+
+#ifdef HAVE_AUTHDES
 #ifdef __cplusplus
 extern "C" {
 #endif
@@ -170,6 +172,7 @@ extern bool_t xdr_des_block(XDR *, des_block *);
 #ifdef __cplusplus
 }
 #endif
+#endif /* HAVE_AUTHDES */
 
 /*
  * Authentication info.  Opaque to client.
@@ -316,6 +319,8 @@ extern AUTH *authnone_create(void);		/* takes no parameters */
 #ifdef __cplusplus
 }
 #endif
+
+#ifdef HAVE_AUTHDES
 /*
  * DES style authentication
  * AUTH *authsecdes_create(servername, window, timehost, ckey)
@@ -333,6 +338,7 @@ extern AUTH *authdes_seccreate (const char *, const u_int, const  char *,
 #ifdef __cplusplus
 }
 #endif
+#endif /* HAVE_AUTHDES */
 
 #ifdef __cplusplus
 extern "C" {
@@ -356,7 +362,9 @@ extern int host2netname(char *, const char *, const char *);
 extern int user2netname(char *, const uid_t, const char *);
 extern int netname2user(char *, uid_t *, gid_t *, int *, gid_t *);
 extern int netname2host(char *, char *, const int);
+#ifdef HAVE_AUTHDES
 extern void passwd2des ( char *, char * );
+#endif /* HAVE_AUTHDES */
 #ifdef __cplusplus
 }
 #endif
@@ -371,7 +379,9 @@ extern "C" {
 #endif
 extern int key_decryptsession(const char *, des_block *);
 extern int key_encryptsession(const char *, des_block *);
+#ifdef HAVE_AUTHDES
 extern int key_gendes(des_block *);
+#endif /* HAVE_AUTHDES */
 extern int key_setsecret(const char *);
 extern int key_secretkey_is_set(void);
 #ifdef __cplusplus
diff --git a/tirpc/rpc/rpc.h b/tirpc/rpc/rpc.h
index fac2fa9..1dbb391 100644
--- a/tirpc/rpc/rpc.h
+++ b/tirpc/rpc/rpc.h
@@ -52,11 +52,13 @@
 #include <rpc/rpc_msg.h>	/* protocol for rpc messages */
 #include <rpc/auth_unix.h>	/* protocol for unix style cred */
 
+#ifdef HAVE_AUTHDES
 /*
  *  Uncomment-out the next line if you are building the rpc library with
  *  DES Authentication (see the README file in the secure_rpc/ directory).
  */
 #include <rpc/auth_des.h>	/* protocol for des style cred */
+#endif /* HAVE_AUTHDES */
 
 #ifdef HAVE_RPCSEC_GSS
 #include <rpc/auth_gss.h>   /* RPCSEC_GSS */
-- 
2.1.4

