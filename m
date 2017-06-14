Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:43726 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752081AbdFNPS1 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 14 Jun 2017 11:18:27 -0400
Subject: [PATCH 20/27] NFS: Split nfs_parse_mount_options() [ver #5]
From: David Howells <dhowells@redhat.com>
To: mszeredi@redhat.com, viro@zeniv.linux.org.uk
Cc: linux-nfs@vger.kernel.org, jlayton@redhat.com,
        linux-kernel@vger.kernel.org, dhowells@redhat.com,
        linux-security-module@vger.kernel.org,
        linux-fsdevel@vger.kernel.org
Date: Wed, 14 Jun 2017 16:18:18 +0100
Message-ID: <149745349873.10897.555827680472195269.stgit@warthog.procyon.org.uk>
In-Reply-To: <149745330648.10897.9605870130502083184.stgit@warthog.procyon.org.uk>
References: <149745330648.10897.9605870130502083184.stgit@warthog.procyon.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Split nfs_parse_mount_options() to move the prologue, list-splitting and
epilogue into one function and the per-option processing into another.

Signed-off-by: David Howells <dhowells@redhat.com>
---

 fs/nfs/fs_context.c |  143 +++++++++++++++++++++++++++++----------------------
 fs/nfs/internal.h   |    3 +
 2 files changed, 83 insertions(+), 63 deletions(-)

diff --git a/fs/nfs/fs_context.c b/fs/nfs/fs_context.c
index 91e412e68183..e3e431e3a1fc 100644
--- a/fs/nfs/fs_context.c
+++ b/fs/nfs/fs_context.c
@@ -494,46 +494,18 @@ static int nfs_get_option_ul_bound(substring_t args[], unsigned long *option,
 }
 
 /*
- * Error-check and convert a string of mount options from user space into
- * a data structure.  The whole mount string is processed; bad options are
- * skipped as they are encountered.  If there were no errors, return 1;
- * otherwise return 0 (zero).
+ * Parse a single mount option in "key[=val]" form.
  */
-int nfs_parse_mount_options(char *raw, struct nfs_fs_context *ctx)
+static int nfs_fs_context_parse_option(struct nfs_fs_context *ctx, char *p)
 {
-	char *p, *string, *secdata;
-	int rc, sloppy = 0, invalid_option = 0;
-	unsigned short protofamily = AF_UNSPEC;
-	unsigned short mountfamily = AF_UNSPEC;
-
-	if (!raw) {
-		dfprintk(MOUNT, "NFS: mount options string was NULL.\n");
-		return 1;
-	}
-	dfprintk(MOUNT, "NFS: nfs mount opts='%s'\n", raw);
-
-	secdata = alloc_secdata();
-	if (!secdata)
-		goto out_nomem;
-
-	rc = security_sb_copy_data(raw, secdata);
-	if (rc)
-		goto out_security_failure;
-
-	rc = security_sb_parse_opts_str(secdata, &ctx->lsm_opts);
-	if (rc)
-		goto out_security_failure;
-
-	free_secdata(secdata);
+	char *string;
+	int rc;
 
-	while ((p = strsep(&raw, ",")) != NULL) {
+	{
 		substring_t args[MAX_OPT_ARGS];
 		unsigned long option;
 		int token;
 
-		if (!*p)
-			continue;
-
 		dfprintk(MOUNT, "NFS:   parsing nfs mount option '%s'\n", p);
 
 		token = match_token(p, nfs_mount_option_tokens, args);
@@ -737,7 +709,7 @@ int nfs_parse_mount_options(char *raw, struct nfs_fs_context *ctx)
 			if (!rc) {
 				dfprintk(MOUNT, "NFS:   unrecognized "
 						"security flavor\n");
-				return 0;
+				return -EINVAL;
 			}
 			break;
 		case Opt_proto:
@@ -747,22 +719,22 @@ int nfs_parse_mount_options(char *raw, struct nfs_fs_context *ctx)
 			token = match_token(string,
 					    nfs_xprt_protocol_tokens, args);
 
-			protofamily = AF_INET;
+			ctx->protofamily = AF_INET;
 			switch (token) {
 			case Opt_xprt_udp6:
-				protofamily = AF_INET6;
+				ctx->protofamily = AF_INET6;
 			case Opt_xprt_udp:
 				ctx->flags &= ~NFS_MOUNT_TCP;
 				ctx->nfs_server.protocol = XPRT_TRANSPORT_UDP;
 				break;
 			case Opt_xprt_tcp6:
-				protofamily = AF_INET6;
+				ctx->protofamily = AF_INET6;
 			case Opt_xprt_tcp:
 				ctx->flags |= NFS_MOUNT_TCP;
 				ctx->nfs_server.protocol = XPRT_TRANSPORT_TCP;
 				break;
 			case Opt_xprt_rdma6:
-				protofamily = AF_INET6;
+				ctx->protofamily = AF_INET6;
 			case Opt_xprt_rdma:
 				/* vector side protocols to TCP */
 				ctx->flags |= NFS_MOUNT_TCP;
@@ -773,7 +745,7 @@ int nfs_parse_mount_options(char *raw, struct nfs_fs_context *ctx)
 				dfprintk(MOUNT, "NFS:   unrecognized "
 						"transport protocol\n");
 				kfree(string);
-				return 0;
+				return -EINVAL;
 			}
 			kfree(string);
 			break;
@@ -785,15 +757,15 @@ int nfs_parse_mount_options(char *raw, struct nfs_fs_context *ctx)
 					    nfs_xprt_protocol_tokens, args);
 			kfree(string);
 
-			mountfamily = AF_INET;
+			ctx->mountfamily = AF_INET;
 			switch (token) {
 			case Opt_xprt_udp6:
-				mountfamily = AF_INET6;
+				ctx->mountfamily = AF_INET6;
 			case Opt_xprt_udp:
 				ctx->mount_server.protocol = XPRT_TRANSPORT_UDP;
 				break;
 			case Opt_xprt_tcp6:
-				mountfamily = AF_INET6;
+				ctx->mountfamily = AF_INET6;
 			case Opt_xprt_tcp:
 				ctx->mount_server.protocol = XPRT_TRANSPORT_TCP;
 				break;
@@ -801,7 +773,7 @@ int nfs_parse_mount_options(char *raw, struct nfs_fs_context *ctx)
 			default:
 				dfprintk(MOUNT, "NFS:   unrecognized "
 						"transport protocol\n");
-				return 0;
+				return -EINVAL;
 			}
 			break;
 		case Opt_addr:
@@ -860,7 +832,7 @@ int nfs_parse_mount_options(char *raw, struct nfs_fs_context *ctx)
 				default:
 					dfprintk(MOUNT, "NFS:   invalid "
 							"lookupcache argument\n");
-					return 0;
+					return -EINVAL;
 			};
 			break;
 		case Opt_fscache_uniq:
@@ -893,7 +865,7 @@ int nfs_parse_mount_options(char *raw, struct nfs_fs_context *ctx)
 			default:
 				dfprintk(MOUNT, "NFS:	invalid	"
 						"local_lock argument\n");
-				return 0;
+				return -EINVAL;
 			};
 			break;
 
@@ -901,7 +873,7 @@ int nfs_parse_mount_options(char *raw, struct nfs_fs_context *ctx)
 		 * Special options
 		 */
 		case Opt_sloppy:
-			sloppy = 1;
+			ctx->sloppy = 1;
 			dfprintk(MOUNT, "NFS:   relaxing parsing rules\n");
 			break;
 		case Opt_userspace:
@@ -911,12 +883,63 @@ int nfs_parse_mount_options(char *raw, struct nfs_fs_context *ctx)
 			break;
 
 		default:
-			invalid_option = 1;
 			dfprintk(MOUNT, "NFS:   unrecognized mount option "
 					"'%s'\n", p);
+			return -EINVAL;
 		}
 	}
 
+	return 0;
+
+out_invalid_address:
+	printk(KERN_INFO "NFS: bad IP address specified: %s\n", p);
+	return -EINVAL;
+out_invalid_value:
+	printk(KERN_INFO "NFS: bad mount option value specified: %s\n", p);
+	return -EINVAL;
+out_nomem:
+	printk(KERN_INFO "NFS: not enough memory to parse option\n");
+	return -ENOMEM;
+}
+
+/*
+ * Error-check and convert a string of mount options from user space into
+ * a data structure.  The whole mount string is processed; bad options are
+ * skipped as they are encountered.  If there were no errors, return 1;
+ * otherwise return 0 (zero).
+ */
+int nfs_parse_mount_options(char *raw, struct nfs_fs_context *ctx)
+{
+	char *p, *secdata;
+	int rc, sloppy = 0, invalid_option = 0;
+
+	if (!raw) {
+		dfprintk(MOUNT, "NFS: mount options string was NULL.\n");
+		return 1;
+	}
+	dfprintk(MOUNT, "NFS: nfs mount opts='%s'\n", raw);
+
+	secdata = alloc_secdata();
+	if (!secdata)
+		goto out_nomem;
+
+	rc = security_sb_copy_data(raw, secdata);
+	if (rc)
+		goto out_security_failure;
+
+	rc = security_sb_parse_opts_str(secdata, &ctx->lsm_opts);
+	if (rc)
+		goto out_security_failure;
+
+	free_secdata(secdata);
+
+	while ((p = strsep(&raw, ",")) != NULL) {
+		if (!*p)
+			continue;
+		if (nfs_fs_context_parse_option(ctx, p) < 0)
+			invalid_option = true;
+	}
+
 	if (!sloppy && invalid_option)
 		return 0;
 
@@ -931,22 +954,26 @@ int nfs_parse_mount_options(char *raw, struct nfs_fs_context *ctx)
 	 * verify that any proto=/mountproto= options match the address
 	 * families in the addr=/mountaddr= options.
 	 */
-	if (protofamily != AF_UNSPEC &&
-	    protofamily != ctx->nfs_server.address.ss_family)
+	if (ctx->protofamily != AF_UNSPEC &&
+	    ctx->protofamily != ctx->nfs_server.address.ss_family)
 		goto out_proto_mismatch;
 
-	if (mountfamily != AF_UNSPEC) {
+	if (ctx->mountfamily != AF_UNSPEC) {
 		if (ctx->mount_server.addrlen) {
-			if (mountfamily != ctx->mount_server.address.ss_family)
+			if (ctx->mountfamily != ctx->mount_server.address.ss_family)
 				goto out_mountproto_mismatch;
 		} else {
-			if (mountfamily != ctx->nfs_server.address.ss_family)
+			if (ctx->mountfamily != ctx->nfs_server.address.ss_family)
 				goto out_mountproto_mismatch;
 		}
 	}
 
 	return 1;
 
+out_minorversion_mismatch:
+	printk(KERN_INFO "NFS: mount option vers=%u does not support "
+			 "minorversion=%u\n", ctx->version, ctx->minorversion);
+	return 0;
 out_mountproto_mismatch:
 	printk(KERN_INFO "NFS: mount server address does not match mountproto= "
 			 "option\n");
@@ -954,20 +981,10 @@ int nfs_parse_mount_options(char *raw, struct nfs_fs_context *ctx)
 out_proto_mismatch:
 	printk(KERN_INFO "NFS: server address does not match proto= option\n");
 	return 0;
-out_invalid_address:
-	printk(KERN_INFO "NFS: bad IP address specified: %s\n", p);
-	return 0;
-out_invalid_value:
-	printk(KERN_INFO "NFS: bad mount option value specified: %s\n", p);
-	return 0;
-out_minorversion_mismatch:
-	printk(KERN_INFO "NFS: mount option vers=%u does not support "
-			 "minorversion=%u\n", ctx->version, ctx->minorversion);
-	return 0;
 out_migration_misuse:
 	printk(KERN_INFO
 		"NFS: 'migration' not supported for this NFS version\n");
-	return 0;
+	return -EINVAL;
 out_nomem:
 	printk(KERN_INFO "NFS: not enough memory to parse option\n");
 	return 0;
diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
index 990e0d4d59fa..fab0fca9e0ef 100644
--- a/fs/nfs/internal.h
+++ b/fs/nfs/internal.h
@@ -100,7 +100,10 @@ struct nfs_fs_context {
 	unsigned int		version;
 	unsigned int		minorversion;
 	char			*fscache_uniq;
+	unsigned short		protofamily;
+	unsigned short		mountfamily;
 	bool			need_mount;
+	bool			sloppy;
 
 	struct {
 		struct sockaddr_storage	address;

