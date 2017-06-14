Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:58652 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752579AbdFNPS6 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 14 Jun 2017 11:18:58 -0400
Subject: [PATCH 24/27] NFS: Add fs_context support. [ver #5]
From: David Howells <dhowells@redhat.com>
To: mszeredi@redhat.com, viro@zeniv.linux.org.uk
Cc: linux-nfs@vger.kernel.org, jlayton@redhat.com,
        linux-kernel@vger.kernel.org, dhowells@redhat.com,
        linux-security-module@vger.kernel.org,
        linux-fsdevel@vger.kernel.org
Date: Wed, 14 Jun 2017 16:18:54 +0100
Message-ID: <149745353411.10897.420622216132883178.stgit@warthog.procyon.org.uk>
In-Reply-To: <149745330648.10897.9605870130502083184.stgit@warthog.procyon.org.uk>
References: <149745330648.10897.9605870130502083184.stgit@warthog.procyon.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Add filesystem context support to NFS, parsing the options in advance and
attaching the information to struct nfs_fs_context.  The highlights are:

 (*) Merge nfs_mount_info and nfs_clone_mount into nfs_fs_context.  This
     structure represents NFS's superblock config.

 (*) Make use of the VFS's parsing support to split comma-separated lists.

 (*) Pin the NFS protocol module in the nfs_fs_context.

 (*) Attach supplementary error information to fs_context.  This has the
     downside that these strings must be static and can't be formatted.

 (*) Remove the auxiliary file_system_type structs since the information
     necessary can be conveyed in the nfs_fs_context struct instead.

 (*) Root mounts are made by duplicating the config for the requested mount
     so as to have the same parameters.  Submounts pick up their parameters
     from the parent superblock.

Signed-off-by: David Howells <dhowells@redhat.com>
---

 fs/nfs/client.c         |   74 +++--
 fs/nfs/fs_context.c     |  652 ++++++++++++++++++++++++++++-------------------
 fs/nfs/getroot.c        |   72 +++--
 fs/nfs/internal.h       |  104 +++----
 fs/nfs/namespace.c      |   76 ++++-
 fs/nfs/nfs3_fs.h        |    2 
 fs/nfs/nfs3client.c     |    6 
 fs/nfs/nfs3proc.c       |    2 
 fs/nfs/nfs4_fs.h        |    4 
 fs/nfs/nfs4client.c     |   44 ++-
 fs/nfs/nfs4namespace.c  |  208 +++++++++------
 fs/nfs/nfs4proc.c       |    3 
 fs/nfs/nfs4super.c      |  220 ++++++++--------
 fs/nfs/proc.c           |    2 
 fs/nfs/super.c          |  381 ++++++++-------------------
 include/linux/nfs_xdr.h |    7 -
 16 files changed, 940 insertions(+), 917 deletions(-)

diff --git a/fs/nfs/client.c b/fs/nfs/client.c
index d25dfa15f2ec..8c9b610ca952 100644
--- a/fs/nfs/client.c
+++ b/fs/nfs/client.c
@@ -635,25 +635,24 @@ EXPORT_SYMBOL_GPL(nfs_init_client);
  * Create a version 2 or 3 client
  */
 static int nfs_init_server(struct nfs_server *server,
-			   const struct nfs_fs_context *cfg,
-			   struct nfs_subversion *nfs_mod)
+			   const struct nfs_fs_context *ctx)
 {
 	struct rpc_timeout timeparms;
 	struct nfs_client_initdata cl_init = {
-		.hostname = cfg->nfs_server.hostname,
-		.addr = (const struct sockaddr *)&cfg->nfs_server.address,
-		.addrlen = cfg->nfs_server.addrlen,
-		.nfs_mod = nfs_mod,
-		.proto = cfg->nfs_server.protocol,
-		.net = cfg->net,
+		.hostname = ctx->nfs_server.hostname,
+		.addr = (const struct sockaddr *)&ctx->nfs_server.address,
+		.addrlen = ctx->nfs_server.addrlen,
+		.nfs_mod = ctx->nfs_mod,
+		.proto = ctx->nfs_server.protocol,
+		.net = ctx->fc.net_ns,
 		.timeparms = &timeparms,
 	};
 	struct nfs_client *clp;
 	int error;
 
-	nfs_init_timeout_values(&timeparms, cfg->nfs_server.protocol,
-				cfg->timeo, cfg->retrans);
-	if (cfg->flags & NFS_MOUNT_NORESVPORT)
+	nfs_init_timeout_values(&timeparms, ctx->nfs_server.protocol,
+				ctx->timeo, ctx->retrans);
+	if (ctx->flags & NFS_MOUNT_NORESVPORT)
 		set_bit(NFS_CS_NORESVPORT, &cl_init.init_flags);
 
 	/* Allocate or find a client reference we can use */
@@ -664,46 +663,46 @@ static int nfs_init_server(struct nfs_server *server,
 	server->nfs_client = clp;
 
 	/* Initialise the client representation from the mount data */
-	server->flags = cfg->flags;
-	server->options = cfg->options;
+	server->flags = ctx->flags;
+	server->options = ctx->options;
 	server->caps |= NFS_CAP_HARDLINKS|NFS_CAP_SYMLINKS|NFS_CAP_FILEID|
 		NFS_CAP_MODE|NFS_CAP_NLINK|NFS_CAP_OWNER|NFS_CAP_OWNER_GROUP|
 		NFS_CAP_ATIME|NFS_CAP_CTIME|NFS_CAP_MTIME;
 
-	if (cfg->rsize)
-		server->rsize = nfs_block_size(cfg->rsize, NULL);
-	if (cfg->wsize)
-		server->wsize = nfs_block_size(cfg->wsize, NULL);
+	if (ctx->rsize)
+		server->rsize = nfs_block_size(ctx->rsize, NULL);
+	if (ctx->wsize)
+		server->wsize = nfs_block_size(ctx->wsize, NULL);
 
-	server->acregmin = cfg->acregmin * HZ;
-	server->acregmax = cfg->acregmax * HZ;
-	server->acdirmin = cfg->acdirmin * HZ;
-	server->acdirmax = cfg->acdirmax * HZ;
+	server->acregmin = ctx->acregmin * HZ;
+	server->acregmax = ctx->acregmax * HZ;
+	server->acdirmin = ctx->acdirmin * HZ;
+	server->acdirmax = ctx->acdirmax * HZ;
 
 	/* Start lockd here, before we might error out */
 	error = nfs_start_lockd(server);
 	if (error < 0)
 		goto error;
 
-	server->port = cfg->nfs_server.port;
-	server->auth_info = cfg->auth_info;
+	server->port = ctx->nfs_server.port;
+	server->auth_info = ctx->auth_info;
 
 	error = nfs_init_server_rpcclient(server, &timeparms,
-					  cfg->selected_flavor);
+					  ctx->selected_flavor);
 	if (error < 0)
 		goto error;
 
 	/* Preserve the values of mount_server-related mount options */
-	if (cfg->mount_server.addrlen) {
-		memcpy(&server->mountd_address, &cfg->mount_server.address,
-			cfg->mount_server.addrlen);
-		server->mountd_addrlen = cfg->mount_server.addrlen;
+	if (ctx->mount_server.addrlen) {
+		memcpy(&server->mountd_address, &ctx->mount_server.address,
+			ctx->mount_server.addrlen);
+		server->mountd_addrlen = ctx->mount_server.addrlen;
 	}
-	server->mountd_version = cfg->mount_server.version;
-	server->mountd_port = cfg->mount_server.port;
-	server->mountd_protocol = cfg->mount_server.protocol;
+	server->mountd_version = ctx->mount_server.version;
+	server->mountd_port = ctx->mount_server.port;
+	server->mountd_protocol = ctx->mount_server.protocol;
 
-	server->namelen  = cfg->namlen;
+	server->namelen  = ctx->namlen;
 	return 0;
 
 error:
@@ -921,8 +920,7 @@ EXPORT_SYMBOL_GPL(nfs_free_server);
  * Create a version 2 or 3 volume record
  * - keyed on server and FSID
  */
-struct nfs_server *nfs_create_server(struct nfs_mount_info *mount_info,
-				     struct nfs_subversion *nfs_mod)
+struct nfs_server *nfs_create_server(struct nfs_fs_context *ctx)
 {
 	struct nfs_server *server;
 	struct nfs_fattr *fattr;
@@ -938,18 +936,18 @@ struct nfs_server *nfs_create_server(struct nfs_mount_info *mount_info,
 		goto error;
 
 	/* Get a client representation */
-	error = nfs_init_server(server, mount_info->ctx, nfs_mod);
+	error = nfs_init_server(server, ctx);
 	if (error < 0)
 		goto error;
 
 	/* Probe the root fh to retrieve its FSID */
-	error = nfs_probe_fsinfo(server, mount_info->mntfh, fattr);
+	error = nfs_probe_fsinfo(server, ctx->mntfh, fattr);
 	if (error < 0)
 		goto error;
 	if (server->nfs_client->rpc_ops->version == 3) {
 		if (server->namelen == 0 || server->namelen > NFS3_MAXNAMLEN)
 			server->namelen = NFS3_MAXNAMLEN;
-		if (!(mount_info->ctx->flags & NFS_MOUNT_NORDIRPLUS))
+		if (!(ctx->flags & NFS_MOUNT_NORDIRPLUS))
 			server->caps |= NFS_CAP_READDIRPLUS;
 	} else {
 		if (server->namelen == 0 || server->namelen > NFS2_MAXNAMLEN)
@@ -957,7 +955,7 @@ struct nfs_server *nfs_create_server(struct nfs_mount_info *mount_info,
 	}
 
 	if (!(fattr->valid & NFS_ATTR_FATTR)) {
-		error = nfs_mod->rpc_ops->getattr(server, mount_info->mntfh, fattr, NULL);
+		error = ctx->nfs_mod->rpc_ops->getattr(server, ctx->mntfh, fattr, NULL);
 		if (error < 0) {
 			dprintk("nfs_create_server: getattr error = %d\n", -error);
 			goto error;
diff --git a/fs/nfs/fs_context.c b/fs/nfs/fs_context.c
index 24becb82540f..e8e88aaa5164 100644
--- a/fs/nfs/fs_context.c
+++ b/fs/nfs/fs_context.c
@@ -240,42 +240,8 @@ static const match_table_t nfs_vers_tokens = {
 	{ Opt_vers_err, NULL }
 };
 
-struct nfs_fs_context *nfs_alloc_parsed_mount_data(void)
-{
-	struct nfs_fs_context *ctx;
-
-	ctx = kzalloc(sizeof(*ctx), GFP_KERNEL);
-	if (ctx) {
-		ctx->timeo		= NFS_UNSPEC_TIMEO;
-		ctx->retrans		= NFS_UNSPEC_RETRANS;
-		ctx->acregmin		= NFS_DEF_ACREGMIN;
-		ctx->acregmax		= NFS_DEF_ACREGMAX;
-		ctx->acdirmin		= NFS_DEF_ACDIRMIN;
-		ctx->acdirmax		= NFS_DEF_ACDIRMAX;
-		ctx->mount_server.port	= NFS_UNSPEC_PORT;
-		ctx->nfs_server.port	= NFS_UNSPEC_PORT;
-		ctx->nfs_server.protocol = XPRT_TRANSPORT_TCP;
-		ctx->selected_flavor	= RPC_AUTH_MAXFLAVOR;
-		ctx->minorversion	= 0;
-		ctx->need_mount	= true;
-		ctx->net		= current->nsproxy->net_ns;
-		security_init_mnt_opts(&ctx->lsm_opts);
-	}
-	return ctx;
-}
-
-void nfs_free_parsed_mount_data(struct nfs_fs_context *ctx)
-{
-	if (ctx) {
-		kfree(ctx->client_address);
-		kfree(ctx->mount_server.hostname);
-		kfree(ctx->nfs_server.export_path);
-		kfree(ctx->nfs_server.hostname);
-		kfree(ctx->fscache_uniq);
-		security_free_mnt_opts(&ctx->lsm_opts);
-		kfree(ctx);
-	}
-}
+const char nfs_slash[] = "/";
+EXPORT_SYMBOL_GPL(nfs_slash);
 
 /*
  * Sanity-check a server address provided by the mount command.
@@ -354,10 +320,8 @@ static int nfs_auth_info_add(struct nfs_fs_context *ctx,
 			return 0;
 	}
 
-	if (auth_info->flavor_len + 1 >= max_flavor_len) {
-		dfprintk(MOUNT, "NFS: too many sec= flavors\n");
-		return -EINVAL;
-	}
+	if (auth_info->flavor_len + 1 >= max_flavor_len)
+		return invalf("NFS: too many sec= flavors");
 
 	auth_info->flavors[auth_info->flavor_len++] = flavor;
 	return 0;
@@ -411,9 +375,7 @@ static int nfs_parse_security_flavors(struct nfs_fs_context *ctx, char *value)
 			pseudoflavor = RPC_AUTH_GSS_SPKMP;
 			break;
 		default:
-			dfprintk(MOUNT,
-				 "NFS: sec= option '%s' not recognized\n", p);
-			return -EINVAL;
+			return invalf("NFS: sec=%s option not recognized", p);
 		}
 
 		ret = nfs_auth_info_add(ctx, &ctx->auth_info, pseudoflavor);
@@ -457,8 +419,7 @@ static int nfs_parse_version_string(struct nfs_fs_context *ctx,
 		ctx->minorversion = 2;
 		break;
 	default:
-		dfprintk(MOUNT, "NFS:   Unsupported NFS version\n");
-		return -EINVAL;
+		return invalf("NFS: Unsupported NFS version");
 	}
 	return 0;
 }
@@ -495,8 +456,9 @@ static int nfs_get_option_ui_bound(struct nfs_fs_context *ctx,
 /*
  * Parse a single mount option in "key[=val]" form.
  */
-static int nfs_fs_context_parse_option(struct nfs_fs_context *ctx, char *p)
+static int nfs_fs_context_parse_option(struct fs_context *fc, char *p)
 {
+	struct nfs_fs_context *ctx = container_of(fc, struct nfs_fs_context, fc);
 	substring_t args[MAX_OPT_ARGS];
 	char *string;
 	int ret, token;
@@ -715,8 +677,7 @@ static int nfs_fs_context_parse_option(struct nfs_fs_context *ctx, char *p)
 			break;
 		default:
 			kfree(string);
-			dfprintk(MOUNT, "NFS:   unrecognized transport protocol\n");
-			return -EINVAL;
+			return invalf("NFS: Unrecognized transport protocol");
 		}
 		kfree(string);
 		break;
@@ -741,8 +702,7 @@ static int nfs_fs_context_parse_option(struct nfs_fs_context *ctx, char *p)
 			break;
 		case Opt_xprt_rdma: /* not used for side protocols */
 		default:
-			dfprintk(MOUNT, "NFS:   unrecognized transport protocol\n");
-			return -EINVAL;
+			return invalf("NFS: Unrecognized transport protocol");
 		}
 		break;
 	case Opt_addr:
@@ -750,7 +710,7 @@ static int nfs_fs_context_parse_option(struct nfs_fs_context *ctx, char *p)
 		if (string == NULL)
 			goto out_nomem;
 		ctx->nfs_server.addrlen =
-			rpc_pton(ctx->net, string, strlen(string),
+			rpc_pton(fc->net_ns, string, strlen(string),
 				 &ctx->nfs_server.address,
 				 sizeof(ctx->nfs_server._address));
 		kfree(string);
@@ -770,7 +730,7 @@ static int nfs_fs_context_parse_option(struct nfs_fs_context *ctx, char *p)
 		if (string == NULL)
 			goto out_nomem;
 		ctx->mount_server.addrlen =
-			rpc_pton(ctx->net, string, strlen(string),
+			rpc_pton(fc->net_ns, string, strlen(string),
 				 &ctx->mount_server.address,
 				 sizeof(ctx->mount_server._address));
 		kfree(string);
@@ -795,8 +755,7 @@ static int nfs_fs_context_parse_option(struct nfs_fs_context *ctx, char *p)
 			ctx->flags |= NFS_MOUNT_LOOKUP_CACHE_NONEG|NFS_MOUNT_LOOKUP_CACHE_NONE;
 			break;
 		default:
-			dfprintk(MOUNT, "NFS:   invalid lookupcache argument\n");
-			return -EINVAL;
+			return invalf("NFS: Invalid lookupcache argument");
 		}
 		break;
 	case Opt_fscache_uniq:
@@ -826,16 +785,15 @@ static int nfs_fs_context_parse_option(struct nfs_fs_context *ctx, char *p)
 					NFS_MOUNT_LOCAL_FCNTL);
 			break;
 		default:
-			dfprintk(MOUNT, "NFS:	invalid	local_lock argument\n");
-			return -EINVAL;
-		};
+			return invalf("NFS: invalid local_lock argument");
+		}
 		break;
 
 		/*
 		 * Special options
 		 */
 	case Opt_sloppy:
-		ctx->sloppy = 1;
+		fc->sloppy = 1;
 		dfprintk(MOUNT, "NFS:   relaxing parsing rules\n");
 		break;
 	case Opt_userspace:
@@ -845,116 +803,24 @@ static int nfs_fs_context_parse_option(struct nfs_fs_context *ctx, char *p)
 
 	default:
 		dfprintk(MOUNT, "NFS:   unrecognized mount option '%s'\n", p);
-		return -EINVAL;
+		if (!fc->sloppy)
+			return invalf("NFS: Unrecognized mount option '%s'", p);
+		break;
 	}
 
 	return 0;
 
-out_invalid_address:
-	printk(KERN_INFO "NFS: bad IP address specified: %s\n", p);
-	return -EINVAL;
-out_invalid_value:
-	printk(KERN_INFO "NFS: bad mount option value specified: %s\n", p);
-	return -EINVAL;
 out_nomem:
 	printk(KERN_INFO "NFS: not enough memory to parse option\n");
 	return -ENOMEM;
+out_invalid_value:
+	return invalf("NFS: Bad mount option value specified");
+out_invalid_address:
+	return invalf("NFS: Bad IP address specified");
 }
 
 /*
- * Error-check and convert a string of mount options from user space into
- * a data structure.  The whole mount string is processed; bad options are
- * skipped as they are encountered.  If there were no errors, return 1;
- * otherwise return 0 (zero).
- */
-int nfs_parse_mount_options(char *raw, struct nfs_fs_context *ctx)
-{
-	char *p, *secdata;
-	int rc, sloppy = 0, invalid_option = 0;
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
-
-	while ((p = strsep(&raw, ",")) != NULL) {
-		if (!*p)
-			continue;
-		if (nfs_fs_context_parse_option(ctx, p) < 0)
-			invalid_option = true;
-	}
-
-	if (!sloppy && invalid_option)
-		return 0;
-
-	if (ctx->minorversion && ctx->version != 4)
-		goto out_minorversion_mismatch;
-
-	if (ctx->options & NFS_OPTION_MIGRATION &&
-	    (ctx->version != 4 || ctx->minorversion != 0))
-		goto out_migration_misuse;
-
-	/*
-	 * verify that any proto=/mountproto= options match the address
-	 * families in the addr=/mountaddr= options.
-	 */
-	if (ctx->protofamily != AF_UNSPEC &&
-	    ctx->protofamily != ctx->nfs_server.address.sa_family)
-		goto out_proto_mismatch;
-
-	if (ctx->mountfamily != AF_UNSPEC) {
-		if (ctx->mount_server.addrlen) {
-			if (ctx->mountfamily != ctx->mount_server.address.sa_family)
-				goto out_mountproto_mismatch;
-		} else {
-			if (ctx->mountfamily != ctx->nfs_server.address.sa_family)
-				goto out_mountproto_mismatch;
-		}
-	}
-
-	return 1;
-
-out_minorversion_mismatch:
-	printk(KERN_INFO "NFS: mount option vers=%u does not support "
-			 "minorversion=%u\n", ctx->version, ctx->minorversion);
-	return 0;
-out_mountproto_mismatch:
-	printk(KERN_INFO "NFS: mount server address does not match mountproto= "
-			 "option\n");
-	return 0;
-out_proto_mismatch:
-	printk(KERN_INFO "NFS: server address does not match proto= option\n");
-	return 0;
-out_migration_misuse:
-	printk(KERN_INFO
-		"NFS: 'migration' not supported for this NFS version\n");
-	return -EINVAL;
-out_nomem:
-	printk(KERN_INFO "NFS: not enough memory to parse option\n");
-	return 0;
-out_security_failure:
-	free_secdata(secdata);
-	printk(KERN_INFO "NFS: security options invalid: %d\n", rc);
-	return 0;
-}
-
-/*
- * Split "dev_name" into "hostname:export_path".
+ * Split sc->device into "hostname:export_path".
  *
  * The leftmost colon demarks the split between the server's hostname
  * and the export path.  If the hostname starts with a left square
@@ -963,9 +829,9 @@ int nfs_parse_mount_options(char *raw, struct nfs_fs_context *ctx)
  * Note: caller frees hostname and export path, even on error.
  */
 static int nfs_parse_devname(struct nfs_fs_context *ctx,
-			     const char *dev_name,
 			     size_t maxnamlen, size_t maxpathlen)
 {
+	char *dev_name = ctx->fc.device;
 	size_t len;
 	char *end;
 
@@ -1009,19 +875,15 @@ static int nfs_parse_devname(struct nfs_fs_context *ctx,
 	return 0;
 
 out_bad_devname:
-	dfprintk(MOUNT, "NFS: device name not in host:path format\n");
-	return -EINVAL;
-
+	return invalf("NFS: device name not in host:path format");
 out_nomem:
-	dfprintk(MOUNT, "NFS: not enough memory to parse device name\n");
+	errorf("NFS: not enough memory to parse device name");
 	return -ENOMEM;
-
 out_hostname:
-	dfprintk(MOUNT, "NFS: server hostname too long\n");
+	errorf("NFS: server hostname too long");
 	return -ENAMETOOLONG;
-
 out_path:
-	dfprintk(MOUNT, "NFS: export pathname too long\n");
+	errorf("NFS: export pathname too long");
 	return -ENAMETOOLONG;
 }
 
@@ -1041,14 +903,14 @@ static int nfs_parse_devname(struct nfs_fs_context *ctx,
  * + breaking back: trying proto=udp after proto=tcp, v2 after v3,
  *   mountproto=tcp after mountproto=udp, and so on
  */
-static int nfs23_validate_mount_data(void *options,
-				     struct nfs_fs_context *ctx,
-				     struct nfs_fh *mntfh,
-				     const char *dev_name)
+static int nfs23_monolithic_mount_data(struct fs_context *fc,
+				       struct nfs_mount_data *data)
 {
-	struct nfs_mount_data *data = (struct nfs_mount_data *)options;
+	struct nfs_fs_context *ctx = container_of(fc, struct nfs_fs_context, fc);
+	struct nfs_fh *mntfh = ctx->mntfh;
 	struct sockaddr *sap = (struct sockaddr *)&ctx->nfs_server.address;
 	int extra_flags = NFS_MOUNT_LEGACY_INTERFACE;
+	int ret;
 
 	if (data == NULL)
 		goto out_no_data;
@@ -1114,6 +976,9 @@ static int nfs23_validate_mount_data(void *options,
 			ctx->nfs_server.protocol = XPRT_TRANSPORT_UDP;
 		/* N.B. caller will free nfs_server.hostname in all cases */
 		ctx->nfs_server.hostname = kstrdup(data->hostname, GFP_KERNEL);
+		if (!ctx->nfs_server.hostname)
+			goto out_nomem;
+
 		ctx->namlen		= data->namlen;
 		ctx->bsize		= data->bsize;
 
@@ -1121,8 +986,6 @@ static int nfs23_validate_mount_data(void *options,
 			ctx->selected_flavor = data->pseudoflavor;
 		else
 			ctx->selected_flavor = RPC_AUTH_UNIX;
-		if (!ctx->nfs_server.hostname)
-			goto out_nomem;
 
 		if (!(data->flags & NFS_MOUNT_NONLM))
 			ctx->flags &= ~(NFS_MOUNT_LOCAL_FLOCK|
@@ -1130,6 +993,7 @@ static int nfs23_validate_mount_data(void *options,
 		else
 			ctx->flags |= (NFS_MOUNT_LOCAL_FLOCK|
 					NFS_MOUNT_LOCAL_FCNTL);
+
 		/*
 		 * The legacy version 6 binary mount data from userspace has a
 		 * field used only to transport selinux information into the
@@ -1140,17 +1004,16 @@ static int nfs23_validate_mount_data(void *options,
 		 */
 		if (data->context[0]){
 #ifdef CONFIG_SECURITY_SELINUX
-			int rc;
 			char *opts_str = kmalloc(sizeof(data->context) + 8, GFP_KERNEL);
 			if (!opts_str)
 				return -ENOMEM;
 			strcpy(opts_str, "context=");
 			data->context[NFS_MAX_CONTEXT_LEN] = '\0';
 			strcat(opts_str, &data->context[0]);
-			rc = security_sb_parse_opts_str(opts_str, &ctx->lsm_opts);
+			ret = vfs_parse_mount_option(fc, opts_str);
 			kfree(opts_str);
-			if (rc)
-				return rc;
+			if (ret)
+				return ret;
 #else
 			return -EINVAL;
 #endif
@@ -1158,54 +1021,44 @@ static int nfs23_validate_mount_data(void *options,
 
 		break;
 	default:
-		return NFS_TEXT_DATA;
+		return generic_monolithic_mount_data(fc, data);
 	}
 
+	ctx->skip_remount_option_check = true;
 	return 0;
 
 out_no_data:
-	dfprintk(MOUNT, "NFS: mount program didn't pass any mount data\n");
-	return -EINVAL;
+	if (fc->sb_flags & MS_REMOUNT) {
+		ctx->skip_remount_option_check = true;
+		return 0;
+	}
+	return invalf("NFS: mount program didn't pass any mount data");
 
 out_no_v3:
-	dfprintk(MOUNT, "NFS: nfs_mount_data version %d does not support v3\n",
-		 data->version);
-	return -EINVAL;
+	return invalf("NFS: nfs_mount_data version does not support v3");
 
 out_no_sec:
-	dfprintk(MOUNT, "NFS: nfs_mount_data version supports only AUTH_SYS\n");
-	return -EINVAL;
+	return invalf("NFS: nfs_mount_data version supports only AUTH_SYS");
 
 out_nomem:
-	dfprintk(MOUNT, "NFS: not enough memory to handle mount options\n");
+	dfprintk(MOUNT, "NFS: not enough memory to handle mount options");
 	return -ENOMEM;
 
 out_no_address:
-	dfprintk(MOUNT, "NFS: mount program didn't pass remote address\n");
-	return -EINVAL;
+	return invalf("NFS: mount program didn't pass remote address");
 
 out_invalid_fh:
-	dfprintk(MOUNT, "NFS: invalid root filehandle\n");
-	return -EINVAL;
-}
-
-#if IS_ENABLED(CONFIG_NFS_V4)
-
-static void nfs4_validate_mount_flags(struct nfs_fs_context *ctx)
-{
-	ctx->flags &= ~(NFS_MOUNT_NONLM|NFS_MOUNT_NOACL|NFS_MOUNT_VER3|
-			 NFS_MOUNT_LOCAL_FLOCK|NFS_MOUNT_LOCAL_FCNTL);
+	return invalf("NFS: invalid root filehandle");
 }
 
 /*
  * Validate NFSv4 mount options
  */
-static int nfs4_validate_mount_data(void *options,
-				    struct nfs_fs_context *ctx,
-				    const char *dev_name)
+static int nfs4_monolithic_mount_data(struct fs_context *fc,
+				      struct nfs4_mount_data *data)
 {
+	struct nfs_fs_context *ctx = container_of(fc, struct nfs_fs_context, fc);
 	struct sockaddr *sap = (struct sockaddr *)&ctx->nfs_server.address;
-	struct nfs4_mount_data *data = (struct nfs4_mount_data *)options;
 	char *c;
 
 	if (data == NULL)
@@ -1255,7 +1108,7 @@ static int nfs4_validate_mount_data(void *options,
 		ctx->client_address = c;
 
 		/*
-		 * Translate to nfs_fs_context, which nfs4_fill_super
+		 * Translate to nfs_fs_context, which nfs_fill_super
 		 * can deal with.
 		 */
 
@@ -1275,95 +1128,372 @@ static int nfs4_validate_mount_data(void *options,
 
 		break;
 	default:
-		return NFS_TEXT_DATA;
+		return generic_monolithic_mount_data(fc, data);
 	}
 
+	ctx->skip_remount_option_check = true;
 	return 0;
 
 out_no_data:
-	dfprintk(MOUNT, "NFS4: mount program didn't pass any mount data\n");
-	return -EINVAL;
+	if (fc->sb_flags & MS_REMOUNT) {
+		ctx->skip_remount_option_check = true;
+		return 0;
+	}
+	return invalf("NFS4: mount program didn't pass any mount data");
 
 out_inval_auth:
-	dfprintk(MOUNT, "NFS4: Invalid number of RPC auth flavours %d\n",
-		 data->auth_flavourlen);
-	return -EINVAL;
+	return invalf("NFS4: Invalid number of RPC auth flavours %d",
+		      data->auth_flavourlen);
 
 out_no_address:
-	dfprintk(MOUNT, "NFS4: mount program didn't pass remote address\n");
-	return -EINVAL;
+	return invalf("NFS4: mount program didn't pass remote address");
 
 out_invalid_transport_udp:
-	dfprintk(MOUNT, "NFSv4: Unsupported transport protocol udp\n");
-	return -EINVAL;
+	return invalf("NFSv4: Unsupported transport protocol udp");
 }
 
-int nfs_validate_mount_data(struct file_system_type *fs_type,
-			    void *options,
-			    struct nfs_fs_context *ctx,
-			    struct nfs_fh *mntfh,
-			    const char *dev_name)
-{
-	if (fs_type == &nfs_fs_type)
-		return nfs23_validate_mount_data(options, ctx, mntfh, dev_name);
-	return nfs4_validate_mount_data(options, ctx, dev_name);
-}
-#else
-int nfs_validate_mount_data(struct file_system_type *fs_type,
-			    void *options,
-			    struct nfs_fs_context *ctx,
-			    struct nfs_fh *mntfh,
-			    const char *dev_name)
+/*
+ * Parse a monolithic block of data from sys_mount().
+ */
+static int nfs_monolithic_mount_data(struct fs_context *fc, void *data)
 {
-	return nfs23_validate_mount_data(options, ctx, mntfh, dev_name);
-}
+	if (fc->fs_type == &nfs_fs_type)
+		return nfs23_monolithic_mount_data(fc, data);
+
+#if IS_ENABLED(CONFIG_NFS_V4)
+	if (fc->fs_type == &nfs4_fs_type)
+		return nfs4_monolithic_mount_data(fc, data);
 #endif
 
-int nfs_validate_text_mount_data(void *options,
-				 struct nfs_fs_context *ctx,
-				 const char *dev_name)
+	return invalf("NFS: Unsupported monolithic data version");
+}
+
+/*
+ * Validate the preparsed information in the config.
+ */
+static int nfs_fs_context_validate(struct fs_context *fc)
 {
-	int port = 0;
+	struct nfs_fs_context *ctx = container_of(fc, struct nfs_fs_context, fc);
+	struct nfs_subversion *nfs_mod;
+	struct sockaddr *sap = (struct sockaddr *)&ctx->nfs_server.address;
 	int max_namelen = PAGE_SIZE;
 	int max_pathlen = NFS_MAXPATHLEN;
-	struct sockaddr *sap = (struct sockaddr *)&ctx->nfs_server.address;
+	int port = 0;
+	int ret;
 
-	if (nfs_parse_mount_options((char *)options, ctx) == 0)
-		return -EINVAL;
+	if (ctx->fc.purpose == FS_CONTEXT_FOR_REMOUNT)
+		return 0;
+
+	if (!ctx->fc.device)
+		goto out_no_device_name;
+
+	/* Check for sanity first. */
+	if (ctx->minorversion && ctx->version != 4)
+		goto out_minorversion_mismatch;
+
+	if (ctx->options & NFS_OPTION_MIGRATION &&
+	    (ctx->version != 4 || ctx->minorversion != 0))
+		goto out_migration_misuse;
+
+	/* Verify that any proto=/mountproto= options match the address
+	 * families in the addr=/mountaddr= options.
+	 */
+	if (ctx->protofamily != AF_UNSPEC &&
+	    ctx->protofamily != ctx->nfs_server.address.sa_family)
+		goto out_proto_mismatch;
+
+	if (ctx->mountfamily != AF_UNSPEC) {
+		if (ctx->mount_server.addrlen) {
+			if (ctx->mountfamily != ctx->mount_server.address.sa_family)
+				goto out_mountproto_mismatch;
+		} else {
+			if (ctx->mountfamily != ctx->nfs_server.address.sa_family)
+				goto out_mountproto_mismatch;
+		}
+	}
 
 	if (!nfs_verify_server_address(sap))
 		goto out_no_address;
 
 	if (ctx->version == 4) {
-#if IS_ENABLED(CONFIG_NFS_V4)
-		port = NFS_PORT;
-		max_namelen = NFS4_MAXNAMLEN;
-		max_pathlen = NFS4_MAXPATHLEN;
-		nfs_validate_transport_protocol(ctx);
-		if (ctx->nfs_server.protocol == XPRT_TRANSPORT_UDP)
-			goto out_invalid_transport_udp;
-		nfs4_validate_mount_flags(ctx);
-#else
-		goto out_v4_not_compiled;
-#endif /* CONFIG_NFS_V4 */
-	} else
+		if (IS_ENABLED(CONFIG_NFS_V4)) {
+			port = NFS_PORT;
+			max_namelen = NFS4_MAXNAMLEN;
+			max_pathlen = NFS4_MAXPATHLEN;
+			nfs_validate_transport_protocol(ctx);
+			if (ctx->nfs_server.protocol == XPRT_TRANSPORT_UDP)
+				goto out_invalid_transport_udp;
+			ctx->flags &= ~(NFS_MOUNT_NONLM | NFS_MOUNT_NOACL |
+					 NFS_MOUNT_VER3 | NFS_MOUNT_LOCAL_FLOCK |
+					 NFS_MOUNT_LOCAL_FCNTL);
+		} else {
+			goto out_v4_not_compiled;
+		}
+	} else {
 		nfs_set_mount_transport_protocol(ctx);
+	}
 
 	nfs_set_port(sap, &ctx->nfs_server.port, port);
 
-	return nfs_parse_devname(ctx, dev_name, max_namelen, max_pathlen);
+	ret = nfs_parse_devname(ctx, max_namelen, max_pathlen);
+	if (ret < 0)
+		return ret;
 
-#if !IS_ENABLED(CONFIG_NFS_V4)
+	/* Load the NFS protocol module if we haven't done so yet */
+	if (!ctx->nfs_mod) {
+		nfs_mod = get_nfs_version(ctx->version);
+		if (IS_ERR(nfs_mod)) {
+			ret = PTR_ERR(nfs_mod);
+			goto out_version_unavailable;
+		}
+		ctx->nfs_mod = nfs_mod;
+	}
+	return 0;
+
+out_no_device_name:
+	return invalf("NFS: Device name not specified");
 out_v4_not_compiled:
-	dfprintk(MOUNT, "NFS: NFSv4 is not compiled into kernel\n");
+	errorf("NFS: NFSv4 is not compiled into kernel");
 	return -EPROTONOSUPPORT;
-#else
 out_invalid_transport_udp:
-	dfprintk(MOUNT, "NFSv4: Unsupported transport protocol udp\n");
-	return -EINVAL;
-#endif /* !CONFIG_NFS_V4 */
-
+	return invalf("NFSv4: Unsupported transport protocol udp");
 out_no_address:
-	dfprintk(MOUNT, "NFS: mount program didn't pass remote address\n");
-	return -EINVAL;
+	return invalf("NFS: mount program didn't pass remote address");
+out_mountproto_mismatch:
+	return invalf("NFS: Mount server address does not match mountproto= option");
+out_proto_mismatch:
+	return invalf("NFS: Server address does not match proto= option");
+out_minorversion_mismatch:
+	return invalf("NFS: Mount option vers=%u does not support minorversion=%u",
+		      ctx->version, ctx->minorversion);
+out_migration_misuse:
+	return invalf("NFS: 'Migration' not supported for this NFS version");
+out_version_unavailable:
+	errorf("NFS: Version unavailable");
+	return ret;
+}
+
+/*
+ * Use the preparsed information in the config to effect a mount.
+ */
+static int nfs_get_ordinary_tree(struct nfs_fs_context *ctx)
+{
+	ctx->set_security = nfs_set_sb_security;
+
+	return ctx->nfs_mod->rpc_ops->try_get_tree(ctx);
 }
+
+/*
+ * Clone an NFS2/3/4 server record on xdev traversal (FSID-change)
+ */
+static int nfs_get_xdev_tree(struct nfs_fs_context *ctx)
+{
+	struct nfs_server *server;
+	int ret;
+
+	dprintk("--> nfs_xdev_mount()\n");
+
+	ctx->set_security = nfs_clone_sb_security;
+
+	/* create a new volume representation */
+	server = ctx->nfs_mod->rpc_ops->clone_server(NFS_SB(ctx->clone_data.sb),
+						     ctx->mntfh,
+						     ctx->clone_data.fattr,
+						     ctx->selected_flavor);
+
+	if (IS_ERR(server))
+		ret = PTR_ERR(server);
+	else
+		ret = nfs_get_tree_common(server, ctx);
+
+	dprintk("<-- nfs_get_xdev_tree() = %d\n", ret);
+	return ret;
+}
+
+/*
+ * Create an NFS superblock by the appropriate method.
+ */
+static int nfs_get_tree(struct fs_context *fc)
+{
+	struct nfs_fs_context *ctx = container_of(fc, struct nfs_fs_context, fc);
+	int ret;
+
+	if (!ctx->nfs_mod) {
+		pr_warn("Missing nfs_mod\n");
+		return -EINVAL;
+	}
+	if (!ctx->nfs_mod->rpc_ops) {
+		pr_warn("Missing rpc_ops\n");
+		return -EINVAL;
+	}
+
+	if (ctx->nfs_mod->rpc_ops->get_tree) {
+		ret = ctx->nfs_mod->rpc_ops->get_tree(ctx);
+		if (ret != 1)
+			return ret;
+	}
+
+	switch (ctx->mount_type) {
+	case NFS_MOUNT_ORDINARY:
+		return nfs_get_ordinary_tree(ctx);
+
+	case NFS_MOUNT_CROSS_DEV:
+		return nfs_get_xdev_tree(ctx);
+
+	default:
+		errorf("NFS: Unknown mount type");
+		return -ENOTSUPP;
+	}
+}
+
+/*
+ * Handle duplication of a configuration.  The caller copied *src into *sc, but
+ * it can't deal with resource pointers in the filesystem context, so we have
+ * to do that.  We need to clear pointers, copy data or get extra refs as
+ * appropriate.
+ */
+static int nfs_fs_context_dup(struct fs_context *fc, struct fs_context *src)
+{
+	struct nfs_fs_context *ctx = container_of(fc, struct nfs_fs_context, fc);
+
+	__module_get(ctx->nfs_mod->owner);
+	ctx->client_address		= NULL;
+	ctx->mount_server.hostname	= NULL;
+	ctx->nfs_server.export_path	= NULL;
+	ctx->nfs_server.hostname	= NULL;
+	ctx->fscache_uniq		= NULL;
+
+	ctx->mntfh = nfs_alloc_fhandle();
+	if (!ctx->mntfh)
+		return -ENOMEM;
+	return 0;
+}
+
+static void nfs_fs_context_free(struct fs_context *fc)
+{
+	struct nfs_fs_context *ctx = container_of(fc, struct nfs_fs_context, fc);
+
+	if (ctx->nfs_mod)
+		put_nfs_version(ctx->nfs_mod);
+	kfree(ctx->client_address);
+	kfree(ctx->mount_server.hostname);
+	if (ctx->nfs_server.export_path != nfs_slash)
+		kfree(ctx->nfs_server.export_path);
+	kfree(ctx->nfs_server.hostname);
+	kfree(ctx->fscache_uniq);
+	nfs_free_fhandle(ctx->mntfh);
+}
+
+static const struct fs_context_operations nfs_fs_context_ops = {
+	.free			= nfs_fs_context_free,
+	.dup			= nfs_fs_context_dup,
+	.parse_option		= nfs_fs_context_parse_option,
+	.monolithic_mount_data	= nfs_monolithic_mount_data,
+	.validate		= nfs_fs_context_validate,
+	.get_tree		= nfs_get_tree,
+};
+
+/*
+ * Initialise a configuration from an extant superblock for remounting.
+ */
+static int nfs_mount_init_from_sb(struct fs_context *fc,
+				  struct super_block *sb)
+{
+	struct nfs_fs_context *ctx = container_of(fc, struct nfs_fs_context, fc);
+	struct nfs_server *nfss = sb->s_fs_info;
+	struct net *net = nfss->nfs_client->cl_net;
+
+	ctx->flags		= nfss->flags;
+	ctx->rsize		= nfss->rsize;
+	ctx->wsize		= nfss->wsize;
+	ctx->retrans		= nfss->client->cl_timeout->to_retries;
+	ctx->selected_flavor	= nfss->client->cl_auth->au_flavor;
+	ctx->acregmin		= nfss->acregmin / HZ;
+	ctx->acregmax		= nfss->acregmax / HZ;
+	ctx->acdirmin		= nfss->acdirmin / HZ;
+	ctx->acdirmax		= nfss->acdirmax / HZ;
+	ctx->timeo		= 10U * nfss->client->cl_timeout->to_initval / HZ;
+	ctx->nfs_server.port	= nfss->port;
+	ctx->nfs_server.addrlen	= nfss->nfs_client->cl_addrlen;
+	ctx->version		= nfss->nfs_client->rpc_ops->version;
+	ctx->minorversion	= nfss->nfs_client->cl_minorversion;
+
+	memcpy(&ctx->nfs_server.address, &nfss->nfs_client->cl_addr,
+		ctx->nfs_server.addrlen);
+
+	if (ctx->fc.net_ns != net) {
+		put_net(ctx->fc.net_ns);
+		ctx->fc.net_ns = get_net(net);
+	}
+
+	ctx->nfs_mod = nfss->nfs_client->cl_nfs_mod;
+	if (!try_module_get(ctx->nfs_mod->owner)) {
+		ctx->nfs_mod = NULL;
+		errorf("NFS: Protocol module not available");
+		return -ENOENT;
+	}
+
+	return 0;
+}
+
+/*
+ * Prepare superblock configuration.  We use the namespaces attached to the
+ * context.  This may be the current process's namespaces, or it may be a
+ * container's namespaces.
+ */
+static int nfs_init_fs_context(struct fs_context *fc, struct super_block *src_sb)
+{
+	struct nfs_fs_context *ctx = container_of(fc, struct nfs_fs_context, fc);
+
+	ctx->mntfh = nfs_alloc_fhandle();
+	if (!ctx->mntfh)
+		return -ENOMEM;
+
+	ctx->fc.ops		= &nfs_fs_context_ops;
+	ctx->mount_type		= NFS_MOUNT_ORDINARY;
+	ctx->protofamily	= AF_UNSPEC;
+	ctx->mountfamily	= AF_UNSPEC;
+	ctx->mount_server.port	= NFS_UNSPEC_PORT;
+
+	if (!src_sb) {
+		ctx->timeo		= NFS_UNSPEC_TIMEO;
+		ctx->retrans		= NFS_UNSPEC_RETRANS;
+		ctx->acregmin		= NFS_DEF_ACREGMIN;
+		ctx->acregmax		= NFS_DEF_ACREGMAX;
+		ctx->acdirmin		= NFS_DEF_ACDIRMIN;
+		ctx->acdirmax		= NFS_DEF_ACDIRMAX;
+		ctx->nfs_server.port	= NFS_UNSPEC_PORT;
+		ctx->nfs_server.protocol = XPRT_TRANSPORT_TCP;
+		ctx->selected_flavor	= RPC_AUTH_MAXFLAVOR;
+		ctx->minorversion	= 0;
+		ctx->need_mount		= true;
+		return 0;
+	}
+
+	return nfs_mount_init_from_sb(fc, src_sb);
+}
+
+struct file_system_type nfs_fs_type = {
+	.owner			= THIS_MODULE,
+	.name			= "nfs",
+	.init_fs_context	= nfs_init_fs_context,
+	.fs_context_size	= sizeof(struct nfs_fs_context),
+	.kill_sb		= nfs_kill_super,
+	.fs_flags		= FS_RENAME_DOES_D_MOVE|FS_BINARY_MOUNTDATA,
+};
+MODULE_ALIAS_FS("nfs");
+EXPORT_SYMBOL_GPL(nfs_fs_type);
+
+#if IS_ENABLED(CONFIG_NFS_V4)
+struct file_system_type nfs4_fs_type = {
+	.owner			= THIS_MODULE,
+	.name			= "nfs4",
+	.fs_context_size	= sizeof(struct nfs_fs_context),
+	.init_fs_context	= nfs_init_fs_context,
+	.kill_sb		= nfs_kill_super,
+	.fs_flags		= FS_RENAME_DOES_D_MOVE|FS_BINARY_MOUNTDATA,
+};
+MODULE_ALIAS_FS("nfs4");
+MODULE_ALIAS("nfs4");
+EXPORT_SYMBOL_GPL(nfs4_fs_type);
+#endif /* CONFIG_NFS_V4 */
diff --git a/fs/nfs/getroot.c b/fs/nfs/getroot.c
index 391dafaf9182..4a5ee38117b5 100644
--- a/fs/nfs/getroot.c
+++ b/fs/nfs/getroot.c
@@ -68,66 +68,70 @@ static int nfs_superblock_set_dummy_root(struct super_block *sb, struct inode *i
 /*
  * get an NFS2/NFS3 root dentry from the root filehandle
  */
-struct dentry *nfs_get_root(struct super_block *sb, struct nfs_fh *mntfh,
-			    const char *devname)
+int nfs_get_root(struct super_block *s, struct nfs_fs_context *ctx)
 {
-	struct nfs_server *server = NFS_SB(sb);
+	struct nfs_server *server = NFS_SB(s);
 	struct nfs_fsinfo fsinfo;
-	struct dentry *ret;
+	struct dentry *root;
 	struct inode *inode;
-	void *name = kstrdup(devname, GFP_KERNEL);
-	int error;
+	char *name;
+	int error = -ENOMEM;
 
+	name = kstrdup(ctx->fc.device, GFP_KERNEL);
 	if (!name)
-		return ERR_PTR(-ENOMEM);
+		goto out;
 
 	/* get the actual root for this mount */
 	fsinfo.fattr = nfs_alloc_fattr();
-	if (fsinfo.fattr == NULL) {
-		kfree(name);
-		return ERR_PTR(-ENOMEM);
-	}
+	if (fsinfo.fattr == NULL)
+		goto out_name;
 
-	error = server->nfs_client->rpc_ops->getroot(server, mntfh, &fsinfo);
+	error = server->nfs_client->rpc_ops->getroot(server, ctx->mntfh, &fsinfo);
 	if (error < 0) {
 		dprintk("nfs_get_root: getattr error = %d\n", -error);
-		ret = ERR_PTR(error);
-		goto out;
+		errorf("NFS: Couldn't getattr on root");
+		goto out_fattr;
 	}
 
-	inode = nfs_fhget(sb, mntfh, fsinfo.fattr, NULL);
+	inode = nfs_fhget(s, ctx->mntfh, fsinfo.fattr, NULL);
 	if (IS_ERR(inode)) {
 		dprintk("nfs_get_root: get root inode failed\n");
-		ret = ERR_CAST(inode);
-		goto out;
+		error = PTR_ERR(inode);
+		errorf("NFS: Couldn't get root inode");
+		goto out_fattr;
 	}
 
-	error = nfs_superblock_set_dummy_root(sb, inode);
-	if (error != 0) {
-		ret = ERR_PTR(error);
-		goto out;
-	}
+	error = nfs_superblock_set_dummy_root(s, inode);
+	if (error != 0)
+		goto out_fattr;
 
 	/* root dentries normally start off anonymous and get spliced in later
 	 * if the dentry tree reaches them; however if the dentry already
 	 * exists, we'll pick it up at this point and use it as the root
 	 */
-	ret = d_obtain_root(inode);
-	if (IS_ERR(ret)) {
+	root = d_obtain_root(inode);
+	if (IS_ERR(root)) {
 		dprintk("nfs_get_root: get root dentry failed\n");
-		goto out;
+		error = PTR_ERR(root);
+		errorf("NFS: Couldn't get root dentry");
+		goto out_fattr;
 	}
 
-	security_d_instantiate(ret, inode);
-	spin_lock(&ret->d_lock);
-	if (IS_ROOT(ret) && !ret->d_fsdata &&
-	    !(ret->d_flags & DCACHE_NFSFS_RENAMED)) {
-		ret->d_fsdata = name;
+	security_d_instantiate(root, inode);
+	spin_lock(&root->d_lock);
+	if (IS_ROOT(root) && !root->d_fsdata &&
+	    !(root->d_flags & DCACHE_NFSFS_RENAMED)) {
+		root->d_fsdata = name;
 		name = NULL;
 	}
-	spin_unlock(&ret->d_lock);
-out:
-	kfree(name);
+	spin_unlock(&root->d_lock);
+	ctx->fc.root = root;
+	error = 0;
+
+out_fattr:
 	nfs_free_fattr(fsinfo.fattr);
-	return ret;
+out_name:
+	kfree(name);
+out:
+	return error;
 }
diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
index fa568407cda8..ef7193479cda 100644
--- a/fs/nfs/internal.h
+++ b/fs/nfs/internal.h
@@ -3,7 +3,7 @@
  */
 
 #include "nfs4_fs.h"
-#include <linux/mount.h>
+#include <linux/fs_context.h>
 #include <linux/security.h>
 #include <linux/crc32.h>
 #include <linux/sunrpc/addr.h>
@@ -36,18 +36,6 @@ static inline int nfs_attr_use_mounted_on_fileid(struct nfs_fattr *fattr)
 	return 1;
 }
 
-struct nfs_clone_mount {
-	const struct super_block *sb;
-	const struct dentry *dentry;
-	struct nfs_fh *fh;
-	struct nfs_fattr *fattr;
-	char *hostname;
-	char *mnt_path;
-	struct sockaddr *addr;
-	size_t addrlen;
-	rpc_authflavor_t authflavor;
-};
-
 /*
  * Note: RFC 1813 doesn't limit the number of auth flavors that
  * a server can return, so make something up.
@@ -82,10 +70,22 @@ struct nfs_client_initdata {
 	const struct rpc_timeout *timeparms;
 };
 
+enum nfs_mount_type {
+	NFS_MOUNT_ORDINARY,
+	NFS_MOUNT_CROSS_DEV,
+	NFS4_MOUNT_REMOTE,
+	NFS4_MOUNT_REFERRAL,
+	NFS4_MOUNT_REMOTE_REFERRAL,
+};
+
 /*
  * In-kernel mount arguments
  */
 struct nfs_fs_context {
+	struct fs_context	fc;
+	enum nfs_mount_type	mount_type : 8;
+	bool			skip_remount_option_check;
+	bool			need_mount;
 	unsigned int		flags;		/* NFS{,4}_MOUNT_* flags */
 	unsigned int		rsize, wsize;
 	unsigned int		timeo, retrans;
@@ -102,8 +102,6 @@ struct nfs_fs_context {
 	char			*fscache_uniq;
 	unsigned short		protofamily;
 	unsigned short		mountfamily;
-	bool			need_mount;
-	bool			sloppy;
 
 	struct {
 		union {
@@ -127,10 +125,22 @@ struct nfs_fs_context {
 		char			*export_path;
 		int			port;
 		unsigned short		protocol;
+		unsigned short		export_path_len;
 	} nfs_server;
 
-	struct security_mnt_opts lsm_opts;
-	struct net		*net;
+	struct nfs_fh		*mntfh;
+	struct nfs_subversion	*nfs_mod;
+	struct nfs_server	*server;
+
+	int (*set_security)(struct super_block *, struct nfs_fs_context *);
+
+	/* Information for a cloned mount. */
+	struct nfs_clone_mount {
+		struct super_block	*sb;
+		struct dentry		*dentry;
+		struct nfs_fattr	*fattr;
+		bool			cloned;
+	} clone_data;
 
 	char			buf[32];	/* Parse buffer */
 };
@@ -150,14 +160,6 @@ struct nfs_mount_request {
 	struct net		*net;
 };
 
-struct nfs_mount_info {
-	void (*fill_super)(struct super_block *, struct nfs_mount_info *);
-	int (*set_security)(struct super_block *, struct dentry *, struct nfs_mount_info *);
-	struct nfs_fs_context *ctx;
-	struct nfs_clone_mount *cloned;
-	struct nfs_fh *mntfh;
-};
-
 extern int nfs_mount(struct nfs_mount_request *info);
 extern void nfs_umount(const struct nfs_mount_request *info);
 
@@ -183,13 +185,9 @@ extern struct nfs_client *nfs4_find_client_ident(struct net *, int);
 extern struct nfs_client *
 nfs4_find_client_sessionid(struct net *, const struct sockaddr *,
 				struct nfs4_sessionid *, u32);
-extern struct nfs_server *nfs_create_server(struct nfs_mount_info *,
-					struct nfs_subversion *);
-extern struct nfs_server *nfs4_create_server(
-					struct nfs_mount_info *,
-					struct nfs_subversion *);
-extern struct nfs_server *nfs4_create_referral_server(struct nfs_clone_mount *,
-						      struct nfs_fh *);
+extern struct nfs_server *nfs_create_server(struct nfs_fs_context *);
+extern struct nfs_server *nfs4_create_server(struct nfs_fs_context *);
+extern struct nfs_server *nfs4_create_referral_server(struct nfs_fs_context *);
 extern int nfs4_update_server(struct nfs_server *server, const char *hostname,
 					struct sockaddr *sap, size_t salen,
 					struct net *net);
@@ -243,19 +241,7 @@ extern struct svc_version nfs4_callback_version4;
 struct nfs_pageio_descriptor;
 
 /* mount.c */
-#define NFS_TEXT_DATA		1
-
-extern struct nfs_fs_context *nfs_alloc_parsed_mount_data(void);
-extern void nfs_free_parsed_mount_data(struct nfs_fs_context *ctx);
-extern int nfs_parse_mount_options(char *raw, struct nfs_fs_context *ctx);
-extern int nfs_validate_mount_data(struct file_system_type *fs_type,
-				   void *options,
-				   struct nfs_fs_context *ctx,
-				   struct nfs_fh *mntfh,
-				   const char *dev_name);
-extern int nfs_validate_text_mount_data(void *options,
-					struct nfs_fs_context *ctx,
-					const char *dev_name);
+extern const char nfs_slash[];
 
 /* pagelist.c */
 extern int __init nfs_init_nfspagecache(void);
@@ -418,23 +404,12 @@ extern int nfs_wait_atomic_killable(atomic_t *p);
 /* super.c */
 extern const struct super_operations nfs_sops;
 extern struct file_system_type nfs_fs_type;
-extern struct file_system_type nfs_xdev_fs_type;
-#if IS_ENABLED(CONFIG_NFS_V4)
-extern struct file_system_type nfs4_xdev_fs_type;
-extern struct file_system_type nfs4_referral_fs_type;
-#endif
 bool nfs_auth_info_match(const struct nfs_auth_info *, rpc_authflavor_t);
-struct dentry *nfs_try_mount(int, const char *, struct nfs_mount_info *,
-			struct nfs_subversion *);
-int nfs_set_sb_security(struct super_block *, struct dentry *, struct nfs_mount_info *);
-int nfs_clone_sb_security(struct super_block *, struct dentry *, struct nfs_mount_info *);
-struct dentry *nfs_fs_mount_common(struct nfs_server *, int, const char *,
-				   struct nfs_mount_info *, struct nfs_subversion *);
-struct dentry *nfs_fs_mount(struct file_system_type *, int, const char *, void *);
-struct dentry * nfs_xdev_mount_common(struct file_system_type *, int,
-		const char *, struct nfs_mount_info *);
+int nfs_try_get_tree(struct nfs_fs_context *);
+int nfs_set_sb_security(struct super_block *, struct nfs_fs_context *);
+int nfs_clone_sb_security(struct super_block *, struct nfs_fs_context *);
+int nfs_get_tree_common(struct nfs_server *, struct nfs_fs_context *);
 void nfs_kill_super(struct super_block *);
-void nfs_fill_super(struct super_block *, struct nfs_mount_info *);
 
 extern struct rpc_stat nfs_rpcstat;
 
@@ -467,12 +442,9 @@ struct vfsmount *nfs_do_submount(struct dentry *, struct nfs_fh *,
 				 struct nfs_fattr *, rpc_authflavor_t);
 
 /* getroot.c */
-extern struct dentry *nfs_get_root(struct super_block *, struct nfs_fh *,
-				   const char *);
+extern int nfs_get_root(struct super_block *s, struct nfs_fs_context *cfg);
 #if IS_ENABLED(CONFIG_NFS_V4)
-extern struct dentry *nfs4_get_root(struct super_block *, struct nfs_fh *,
-				    const char *);
-
+extern int nfs4_get_root(struct super_block *s, struct nfs_fs_context *cfg);
 extern int nfs4_get_rootfh(struct nfs_server *server, struct nfs_fh *mntfh, bool);
 #endif
 
@@ -491,7 +463,7 @@ int  nfs_show_options(struct seq_file *, struct dentry *);
 int  nfs_show_devname(struct seq_file *, struct dentry *);
 int  nfs_show_path(struct seq_file *, struct dentry *);
 int  nfs_show_stats(struct seq_file *, struct dentry *);
-int nfs_remount(struct super_block *sb, int *flags, char *raw_data);
+int nfs_remount(struct super_block *sb, struct fs_context *fc);
 
 /* write.c */
 extern void nfs_pageio_init_write(struct nfs_pageio_descriptor *pgio,
diff --git a/fs/nfs/namespace.c b/fs/nfs/namespace.c
index e5686be67be8..f80062d626f9 100644
--- a/fs/nfs/namespace.c
+++ b/fs/nfs/namespace.c
@@ -18,6 +18,7 @@
 #include <linux/vfs.h>
 #include <linux/sunrpc/gss_api.h>
 #include "internal.h"
+#include "nfs.h"
 
 #define NFSDBG_FACILITY		NFSDBG_VFS
 
@@ -209,16 +210,6 @@ void nfs_release_automount_timer(void)
 		cancel_delayed_work(&nfs_automount_task);
 }
 
-/*
- * Clone a mountpoint of the appropriate type
- */
-static struct vfsmount *nfs_do_clone_mount(struct nfs_server *server,
-					   const char *devname,
-					   struct nfs_clone_mount *mountdata)
-{
-	return vfs_submount(mountdata->dentry, &nfs_xdev_fs_type, devname, mountdata);
-}
-
 /**
  * nfs_do_submount - set up mountpoint when crossing a filesystem boundary
  * @dentry - parent directory
@@ -230,27 +221,58 @@ static struct vfsmount *nfs_do_clone_mount(struct nfs_server *server,
 struct vfsmount *nfs_do_submount(struct dentry *dentry, struct nfs_fh *fh,
 				 struct nfs_fattr *fattr, rpc_authflavor_t authflavor)
 {
-	struct nfs_clone_mount mountdata = {
-		.sb = dentry->d_sb,
-		.dentry = dentry,
-		.fh = fh,
-		.fattr = fattr,
-		.authflavor = authflavor,
-	};
+	struct nfs_fs_context *ctx;
+	struct fs_context *fc;
 	struct vfsmount *mnt;
-	char *page = (char *) __get_free_page(GFP_USER);
-	char *devname;
+	char *buffer, *p;
+	int ret;
+
+	/* Open a new filesystem context, transferring parameters from the
+	 * parent superblock, including the network namespace.
+	 */
+	fc = vfs_new_fs_context(&nfs_fs_type, dentry->d_sb, 0,
+				FS_CONTEXT_FOR_SUBMOUNT);
+	if (IS_ERR(fc))
+		return ERR_CAST(fc);
+	ctx = container_of(fc, struct nfs_fs_context, fc);
+
+	mnt = ERR_PTR(-ENOMEM);
+	buffer = kmalloc(4096, GFP_USER);
+	if (!buffer)
+		goto err_fc;
+
+	ctx->mount_type		= NFS_MOUNT_CROSS_DEV;
+	ctx->selected_flavor	= authflavor;
+	ctx->clone_data.sb	= dentry->d_sb;
+	ctx->clone_data.dentry	= dentry;
+	ctx->clone_data.fattr	= fattr;
+	ctx->clone_data.cloned	= true;
+
+	nfs_copy_fh(ctx->mntfh, fh);
+
+	p = nfs_devname(dentry, buffer, 4096);
+	if (IS_ERR(p)) {
+		errorf("NFS: Couldn't determine submount pathname");
+		mnt = ERR_CAST(p);
+		goto err_buffer;
+	}
+
+	ctx->fc.device = kmemdup(p, buffer + 4096 - p, GFP_KERNEL);
+	kfree(buffer);
+	if (!ctx->fc.device)
+		goto err_fc;
 
-	if (page == NULL)
-		return ERR_PTR(-ENOMEM);
+	ret = vfs_get_tree(fc);
+	if (ret < 0)
+		goto err_fc;
 
-	devname = nfs_devname(dentry, page, PAGE_SIZE);
-	if (IS_ERR(devname))
-		mnt = ERR_CAST(devname);
-	else
-		mnt = nfs_do_clone_mount(NFS_SB(dentry->d_sb), devname, &mountdata);
+	mnt = vfs_kern_mount_fc(&ctx->fc);
+	goto err_fc;
 
-	free_page((unsigned long)page);
+err_buffer:
+	kfree(buffer);
+err_fc:
+	put_fs_context(fc);
 	return mnt;
 }
 EXPORT_SYMBOL_GPL(nfs_do_submount);
diff --git a/fs/nfs/nfs3_fs.h b/fs/nfs/nfs3_fs.h
index e134d6548ab7..2094bb1f022e 100644
--- a/fs/nfs/nfs3_fs.h
+++ b/fs/nfs/nfs3_fs.h
@@ -26,7 +26,7 @@ static inline int nfs3_proc_setacls(struct inode *inode, struct posix_acl *acl,
 #endif /* CONFIG_NFS_V3_ACL */
 
 /* nfs3client.c */
-struct nfs_server *nfs3_create_server(struct nfs_mount_info *, struct nfs_subversion *);
+struct nfs_server *nfs3_create_server(struct nfs_fs_context *);
 struct nfs_server *nfs3_clone_server(struct nfs_server *, struct nfs_fh *,
 				     struct nfs_fattr *, rpc_authflavor_t);
 
diff --git a/fs/nfs/nfs3client.c b/fs/nfs/nfs3client.c
index 7879f2a0fcfd..3b99d4985c4c 100644
--- a/fs/nfs/nfs3client.c
+++ b/fs/nfs/nfs3client.c
@@ -45,10 +45,10 @@ static inline void nfs_init_server_aclclient(struct nfs_server *server)
 }
 #endif
 
-struct nfs_server *nfs3_create_server(struct nfs_mount_info *mount_info,
-				      struct nfs_subversion *nfs_mod)
+struct nfs_server *nfs3_create_server(struct nfs_fs_context *ctx)
 {
-	struct nfs_server *server = nfs_create_server(mount_info, nfs_mod);
+	struct nfs_server *server = nfs_create_server(ctx);
+
 	/* Create a client RPC handle for the NFS v3 ACL management interface */
 	if (!IS_ERR(server))
 		nfs_init_server_aclclient(server);
diff --git a/fs/nfs/nfs3proc.c b/fs/nfs/nfs3proc.c
index 0c07b567118d..96e315916a34 100644
--- a/fs/nfs/nfs3proc.c
+++ b/fs/nfs/nfs3proc.c
@@ -975,7 +975,7 @@ const struct nfs_rpc_ops nfs_v3_clientops = {
 	.nlmclnt_ops	= &nlmclnt_fl_close_lock_ops,
 	.getroot	= nfs3_proc_get_root,
 	.submount	= nfs_submount,
-	.try_mount	= nfs_try_mount,
+	.try_get_tree	= nfs_try_get_tree,
 	.getattr	= nfs3_proc_getattr,
 	.setattr	= nfs3_proc_setattr,
 	.lookup		= nfs3_proc_lookup,
diff --git a/fs/nfs/nfs4_fs.h b/fs/nfs/nfs4_fs.h
index af285cc27ccf..c5882668dc8a 100644
--- a/fs/nfs/nfs4_fs.h
+++ b/fs/nfs/nfs4_fs.h
@@ -467,7 +467,6 @@ extern const nfs4_stateid zero_stateid;
 /* nfs4super.c */
 struct nfs_mount_info;
 extern struct nfs_subversion nfs_v4;
-struct dentry *nfs4_try_mount(int, const char *, struct nfs_mount_info *, struct nfs_subversion *);
 extern bool nfs4_disable_idmapping;
 extern unsigned short max_session_slots;
 extern unsigned short max_session_cb_slots;
@@ -477,6 +476,9 @@ extern bool recover_lost_locks;
 #define NFS4_CLIENT_ID_UNIQ_LEN		(64)
 extern char nfs4_client_id_uniquifier[NFS4_CLIENT_ID_UNIQ_LEN];
 
+extern int nfs4_try_get_tree(struct nfs_fs_context *);
+extern int nfs4_get_tree(struct nfs_fs_context *);
+
 /* nfs4sysctl.c */
 #ifdef CONFIG_SYSCTL
 int nfs4_register_sysctl(void);
diff --git a/fs/nfs/nfs4client.c b/fs/nfs/nfs4client.c
index 0b5e1ecfa8f8..431eae161383 100644
--- a/fs/nfs/nfs4client.c
+++ b/fs/nfs/nfs4client.c
@@ -1032,14 +1032,14 @@ static int nfs4_init_server(struct nfs_server *server,
 
 	/* Get a client record */
 	error = nfs4_set_client(server,
-			ctx->nfs_server.hostname,
-			(const struct sockaddr *)&ctx->nfs_server.address,
-			ctx->nfs_server.addrlen,
-			ctx->client_address,
-			ctx->nfs_server.protocol,
-			&timeparms,
-			ctx->minorversion,
-			ctx->net);
+				ctx->nfs_server.hostname,
+				&ctx->nfs_server.address,
+				ctx->nfs_server.addrlen,
+				ctx->client_address,
+				ctx->nfs_server.protocol,
+				&timeparms,
+				ctx->minorversion,
+				ctx->fc.net_ns);
 	if (error < 0)
 		return error;
 
@@ -1062,10 +1062,7 @@ static int nfs4_init_server(struct nfs_server *server,
  * Create a version 4 volume record
  * - keyed on server and FSID
  */
-/*struct nfs_server *nfs4_create_server(const struct nfs_fs_context *data,
-				      struct nfs_fh *mntfh)*/
-struct nfs_server *nfs4_create_server(struct nfs_mount_info *mount_info,
-				      struct nfs_subversion *nfs_mod)
+struct nfs_server *nfs4_create_server(struct nfs_fs_context *ctx)
 {
 	struct nfs_server *server;
 	bool auth_probe;
@@ -1075,14 +1072,14 @@ struct nfs_server *nfs4_create_server(struct nfs_mount_info *mount_info,
 	if (!server)
 		return ERR_PTR(-ENOMEM);
 
-	auth_probe = mount_info->ctx->auth_info.flavor_len < 1;
+	auth_probe = ctx->auth_info.flavor_len < 1;
 
 	/* set up the general RPC client */
-	error = nfs4_init_server(server, mount_info->ctx);
+	error = nfs4_init_server(server, ctx);
 	if (error < 0)
 		goto error;
 
-	error = nfs4_server_common_setup(server, mount_info->mntfh, auth_probe);
+	error = nfs4_server_common_setup(server, ctx->mntfh, auth_probe);
 	if (error < 0)
 		goto error;
 
@@ -1096,8 +1093,7 @@ struct nfs_server *nfs4_create_server(struct nfs_mount_info *mount_info,
 /*
  * Create an NFS4 referral server record
  */
-struct nfs_server *nfs4_create_referral_server(struct nfs_clone_mount *data,
-					       struct nfs_fh *mntfh)
+struct nfs_server *nfs4_create_referral_server(struct nfs_fs_context *ctx)
 {
 	struct nfs_client *parent_client;
 	struct nfs_server *server, *parent_server;
@@ -1108,7 +1104,7 @@ struct nfs_server *nfs4_create_referral_server(struct nfs_clone_mount *data,
 	if (!server)
 		return ERR_PTR(-ENOMEM);
 
-	parent_server = NFS_SB(data->sb);
+	parent_server = NFS_SB(ctx->clone_data.sb);
 	parent_client = parent_server->nfs_client;
 
 	/* Initialise the client representation from the parent server */
@@ -1116,9 +1112,10 @@ struct nfs_server *nfs4_create_referral_server(struct nfs_clone_mount *data,
 
 	/* Get a client representation.
 	 * Note: NFSv4 always uses TCP, */
-	error = nfs4_set_client(server, data->hostname,
-				data->addr,
-				data->addrlen,
+	error = nfs4_set_client(server,
+				ctx->nfs_server.hostname,
+				&ctx->nfs_server.address,
+				ctx->nfs_server.addrlen,
 				parent_client->cl_ipaddr,
 				rpc_protocol(parent_server->client),
 				parent_server->client->cl_timeout,
@@ -1127,13 +1124,14 @@ struct nfs_server *nfs4_create_referral_server(struct nfs_clone_mount *data,
 	if (error < 0)
 		goto error;
 
-	error = nfs_init_server_rpcclient(server, parent_server->client->cl_timeout, data->authflavor);
+	error = nfs_init_server_rpcclient(server, parent_server->client->cl_timeout,
+					  ctx->selected_flavor);
 	if (error < 0)
 		goto error;
 
 	auth_probe = parent_server->auth_info.flavor_len < 1;
 
-	error = nfs4_server_common_setup(server, mntfh, auth_probe);
+	error = nfs4_server_common_setup(server, ctx->mntfh, auth_probe);
 	if (error < 0)
 		goto error;
 
diff --git a/fs/nfs/nfs4namespace.c b/fs/nfs/nfs4namespace.c
index 7d531da1bae3..07466ae971cc 100644
--- a/fs/nfs/nfs4namespace.c
+++ b/fs/nfs/nfs4namespace.c
@@ -7,6 +7,7 @@
  * NFSv4 namespace
  */
 
+#include <linux/module.h>
 #include <linux/dcache.h>
 #include <linux/mount.h>
 #include <linux/namei.h>
@@ -20,37 +21,64 @@
 #include <linux/inet.h>
 #include "internal.h"
 #include "nfs4_fs.h"
+#include "nfs.h"
 #include "dns_resolve.h"
 
 #define NFSDBG_FACILITY		NFSDBG_VFS
 
 /*
+ * Work out the length that an NFSv4 path would render to as a standard posix
+ * path, with a leading slash but no terminating slash.
+ */
+static ssize_t nfs4_pathname_len(const struct nfs4_pathname *pathname)
+{
+	ssize_t len;
+	int i;
+
+	for (i = 0; i < pathname->ncomponents; i++) {
+		const struct nfs4_string *component = &pathname->components[i];
+
+		if (component->len > NAME_MAX)
+			goto too_long;
+		len += 1 + component->len; /* Adding "/foo" */
+		if (len > PATH_MAX)
+			goto too_long;
+	}
+	return len;
+
+too_long:
+	return -ENAMETOOLONG;
+}
+
+/*
  * Convert the NFSv4 pathname components into a standard posix path.
- *
- * Note that the resulting string will be placed at the end of the buffer
  */
-static inline char *nfs4_pathname_string(const struct nfs4_pathname *pathname,
-					 char *buffer, ssize_t buflen)
+static char *nfs4_pathname_string(const struct nfs4_pathname *pathname,
+				  unsigned short *_len)
 {
-	char *end = buffer + buflen;
-	int n;
+	ssize_t len;
+	char *buf, *p;
+	int i;
 
-	*--end = '\0';
-	buflen--;
-
-	n = pathname->ncomponents;
-	while (--n >= 0) {
-		const struct nfs4_string *component = &pathname->components[n];
-		buflen -= component->len + 1;
-		if (buflen < 0)
-			goto Elong;
-		end -= component->len;
-		memcpy(end, component->data, component->len);
-		*--end = '/';
+	len = nfs4_pathname_len(pathname);
+	if (len < 0)
+		return ERR_PTR(len);
+	*_len = len;
+
+	p = buf = kmalloc(len + 1, GFP_KERNEL);
+	if (!buf)
+		return ERR_PTR(-ENOMEM);
+
+	for (i = 0; i < pathname->ncomponents; i++) {
+		const struct nfs4_string *component = &pathname->components[i];
+
+		*p++ = '/';
+		memcpy(p, component->data, component->len);
+		p += component->len;
 	}
-	return end;
-Elong:
-	return ERR_PTR(-ENAMETOOLONG);
+
+	*p = 0;
+	return buf;
 }
 
 /*
@@ -99,21 +127,25 @@ static char *nfs4_path(struct dentry *dentry, char *buffer, ssize_t buflen)
  */
 static int nfs4_validate_fspath(struct dentry *dentry,
 				const struct nfs4_fs_locations *locations,
-				char *page, char *page2)
+				struct nfs_fs_context *ctx)
 {
-	const char *path, *fs_path;
+	const char *path;
+	char *buf;
+	int n;
 
-	path = nfs4_path(dentry, page, PAGE_SIZE);
-	if (IS_ERR(path))
+	buf = kmalloc(4096, GFP_KERNEL);
+	path = nfs4_path(dentry, buf, 4096);
+	if (IS_ERR(path)) {
+		kfree(buf);
 		return PTR_ERR(path);
+	}
 
-	fs_path = nfs4_pathname_string(&locations->fs_path, page2, PAGE_SIZE);
-	if (IS_ERR(fs_path))
-		return PTR_ERR(fs_path);
-
-	if (strncmp(path, fs_path, strlen(fs_path)) != 0) {
+	n = strncmp(path, ctx->nfs_server.export_path,
+		    ctx->nfs_server.export_path_len);
+	kfree(buf);
+	if (n != 0) {
 		dprintk("%s: path %s does not begin with fsroot %s\n",
-			__func__, path, fs_path);
+			__func__, path, ctx->nfs_server.export_path);
 		return -ENOENT;
 	}
 
@@ -234,56 +266,66 @@ nfs4_negotiate_security(struct rpc_clnt *clnt, struct inode *inode,
 	return new;
 }
 
-static struct vfsmount *try_location(struct nfs_clone_mount *mountdata,
-				     char *page, char *page2,
+static struct vfsmount *try_location(struct dentry *dentry,
+				     struct nfs_fs_context *ctx,
 				     const struct nfs4_fs_location *location)
 {
-	const size_t addr_bufsize = sizeof(struct sockaddr_storage);
-	struct net *net = rpc_net_ns(NFS_SB(mountdata->sb)->client);
+	struct net *net = rpc_net_ns(NFS_SB(dentry->d_sb)->client);
 	struct vfsmount *mnt = ERR_PTR(-ENOENT);
-	char *mnt_path;
-	unsigned int maxbuflen;
-	unsigned int s;
+	unsigned int len, s;
+	char *p;
 
-	mnt_path = nfs4_pathname_string(&location->rootpath, page2, PAGE_SIZE);
-	if (IS_ERR(mnt_path))
-		return ERR_CAST(mnt_path);
-	mountdata->mnt_path = mnt_path;
-	maxbuflen = mnt_path - 1 - page2;
+	/* Allocate a buffer big enough to hold any of the hostnames plus a
+	 * terminating char and also a buffer big enough to hold the hostname
+	 * plus a colon plus the path.
+	 */
+	len = 0;
+	for (s = 0; s < location->nservers; s++) {
+		const struct nfs4_string *buf = &location->servers[s];
+		if (buf->len > len)
+			len = buf->len;
+	}
 
-	mountdata->addr = kmalloc(addr_bufsize, GFP_KERNEL);
-	if (mountdata->addr == NULL)
+	ctx->nfs_server.hostname = kmalloc(len + 1, GFP_KERNEL);
+	if (!ctx->nfs_server.hostname)
 		return ERR_PTR(-ENOMEM);
 
+	ctx->fc.device = kmalloc(len + 1 + ctx->nfs_server.export_path_len + 1,
+				 GFP_KERNEL);
+	if (!ctx->fc.device)
+		return ERR_PTR(-ENOMEM);
+	
 	for (s = 0; s < location->nservers; s++) {
 		const struct nfs4_string *buf = &location->servers[s];
 
-		if (buf->len <= 0 || buf->len >= maxbuflen)
-			continue;
-
 		if (memchr(buf->data, IPV6_SCOPE_DELIMITER, buf->len))
 			continue;
 
-		mountdata->addrlen = nfs_parse_server_name(buf->data, buf->len,
-				mountdata->addr, addr_bufsize, net);
-		if (mountdata->addrlen == 0)
+		ctx->nfs_server.addrlen =
+			nfs_parse_server_name(buf->data, buf->len,
+					      &ctx->nfs_server.address,
+					      sizeof(ctx->nfs_server._address),
+					      net);
+		if (ctx->nfs_server.addrlen == 0)
 			continue;
 
-		rpc_set_port(mountdata->addr, NFS_PORT);
+		rpc_set_port(&ctx->nfs_server.address, NFS_PORT);
 
-		memcpy(page2, buf->data, buf->len);
-		page2[buf->len] = '\0';
-		mountdata->hostname = page2;
+		memcpy(ctx->nfs_server.hostname, buf->data, buf->len);
+		ctx->nfs_server.hostname[buf->len] = '\0';
 
-		snprintf(page, PAGE_SIZE, "%s:%s",
-				mountdata->hostname,
-				mountdata->mnt_path);
+		p = ctx->fc.device;
+		memcpy(p, buf->data, buf->len);
+		p += buf->len;
+		*p++ = ':';
+		memcpy(p, ctx->nfs_server.export_path, ctx->nfs_server.export_path_len);
+		p += ctx->nfs_server.export_path_len;
+		*p = 0;
 
-		mnt = vfs_submount(mountdata->dentry, &nfs4_referral_fs_type, page, mountdata);
+		mnt = vfs_kern_mount_fc(&ctx->fc);
 		if (!IS_ERR(mnt))
 			break;
 	}
-	kfree(mountdata->addr);
 	return mnt;
 }
 
@@ -296,33 +338,43 @@ static struct vfsmount *try_location(struct nfs_clone_mount *mountdata,
 static struct vfsmount *nfs_follow_referral(struct dentry *dentry,
 					    const struct nfs4_fs_locations *locations)
 {
-	struct vfsmount *mnt = ERR_PTR(-ENOENT);
-	struct nfs_clone_mount mountdata = {
-		.sb = dentry->d_sb,
-		.dentry = dentry,
-		.authflavor = NFS_SB(dentry->d_sb)->client->cl_auth->au_flavor,
-	};
-	char *page = NULL, *page2 = NULL;
+	struct nfs_fs_context *ctx;
+	struct fs_context *fc;
+	struct vfsmount *mnt;
+	char *export_path;
 	int loc, error;
 
 	if (locations == NULL || locations->nlocations <= 0)
 		goto out;
 
+	fc = vfs_new_fs_context(&nfs4_fs_type, dentry->d_sb, 0,
+			       FS_CONTEXT_FOR_SUBMOUNT);
+	if (IS_ERR(fc)) {
+		mnt = ERR_CAST(fc);
+		goto out;
+	}
+	ctx = container_of(fc, struct nfs_fs_context, fc);
+
 	dprintk("%s: referral at %pd2\n", __func__, dentry);
 
-	page = (char *) __get_free_page(GFP_USER);
-	if (!page)
-		goto out;
+	ctx->mount_type		= NFS4_MOUNT_REFERRAL;
+	ctx->clone_data.sb	= dentry->d_sb;
+	ctx->clone_data.dentry	= dentry;
+	ctx->clone_data.cloned	= true;
 
-	page2 = (char *) __get_free_page(GFP_USER);
-	if (!page2)
-		goto out;
+	export_path = nfs4_pathname_string(&locations->fs_path,
+					   &ctx->nfs_server.export_path_len);
+	if (IS_ERR(export_path)) {
+		mnt = ERR_CAST(export_path);
+		goto out_sc;
+	}
+	ctx->nfs_server.export_path = export_path;
 
 	/* Ensure fs path is a prefix of current dentry path */
-	error = nfs4_validate_fspath(dentry, locations, page, page2);
+	error = nfs4_validate_fspath(dentry, locations, ctx);
 	if (error < 0) {
 		mnt = ERR_PTR(error);
-		goto out;
+		goto out_sc;
 	}
 
 	for (loc = 0; loc < locations->nlocations; loc++) {
@@ -332,14 +384,14 @@ static struct vfsmount *nfs_follow_referral(struct dentry *dentry,
 		    location->rootpath.ncomponents == 0)
 			continue;
 
-		mnt = try_location(&mountdata, page, page2, location);
+		mnt = try_location(ctx->clone_data.dentry, ctx, location);
 		if (!IS_ERR(mnt))
 			break;
 	}
 
+out_sc:
+	put_fs_context(fc);
 out:
-	free_page((unsigned long) page);
-	free_page((unsigned long) page2);
 	return mnt;
 }
 
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index c08c46a3b8cd..ca792f799941 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -9307,8 +9307,9 @@ const struct nfs_rpc_ops nfs_v4_clientops = {
 	.file_inode_ops	= &nfs4_file_inode_operations,
 	.file_ops	= &nfs4_file_operations,
 	.getroot	= nfs4_proc_get_root,
+	.get_tree	= nfs4_get_tree,
 	.submount	= nfs4_submount,
-	.try_mount	= nfs4_try_mount,
+	.try_get_tree	= nfs4_try_get_tree,
 	.getattr	= nfs4_proc_getattr,
 	.setattr	= nfs4_proc_setattr,
 	.lookup		= nfs4_proc_lookup,
diff --git a/fs/nfs/nfs4super.c b/fs/nfs/nfs4super.c
index 70111f222a25..9f2eacfee42c 100644
--- a/fs/nfs/nfs4super.c
+++ b/fs/nfs/nfs4super.c
@@ -3,6 +3,7 @@
  */
 #include <linux/init.h>
 #include <linux/module.h>
+#include <linux/mount.h>
 #include <linux/nfs4_mount.h>
 #include <linux/nfs_fs.h>
 #include "delegation.h"
@@ -17,36 +18,6 @@
 
 static int nfs4_write_inode(struct inode *inode, struct writeback_control *wbc);
 static void nfs4_evict_inode(struct inode *inode);
-static struct dentry *nfs4_remote_mount(struct file_system_type *fs_type,
-	int flags, const char *dev_name, void *raw_data);
-static struct dentry *nfs4_referral_mount(struct file_system_type *fs_type,
-	int flags, const char *dev_name, void *raw_data);
-static struct dentry *nfs4_remote_referral_mount(struct file_system_type *fs_type,
-	int flags, const char *dev_name, void *raw_data);
-
-static struct file_system_type nfs4_remote_fs_type = {
-	.owner		= THIS_MODULE,
-	.name		= "nfs4",
-	.mount		= nfs4_remote_mount,
-	.kill_sb	= nfs_kill_super,
-	.fs_flags	= FS_RENAME_DOES_D_MOVE|FS_BINARY_MOUNTDATA,
-};
-
-static struct file_system_type nfs4_remote_referral_fs_type = {
-	.owner		= THIS_MODULE,
-	.name		= "nfs4",
-	.mount		= nfs4_remote_referral_mount,
-	.kill_sb	= nfs_kill_super,
-	.fs_flags	= FS_RENAME_DOES_D_MOVE|FS_BINARY_MOUNTDATA,
-};
-
-struct file_system_type nfs4_referral_fs_type = {
-	.owner		= THIS_MODULE,
-	.name		= "nfs4",
-	.mount		= nfs4_referral_mount,
-	.kill_sb	= nfs_kill_super,
-	.fs_flags	= FS_RENAME_DOES_D_MOVE|FS_BINARY_MOUNTDATA,
-};
 
 static const struct super_operations nfs4_sops = {
 	.alloc_inode	= nfs_alloc_inode,
@@ -60,16 +31,16 @@ static const struct super_operations nfs4_sops = {
 	.show_devname	= nfs_show_devname,
 	.show_path	= nfs_show_path,
 	.show_stats	= nfs_show_stats,
-	.remount_fs	= nfs_remount,
+	.remount_fs_fc	= nfs_remount,
 };
 
 struct nfs_subversion nfs_v4 = {
-	.owner = THIS_MODULE,
-	.nfs_fs   = &nfs4_fs_type,
-	.rpc_vers = &nfs_version4,
-	.rpc_ops  = &nfs_v4_clientops,
-	.sops     = &nfs4_sops,
-	.xattr    = nfs4_xattr_handlers,
+	.owner		= THIS_MODULE,
+	.nfs_fs		= &nfs4_fs_type,
+	.rpc_vers	= &nfs_version4,
+	.rpc_ops	= &nfs_v4_clientops,
+	.sops		= &nfs4_sops,
+	.xattr		= nfs4_xattr_handlers,
 };
 
 static int nfs4_write_inode(struct inode *inode, struct writeback_control *wbc)
@@ -103,47 +74,63 @@ static void nfs4_evict_inode(struct inode *inode)
 /*
  * Get the superblock for the NFS4 root partition
  */
-static struct dentry *
-nfs4_remote_mount(struct file_system_type *fs_type, int flags,
-		  const char *dev_name, void *info)
+static int nfs4_get_remote_tree(struct nfs_fs_context *ctx)
 {
-	struct nfs_mount_info *mount_info = info;
 	struct nfs_server *server;
-	struct dentry *mntroot = ERR_PTR(-ENOMEM);
 
-	mount_info->set_security = nfs_set_sb_security;
+	ctx->set_security = nfs_set_sb_security;
 
 	/* Get a volume representation */
-	server = nfs4_create_server(mount_info, &nfs_v4);
-	if (IS_ERR(server)) {
-		mntroot = ERR_CAST(server);
-		goto out;
-	}
-
-	mntroot = nfs_fs_mount_common(server, flags, dev_name, mount_info, &nfs_v4);
+	server = nfs4_create_server(ctx);
+	if (IS_ERR(server))
+		return PTR_ERR(server);
 
-out:
-	return mntroot;
+	return nfs_get_tree_common(server, ctx);
 }
 
-static struct vfsmount *nfs_do_root_mount(struct file_system_type *fs_type,
-		int flags, void *data, const char *hostname)
+/*
+ * Create a mount for the root of the server.  We copy the mount context we
+ * have for the parameters and set its hostname, path and type.
+ */
+static struct vfsmount *nfs_do_root_mount(struct nfs_fs_context *ctx,
+					  const char *hostname,
+					  enum nfs_mount_type type)
 {
+	struct nfs_fs_context *root_ctx;
+	struct fs_context *root_fc;
 	struct vfsmount *root_mnt;
 	char *root_devname;
 	size_t len;
+	int ret;
+
+	root_fc = vfs_dup_fs_context(&ctx->fc);
+	if (IS_ERR(root_fc))
+		return ERR_CAST(root_fc);
+	root_ctx = container_of(root_fc, struct nfs_fs_context, fc);
+
+	root_ctx->mount_type = type;
+	root_ctx->nfs_server.export_path = (char *)nfs_slash;
 
 	len = strlen(hostname) + 5;
+	root_mnt = ERR_PTR(-ENOMEM);
 	root_devname = kmalloc(len, GFP_KERNEL);
 	if (root_devname == NULL)
-		return ERR_PTR(-ENOMEM);
+		goto out_fc;
+
 	/* Does hostname needs to be enclosed in brackets? */
 	if (strchr(hostname, ':'))
 		snprintf(root_devname, len, "[%s]:/", hostname);
 	else
 		snprintf(root_devname, len, "%s:/", hostname);
-	root_mnt = vfs_kern_mount(fs_type, flags, root_devname, data);
-	kfree(root_devname);
+	root_ctx->fc.device = root_devname;
+
+	ret = vfs_get_tree(&root_ctx->fc);
+	if (ret < 0)
+		return ERR_PTR(ret);
+
+	root_mnt = vfs_kern_mount_fc(&root_ctx->fc);
+out_fc:
+	put_fs_context(root_fc);
 	return root_mnt;
 }
 
@@ -234,89 +221,98 @@ static struct dentry *nfs_follow_remote_path(struct vfsmount *root_mnt,
 	return dentry;
 }
 
-struct dentry *nfs4_try_mount(int flags, const char *dev_name,
-			      struct nfs_mount_info *mount_info,
-			      struct nfs_subversion *nfs_mod)
+int nfs4_try_get_tree(struct nfs_fs_context *ctx)
 {
-	char *export_path;
 	struct vfsmount *root_mnt;
-	struct dentry *res;
-	struct nfs_fs_context *ctx = mount_info->ctx;
+	struct dentry *root;
 
-	dfprintk(MOUNT, "--> nfs4_try_mount()\n");
+	dfprintk(MOUNT, "--> nfs4_try_get_tree()\n");
 
-	export_path = ctx->nfs_server.export_path;
-	ctx->nfs_server.export_path = "/";
-	root_mnt = nfs_do_root_mount(&nfs4_remote_fs_type, flags, mount_info,
-			ctx->nfs_server.hostname);
-	ctx->nfs_server.export_path = export_path;
-
-	res = nfs_follow_remote_path(root_mnt, export_path);
+	/* We create a mount for the server's root, walk to the requested
+	 * location and then create another mount for that.
+	 */
+	root_mnt = nfs_do_root_mount(ctx, ctx->nfs_server.hostname,
+				     NFS4_MOUNT_REMOTE);
+	if (IS_ERR(root_mnt))
+		return PTR_ERR(root_mnt);
+
+	root = nfs_follow_remote_path(root_mnt, ctx->nfs_server.export_path);
+	if (IS_ERR(root)) {
+		errorf("NFS4: Couldn't follow remote path");
+		dfprintk(MOUNT, "<-- nfs4_try_mount() = %ld [error]\n",
+			 PTR_ERR(root));
+		return PTR_ERR(root);
+	}
 
-	dfprintk(MOUNT, "<-- nfs4_try_mount() = %d%s\n",
-		 PTR_ERR_OR_ZERO(res),
-		 IS_ERR(res) ? " [error]" : "");
-	return res;
+	ctx->fc.root = root;
+	dfprintk(MOUNT, "<-- nfs4_try_get_tree() = 0\n");
+	return 0;
 }
 
-static struct dentry *
-nfs4_remote_referral_mount(struct file_system_type *fs_type, int flags,
-			   const char *dev_name, void *raw_data)
+static int nfs4_get_remote_referral_tree(struct nfs_fs_context *ctx)
 {
-	struct nfs_mount_info mount_info = {
-		.fill_super = nfs_fill_super,
-		.set_security = nfs_clone_sb_security,
-		.cloned = raw_data,
-	};
 	struct nfs_server *server;
-	struct dentry *mntroot = ERR_PTR(-ENOMEM);
 
-	dprintk("--> nfs4_referral_get_sb()\n");
+	dprintk("--> nfs4_get_remote_referral_tree()\n");
 
-	mount_info.mntfh = nfs_alloc_fhandle();
-	if (mount_info.cloned == NULL || mount_info.mntfh == NULL)
-		goto out;
+	ctx->set_security = nfs_clone_sb_security;
+
+	if (!ctx->clone_data.cloned)
+		return -EINVAL;
 
 	/* create a new volume representation */
-	server = nfs4_create_referral_server(mount_info.cloned, mount_info.mntfh);
-	if (IS_ERR(server)) {
-		mntroot = ERR_CAST(server);
-		goto out;
-	}
+	server = nfs4_create_referral_server(ctx);
+	if (IS_ERR(server))
+		return PTR_ERR(server);
 
-	mntroot = nfs_fs_mount_common(server, flags, dev_name, &mount_info, &nfs_v4);
-out:
-	nfs_free_fhandle(mount_info.mntfh);
-	return mntroot;
+	return nfs_get_tree_common(server, ctx);
 }
 
 /*
  * Create an NFS4 server record on referral traversal
  */
-static struct dentry *nfs4_referral_mount(struct file_system_type *fs_type,
-		int flags, const char *dev_name, void *raw_data)
+static int nfs4_get_referral_tree(struct nfs_fs_context *ctx)
 {
-	struct nfs_clone_mount *data = raw_data;
-	char *export_path;
 	struct vfsmount *root_mnt;
-	struct dentry *res;
+	struct dentry *root;
 
 	dprintk("--> nfs4_referral_mount()\n");
 
-	export_path = data->mnt_path;
-	data->mnt_path = "/";
+	root_mnt = nfs_do_root_mount(ctx, ctx->nfs_server.hostname,
+				     NFS4_MOUNT_REMOTE_REFERRAL);
 
-	root_mnt = nfs_do_root_mount(&nfs4_remote_referral_fs_type,
-			flags, data, data->hostname);
-	data->mnt_path = export_path;
+	root = nfs_follow_remote_path(root_mnt, ctx->nfs_server.export_path);
+	if (IS_ERR(root)) {
+		errorf("NFS4: Couldn't follow remote path");
+		dfprintk(MOUNT, "<-- nfs4_referral_mount() = %ld [error]\n",
+			 PTR_ERR(root));
+		return PTR_ERR(root);
+	}
 
-	res = nfs_follow_remote_path(root_mnt, export_path);
-	dprintk("<-- nfs4_referral_mount() = %d%s\n",
-		PTR_ERR_OR_ZERO(res),
-		IS_ERR(res) ? " [error]" : "");
-	return res;
+	ctx->fc.root = root;
+	dfprintk(MOUNT, "<-- nfs4_get_referral_tree() = 0\n");
+	return 0;
 }
 
+/*
+ * Handle special NFS4 mount types.
+ */
+int nfs4_get_tree(struct nfs_fs_context *ctx)
+{
+	switch (ctx->mount_type) {
+	case NFS4_MOUNT_REMOTE:
+		return nfs4_get_remote_tree(ctx);
+
+	case NFS4_MOUNT_REFERRAL:
+		return nfs4_get_referral_tree(ctx);
+
+	case NFS4_MOUNT_REMOTE_REFERRAL:
+		return nfs4_get_remote_referral_tree(ctx);
+
+	default:
+		return 1;
+	}
+}
 
 static int __init init_nfs_v4(void)
 {
diff --git a/fs/nfs/proc.c b/fs/nfs/proc.c
index 9872cf676a50..cd22b82e7bb8 100644
--- a/fs/nfs/proc.c
+++ b/fs/nfs/proc.c
@@ -705,7 +705,7 @@ const struct nfs_rpc_ops nfs_v2_clientops = {
 	.file_ops	= &nfs_file_operations,
 	.getroot	= nfs_proc_get_root,
 	.submount	= nfs_submount,
-	.try_mount	= nfs_try_mount,
+	.try_get_tree	= nfs_try_get_tree,
 	.getattr	= nfs_proc_getattr,
 	.setattr	= nfs_proc_setattr,
 	.lookup		= nfs_proc_lookup,
diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index c13f0ff42df9..3ef689c08f48 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -69,27 +69,6 @@
 
 #define NFSDBG_FACILITY		NFSDBG_VFS
 
-static struct dentry *nfs_xdev_mount(struct file_system_type *fs_type,
-		int flags, const char *dev_name, void *raw_data);
-
-struct file_system_type nfs_fs_type = {
-	.owner		= THIS_MODULE,
-	.name		= "nfs",
-	.mount		= nfs_fs_mount,
-	.kill_sb	= nfs_kill_super,
-	.fs_flags	= FS_RENAME_DOES_D_MOVE|FS_BINARY_MOUNTDATA,
-};
-MODULE_ALIAS_FS("nfs");
-EXPORT_SYMBOL_GPL(nfs_fs_type);
-
-struct file_system_type nfs_xdev_fs_type = {
-	.owner		= THIS_MODULE,
-	.name		= "nfs",
-	.mount		= nfs_xdev_mount,
-	.kill_sb	= nfs_kill_super,
-	.fs_flags	= FS_RENAME_DOES_D_MOVE|FS_BINARY_MOUNTDATA,
-};
-
 const struct super_operations nfs_sops = {
 	.alloc_inode	= nfs_alloc_inode,
 	.destroy_inode	= nfs_destroy_inode,
@@ -102,22 +81,11 @@ const struct super_operations nfs_sops = {
 	.show_devname	= nfs_show_devname,
 	.show_path	= nfs_show_path,
 	.show_stats	= nfs_show_stats,
-	.remount_fs	= nfs_remount,
+	.remount_fs_fc	= nfs_remount,
 };
 EXPORT_SYMBOL_GPL(nfs_sops);
 
 #if IS_ENABLED(CONFIG_NFS_V4)
-struct file_system_type nfs4_fs_type = {
-	.owner		= THIS_MODULE,
-	.name		= "nfs4",
-	.mount		= nfs_fs_mount,
-	.kill_sb	= nfs_kill_super,
-	.fs_flags	= FS_RENAME_DOES_D_MOVE|FS_BINARY_MOUNTDATA,
-};
-MODULE_ALIAS_FS("nfs4");
-MODULE_ALIAS("nfs4");
-EXPORT_SYMBOL_GPL(nfs4_fs_type);
-
 static int __init register_nfs4_fs(void)
 {
 	return register_filesystem(&nfs4_fs_type);
@@ -710,11 +678,11 @@ bool nfs_auth_info_match(const struct nfs_auth_info *auth_info,
 EXPORT_SYMBOL_GPL(nfs_auth_info_match);
 
 /*
- * Ensure that a specified authtype in cfg->auth_info is supported by
- * the server. Returns 0 and sets cfg->selected_flavor if it's ok, and
+ * Ensure that a specified authtype in ctx->auth_info is supported by
+ * the server. Returns 0 and sets ctx->selected_flavor if it's ok, and
  * -EACCES if not.
  */
-static int nfs_verify_authflavors(struct nfs_fs_context *cfg,
+static int nfs_verify_authflavors(struct nfs_fs_context *ctx,
 			rpc_authflavor_t *server_authlist, unsigned int count)
 {
 	rpc_authflavor_t flavor = RPC_AUTH_MAXFLAVOR;
@@ -732,7 +700,7 @@ static int nfs_verify_authflavors(struct nfs_fs_context *cfg,
 	for (i = 0; i < count; i++) {
 		flavor = server_authlist[i];
 
-		if (nfs_auth_info_match(&cfg->auth_info, flavor))
+		if (nfs_auth_info_match(&ctx->auth_info, flavor))
 			goto out;
 
 		if (flavor == RPC_AUTH_NULL)
@@ -749,8 +717,8 @@ static int nfs_verify_authflavors(struct nfs_fs_context *cfg,
 	return -EACCES;
 
 out:
-	cfg->selected_flavor = flavor;
-	dfprintk(MOUNT, "NFS: using auth flavor %u\n", cfg->selected_flavor);
+	ctx->selected_flavor = flavor;
+	dfprintk(MOUNT, "NFS: using auth flavor %u\n", ctx->selected_flavor);
 	return 0;
 }
 
@@ -758,50 +726,50 @@ static int nfs_verify_authflavors(struct nfs_fs_context *cfg,
  * Use the remote server's MOUNT service to request the NFS file handle
  * corresponding to the provided path.
  */
-static int nfs_request_mount(struct nfs_fs_context *cfg,
+static int nfs_request_mount(struct nfs_fs_context *ctx,
 			     struct nfs_fh *root_fh,
 			     rpc_authflavor_t *server_authlist,
 			     unsigned int *server_authlist_len)
 {
 	struct nfs_mount_request request = {
 		.sap		= (struct sockaddr *)
-						&cfg->mount_server.address,
-		.dirpath	= cfg->nfs_server.export_path,
-		.protocol	= cfg->mount_server.protocol,
+						&ctx->mount_server.address,
+		.dirpath	= ctx->nfs_server.export_path,
+		.protocol	= ctx->mount_server.protocol,
 		.fh		= root_fh,
-		.noresvport	= cfg->flags & NFS_MOUNT_NORESVPORT,
+		.noresvport	= ctx->flags & NFS_MOUNT_NORESVPORT,
 		.auth_flav_len	= server_authlist_len,
 		.auth_flavs	= server_authlist,
-		.net		= cfg->net,
+		.net		= ctx->fc.net_ns,
 	};
 	int status;
 
-	if (cfg->mount_server.version == 0) {
-		switch (cfg->version) {
+	if (ctx->mount_server.version == 0) {
+		switch (ctx->version) {
 			default:
-				cfg->mount_server.version = NFS_MNT3_VERSION;
+				ctx->mount_server.version = NFS_MNT3_VERSION;
 				break;
 			case 2:
-				cfg->mount_server.version = NFS_MNT_VERSION;
+				ctx->mount_server.version = NFS_MNT_VERSION;
 		}
 	}
-	request.version = cfg->mount_server.version;
+	request.version = ctx->mount_server.version;
 
-	if (cfg->mount_server.hostname)
-		request.hostname = cfg->mount_server.hostname;
+	if (ctx->mount_server.hostname)
+		request.hostname = ctx->mount_server.hostname;
 	else
-		request.hostname = cfg->nfs_server.hostname;
+		request.hostname = ctx->nfs_server.hostname;
 
 	/*
 	 * Construct the mount server's address.
 	 */
-	if (cfg->mount_server.address.sa_family == AF_UNSPEC) {
-		memcpy(request.sap, &cfg->nfs_server.address,
-		       cfg->nfs_server.addrlen);
-		cfg->mount_server.addrlen = cfg->nfs_server.addrlen;
+	if (ctx->mount_server.address.sa_family == AF_UNSPEC) {
+		memcpy(request.sap, &ctx->nfs_server.address,
+		       ctx->nfs_server.addrlen);
+		ctx->mount_server.addrlen = ctx->nfs_server.addrlen;
 	}
-	request.salen = cfg->mount_server.addrlen;
-	nfs_set_port(request.sap, &cfg->mount_server.port, 0);
+	request.salen = ctx->mount_server.addrlen;
+	nfs_set_port(request.sap, &ctx->mount_server.port, 0);
 
 	/*
 	 * Now ask the mount server to map our export path
@@ -817,20 +785,17 @@ static int nfs_request_mount(struct nfs_fs_context *cfg,
 	return 0;
 }
 
-static struct nfs_server *nfs_try_mount_request(struct nfs_mount_info *mount_info,
-					struct nfs_subversion *nfs_mod)
+static struct nfs_server *nfs_try_mount_request(struct nfs_fs_context *ctx)
 {
 	int status;
 	unsigned int i;
 	bool tried_auth_unix = false;
 	bool auth_null_in_list = false;
 	struct nfs_server *server = ERR_PTR(-EACCES);
-	struct nfs_fs_context *ctx = mount_info->ctx;
 	rpc_authflavor_t authlist[NFS_MAX_SECFLAVORS];
 	unsigned int authlist_len = ARRAY_SIZE(authlist);
 
-	status = nfs_request_mount(ctx, mount_info->mntfh, authlist,
-					&authlist_len);
+	status = nfs_request_mount(ctx, ctx->mntfh, authlist, &authlist_len);
 	if (status)
 		return ERR_PTR(status);
 
@@ -844,7 +809,7 @@ static struct nfs_server *nfs_try_mount_request(struct nfs_mount_info *mount_inf
 			 ctx->selected_flavor);
 		if (status)
 			return ERR_PTR(status);
-		return nfs_mod->rpc_ops->create_server(mount_info, nfs_mod);
+		return ctx->nfs_mod->rpc_ops->create_server(ctx);
 	}
 
 	/*
@@ -871,7 +836,7 @@ static struct nfs_server *nfs_try_mount_request(struct nfs_mount_info *mount_inf
 		}
 		dfprintk(MOUNT, "NFS: attempting to use auth flavor %u\n", flavor);
 		ctx->selected_flavor = flavor;
-		server = nfs_mod->rpc_ops->create_server(mount_info, nfs_mod);
+		server = ctx->nfs_mod->rpc_ops->create_server(ctx);
 		if (!IS_ERR(server))
 			return server;
 	}
@@ -887,26 +852,27 @@ static struct nfs_server *nfs_try_mount_request(struct nfs_mount_info *mount_inf
 	/* Last chance! Try AUTH_UNIX */
 	dfprintk(MOUNT, "NFS: attempting to use auth flavor %u\n", RPC_AUTH_UNIX);
 	ctx->selected_flavor = RPC_AUTH_UNIX;
-	return nfs_mod->rpc_ops->create_server(mount_info, nfs_mod);
+	return ctx->nfs_mod->rpc_ops->create_server(ctx);
 }
 
-struct dentry *nfs_try_mount(int flags, const char *dev_name,
-			     struct nfs_mount_info *mount_info,
-			     struct nfs_subversion *nfs_mod)
+int nfs_try_get_tree(struct nfs_fs_context *ctx)
 {
 	struct nfs_server *server;
 
-	if (mount_info->ctx->need_mount)
-		server = nfs_try_mount_request(mount_info, nfs_mod);
+	if (ctx->need_mount)
+		server = nfs_try_mount_request(ctx);
 	else
-		server = nfs_mod->rpc_ops->create_server(mount_info, nfs_mod);
+		server = ctx->nfs_mod->rpc_ops->create_server(ctx);
 
-	if (IS_ERR(server))
-		return ERR_CAST(server);
+	if (IS_ERR(server)) {
+		errorf("NFS: Couldn't create server");
+		return PTR_ERR(server);
+	}
 
-	return nfs_fs_mount_common(server, flags, dev_name, mount_info, nfs_mod);
+	return nfs_get_tree_common(server, ctx);
 }
-EXPORT_SYMBOL_GPL(nfs_try_mount);
+EXPORT_SYMBOL_GPL(nfs_try_get_tree);
+
 
 #define NFS_REMOUNT_CMP_FLAGMASK ~(NFS_MOUNT_INTR \
 		| NFS_MOUNT_SECURE \
@@ -946,15 +912,11 @@ nfs_compare_remount_data(struct nfs_server *nfss,
 	return 0;
 }
 
-int
-nfs_remount(struct super_block *sb, int *flags, char *raw_data)
+int nfs_remount(struct super_block *sb, struct fs_context *fc)
 {
-	int error;
+	struct nfs_fs_context *ctx =
+		container_of(fc, struct nfs_fs_context, fc);
 	struct nfs_server *nfss = sb->s_fs_info;
-	struct nfs_fs_context *ctx;
-	struct nfs_mount_data *options = (struct nfs_mount_data *)raw_data;
-	struct nfs4_mount_data *options4 = (struct nfs4_mount_data *)raw_data;
-	u32 nfsvers = nfss->nfs_client->rpc_ops->version;
 
 	sync_filesystem(sb);
 
@@ -964,39 +926,9 @@ nfs_remount(struct super_block *sb, int *flags, char *raw_data)
 	 * ones were explicitly specified. Fall back to legacy behavior and
 	 * just return success.
 	 */
-	if ((nfsvers == 4 && (!options4 || options4->version == 1)) ||
-	    (nfsvers <= 3 && (!options || (options->version >= 1 &&
-					   options->version <= 6))))
+	if (ctx->skip_remount_option_check)
 		return 0;
 
-	ctx = kzalloc(sizeof(*ctx), GFP_KERNEL);
-	if (ctx == NULL)
-		return -ENOMEM;
-
-	/* fill out struct with values from existing mount */
-	ctx->flags = nfss->flags;
-	ctx->rsize = nfss->rsize;
-	ctx->wsize = nfss->wsize;
-	ctx->retrans = nfss->client->cl_timeout->to_retries;
-	ctx->selected_flavor = nfss->client->cl_auth->au_flavor;
-	ctx->acregmin = nfss->acregmin / HZ;
-	ctx->acregmax = nfss->acregmax / HZ;
-	ctx->acdirmin = nfss->acdirmin / HZ;
-	ctx->acdirmax = nfss->acdirmax / HZ;
-	ctx->timeo = 10U * nfss->client->cl_timeout->to_initval / HZ;
-	ctx->nfs_server.port = nfss->port;
-	ctx->nfs_server.addrlen = nfss->nfs_client->cl_addrlen;
-	ctx->version = nfsvers;
-	ctx->minorversion = nfss->nfs_client->cl_minorversion;
-	ctx->net = current->nsproxy->net_ns;
-	memcpy(&ctx->nfs_server.address, &nfss->nfs_client->cl_addr,
-		ctx->nfs_server.addrlen);
-
-	/* overwrite those values with any that were specified */
-	error = -EINVAL;
-	if (!nfs_parse_mount_options((char *)options, ctx))
-		goto out;
-
 	/*
 	 * noac is a special case. It implies -o sync, but that's not
 	 * necessarily reflected in the mtab options. do_remount_sb
@@ -1004,13 +936,10 @@ nfs_remount(struct super_block *sb, int *flags, char *raw_data)
 	 * remount options, so we have to explicitly reset it.
 	 */
 	if (ctx->flags & NFS_MOUNT_NOAC)
-		*flags |= SB_SYNCHRONOUS;
+		ctx->fc.sb_flags |= SB_SYNCHRONOUS;
 
 	/* compare new mount options with old ones */
-	error = nfs_compare_remount_data(nfss, ctx);
-out:
-	kfree(ctx);
-	return error;
+	return nfs_compare_remount_data(nfss, ctx);
 }
 EXPORT_SYMBOL_GPL(nfs_remount);
 
@@ -1037,9 +966,8 @@ static void nfs_initialise_sb(struct super_block *sb)
 /*
  * Finish setting up an NFS2/3 superblock
  */
-void nfs_fill_super(struct super_block *sb, struct nfs_mount_info *mount_info)
+static void nfs_fill_super(struct super_block *sb, struct nfs_fs_context *ctx)
 {
-	struct nfs_fs_context *ctx = mount_info->ctx;
 	struct nfs_server *server = NFS_SB(sb);
 
 	sb->s_blocksize_bits = 0;
@@ -1059,15 +987,13 @@ void nfs_fill_super(struct super_block *sb, struct nfs_mount_info *mount_info)
 
  	nfs_initialise_sb(sb);
 }
-EXPORT_SYMBOL_GPL(nfs_fill_super);
 
 /*
  * Finish setting up a cloned NFS2/3/4 superblock
  */
-static void nfs_clone_super(struct super_block *sb,
-			    struct nfs_mount_info *mount_info)
+static void nfs_clone_super(struct super_block *sb, struct nfs_fs_context *ctx)
 {
-	const struct super_block *old_sb = mount_info->cloned->sb;
+	const struct super_block *old_sb = ctx->clone_data.sb;
 	struct nfs_server *server = NFS_SB(sb);
 
 	sb->s_blocksize_bits = old_sb->s_blocksize_bits;
@@ -1087,13 +1013,14 @@ static void nfs_clone_super(struct super_block *sb,
  	nfs_initialise_sb(sb);
 }
 
-static int nfs_compare_mount_options(const struct super_block *s, const struct nfs_server *b, int flags)
+static int nfs_compare_mount_options(const struct super_block *s, const struct nfs_server *b,
+				     const struct nfs_fs_context *ctx)
 {
 	const struct nfs_server *a = s->s_fs_info;
 	const struct rpc_clnt *clnt_a = a->client;
 	const struct rpc_clnt *clnt_b = b->client;
 
-	if ((s->s_flags & NFS_SB_MASK) != (flags & NFS_SB_MASK))
+	if ((s->s_flags & NFS_SB_MASK) != (ctx->fc.sb_flags & NFS_SB_MASK))
 		goto Ebusy;
 	if (a->nfs_client != b->nfs_client)
 		goto Ebusy;
@@ -1119,18 +1046,13 @@ static int nfs_compare_mount_options(const struct super_block *s, const struct n
 	return 0;
 }
 
-struct nfs_sb_mountdata {
-	struct nfs_server *server;
-	int mntflags;
-};
-
-static int nfs_set_super(struct super_block *s, void *data)
+static int nfs_set_super(struct super_block *s, struct fs_context *fc)
 {
-	struct nfs_sb_mountdata *sb_mntdata = data;
-	struct nfs_server *server = sb_mntdata->server;
+	struct nfs_fs_context *ctx = container_of(fc, struct nfs_fs_context, fc);
+	struct nfs_server *server = ctx->server;
 	int ret;
 
-	s->s_flags = sb_mntdata->mntflags;
+	s->s_flags = ctx->fc.sb_flags;
 	s->s_fs_info = server;
 	s->s_d_op = server->nfs_client->rpc_ops->dentry_ops;
 	ret = set_anon_super(s, server);
@@ -1181,11 +1103,10 @@ static int nfs_compare_super_address(struct nfs_server *server1,
 	return 1;
 }
 
-static int nfs_compare_super(struct super_block *sb, void *data)
+static int nfs_compare_super(struct super_block *sb, struct fs_context *fc)
 {
-	struct nfs_sb_mountdata *sb_mntdata = data;
-	struct nfs_server *server = sb_mntdata->server, *old = NFS_SB(sb);
-	int mntflags = sb_mntdata->mntflags;
+	struct nfs_fs_context *ctx = container_of(fc, struct nfs_fs_context, fc);
+	struct nfs_server *server = ctx->server, *old = NFS_SB(sb);
 
 	if (!nfs_compare_super_address(old, server))
 		return 0;
@@ -1194,13 +1115,12 @@ static int nfs_compare_super(struct super_block *sb, void *data)
 		return 0;
 	if (memcmp(&old->fsid, &server->fsid, sizeof(old->fsid)) != 0)
 		return 0;
-	return nfs_compare_mount_options(sb, server, mntflags);
+	return nfs_compare_mount_options(sb, server, ctx);
 }
 
 #ifdef CONFIG_NFS_FSCACHE
 static void nfs_get_cache_cookie(struct super_block *sb,
-				 struct nfs_fs_context *ctx,
-				 struct nfs_clone_mount *cloned)
+				 struct nfs_fs_context *ctx)
 {
 	struct nfs_server *nfss = NFS_SB(sb);
 	char *uniq = NULL;
@@ -1209,77 +1129,72 @@ static void nfs_get_cache_cookie(struct super_block *sb,
 	nfss->fscache_key = NULL;
 	nfss->fscache = NULL;
 
-	if (ctx) {
+	if (!ctx)
+		return;
+
+	if (ctx->clone_data.cloned) {
+		struct nfs_server *mnt_s = NFS_SB(ctx->clone_data.sb);
+		if (!(mnt_s->options & NFS_OPTION_FSCACHE))
+			return;
+		if (mnt_s->fscache_key) {
+			uniq = mnt_s->fscache_key->key.uniquifier;
+			ulen = mnt_s->fscache_key->key.uniq_len;
+		}
+	} else {
 		if (!(ctx->options & NFS_OPTION_FSCACHE))
 			return;
 		if (ctx->fscache_uniq) {
 			uniq = ctx->fscache_uniq;
 			ulen = strlen(ctx->fscache_uniq);
 		}
-	} else if (cloned) {
-		struct nfs_server *mnt_s = NFS_SB(cloned->sb);
-		if (!(mnt_s->options & NFS_OPTION_FSCACHE))
-			return;
-		if (mnt_s->fscache_key) {
-			uniq = mnt_s->fscache_key->key.uniquifier;
-			ulen = mnt_s->fscache_key->key.uniq_len;
-		};
-	} else
 		return;
+	}
 
 	nfs_fscache_get_super_cookie(sb, uniq, ulen);
 }
 #else
 static void nfs_get_cache_cookie(struct super_block *sb,
-				 struct nfs_fs_context *parsed,
-				 struct nfs_clone_mount *cloned)
+				 struct nfs_fs_context *ctx)
 {
 }
 #endif
 
-int nfs_set_sb_security(struct super_block *s, struct dentry *mntroot,
-			struct nfs_mount_info *mount_info)
+int nfs_set_sb_security(struct super_block *sb, struct nfs_fs_context *ctx)
 {
 	int error;
 	unsigned long kflags = 0, kflags_out = 0;
-	if (NFS_SB(s)->caps & NFS_CAP_SECURITY_LABEL)
+
+	if (NFS_SB(sb)->caps & NFS_CAP_SECURITY_LABEL)
 		kflags |= SECURITY_LSM_NATIVE_LABELS;
 
-	error = security_sb_set_mnt_opts(s, &mount_info->ctx->lsm_opts,
-						kflags, &kflags_out);
+	error = security_sb_set_mnt_opts(sb, ctx->fc.security,
+					 kflags, &kflags_out);
 	if (error)
 		goto err;
 
-	if (NFS_SB(s)->caps & NFS_CAP_SECURITY_LABEL &&
-		!(kflags_out & SECURITY_LSM_NATIVE_LABELS))
-		NFS_SB(s)->caps &= ~NFS_CAP_SECURITY_LABEL;
+	if (NFS_SB(sb)->caps & NFS_CAP_SECURITY_LABEL &&
+	    !(kflags_out & SECURITY_LSM_NATIVE_LABELS))
+		NFS_SB(sb)->caps &= ~NFS_CAP_SECURITY_LABEL;
 err:
 	return error;
 }
 EXPORT_SYMBOL_GPL(nfs_set_sb_security);
 
-int nfs_clone_sb_security(struct super_block *s, struct dentry *mntroot,
-			  struct nfs_mount_info *mount_info)
+int nfs_clone_sb_security(struct super_block *sb, struct nfs_fs_context *ctx)
 {
 	/* clone any lsm security options from the parent to the new sb */
-	if (d_inode(mntroot)->i_op != NFS_SB(s)->nfs_client->rpc_ops->dir_inode_ops)
+	if (d_inode(ctx->fc.root)->i_op !=
+	    NFS_SB(sb)->nfs_client->rpc_ops->dir_inode_ops)
 		return -ESTALE;
-	return security_sb_clone_mnt_opts(mount_info->cloned->sb, s);
+	return security_sb_clone_mnt_opts(ctx->clone_data.sb, sb);
 }
 EXPORT_SYMBOL_GPL(nfs_clone_sb_security);
 
-struct dentry *nfs_fs_mount_common(struct nfs_server *server,
-				   int flags, const char *dev_name,
-				   struct nfs_mount_info *mount_info,
-				   struct nfs_subversion *nfs_mod)
+int nfs_get_tree_common(struct nfs_server *server, struct nfs_fs_context *ctx)
 {
 	struct super_block *s;
 	struct dentry *mntroot = ERR_PTR(-ENOMEM);
-	int (*compare_super)(struct super_block *, void *) = nfs_compare_super;
-	struct nfs_sb_mountdata sb_mntdata = {
-		.mntflags = flags,
-		.server = server,
-	};
+	int (*compare_super)(struct super_block *, struct fs_context *) = nfs_compare_super;
 	int error;
 
 	if (server->flags & NFS_MOUNT_UNSHARED)
@@ -1287,16 +1202,19 @@ struct dentry *nfs_fs_mount_common(struct nfs_server *server,
 
 	/* -o noac implies -o sync */
 	if (server->flags & NFS_MOUNT_NOAC)
-		sb_mntdata.mntflags |= SB_SYNCHRONOUS;
+		ctx->fc.sb_flags |= SB_SYNCHRONOUS;
 
-	if (mount_info->cloned != NULL && mount_info->cloned->sb != NULL)
-		if (mount_info->cloned->sb->s_flags & SB_SYNCHRONOUS)
-			sb_mntdata.mntflags |= SB_SYNCHRONOUS;
+	if (ctx->clone_data.cloned && ctx->clone_data.sb != NULL)
+		if (ctx->clone_data.sb->s_flags & SB_SYNCHRONOUS)
+			ctx->fc.sb_flags |= SB_SYNCHRONOUS;
 
 	/* Get a superblock - note that we may end up sharing one that already exists */
-	s = sget(nfs_mod->nfs_fs, compare_super, nfs_set_super, flags, &sb_mntdata);
+	ctx->server = server;
+	s = sget_fc(&ctx->fc, compare_super, nfs_set_super);
+	ctx->server = NULL;
 	if (IS_ERR(s)) {
-		mntroot = ERR_CAST(s);
+		error = PTR_ERR(s);
+		errorf("NFS: Couldn't get superblock");
 		goto out_err_nosb;
 	}
 
@@ -1316,22 +1234,28 @@ struct dentry *nfs_fs_mount_common(struct nfs_server *server,
 
 	if (!s->s_root) {
 		/* initial superblock/root creation */
-		mount_info->fill_super(s, mount_info);
-		nfs_get_cache_cookie(s, mount_info->ctx, mount_info->cloned);
+		if (ctx->clone_data.sb)
+			nfs_clone_super(s, ctx);
+		else
+			nfs_fill_super(s, ctx);
+		nfs_get_cache_cookie(s, ctx);
 	}
 
-	mntroot = nfs_get_root(s, mount_info->mntfh, dev_name);
-	if (IS_ERR(mntroot))
+	error = nfs_get_root(s, ctx);
+	if (error < 0) {
+		errorf("NFS: Couldn't get root dentry");
 		goto error_splat_super;
+	}
 
-	error = mount_info->set_security(s, mntroot, mount_info);
+	error = ctx->set_security(s, ctx);
 	if (error)
 		goto error_splat_root;
 
 	s->s_flags |= SB_ACTIVE;
+	error = 0;
 
 out:
-	return mntroot;
+	return error;
 
 out_err_nosb:
 	nfs_free_server(server);
@@ -1339,53 +1263,11 @@ struct dentry *nfs_fs_mount_common(struct nfs_server *server,
 
 error_splat_root:
 	dput(mntroot);
-	mntroot = ERR_PTR(error);
 error_splat_super:
 	deactivate_locked_super(s);
 	goto out;
 }
-EXPORT_SYMBOL_GPL(nfs_fs_mount_common);
-
-struct dentry *nfs_fs_mount(struct file_system_type *fs_type,
-	int flags, const char *dev_name, void *raw_data)
-{
-	struct nfs_mount_info mount_info = {
-		.fill_super = nfs_fill_super,
-		.set_security = nfs_set_sb_security,
-	};
-	struct dentry *mntroot = ERR_PTR(-ENOMEM);
-	struct nfs_subversion *nfs_mod;
-	int error;
-
-	mount_info.ctx = nfs_alloc_parsed_mount_data();
-	mount_info.mntfh = nfs_alloc_fhandle();
-	if (mount_info.ctx == NULL || mount_info.mntfh == NULL)
-		goto out;
-
-	/* Validate the mount data */
-	error = nfs_validate_mount_data(fs_type, raw_data, mount_info.ctx, mount_info.mntfh, dev_name);
-	if (error == NFS_TEXT_DATA)
-		error = nfs_validate_text_mount_data(raw_data, mount_info.ctx, dev_name);
-	if (error < 0) {
-		mntroot = ERR_PTR(error);
-		goto out;
-	}
-
-	nfs_mod = get_nfs_version(mount_info.ctx->version);
-	if (IS_ERR(nfs_mod)) {
-		mntroot = ERR_CAST(nfs_mod);
-		goto out;
-	}
-
-	mntroot = nfs_mod->rpc_ops->try_mount(flags, dev_name, &mount_info, nfs_mod);
-
-	put_nfs_version(nfs_mod);
-out:
-	nfs_free_parsed_mount_data(mount_info.ctx);
-	nfs_free_fhandle(mount_info.mntfh);
-	return mntroot;
-}
-EXPORT_SYMBOL_GPL(nfs_fs_mount);
+EXPORT_SYMBOL_GPL(nfs_get_tree_common);
 
 /*
  * Destroy an NFS2/3 superblock
@@ -1404,41 +1286,6 @@ void nfs_kill_super(struct super_block *s)
 }
 EXPORT_SYMBOL_GPL(nfs_kill_super);
 
-/*
- * Clone an NFS2/3/4 server record on xdev traversal (FSID-change)
- */
-static struct dentry *
-nfs_xdev_mount(struct file_system_type *fs_type, int flags,
-		const char *dev_name, void *raw_data)
-{
-	struct nfs_clone_mount *data = raw_data;
-	struct nfs_mount_info mount_info = {
-		.fill_super = nfs_clone_super,
-		.set_security = nfs_clone_sb_security,
-		.cloned = data,
-	};
-	struct nfs_server *server;
-	struct dentry *mntroot = ERR_PTR(-ENOMEM);
-	struct nfs_subversion *nfs_mod = NFS_SB(data->sb)->nfs_client->cl_nfs_mod;
-
-	dprintk("--> nfs_xdev_mount()\n");
-
-	mount_info.mntfh = mount_info.cloned->fh;
-
-	/* create a new volume representation */
-	server = nfs_mod->rpc_ops->clone_server(NFS_SB(data->sb), data->fh, data->fattr, data->authflavor);
-
-	if (IS_ERR(server))
-		mntroot = ERR_CAST(server);
-	else
-		mntroot = nfs_fs_mount_common(server, flags,
-				dev_name, &mount_info, nfs_mod);
-
-	dprintk("<-- nfs_xdev_mount() = %ld\n",
-			IS_ERR(mntroot) ? PTR_ERR(mntroot) : 0L);
-	return mntroot;
-}
-
 #if IS_ENABLED(CONFIG_NFS_V4)
 
 /*
diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
index b28c83475ee8..71697103a887 100644
--- a/include/linux/nfs_xdr.h
+++ b/include/linux/nfs_xdr.h
@@ -1542,6 +1542,7 @@ struct nfs_subversion;
 struct nfs_mount_info;
 struct nfs_client_initdata;
 struct nfs_pageio_descriptor;
+struct nfs_fs_context;
 
 /*
  * RPC procedure vector for NFSv2/NFSv3 demuxing
@@ -1556,10 +1557,10 @@ struct nfs_rpc_ops {
 
 	int	(*getroot) (struct nfs_server *, struct nfs_fh *,
 			    struct nfs_fsinfo *);
+	int	(*get_tree)(struct nfs_fs_context *);
 	struct vfsmount *(*submount) (struct nfs_server *, struct dentry *,
 				      struct nfs_fh *, struct nfs_fattr *);
-	struct dentry *(*try_mount) (int, const char *, struct nfs_mount_info *,
-				     struct nfs_subversion *);
+	int	(*try_get_tree) (struct nfs_fs_context *);
 	int	(*getattr) (struct nfs_server *, struct nfs_fh *,
 			    struct nfs_fattr *, struct nfs4_label *);
 	int	(*setattr) (struct dentry *, struct nfs_fattr *,
@@ -1620,7 +1621,7 @@ struct nfs_rpc_ops {
 	struct nfs_client *(*init_client) (struct nfs_client *,
 				const struct nfs_client_initdata *);
 	void	(*free_client) (struct nfs_client *);
-	struct nfs_server *(*create_server)(struct nfs_mount_info *, struct nfs_subversion *);
+	struct nfs_server *(*create_server)(struct nfs_fs_context *);
 	struct nfs_server *(*clone_server)(struct nfs_server *, struct nfs_fh *,
 					   struct nfs_fattr *, rpc_authflavor_t);
 };

