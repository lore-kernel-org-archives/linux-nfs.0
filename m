Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:34272 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752049AbdFNPSm (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 14 Jun 2017 11:18:42 -0400
Subject: [PATCH 22/27] NFS: Add a small buffer in nfs_fs_context to avoid
 string dup [ver #5]
From: David Howells <dhowells@redhat.com>
To: mszeredi@redhat.com, viro@zeniv.linux.org.uk
Cc: linux-nfs@vger.kernel.org, jlayton@redhat.com,
        linux-kernel@vger.kernel.org, dhowells@redhat.com,
        linux-security-module@vger.kernel.org,
        linux-fsdevel@vger.kernel.org
Date: Wed, 14 Jun 2017 16:18:34 +0100
Message-ID: <149745351477.10897.3038422602772913461.stgit@warthog.procyon.org.uk>
In-Reply-To: <149745330648.10897.9605870130502083184.stgit@warthog.procyon.org.uk>
References: <149745330648.10897.9605870130502083184.stgit@warthog.procyon.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Add a small buffer in nfs_fs_context to avoid string duplication when
parsing numbers.  Also make the parsing function wrapper place the parsed
integer directly in the appropriate nfs_fs_context struct member.

Signed-off-by: David Howells <dhowells@redhat.com>
---

 fs/nfs/fs_context.c |   83 ++++++++++++++++++---------------------------------
 fs/nfs/internal.h   |    2 +
 2 files changed, 32 insertions(+), 53 deletions(-)

diff --git a/fs/nfs/fs_context.c b/fs/nfs/fs_context.c
index a2ff9c30ff5a..763a09b64971 100644
--- a/fs/nfs/fs_context.c
+++ b/fs/nfs/fs_context.c
@@ -466,27 +466,22 @@ static int nfs_get_option_str(substring_t args[], char **option)
 	return !*option;
 }
 
-static int nfs_get_option_ul(substring_t args[], unsigned long *option)
+static int nfs_get_option_ui(struct nfs_fs_context *ctx,
+			     substring_t args[], unsigned int *option)
 {
-	int rc;
-	char *string;
-
-	string = match_strdup(args);
-	if (string == NULL)
-		return -ENOMEM;
-	rc = kstrtoul(string, 10, option);
-	kfree(string);
-
-	return rc;
+	match_strlcpy(ctx->buf, args, sizeof(ctx->buf));
+	return kstrtouint(ctx->buf, 10, option);
 }
 
-static int nfs_get_option_ul_bound(substring_t args[], unsigned long *option,
-		unsigned long l_bound, unsigned long u_bound)
+static int nfs_get_option_ui_bound(struct nfs_fs_context *ctx,
+				   substring_t args[], unsigned int *option,
+				   unsigned int l_bound, unsigned u_bound)
 {
 	int ret;
 
-	ret = nfs_get_option_ul(args, option);
-	if (ret != 0)
+	match_strlcpy(ctx->buf, args, sizeof(ctx->buf));
+	ret = kstrtouint(ctx->buf, 10, option);
+	if (ret < 0)
 		return ret;
 	if (*option < l_bound || *option > u_bound)
 		return -ERANGE;
@@ -499,7 +494,6 @@ static int nfs_get_option_ul_bound(substring_t args[], unsigned long *option,
 static int nfs_fs_context_parse_option(struct nfs_fs_context *ctx, char *p)
 {
 	substring_t args[MAX_OPT_ARGS];
-	unsigned long option;
 	char *string;
 	int rc, token;
 
@@ -507,7 +501,6 @@ static int nfs_fs_context_parse_option(struct nfs_fs_context *ctx, char *p)
 
 	token = match_token(p, nfs_mount_option_tokens, args);
 	switch (token) {
-
 		/*
 		 * boolean options:  foo/nofoo
 		 */
@@ -603,86 +596,70 @@ static int nfs_fs_context_parse_option(struct nfs_fs_context *ctx, char *p)
 		 * options that take numeric values
 		 */
 	case Opt_port:
-		if (nfs_get_option_ul(args, &option) ||
-		    option > USHRT_MAX)
+		if (nfs_get_option_ui_bound(ctx, args, &ctx->nfs_server.port,
+					    0, USHRT_MAX))
 			goto out_invalid_value;
-		ctx->nfs_server.port = option;
 		break;
 	case Opt_rsize:
-		if (nfs_get_option_ul(args, &option))
+		if (nfs_get_option_ui(ctx, args, &ctx->rsize))
 			goto out_invalid_value;
-		ctx->rsize = option;
 		break;
 	case Opt_wsize:
-		if (nfs_get_option_ul(args, &option))
+		if (nfs_get_option_ui(ctx, args, &ctx->wsize))
 			goto out_invalid_value;
-		ctx->wsize = option;
 		break;
 	case Opt_bsize:
-		if (nfs_get_option_ul(args, &option))
+		if (nfs_get_option_ui(ctx, args, &ctx->bsize))
 			goto out_invalid_value;
-		ctx->bsize = option;
 		break;
 	case Opt_timeo:
-		if (nfs_get_option_ul_bound(args, &option, 1, INT_MAX))
+		if (nfs_get_option_ui_bound(ctx, args, &ctx->timeo, 1, INT_MAX))
 			goto out_invalid_value;
-		ctx->timeo = option;
 		break;
 	case Opt_retrans:
-		if (nfs_get_option_ul_bound(args, &option, 0, INT_MAX))
+		if (nfs_get_option_ui_bound(ctx, args, &ctx->retrans, 0, INT_MAX))
 			goto out_invalid_value;
-		ctx->retrans = option;
 		break;
 	case Opt_acregmin:
-		if (nfs_get_option_ul(args, &option))
+		if (nfs_get_option_ui(ctx, args, &ctx->acregmin))
 			goto out_invalid_value;
-		ctx->acregmin = option;
 		break;
 	case Opt_acregmax:
-		if (nfs_get_option_ul(args, &option))
+		if (nfs_get_option_ui(ctx, args, &ctx->acregmax))
 			goto out_invalid_value;
-		ctx->acregmax = option;
 		break;
 	case Opt_acdirmin:
-		if (nfs_get_option_ul(args, &option))
+		if (nfs_get_option_ui(ctx, args, &ctx->acdirmin))
 			goto out_invalid_value;
-		ctx->acdirmin = option;
 		break;
 	case Opt_acdirmax:
-		if (nfs_get_option_ul(args, &option))
+		if (nfs_get_option_ui(ctx, args, &ctx->acdirmax))
 			goto out_invalid_value;
-		ctx->acdirmax = option;
 		break;
 	case Opt_actimeo:
-		if (nfs_get_option_ul(args, &option))
+		if (nfs_get_option_ui(ctx, args, &ctx->acdirmax))
 			goto out_invalid_value;
 		ctx->acregmin = ctx->acregmax =
-			ctx->acdirmin = ctx->acdirmax = option;
+			ctx->acdirmin = ctx->acdirmax;
 		break;
 	case Opt_namelen:
-		if (nfs_get_option_ul(args, &option))
+		if (nfs_get_option_ui(ctx, args, &ctx->namlen))
 			goto out_invalid_value;
-		ctx->namlen = option;
 		break;
 	case Opt_mountport:
-		if (nfs_get_option_ul(args, &option) ||
-		    option > USHRT_MAX)
+		if (nfs_get_option_ui_bound(ctx, args, &ctx->mount_server.port,
+					    0, USHRT_MAX))
 			goto out_invalid_value;
-		ctx->mount_server.port = option;
 		break;
 	case Opt_mountvers:
-		if (nfs_get_option_ul(args, &option) ||
-		    option < NFS_MNT_VERSION ||
-		    option > NFS_MNT3_VERSION)
+		if (nfs_get_option_ui_bound(ctx, args, &ctx->mount_server.version,
+					    NFS_MNT_VERSION, NFS_MNT3_VERSION))
 			goto out_invalid_value;
-		ctx->mount_server.version = option;
 		break;
 	case Opt_minorversion:
-		if (nfs_get_option_ul(args, &option))
-			goto out_invalid_value;
-		if (option > NFS4_MAX_MINOR_VERSION)
+		if (nfs_get_option_ui_bound(ctx, args, &ctx->minorversion,
+					    0, NFS4_MAX_MINOR_VERSION))
 			goto out_invalid_value;
-		ctx->minorversion = option;
 		break;
 
 		/*
diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
index fab0fca9e0ef..1c5404d846cc 100644
--- a/fs/nfs/internal.h
+++ b/fs/nfs/internal.h
@@ -125,6 +125,8 @@ struct nfs_fs_context {
 
 	struct security_mnt_opts lsm_opts;
 	struct net		*net;
+
+	char			buf[32];	/* Parse buffer */
 };
 
 /* mount_clnt.c */

