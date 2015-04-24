Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-wi0-f172.google.com ([209.85.212.172]:33660 "EHLO
	mail-wi0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S966432AbbDXA1w (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 23 Apr 2015 20:27:52 -0400
Received: by wiax7 with SMTP id x7so23748914wia.0
        for <linux-nfs@vger.kernel.org>; Thu, 23 Apr 2015 17:27:51 -0700 (PDT)
From: Bernhard Reutner-Fischer <rep.dot.nop@gmail.com>
To: libtirpc-devel@lists.sourceforge.net
Cc: Bernhard Reutner-Fischer <rep.dot.nop@gmail.com>,
        Steve Dickson <SteveD@redhat.com>, linux-nfs@vger.kernel.org
Subject: [PATCH v2 7/7] headers: if 0 out some unbuilt functions
Date: Fri, 24 Apr 2015 02:27:42 +0200
Message-Id: <1429835262-16861-8-git-send-email-rep.dot.nop@gmail.com>
In-Reply-To: <1429835262-16861-1-git-send-email-rep.dot.nop@gmail.com>
References: <1429835262-16861-1-git-send-email-rep.dot.nop@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Bernhard Reutner-Fischer <rep.dot.nop@gmail.com>
---
 tirpc/rpc/auth.h     | 8 +++++++-
 tirpc/rpc/auth_des.h | 2 ++
 2 files changed, 9 insertions(+), 1 deletion(-)

diff --git a/tirpc/rpc/auth.h b/tirpc/rpc/auth.h
index 1b6c699..b7b7943 100644
--- a/tirpc/rpc/auth.h
+++ b/tirpc/rpc/auth.h
@@ -377,13 +377,17 @@ extern void passwd2des ( char *, char * );
 #ifdef __cplusplus
 extern "C" {
 #endif
+#if 0
 extern int key_decryptsession(const char *, des_block *);
 extern int key_encryptsession(const char *, des_block *);
+#endif
 #ifdef HAVE_AUTHDES
 extern int key_gendes(des_block *);
 #endif /* HAVE_AUTHDES */
+#if 0
 extern int key_setsecret(const char *);
 extern int key_secretkey_is_set(void);
+#endif
 #ifdef __cplusplus
 }
 #endif
@@ -394,9 +398,11 @@ extern int key_secretkey_is_set(void);
 #ifdef __cplusplus
 extern "C" {
 #endif
+#if 0
 extern int getpublickey (const char *, char *);
 extern int getpublicandprivatekey (char *, char *);
-extern int getsecretkey (char *, char *, char *);
+//extern int getsecretkey (char *, char *, char *);
+#endif
 #ifdef __cplusplus
 }
 #endif
diff --git a/tirpc/rpc/auth_des.h b/tirpc/rpc/auth_des.h
index 77e169d..b157806 100644
--- a/tirpc/rpc/auth_des.h
+++ b/tirpc/rpc/auth_des.h
@@ -127,8 +127,10 @@ extern "C" {
 #endif
 extern bool_t	xdr_authdes_cred(XDR *, struct authdes_cred *);
 extern bool_t	xdr_authdes_verf(XDR *, struct authdes_verf *);
+#if 0
 extern int	rtime(dev_t, struct netbuf *, int, struct timeval *,
 		    struct timeval *);
+#endif
 extern void	kgetnetname(char *);
 extern enum auth_stat _svcauth_des(struct svc_req *, struct rpc_msg *);
 #ifdef __cplusplus
-- 
2.1.4

