Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:5846 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753134AbdFNPSt (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 14 Jun 2017 11:18:49 -0400
Subject: [PATCH 23/27] NFS: Do some tidying of the parsing code [ver #5]
From: David Howells <dhowells@redhat.com>
To: mszeredi@redhat.com, viro@zeniv.linux.org.uk
Cc: linux-nfs@vger.kernel.org, jlayton@redhat.com,
        linux-kernel@vger.kernel.org, dhowells@redhat.com,
        linux-security-module@vger.kernel.org,
        linux-fsdevel@vger.kernel.org
Date: Wed, 14 Jun 2017 16:18:42 +0100
Message-ID: <149745352262.10897.8921123140526525747.stgit@warthog.procyon.org.uk>
In-Reply-To: <149745330648.10897.9605870130502083184.stgit@warthog.procyon.org.uk>
References: <149745330648.10897.9605870130502083184.stgit@warthog.procyon.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Do some tidying of the parsing code, including:

 (*) Returning 0/error rather than true/false.

 (*) Putting the nfs_fs_context pointer first in some arg lists.

 (*) Unwrap some lines that will now fit on one line.

 (*) Provide unioned sockaddr/sockaddr_storage fields to avoid casts.

 (*) nfs_parse_devname() can paste its return values directly into the
     nfs_fs_context struct as that's where the caller puts them.

Signed-off-by: David Howells <dhowells@redhat.com>
---

 fs/nfs/fs_context.c |  128 ++++++++++++++++++++++-----------------------------
 fs/nfs/internal.h   |   16 ++++--
 fs/nfs/super.c      |    2 -
 3 files changed, 67 insertions(+), 79 deletions(-)

diff --git a/fs/nfs/fs_context.c b/fs/nfs/fs_context.c
index 763a09b64971..24becb82540f 100644
--- a/fs/nfs/fs_context.c
+++ b/fs/nfs/fs_context.c
@@ -341,8 +341,9 @@ static void nfs_set_mount_transport_protocol(struct nfs_fs_context *ctx)
  * Add 'flavor' to 'auth_info' if not already present.
  * Returns true if 'flavor' ends up in the list, false otherwise
  */
-static bool nfs_auth_info_add(struct nfs_auth_info *auth_info,
-			      rpc_authflavor_t flavor)
+static int nfs_auth_info_add(struct nfs_fs_context *ctx,
+			     struct nfs_auth_info *auth_info,
+			     rpc_authflavor_t flavor)
 {
 	unsigned int i;
 	unsigned int max_flavor_len = ARRAY_SIZE(auth_info->flavors);
@@ -350,26 +351,27 @@ static bool nfs_auth_info_add(struct nfs_auth_info *auth_info,
 	/* make sure this flavor isn't already in the list */
 	for (i = 0; i < auth_info->flavor_len; i++) {
 		if (flavor == auth_info->flavors[i])
-			return true;
+			return 0;
 	}
 
 	if (auth_info->flavor_len + 1 >= max_flavor_len) {
 		dfprintk(MOUNT, "NFS: too many sec= flavors\n");
-		return false;
+		return -EINVAL;
 	}
 
 	auth_info->flavors[auth_info->flavor_len++] = flavor;
-	return true;
+	return 0;
 }
 
 /*
  * Parse the value of the 'sec=' option.
  */
-static int nfs_parse_security_flavors(char *value, struct nfs_fs_context *ctx)
+static int nfs_parse_security_flavors(struct nfs_fs_context *ctx, char *value)
 {
 	substring_t args[MAX_OPT_ARGS];
 	rpc_authflavor_t pseudoflavor;
 	char *p;
+	int ret;
 
 	dfprintk(MOUNT, "NFS: parsing sec=%s option\n", value);
 
@@ -411,19 +413,20 @@ static int nfs_parse_security_flavors(char *value, struct nfs_fs_context *ctx)
 		default:
 			dfprintk(MOUNT,
 				 "NFS: sec= option '%s' not recognized\n", p);
-			return 0;
+			return -EINVAL;
 		}
 
-		if (!nfs_auth_info_add(&ctx->auth_info, pseudoflavor))
-			return 0;
+		ret = nfs_auth_info_add(ctx, &ctx->auth_info, pseudoflavor);
+		if (ret < 0)
+			return ret;
 	}
 
-	return 1;
+	return 0;
 }
 
-static int nfs_parse_version_string(char *string,
-		struct nfs_fs_context *ctx,
-		substring_t *args)
+static int nfs_parse_version_string(struct nfs_fs_context *ctx,
+				    char *string,
+				    substring_t *args)
 {
 	ctx->flags &= ~NFS_MOUNT_VER3;
 	switch (match_token(string, nfs_vers_tokens, args)) {
@@ -454,9 +457,10 @@ static int nfs_parse_version_string(char *string,
 		ctx->minorversion = 2;
 		break;
 	default:
-		return 0;
+		dfprintk(MOUNT, "NFS:   Unsupported NFS version\n");
+		return -EINVAL;
 	}
-	return 1;
+	return 0;
 }
 
 static int nfs_get_option_str(substring_t args[], char **option)
@@ -495,7 +499,7 @@ static int nfs_fs_context_parse_option(struct nfs_fs_context *ctx, char *p)
 {
 	substring_t args[MAX_OPT_ARGS];
 	char *string;
-	int rc, token;
+	int ret, token;
 
 	dfprintk(MOUNT, "NFS:   parsing nfs mount option '%s'\n", p);
 
@@ -530,13 +534,11 @@ static int nfs_fs_context_parse_option(struct nfs_fs_context *ctx, char *p)
 		break;
 	case Opt_lock:
 		ctx->flags &= ~NFS_MOUNT_NONLM;
-		ctx->flags &= ~(NFS_MOUNT_LOCAL_FLOCK |
-				NFS_MOUNT_LOCAL_FCNTL);
+		ctx->flags &= ~(NFS_MOUNT_LOCAL_FLOCK | NFS_MOUNT_LOCAL_FCNTL);
 		break;
 	case Opt_nolock:
 		ctx->flags |= NFS_MOUNT_NONLM;
-		ctx->flags |= (NFS_MOUNT_LOCAL_FLOCK |
-			       NFS_MOUNT_LOCAL_FCNTL);
+		ctx->flags |= (NFS_MOUNT_LOCAL_FLOCK | NFS_MOUNT_LOCAL_FCNTL);
 		break;
 	case Opt_udp:
 		ctx->flags &= ~NFS_MOUNT_TCP;
@@ -669,29 +671,25 @@ static int nfs_fs_context_parse_option(struct nfs_fs_context *ctx, char *p)
 		string = match_strdup(args);
 		if (string == NULL)
 			goto out_nomem;
-		rc = nfs_parse_version_string(string, ctx, args);
+		ret = nfs_parse_version_string(ctx, string, args);
 		kfree(string);
-		if (!rc)
-			goto out_invalid_value;
+		if (ret < 0)
+			return ret;
 		break;
 	case Opt_sec:
 		string = match_strdup(args);
 		if (string == NULL)
 			goto out_nomem;
-		rc = nfs_parse_security_flavors(string, ctx);
+		ret = nfs_parse_security_flavors(ctx, string);
 		kfree(string);
-		if (!rc) {
-			dfprintk(MOUNT, "NFS:   unrecognized "
-				 "security flavor\n");
-			return -EINVAL;
-		}
+		if (ret < 0)
+			return ret;
 		break;
 	case Opt_proto:
 		string = match_strdup(args);
 		if (string == NULL)
 			goto out_nomem;
-		token = match_token(string,
-				    nfs_xprt_protocol_tokens, args);
+		token = match_token(string, nfs_xprt_protocol_tokens, args);
 
 		ctx->protofamily = AF_INET;
 		switch (token) {
@@ -716,9 +714,8 @@ static int nfs_fs_context_parse_option(struct nfs_fs_context *ctx, char *p)
 			xprt_load_transport(string);
 			break;
 		default:
-			dfprintk(MOUNT, "NFS:   unrecognized "
-				 "transport protocol\n");
 			kfree(string);
+			dfprintk(MOUNT, "NFS:   unrecognized transport protocol\n");
 			return -EINVAL;
 		}
 		kfree(string);
@@ -727,8 +724,7 @@ static int nfs_fs_context_parse_option(struct nfs_fs_context *ctx, char *p)
 		string = match_strdup(args);
 		if (string == NULL)
 			goto out_nomem;
-		token = match_token(string,
-				    nfs_xprt_protocol_tokens, args);
+		token = match_token(string, nfs_xprt_protocol_tokens, args);
 		kfree(string);
 
 		ctx->mountfamily = AF_INET;
@@ -745,8 +741,7 @@ static int nfs_fs_context_parse_option(struct nfs_fs_context *ctx, char *p)
 			break;
 		case Opt_xprt_rdma: /* not used for side protocols */
 		default:
-			dfprintk(MOUNT, "NFS:   unrecognized "
-				 "transport protocol\n");
+			dfprintk(MOUNT, "NFS:   unrecognized transport protocol\n");
 			return -EINVAL;
 		}
 		break;
@@ -756,9 +751,8 @@ static int nfs_fs_context_parse_option(struct nfs_fs_context *ctx, char *p)
 			goto out_nomem;
 		ctx->nfs_server.addrlen =
 			rpc_pton(ctx->net, string, strlen(string),
-				 (struct sockaddr *)
 				 &ctx->nfs_server.address,
-				 sizeof(ctx->nfs_server.address));
+				 sizeof(ctx->nfs_server._address));
 		kfree(string);
 		if (ctx->nfs_server.addrlen == 0)
 			goto out_invalid_address;
@@ -768,8 +762,7 @@ static int nfs_fs_context_parse_option(struct nfs_fs_context *ctx, char *p)
 			goto out_nomem;
 		break;
 	case Opt_mounthost:
-		if (nfs_get_option_str(args,
-				       &ctx->mount_server.hostname))
+		if (nfs_get_option_str(args, &ctx->mount_server.hostname))
 			goto out_nomem;
 		break;
 	case Opt_mountaddr:
@@ -778,9 +771,8 @@ static int nfs_fs_context_parse_option(struct nfs_fs_context *ctx, char *p)
 			goto out_nomem;
 		ctx->mount_server.addrlen =
 			rpc_pton(ctx->net, string, strlen(string),
-				 (struct sockaddr *)
 				 &ctx->mount_server.address,
-				 sizeof(ctx->mount_server.address));
+				 sizeof(ctx->mount_server._address));
 		kfree(string);
 		if (ctx->mount_server.addrlen == 0)
 			goto out_invalid_address;
@@ -789,8 +781,7 @@ static int nfs_fs_context_parse_option(struct nfs_fs_context *ctx, char *p)
 		string = match_strdup(args);
 		if (string == NULL)
 			goto out_nomem;
-		token = match_token(string,
-				    nfs_lookupcache_tokens, args);
+		token = match_token(string, nfs_lookupcache_tokens, args);
 		kfree(string);
 		switch (token) {
 		case Opt_lookupcache_all:
@@ -804,10 +795,9 @@ static int nfs_fs_context_parse_option(struct nfs_fs_context *ctx, char *p)
 			ctx->flags |= NFS_MOUNT_LOOKUP_CACHE_NONEG|NFS_MOUNT_LOOKUP_CACHE_NONE;
 			break;
 		default:
-			dfprintk(MOUNT, "NFS:   invalid "
-				 "lookupcache argument\n");
+			dfprintk(MOUNT, "NFS:   invalid lookupcache argument\n");
 			return -EINVAL;
-		};
+		}
 		break;
 	case Opt_fscache_uniq:
 		if (nfs_get_option_str(args, &ctx->fscache_uniq))
@@ -818,8 +808,7 @@ static int nfs_fs_context_parse_option(struct nfs_fs_context *ctx, char *p)
 		string = match_strdup(args);
 		if (string == NULL)
 			goto out_nomem;
-		token = match_token(string, nfs_local_lock_tokens,
-				    args);
+		token = match_token(string, nfs_local_lock_tokens, args);
 		kfree(string);
 		switch (token) {
 		case Opt_local_lock_all:
@@ -837,8 +826,7 @@ static int nfs_fs_context_parse_option(struct nfs_fs_context *ctx, char *p)
 					NFS_MOUNT_LOCAL_FCNTL);
 			break;
 		default:
-			dfprintk(MOUNT, "NFS:	invalid	"
-				 "local_lock argument\n");
+			dfprintk(MOUNT, "NFS:	invalid	local_lock argument\n");
 			return -EINVAL;
 		};
 		break;
@@ -852,13 +840,11 @@ static int nfs_fs_context_parse_option(struct nfs_fs_context *ctx, char *p)
 		break;
 	case Opt_userspace:
 	case Opt_deprecated:
-		dfprintk(MOUNT, "NFS:   ignoring mount option "
-			 "'%s'\n", p);
+		dfprintk(MOUNT, "NFS:   ignoring mount option '%s'\n", p);
 		break;
 
 	default:
-		dfprintk(MOUNT, "NFS:   unrecognized mount option "
-			 "'%s'\n", p);
+		dfprintk(MOUNT, "NFS:   unrecognized mount option '%s'\n", p);
 		return -EINVAL;
 	}
 
@@ -928,15 +914,15 @@ int nfs_parse_mount_options(char *raw, struct nfs_fs_context *ctx)
 	 * families in the addr=/mountaddr= options.
 	 */
 	if (ctx->protofamily != AF_UNSPEC &&
-	    ctx->protofamily != ctx->nfs_server.address.ss_family)
+	    ctx->protofamily != ctx->nfs_server.address.sa_family)
 		goto out_proto_mismatch;
 
 	if (ctx->mountfamily != AF_UNSPEC) {
 		if (ctx->mount_server.addrlen) {
-			if (ctx->mountfamily != ctx->mount_server.address.ss_family)
+			if (ctx->mountfamily != ctx->mount_server.address.sa_family)
 				goto out_mountproto_mismatch;
 		} else {
-			if (ctx->mountfamily != ctx->nfs_server.address.ss_family)
+			if (ctx->mountfamily != ctx->nfs_server.address.sa_family)
 				goto out_mountproto_mismatch;
 		}
 	}
@@ -976,9 +962,9 @@ int nfs_parse_mount_options(char *raw, struct nfs_fs_context *ctx)
  *
  * Note: caller frees hostname and export path, even on error.
  */
-static int nfs_parse_devname(const char *dev_name,
-			     char **hostname, size_t maxnamlen,
-			     char **export_path, size_t maxpathlen)
+static int nfs_parse_devname(struct nfs_fs_context *ctx,
+			     const char *dev_name,
+			     size_t maxnamlen, size_t maxpathlen)
 {
 	size_t len;
 	char *end;
@@ -1009,17 +995,17 @@ static int nfs_parse_devname(const char *dev_name,
 		goto out_hostname;
 
 	/* N.B. caller will free nfs_server.hostname in all cases */
-	*hostname = kstrndup(dev_name, len, GFP_KERNEL);
-	if (*hostname == NULL)
+	ctx->nfs_server.hostname = kmemdup_nul(dev_name, len, GFP_KERNEL);
+	if (!ctx->nfs_server.hostname)
 		goto out_nomem;
 	len = strlen(++end);
 	if (len > maxpathlen)
 		goto out_path;
-	*export_path = kstrndup(end, len, GFP_KERNEL);
-	if (!*export_path)
+	ctx->nfs_server.export_path = kmemdup_nul(end, len, GFP_KERNEL);
+	if (!ctx->nfs_server.export_path)
 		goto out_nomem;
 
-	dfprintk(MOUNT, "NFS: MNTPATH: '%s'\n", *export_path);
+	dfprintk(MOUNT, "NFS: MNTPATH: '%s'\n", ctx->nfs_server.export_path);
 	return 0;
 
 out_bad_devname:
@@ -1040,7 +1026,7 @@ static int nfs_parse_devname(const char *dev_name,
 }
 
 /*
- * Validate the NFS2/NFS3 mount data
+ * Parse monolithic NFS2/NFS3 mount data
  * - fills in the mount root filehandle
  *
  * For option strings, user space handles the following behaviors:
@@ -1365,11 +1351,7 @@ int nfs_validate_text_mount_data(void *options,
 
 	nfs_set_port(sap, &ctx->nfs_server.port, port);
 
-	return nfs_parse_devname(dev_name,
-				   &ctx->nfs_server.hostname,
-				   max_namelen,
-				   &ctx->nfs_server.export_path,
-				   max_pathlen);
+	return nfs_parse_devname(ctx, dev_name, max_namelen, max_pathlen);
 
 #if !IS_ENABLED(CONFIG_NFS_V4)
 out_v4_not_compiled:
diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
index 1c5404d846cc..fa568407cda8 100644
--- a/fs/nfs/internal.h
+++ b/fs/nfs/internal.h
@@ -86,11 +86,11 @@ struct nfs_client_initdata {
  * In-kernel mount arguments
  */
 struct nfs_fs_context {
-	int			flags;
+	unsigned int		flags;		/* NFS{,4}_MOUNT_* flags */
 	unsigned int		rsize, wsize;
 	unsigned int		timeo, retrans;
-	unsigned int		acregmin, acregmax,
-				acdirmin, acdirmax;
+	unsigned int		acregmin, acregmax;
+	unsigned int		acdirmin, acdirmax;
 	unsigned int		namlen;
 	unsigned int		options;
 	unsigned int		bsize;
@@ -106,7 +106,10 @@ struct nfs_fs_context {
 	bool			sloppy;
 
 	struct {
-		struct sockaddr_storage	address;
+		union {
+			struct sockaddr	address;
+			struct sockaddr_storage	_address;
+		};
 		size_t			addrlen;
 		char			*hostname;
 		u32			version;
@@ -115,7 +118,10 @@ struct nfs_fs_context {
 	} mount_server;
 
 	struct {
-		struct sockaddr_storage	address;
+		union {
+			struct sockaddr	address;
+			struct sockaddr_storage	_address;
+		};
 		size_t			addrlen;
 		char			*hostname;
 		char			*export_path;
diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index 0eb56748f651..c13f0ff42df9 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -795,7 +795,7 @@ static int nfs_request_mount(struct nfs_fs_context *cfg,
 	/*
 	 * Construct the mount server's address.
 	 */
-	if (cfg->mount_server.address.ss_family == AF_UNSPEC) {
+	if (cfg->mount_server.address.sa_family == AF_UNSPEC) {
 		memcpy(request.sap, &cfg->nfs_server.address,
 		       cfg->nfs_server.addrlen);
 		cfg->mount_server.addrlen = cfg->nfs_server.addrlen;

