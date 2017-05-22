Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:57482 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S935582AbdEVPyr (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 22 May 2017 11:54:47 -0400
Subject: [PATCH 21/23] NFS: Add a small buffer in nfs_sb_config to avoid
 string dup [ver #4]
From: David Howells <dhowells@redhat.com>
To: mszeredi@redhat.com, viro@zeniv.linux.org.uk, jlayton@redhat.com
Cc: dhowells@redhat.com, linux-fsdevel@vger.kernel.org,
        linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Date: Mon, 22 May 2017 16:54:39 +0100
Message-ID: <149546847981.9289.12051666635401926702.stgit@warthog.procyon.org.uk>
In-Reply-To: <149546825563.9289.9065118651584207610.stgit@warthog.procyon.org.uk>
References: <149546825563.9289.9065118651584207610.stgit@warthog.procyon.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Add a small buffer in nfs_sb_config to avoid string duplication when
parsing numbers.  Also make the parsing function wrapper place the parsed
integer directly in the appropriate nfs_sb_config struct member.

Sigend-off-by: David Howells <dhowells@redhat.com>
---

 fs/nfs/internal.h |    2 +
 fs/nfs/mount.c    |   83 +++++++++++++++++++----------------------------------
 2 files changed, 32 insertions(+), 53 deletions(-)

diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
index ed255241baa7..52242240933f 100644
--- a/fs/nfs/internal.h
+++ b/fs/nfs/internal.h
@@ -125,6 +125,8 @@ struct nfs_sb_config {
 
 	struct security_mnt_opts lsm_opts;
 	struct net		*net;
+
+	char			buf[32];	/* Parse buffer */
 };
 
 /* mount_clnt.c */
diff --git a/fs/nfs/mount.c b/fs/nfs/mount.c
index 8296f2f84dc7..e5593070422d 100644
--- a/fs/nfs/mount.c
+++ b/fs/nfs/mount.c
@@ -466,27 +466,22 @@ static int nfs_get_option_str(substring_t args[], char **option)
 	return !*option;
 }
 
-static int nfs_get_option_ul(substring_t args[], unsigned long *option)
+static int nfs_get_option_ui(struct nfs_sb_config *cfg,
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
+	match_strlcpy(cfg->buf, args, sizeof(cfg->buf));
+	return kstrtouint(cfg->buf, 10, option);
 }
 
-static int nfs_get_option_ul_bound(substring_t args[], unsigned long *option,
-		unsigned long l_bound, unsigned long u_bound)
+static int nfs_get_option_ui_bound(struct nfs_sb_config *cfg,
+				   substring_t args[], unsigned int *option,
+				   unsigned int l_bound, unsigned u_bound)
 {
 	int ret;
 
-	ret = nfs_get_option_ul(args, option);
-	if (ret != 0)
+	match_strlcpy(cfg->buf, args, sizeof(cfg->buf));
+	ret = kstrtouint(cfg->buf, 10, option);
+	if (ret < 0)
 		return ret;
 	if (*option < l_bound || *option > u_bound)
 		return -ERANGE;
@@ -499,7 +494,6 @@ static int nfs_get_option_ul_bound(substring_t args[], unsigned long *option,
 static int nfs_sb_config_parse_option(struct nfs_sb_config *cfg, char *p)
 {
 	substring_t args[MAX_OPT_ARGS];
-	unsigned long option;
 	char *string;
 	int rc, token;
 
@@ -507,7 +501,6 @@ static int nfs_sb_config_parse_option(struct nfs_sb_config *cfg, char *p)
 
 	token = match_token(p, nfs_mount_option_tokens, args);
 	switch (token) {
-
 		/*
 		 * boolean options:  foo/nofoo
 		 */
@@ -603,86 +596,70 @@ static int nfs_sb_config_parse_option(struct nfs_sb_config *cfg, char *p)
 		 * options that take numeric values
 		 */
 	case Opt_port:
-		if (nfs_get_option_ul(args, &option) ||
-		    option > USHRT_MAX)
+		if (nfs_get_option_ui_bound(cfg, args, &cfg->nfs_server.port,
+					    0, USHRT_MAX))
 			goto out_invalid_value;
-		cfg->nfs_server.port = option;
 		break;
 	case Opt_rsize:
-		if (nfs_get_option_ul(args, &option))
+		if (nfs_get_option_ui(cfg, args, &cfg->rsize))
 			goto out_invalid_value;
-		cfg->rsize = option;
 		break;
 	case Opt_wsize:
-		if (nfs_get_option_ul(args, &option))
+		if (nfs_get_option_ui(cfg, args, &cfg->wsize))
 			goto out_invalid_value;
-		cfg->wsize = option;
 		break;
 	case Opt_bsize:
-		if (nfs_get_option_ul(args, &option))
+		if (nfs_get_option_ui(cfg, args, &cfg->bsize))
 			goto out_invalid_value;
-		cfg->bsize = option;
 		break;
 	case Opt_timeo:
-		if (nfs_get_option_ul_bound(args, &option, 1, INT_MAX))
+		if (nfs_get_option_ui_bound(cfg, args, &cfg->timeo, 1, INT_MAX))
 			goto out_invalid_value;
-		cfg->timeo = option;
 		break;
 	case Opt_retrans:
-		if (nfs_get_option_ul_bound(args, &option, 0, INT_MAX))
+		if (nfs_get_option_ui_bound(cfg, args, &cfg->retrans, 0, INT_MAX))
 			goto out_invalid_value;
-		cfg->retrans = option;
 		break;
 	case Opt_acregmin:
-		if (nfs_get_option_ul(args, &option))
+		if (nfs_get_option_ui(cfg, args, &cfg->acregmin))
 			goto out_invalid_value;
-		cfg->acregmin = option;
 		break;
 	case Opt_acregmax:
-		if (nfs_get_option_ul(args, &option))
+		if (nfs_get_option_ui(cfg, args, &cfg->acregmax))
 			goto out_invalid_value;
-		cfg->acregmax = option;
 		break;
 	case Opt_acdirmin:
-		if (nfs_get_option_ul(args, &option))
+		if (nfs_get_option_ui(cfg, args, &cfg->acdirmin))
 			goto out_invalid_value;
-		cfg->acdirmin = option;
 		break;
 	case Opt_acdirmax:
-		if (nfs_get_option_ul(args, &option))
+		if (nfs_get_option_ui(cfg, args, &cfg->acdirmax))
 			goto out_invalid_value;
-		cfg->acdirmax = option;
 		break;
 	case Opt_actimeo:
-		if (nfs_get_option_ul(args, &option))
+		if (nfs_get_option_ui(cfg, args, &cfg->acdirmax))
 			goto out_invalid_value;
 		cfg->acregmin = cfg->acregmax =
-			cfg->acdirmin = cfg->acdirmax = option;
+			cfg->acdirmin = cfg->acdirmax;
 		break;
 	case Opt_namelen:
-		if (nfs_get_option_ul(args, &option))
+		if (nfs_get_option_ui(cfg, args, &cfg->namlen))
 			goto out_invalid_value;
-		cfg->namlen = option;
 		break;
 	case Opt_mountport:
-		if (nfs_get_option_ul(args, &option) ||
-		    option > USHRT_MAX)
+		if (nfs_get_option_ui_bound(cfg, args, &cfg->mount_server.port,
+					    0, USHRT_MAX))
 			goto out_invalid_value;
-		cfg->mount_server.port = option;
 		break;
 	case Opt_mountvers:
-		if (nfs_get_option_ul(args, &option) ||
-		    option < NFS_MNT_VERSION ||
-		    option > NFS_MNT3_VERSION)
+		if (nfs_get_option_ui_bound(cfg, args, &cfg->mount_server.version,
+					    NFS_MNT_VERSION, NFS_MNT3_VERSION))
 			goto out_invalid_value;
-		cfg->mount_server.version = option;
 		break;
 	case Opt_minorversion:
-		if (nfs_get_option_ul(args, &option))
-			goto out_invalid_value;
-		if (option > NFS4_MAX_MINOR_VERSION)
+		if (nfs_get_option_ui_bound(cfg, args, &cfg->minorversion,
+					    0, NFS4_MAX_MINOR_VERSION))
 			goto out_invalid_value;
-		cfg->minorversion = option;
 		break;
 
 		/*

