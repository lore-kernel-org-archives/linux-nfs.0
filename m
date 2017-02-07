Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f67.google.com ([209.85.214.67]:33148 "EHLO
        mail-it0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753825AbdBGNsU (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 7 Feb 2017 08:48:20 -0500
Received: by mail-it0-f67.google.com with SMTP id e137so12313652itc.0
        for <linux-nfs@vger.kernel.org>; Tue, 07 Feb 2017 05:48:20 -0800 (PST)
Subject: [PATCH 3/7] sunrpc: rename NFS_NGROUPS to UNX_NGROUPS for auth unix
To: "J. Bruce Fields" <bfields@fieldses.org>, linux-nfs@vger.kernel.org
References: <59432847-8e45-4423-c441-0c67ee645f38@gmail.com>
Cc: Trond Myklebust <trond.myklebust@primarydata.com>,
        Kinglong Mee <kinglongmee@gmail.com>
From: Kinglong Mee <kinglongmee@gmail.com>
Message-ID: <4852ccc0-52a9-ae62-7bf2-18138615c7d0@gmail.com>
Date: Tue, 7 Feb 2017 21:48:11 +0800
MIME-Version: 1.0
In-Reply-To: <59432847-8e45-4423-c441-0c67ee645f38@gmail.com>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

NFS_NGROUPS has been move to sunrpc, rename to UNX_NGROUPS.

Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>
---
 include/linux/sunrpc/auth.h |  1 +
 net/sunrpc/auth_unix.c      | 18 ++++++++----------
 net/sunrpc/svcauth_unix.c   |  4 ++--
 3 files changed, 11 insertions(+), 12 deletions(-)

diff --git a/include/linux/sunrpc/auth.h b/include/linux/sunrpc/auth.h
index b1bc62b..39c85fb 100644
--- a/include/linux/sunrpc/auth.h
+++ b/include/linux/sunrpc/auth.h
@@ -32,6 +32,7 @@
  */
 #define UNX_MAXNODENAME	__NEW_UTS_LEN
 #define UNX_CALLSLACK	(21 + XDR_QUADLEN(UNX_MAXNODENAME))
+#define UNX_NGROUPS	16
 
 struct rpcsec_gss_info;
 
diff --git a/net/sunrpc/auth_unix.c b/net/sunrpc/auth_unix.c
index 306fc0f..82337e1 100644
--- a/net/sunrpc/auth_unix.c
+++ b/net/sunrpc/auth_unix.c
@@ -14,12 +14,10 @@
 #include <linux/sunrpc/auth.h>
 #include <linux/user_namespace.h>
 
-#define NFS_NGROUPS	16
-
 struct unx_cred {
 	struct rpc_cred		uc_base;
 	kgid_t			uc_gid;
-	kgid_t			uc_gids[NFS_NGROUPS];
+	kgid_t			uc_gids[UNX_NGROUPS];
 };
 #define uc_uid			uc_base.cr_uid
 
@@ -82,13 +80,13 @@ unx_create_cred(struct rpc_auth *auth, struct auth_cred *acred, int flags, gfp_t
 
 	if (acred->group_info != NULL)
 		groups = acred->group_info->ngroups;
-	if (groups > NFS_NGROUPS)
-		groups = NFS_NGROUPS;
+	if (groups > UNX_NGROUPS)
+		groups = UNX_NGROUPS;
 
 	cred->uc_gid = acred->gid;
 	for (i = 0; i < groups; i++)
 		cred->uc_gids[i] = acred->group_info->gid[i];
-	if (i < NFS_NGROUPS)
+	if (i < UNX_NGROUPS)
 		cred->uc_gids[i] = INVALID_GID;
 
 	return &cred->uc_base;
@@ -132,12 +130,12 @@ unx_match(struct auth_cred *acred, struct rpc_cred *rcred, int flags)
 
 	if (acred->group_info != NULL)
 		groups = acred->group_info->ngroups;
-	if (groups > NFS_NGROUPS)
-		groups = NFS_NGROUPS;
+	if (groups > UNX_NGROUPS)
+		groups = UNX_NGROUPS;
 	for (i = 0; i < groups ; i++)
 		if (!gid_eq(cred->uc_gids[i], acred->group_info->gid[i]))
 			return 0;
-	if (groups < NFS_NGROUPS && gid_valid(cred->uc_gids[groups]))
+	if (groups < UNX_NGROUPS && gid_valid(cred->uc_gids[groups]))
 		return 0;
 	return 1;
 }
@@ -166,7 +164,7 @@ unx_marshal(struct rpc_task *task, __be32 *p)
 	*p++ = htonl((u32) from_kuid(&init_user_ns, cred->uc_uid));
 	*p++ = htonl((u32) from_kgid(&init_user_ns, cred->uc_gid));
 	hold = p++;
-	for (i = 0; i < 16 && gid_valid(cred->uc_gids[i]); i++)
+	for (i = 0; i < UNX_NGROUPS && gid_valid(cred->uc_gids[i]); i++)
 		*p++ = htonl((u32) from_kgid(&init_user_ns, cred->uc_gids[i]));
 	*hold = htonl(p - hold - 1);		/* gid array length */
 	*base = htonl((p - base - 1) << 2);	/* cred length */
diff --git a/net/sunrpc/svcauth_unix.c b/net/sunrpc/svcauth_unix.c
index 64af4f0..f81eaa8 100644
--- a/net/sunrpc/svcauth_unix.c
+++ b/net/sunrpc/svcauth_unix.c
@@ -403,7 +403,7 @@ svcauth_unix_info_release(struct svc_xprt *xpt)
 /****************************************************************************
  * auth.unix.gid cache
  * simple cache to map a UID to a list of GIDs
- * because AUTH_UNIX aka AUTH_SYS has a max of 16
+ * because AUTH_UNIX aka AUTH_SYS has a max of UNX_NGROUPS
  */
 #define	GID_HASHBITS	8
 #define	GID_HASHMAX	(1<<GID_HASHBITS)
@@ -810,7 +810,7 @@ svcauth_unix_accept(struct svc_rqst *rqstp, __be32 *authp)
 	cred->cr_uid = make_kuid(&init_user_ns, svc_getnl(argv)); /* uid */
 	cred->cr_gid = make_kgid(&init_user_ns, svc_getnl(argv)); /* gid */
 	slen = svc_getnl(argv);			/* gids length */
-	if (slen > 16 || (len -= (slen + 2)*4) < 0)
+	if (slen > UNX_NGROUPS || (len -= (slen + 2)*4) < 0)
 		goto badcred;
 	cred->cr_group_info = groups_alloc(slen);
 	if (cred->cr_group_info == NULL)
-- 
2.9.3

