Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:52464 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S965824AbdEOPUw (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 15 May 2017 11:20:52 -0400
Subject: [PATCH 19/21] NFS: Add mount context support. [ver #3]
From: David Howells <dhowells@redhat.com>
To: mszeredi@redhat.com, viro@zeniv.linux.org.uk, jlayton@redhat.com
Cc: dhowells@redhat.com, linux-fsdevel@vger.kernel.org,
        linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Date: Mon, 15 May 2017 16:20:48 +0100
Message-ID: <149486164812.23956.117026932307374256.stgit@warthog.procyon.org.uk>
In-Reply-To: <149486147335.23956.2504187638938281431.stgit@warthog.procyon.org.uk>
References: <149486147335.23956.2504187638938281431.stgit@warthog.procyon.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Add mount context support to NFS, parsing the options in advance and
attaching the information to the mount context.  The highlights are:

 (*) Define a new nfs_mount_context struct that merges together
     nfs_parsed_mount_data, nfs_mount_info and nfs_clone_mount.  This
     structure represents NFS's mount context.

 (*) Split out the mount option parsing routines from super.c into their
     own mount.c.  The VFS then provides a parser for when the options are
     in the form of a comma separated list of key[=val] items.

 (*) Provide a small buffer in the NFS mount context for copying numbers
     into prior to parsing them to avoid match_strdup() calls.

 (*) Pin the NFS protocol module in the mount context.

 (*) Return error information in mc->error.  This has the downside that
     these strings must be static and can't be formatted.

 (*) Remove the auxiliary file_system_type structs since the information
     necessary can be conveyed in the nfs_mount_context struct instead.

 (*) Root mounts are made by duplicating the context for the requested
     mount so as to have the same parameters.  Submounts pick up their
     parameters from the parent superblock.

Signed-off-by: David Howells <dhowells@redhat.com>
---

 fs/nfs/client.c         |   18 +
 fs/nfs/internal.h       |  110 +++-----
 fs/nfs/mount.c          |  656 ++++++++++++++++++++++++++++-------------------
 fs/nfs/namespace.c      |   66 +++--
 fs/nfs/nfs3_fs.h        |    2 
 fs/nfs/nfs3client.c     |    6 
 fs/nfs/nfs3proc.c       |    1 
 fs/nfs/nfs4_fs.h        |    4 
 fs/nfs/nfs4client.c     |   44 ++-
 fs/nfs/nfs4namespace.c  |  208 +++++++++------
 fs/nfs/nfs4proc.c       |    1 
 fs/nfs/nfs4super.c      |  184 ++++++-------
 fs/nfs/proc.c           |    1 
 fs/nfs/super.c          |  270 +++++--------------
 include/linux/nfs_xdr.h |    7 -
 15 files changed, 809 insertions(+), 769 deletions(-)

diff --git a/fs/nfs/client.c b/fs/nfs/client.c
index 5701f5122a64..acaab9ca0243 100644
--- a/fs/nfs/client.c
+++ b/fs/nfs/client.c
@@ -635,17 +635,16 @@ EXPORT_SYMBOL_GPL(nfs_init_client);
  * Create a version 2 or 3 client
  */
 static int nfs_init_server(struct nfs_server *server,
-			   const struct nfs_sb_config *cfg,
-			   struct nfs_subversion *nfs_mod)
+			   const struct nfs_sb_config *cfg)
 {
 	struct rpc_timeout timeparms;
 	struct nfs_client_initdata cl_init = {
 		.hostname = cfg->nfs_server.hostname,
 		.addr = (const struct sockaddr *)&cfg->nfs_server.address,
 		.addrlen = cfg->nfs_server.addrlen,
-		.nfs_mod = nfs_mod,
+		.nfs_mod = cfg->nfs_mod,
 		.proto = cfg->nfs_server.protocol,
-		.net = cfg->net,
+		.net = cfg->sc.net_ns,
 		.timeparms = &timeparms,
 	};
 	struct nfs_client *clp;
@@ -921,8 +920,7 @@ EXPORT_SYMBOL_GPL(nfs_free_server);
  * Create a version 2 or 3 volume record
  * - keyed on server and FSID
  */
-struct nfs_server *nfs_create_server(struct nfs_mount_info *mount_info,
-				     struct nfs_subversion *nfs_mod)
+struct nfs_server *nfs_create_server(struct nfs_sb_config *cfg)
 {
 	struct nfs_server *server;
 	struct nfs_fattr *fattr;
@@ -938,18 +936,18 @@ struct nfs_server *nfs_create_server(struct nfs_mount_info *mount_info,
 		goto error;
 
 	/* Get a client representation */
-	error = nfs_init_server(server, mount_info->cfg, nfs_mod);
+	error = nfs_init_server(server, cfg);
 	if (error < 0)
 		goto error;
 
 	/* Probe the root fh to retrieve its FSID */
-	error = nfs_probe_fsinfo(server, mount_info->mntfh, fattr);
+	error = nfs_probe_fsinfo(server, cfg->mntfh, fattr);
 	if (error < 0)
 		goto error;
 	if (server->nfs_client->rpc_ops->version == 3) {
 		if (server->namelen == 0 || server->namelen > NFS3_MAXNAMLEN)
 			server->namelen = NFS3_MAXNAMLEN;
-		if (!(mount_info->cfg->flags & NFS_MOUNT_NORDIRPLUS))
+		if (!(cfg->flags & NFS_MOUNT_NORDIRPLUS))
 			server->caps |= NFS_CAP_READDIRPLUS;
 	} else {
 		if (server->namelen == 0 || server->namelen > NFS2_MAXNAMLEN)
@@ -957,7 +955,7 @@ struct nfs_server *nfs_create_server(struct nfs_mount_info *mount_info,
 	}
 
 	if (!(fattr->valid & NFS_ATTR_FATTR)) {
-		error = nfs_mod->rpc_ops->getattr(server, mount_info->mntfh, fattr, NULL);
+		error = cfg->nfs_mod->rpc_ops->getattr(server, cfg->mntfh, fattr, NULL);
 		if (error < 0) {
 			dprintk("nfs_create_server: getattr error = %d\n", -error);
 			goto error;
diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
index 79e77ff2061c..b9231c6359f2 100644
--- a/fs/nfs/internal.h
+++ b/fs/nfs/internal.h
@@ -3,7 +3,7 @@
  */
 
 #include "nfs4_fs.h"
-#include <linux/mount.h>
+#include <linux/sb_config.h>
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
 struct nfs_sb_config {
+	struct sb_config	sc;
+	enum nfs_mount_type	mount_type : 8;
+	bool			skip_remount_option_check;
+	bool			need_mount;
 	unsigned int		flags;		/* NFS{,4}_MOUNT_* flags */
 	unsigned int		rsize, wsize;
 	unsigned int		timeo, retrans;
@@ -102,8 +102,6 @@ struct nfs_sb_config {
 	char			*fscache_uniq;
 	unsigned short		protofamily;
 	unsigned short		mountfamily;
-	bool			need_mount;
-	bool			sloppy;
 
 	struct {
 		union {
@@ -127,10 +125,22 @@ struct nfs_sb_config {
 		char			*export_path;
 		int			port;
 		unsigned short		protocol;
+		unsigned short		export_path_len;
 	} nfs_server;
 
-	struct security_mnt_opts lsm_opts;
-	struct net		*net;
+	struct nfs_fh		*mntfh;
+	struct nfs_subversion	*nfs_mod;
+
+	int (*set_security)(struct super_block *, struct dentry *,
+			    struct nfs_sb_config *);
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
@@ -150,17 +160,19 @@ struct nfs_mount_request {
 	struct net		*net;
 };
 
-struct nfs_mount_info {
-	void (*fill_super)(struct super_block *, struct nfs_mount_info *);
-	int (*set_security)(struct super_block *, struct dentry *, struct nfs_mount_info *);
-	struct nfs_sb_config *cfg;
-	struct nfs_clone_mount *cloned;
-	struct nfs_fh *mntfh;
-};
-
 extern int nfs_mount(struct nfs_mount_request *info);
 extern void nfs_umount(const struct nfs_mount_request *info);
 
+static inline void nfs_cfg_error(struct nfs_sb_config *cfg, const char *msg)
+{
+	sb_cfg_error(&cfg->sc, msg);
+}
+
+static inline int nfs_cfg_inval(struct nfs_sb_config *cfg, const char *msg)
+{
+	return sb_cfg_inval(&cfg->sc, msg);
+}
+
 /* client.c */
 extern const struct rpc_program nfs_program;
 extern void nfs_clients_init(struct net *net);
@@ -183,13 +195,9 @@ extern struct nfs_client *nfs4_find_client_ident(struct net *, int);
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
+extern struct nfs_server *nfs_create_server(struct nfs_sb_config *);
+extern struct nfs_server *nfs4_create_server(struct nfs_sb_config *);
+extern struct nfs_server *nfs4_create_referral_server(struct nfs_sb_config *);
 extern int nfs4_update_server(struct nfs_server *server, const char *hostname,
 					struct sockaddr *sap, size_t salen,
 					struct net *net);
@@ -243,19 +251,8 @@ extern struct svc_version nfs4_callback_version4;
 struct nfs_pageio_descriptor;
 
 /* mount.c */
-#define NFS_TEXT_DATA		1
-
-extern struct nfs_sb_config *nfs_alloc_parsed_mount_data(void);
-extern void nfs_free_parsed_mount_data(struct nfs_sb_config *cfg);
-extern int nfs_parse_mount_options(char *raw, struct nfs_sb_config *cfg);
-extern int nfs_validate_mount_data(struct file_system_type *fs_type,
-				   void *options,
-				   struct nfs_sb_config *cfg,
-				   struct nfs_fh *mntfh,
-				   const char *dev_name);
-extern int nfs_validate_text_mount_data(void *options,
-					struct nfs_sb_config *cfg,
-					const char *dev_name);
+extern const char nfs_slash[];
+extern struct dentry *nfs_general_mount(struct nfs_sb_config *ctx);
 
 /* pagelist.c */
 extern int __init nfs_init_nfspagecache(void);
@@ -418,24 +415,12 @@ extern int nfs_wait_atomic_killable(atomic_t *p);
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
-void nfs_initialise_sb(struct super_block *);
-int nfs_set_sb_security(struct super_block *, struct dentry *, struct nfs_mount_info *);
-int nfs_clone_sb_security(struct super_block *, struct dentry *, struct nfs_mount_info *);
-struct dentry *nfs_fs_mount_common(struct nfs_server *, int, const char *,
-				   struct nfs_mount_info *, struct nfs_subversion *);
-struct dentry *nfs_fs_mount(struct file_system_type *, int, const char *, void *);
-struct dentry * nfs_xdev_mount_common(struct file_system_type *, int,
-		const char *, struct nfs_mount_info *);
+struct dentry *nfs_try_mount(struct nfs_sb_config *);
+int nfs_set_sb_security(struct super_block *, struct dentry *, struct nfs_sb_config *);
+int nfs_clone_sb_security(struct super_block *, struct dentry *, struct nfs_sb_config *);
+struct dentry *nfs_fs_mount_common(struct nfs_server *, struct nfs_sb_config *);
 void nfs_kill_super(struct super_block *);
-void nfs_fill_super(struct super_block *, struct nfs_mount_info *);
 
 extern struct rpc_stat nfs_rpcstat;
 
@@ -486,14 +471,13 @@ extern void nfs_read_prepare(struct rpc_task *task, void *calldata);
 extern void nfs_pageio_reset_read_mds(struct nfs_pageio_descriptor *pgio);
 
 /* super.c */
-void nfs_clone_super(struct super_block *, struct nfs_mount_info *);
 void nfs_umount_begin(struct super_block *);
 int  nfs_statfs(struct dentry *, struct kstatfs *);
 int  nfs_show_options(struct seq_file *, struct dentry *);
 int  nfs_show_devname(struct seq_file *, struct dentry *);
 int  nfs_show_path(struct seq_file *, struct dentry *);
 int  nfs_show_stats(struct seq_file *, struct dentry *);
-int nfs_remount(struct super_block *sb, int *flags, char *raw_data);
+int nfs_remount(struct super_block *sb, struct sb_config *sc);
 
 /* write.c */
 extern void nfs_pageio_init_write(struct nfs_pageio_descriptor *pgio,
diff --git a/fs/nfs/mount.c b/fs/nfs/mount.c
index e0c3381ad5c5..188ee4b324d9 100644
--- a/fs/nfs/mount.c
+++ b/fs/nfs/mount.c
@@ -240,42 +240,8 @@ static const match_table_t nfs_vers_tokens = {
 	{ Opt_vers_err, NULL }
 };
 
-struct nfs_sb_config *nfs_alloc_parsed_mount_data(void)
-{
-	struct nfs_sb_config *cfg;
-
-	cfg = kzalloc(sizeof(*cfg), GFP_KERNEL);
-	if (cfg) {
-		cfg->timeo		= NFS_UNSPEC_TIMEO;
-		cfg->retrans		= NFS_UNSPEC_RETRANS;
-		cfg->acregmin		= NFS_DEF_ACREGMIN;
-		cfg->acregmax		= NFS_DEF_ACREGMAX;
-		cfg->acdirmin		= NFS_DEF_ACDIRMIN;
-		cfg->acdirmax		= NFS_DEF_ACDIRMAX;
-		cfg->mount_server.port	= NFS_UNSPEC_PORT;
-		cfg->nfs_server.port	= NFS_UNSPEC_PORT;
-		cfg->nfs_server.protocol = XPRT_TRANSPORT_TCP;
-		cfg->selected_flavor	= RPC_AUTH_MAXFLAVOR;
-		cfg->minorversion	= 0;
-		cfg->need_mount	= true;
-		cfg->net		= current->nsproxy->net_ns;
-		security_init_mnt_opts(&cfg->lsm_opts);
-	}
-	return cfg;
-}
-
-void nfs_free_parsed_mount_data(struct nfs_sb_config *cfg)
-{
-	if (cfg) {
-		kfree(cfg->client_address);
-		kfree(cfg->mount_server.hostname);
-		kfree(cfg->nfs_server.export_path);
-		kfree(cfg->nfs_server.hostname);
-		kfree(cfg->fscache_uniq);
-		security_free_mnt_opts(&cfg->lsm_opts);
-		kfree(cfg);
-	}
-}
+const char nfs_slash[] = "/";
+EXPORT_SYMBOL_GPL(nfs_slash);
 
 /*
  * Sanity-check a server address provided by the mount command.
@@ -354,10 +320,8 @@ static int nfs_auth_info_add(struct nfs_sb_config *cfg,
 			return 0;
 	}
 
-	if (auth_info->flavor_len + 1 >= max_flavor_len) {
-		dfprintk(MOUNT, "NFS: too many sec= flavors\n");
-		return -EINVAL;
-	}
+	if (auth_info->flavor_len + 1 >= max_flavor_len)
+		return nfs_cfg_inval(cfg, "NFS: too many sec= flavors");
 
 	auth_info->flavors[auth_info->flavor_len++] = flavor;
 	return 0;
@@ -411,9 +375,7 @@ static int nfs_parse_security_flavors(struct nfs_sb_config *cfg, char *value)
 			pseudoflavor = RPC_AUTH_GSS_SPKMP;
 			break;
 		default:
-			dfprintk(MOUNT,
-				 "NFS: sec= option '%s' not recognized\n", p);
-			return -EINVAL;
+			return nfs_cfg_inval(cfg, "NFS: sec= option not recognized");
 		}
 
 		ret = nfs_auth_info_add(cfg, &cfg->auth_info, pseudoflavor);
@@ -457,8 +419,7 @@ static int nfs_parse_version_string(struct nfs_sb_config *cfg,
 		cfg->minorversion = 2;
 		break;
 	default:
-		dfprintk(MOUNT, "NFS:   Unsupported NFS version\n");
-		return -EINVAL;
+		return nfs_cfg_inval(cfg, "NFS: Unsupported NFS version");
 	}
 	return 0;
 }
@@ -495,8 +456,9 @@ static int nfs_get_option_ui_bound(struct nfs_sb_config *cfg,
 /*
  * Parse a single mount option in "key[=val]" form.
  */
-static int nfs_sb_config_parse_option(struct nfs_sb_config *cfg, char *p)
+static int nfs_sb_config_parse_option(struct sb_config *sc, char *p)
 {
+	struct nfs_sb_config *cfg = container_of(sc, struct nfs_sb_config, sc);
 	substring_t args[MAX_OPT_ARGS];
 	char *string;
 	int ret, token;
@@ -715,8 +677,7 @@ static int nfs_sb_config_parse_option(struct nfs_sb_config *cfg, char *p)
 			break;
 		default:
 			kfree(string);
-			dfprintk(MOUNT, "NFS:   unrecognized transport protocol\n");
-			return -EINVAL;
+			return nfs_cfg_inval(cfg, "NFS: Unrecognized transport protocol");
 		}
 		kfree(string);
 		break;
@@ -741,8 +702,7 @@ static int nfs_sb_config_parse_option(struct nfs_sb_config *cfg, char *p)
 			break;
 		case Opt_xprt_rdma: /* not used for side protocols */
 		default:
-			dfprintk(MOUNT, "NFS:   unrecognized transport protocol\n");
-			return -EINVAL;
+			return nfs_cfg_inval(cfg, "NFS: Unrecognized transport protocol");
 		}
 		break;
 	case Opt_addr:
@@ -750,7 +710,7 @@ static int nfs_sb_config_parse_option(struct nfs_sb_config *cfg, char *p)
 		if (string == NULL)
 			goto out_nomem;
 		cfg->nfs_server.addrlen =
-			rpc_pton(cfg->net, string, strlen(string),
+			rpc_pton(sc->net_ns, string, strlen(string),
 				 &cfg->nfs_server.address,
 				 sizeof(cfg->nfs_server._address));
 		kfree(string);
@@ -770,7 +730,7 @@ static int nfs_sb_config_parse_option(struct nfs_sb_config *cfg, char *p)
 		if (string == NULL)
 			goto out_nomem;
 		cfg->mount_server.addrlen =
-			rpc_pton(cfg->net, string, strlen(string),
+			rpc_pton(sc->net_ns, string, strlen(string),
 				 &cfg->mount_server.address,
 				 sizeof(cfg->mount_server._address));
 		kfree(string);
@@ -795,8 +755,7 @@ static int nfs_sb_config_parse_option(struct nfs_sb_config *cfg, char *p)
 			cfg->flags |= NFS_MOUNT_LOOKUP_CACHE_NONEG|NFS_MOUNT_LOOKUP_CACHE_NONE;
 			break;
 		default:
-			dfprintk(MOUNT, "NFS:   invalid lookupcache argument\n");
-			return -EINVAL;
+			return nfs_cfg_inval(cfg, "NFS: Invalid lookupcache argument");
 		}
 		break;
 	case Opt_fscache_uniq:
@@ -826,16 +785,15 @@ static int nfs_sb_config_parse_option(struct nfs_sb_config *cfg, char *p)
 					NFS_MOUNT_LOCAL_FCNTL);
 			break;
 		default:
-			dfprintk(MOUNT, "NFS:	invalid	local_lock argument\n");
-			return -EINVAL;
-		};
+			return nfs_cfg_inval(cfg, "NFS: invalid local_lock argument");
+		}
 		break;
 
 		/*
 		 * Special options
 		 */
 	case Opt_sloppy:
-		cfg->sloppy = 1;
+		sc->sloppy = 1;
 		dfprintk(MOUNT, "NFS:   relaxing parsing rules\n");
 		break;
 	case Opt_userspace:
@@ -845,116 +803,24 @@ static int nfs_sb_config_parse_option(struct nfs_sb_config *cfg, char *p)
 
 	default:
 		dfprintk(MOUNT, "NFS:   unrecognized mount option '%s'\n", p);
-		return -EINVAL;
+		if (!sc->sloppy)
+			return nfs_cfg_inval(cfg, "NFS: Unrecognized mount option");
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
+	return nfs_cfg_inval(cfg, "NFS: Bad mount option value specified");
+out_invalid_address:
+	return nfs_cfg_inval(cfg, "NFS: Bad IP address specified");
 }
 
 /*
- * Error-check and convert a string of mount options from user space into
- * a data structure.  The whole mount string is processed; bad options are
- * skipped as they are encountered.  If there were no errors, return 1;
- * otherwise return 0 (zero).
- */
-int nfs_parse_mount_options(char *raw, struct nfs_sb_config *cfg)
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
-	rc = security_sb_parse_opts_str(secdata, &cfg->lsm_opts);
-	if (rc)
-		goto out_security_failure;
-
-	free_secdata(secdata);
-
-	while ((p = strsep(&raw, ",")) != NULL) {
-		if (!*p)
-			continue;
-		if (nfs_sb_config_parse_option(cfg, p) < 0)
-			invalid_option = true;
-	}
-
-	if (!sloppy && invalid_option)
-		return 0;
-
-	if (cfg->minorversion && cfg->version != 4)
-		goto out_minorversion_mismatch;
-
-	if (cfg->options & NFS_OPTION_MIGRATION &&
-	    (cfg->version != 4 || cfg->minorversion != 0))
-		goto out_migration_misuse;
-
-	/*
-	 * verify that any proto=/mountproto= options match the address
-	 * families in the addr=/mountaddr= options.
-	 */
-	if (cfg->protofamily != AF_UNSPEC &&
-	    cfg->protofamily != cfg->nfs_server.address.sa_family)
-		goto out_proto_mismatch;
-
-	if (cfg->mountfamily != AF_UNSPEC) {
-		if (cfg->mount_server.addrlen) {
-			if (cfg->mountfamily != cfg->mount_server.address.sa_family)
-				goto out_mountproto_mismatch;
-		} else {
-			if (cfg->mountfamily != cfg->nfs_server.address.sa_family)
-				goto out_mountproto_mismatch;
-		}
-	}
-
-	return 1;
-
-out_minorversion_mismatch:
-	printk(KERN_INFO "NFS: mount option vers=%u does not support "
-			 "minorversion=%u\n", cfg->version, cfg->minorversion);
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
@@ -963,9 +829,9 @@ int nfs_parse_mount_options(char *raw, struct nfs_sb_config *cfg)
  * Note: caller frees hostname and export path, even on error.
  */
 static int nfs_parse_devname(struct nfs_sb_config *cfg,
-			     const char *dev_name,
 			     size_t maxnamlen, size_t maxpathlen)
 {
+	char *dev_name = cfg->sc.device;
 	size_t len;
 	char *end;
 
@@ -1009,19 +875,15 @@ static int nfs_parse_devname(struct nfs_sb_config *cfg,
 	return 0;
 
 out_bad_devname:
-	dfprintk(MOUNT, "NFS: device name not in host:path format\n");
-	return -EINVAL;
-
+	return nfs_cfg_inval(cfg, "NFS: device name not in host:path format");
 out_nomem:
-	dfprintk(MOUNT, "NFS: not enough memory to parse device name\n");
+	nfs_cfg_error(cfg, "NFS: not enough memory to parse device name");
 	return -ENOMEM;
-
 out_hostname:
-	dfprintk(MOUNT, "NFS: server hostname too long\n");
+	nfs_cfg_error(cfg, "NFS: server hostname too long");
 	return -ENAMETOOLONG;
-
 out_path:
-	dfprintk(MOUNT, "NFS: export pathname too long\n");
+	nfs_cfg_error(cfg, "NFS: export pathname too long");
 	return -ENAMETOOLONG;
 }
 
@@ -1041,14 +903,14 @@ static int nfs_parse_devname(struct nfs_sb_config *cfg,
  * + breaking back: trying proto=udp after proto=tcp, v2 after v3,
  *   mountproto=tcp after mountproto=udp, and so on
  */
-static int nfs23_validate_mount_data(void *options,
-				     struct nfs_sb_config *cfg,
-				     struct nfs_fh *mntfh,
-				     const char *dev_name)
+static int nfs23_monolithic_mount_data(struct sb_config *sc,
+				       struct nfs_mount_data *data)
 {
-	struct nfs_mount_data *data = (struct nfs_mount_data *)options;
+	struct nfs_sb_config *cfg = container_of(sc, struct nfs_sb_config, sc);
+	struct nfs_fh *mntfh = cfg->mntfh;
 	struct sockaddr *sap = (struct sockaddr *)&cfg->nfs_server.address;
 	int extra_flags = NFS_MOUNT_LEGACY_INTERFACE;
+	int ret;
 
 	if (data == NULL)
 		goto out_no_data;
@@ -1114,6 +976,9 @@ static int nfs23_validate_mount_data(void *options,
 			cfg->nfs_server.protocol = XPRT_TRANSPORT_UDP;
 		/* N.B. caller will free nfs_server.hostname in all cases */
 		cfg->nfs_server.hostname = kstrdup(data->hostname, GFP_KERNEL);
+		if (!cfg->nfs_server.hostname)
+			goto out_nomem;
+
 		cfg->namlen		= data->namlen;
 		cfg->bsize		= data->bsize;
 
@@ -1121,8 +986,6 @@ static int nfs23_validate_mount_data(void *options,
 			cfg->selected_flavor = data->pseudoflavor;
 		else
 			cfg->selected_flavor = RPC_AUTH_UNIX;
-		if (!cfg->nfs_server.hostname)
-			goto out_nomem;
 
 		if (!(data->flags & NFS_MOUNT_NONLM))
 			cfg->flags &= ~(NFS_MOUNT_LOCAL_FLOCK|
@@ -1130,6 +993,7 @@ static int nfs23_validate_mount_data(void *options,
 		else
 			cfg->flags |= (NFS_MOUNT_LOCAL_FLOCK|
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
-			rc = security_sb_parse_opts_str(opts_str, &cfg->lsm_opts);
+			ret = vfs_parse_mount_option(sc, opts_str);
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
+		return generic_monolithic_mount_data(sc, data);
 	}
 
+	cfg->skip_remount_option_check = true;
 	return 0;
 
 out_no_data:
-	dfprintk(MOUNT, "NFS: mount program didn't pass any mount data\n");
-	return -EINVAL;
+	if (sc->ms_flags & MS_REMOUNT) {
+		cfg->skip_remount_option_check = true;
+		return 0;
+	}
+	return nfs_cfg_inval(cfg, "NFS: mount program didn't pass any mount data");
 
 out_no_v3:
-	dfprintk(MOUNT, "NFS: nfs_mount_data version %d does not support v3\n",
-		 data->version);
-	return -EINVAL;
+	return nfs_cfg_inval(cfg, "NFS: nfs_mount_data version does not support v3");
 
 out_no_sec:
-	dfprintk(MOUNT, "NFS: nfs_mount_data version supports only AUTH_SYS\n");
-	return -EINVAL;
+	return nfs_cfg_inval(cfg, "NFS: nfs_mount_data version supports only AUTH_SYS");
 
 out_nomem:
-	dfprintk(MOUNT, "NFS: not enough memory to handle mount options\n");
+	dfprintk(MOUNT, "NFS: not enough memory to handle mount options");
 	return -ENOMEM;
 
 out_no_address:
-	dfprintk(MOUNT, "NFS: mount program didn't pass remote address\n");
-	return -EINVAL;
+	return nfs_cfg_inval(cfg, "NFS: mount program didn't pass remote address");
 
 out_invalid_fh:
-	dfprintk(MOUNT, "NFS: invalid root filehandle\n");
-	return -EINVAL;
-}
-
-#if IS_ENABLED(CONFIG_NFS_V4)
-
-static void nfs4_validate_mount_flags(struct nfs_sb_config *cfg)
-{
-	cfg->flags &= ~(NFS_MOUNT_NONLM|NFS_MOUNT_NOACL|NFS_MOUNT_VER3|
-			 NFS_MOUNT_LOCAL_FLOCK|NFS_MOUNT_LOCAL_FCNTL);
+	return nfs_cfg_inval(cfg, "NFS: invalid root filehandle");
 }
 
 /*
  * Validate NFSv4 mount options
  */
-static int nfs4_validate_mount_data(void *options,
-				    struct nfs_sb_config *cfg,
-				    const char *dev_name)
+static int nfs4_monolithic_mount_data(struct sb_config *sc,
+				      struct nfs4_mount_data *data)
 {
+	struct nfs_sb_config *cfg = container_of(sc, struct nfs_sb_config, sc);
 	struct sockaddr *sap = (struct sockaddr *)&cfg->nfs_server.address;
-	struct nfs4_mount_data *data = (struct nfs4_mount_data *)options;
 	char *c;
 
 	if (data == NULL)
@@ -1255,7 +1108,7 @@ static int nfs4_validate_mount_data(void *options,
 		cfg->client_address = c;
 
 		/*
-		 * Translate to nfs_sb_config, which nfs4_fill_super
+		 * Translate to nfs_sb_config, which nfs_fill_super
 		 * can deal with.
 		 */
 
@@ -1275,95 +1128,376 @@ static int nfs4_validate_mount_data(void *options,
 
 		break;
 	default:
-		return NFS_TEXT_DATA;
+		return generic_monolithic_mount_data(sc, data);
 	}
 
+	cfg->skip_remount_option_check = true;
 	return 0;
 
 out_no_data:
-	dfprintk(MOUNT, "NFS4: mount program didn't pass any mount data\n");
-	return -EINVAL;
+	if (sc->ms_flags & MS_REMOUNT) {
+		cfg->skip_remount_option_check = true;
+		return 0;
+	}
+	return nfs_cfg_inval(cfg, "NFS4: mount program didn't pass any mount data");
 
 out_inval_auth:
-	dfprintk(MOUNT, "NFS4: Invalid number of RPC auth flavours %d\n",
-		 data->auth_flavourlen);
-	return -EINVAL;
+	return nfs_cfg_inval(cfg, "NFS4: Invalid number of RPC auth flavours");
 
 out_no_address:
-	dfprintk(MOUNT, "NFS4: mount program didn't pass remote address\n");
-	return -EINVAL;
+	return nfs_cfg_inval(cfg, "NFS4: mount program didn't pass remote address");
 
 out_invalid_transport_udp:
-	dfprintk(MOUNT, "NFSv4: Unsupported transport protocol udp\n");
-	return -EINVAL;
+	return nfs_cfg_inval(cfg, "NFSv4: Unsupported transport protocol udp");
 }
 
-int nfs_validate_mount_data(struct file_system_type *fs_type,
-			    void *options,
-			    struct nfs_sb_config *cfg,
-			    struct nfs_fh *mntfh,
-			    const char *dev_name)
-{
-	if (fs_type == &nfs_fs_type)
-		return nfs23_validate_mount_data(options, cfg, mntfh, dev_name);
-	return nfs4_validate_mount_data(options, cfg, dev_name);
-}
-#else
-static int nfs_validate_mount_data(struct file_system_type *fs_type,
-				   void *options,
-				   struct nfs_sb_config *cfg,
-				   struct nfs_fh *mntfh,
-				   const char *dev_name)
+/*
+ * Parse a monolithic block of data from sys_mount().
+ */
+static int nfs_monolithic_mount_data(struct sb_config *sc, void *data)
 {
-	return nfs23_validate_mount_data(options, cfg, mntfh, dev_name);
-}
+	struct nfs_sb_config *cfg = container_of(sc, struct nfs_sb_config, sc);
+
+	if (sc->fs_type == &nfs_fs_type)
+		return nfs23_monolithic_mount_data(sc, data);
+
+#if IS_ENABLED(CONFIG_NFS_V4)
+	if (sc->fs_type == &nfs4_fs_type)
+		return nfs4_monolithic_mount_data(sc, data);
 #endif
 
-int nfs_validate_text_mount_data(void *options,
-				 struct nfs_sb_config *cfg,
-				 const char *dev_name)
+	return nfs_cfg_inval(cfg, "NFS: Unsupported monolithic data version");
+}
+
+/*
+ * Validate the preparsed information in the mount context.
+ */
+static int nfs_sb_config_validate(struct sb_config *sc)
 {
-	int port = 0;
+	struct nfs_sb_config *cfg = container_of(sc, struct nfs_sb_config, sc);
+	struct nfs_subversion *nfs_mod;
+	struct sockaddr *sap = (struct sockaddr *)&cfg->nfs_server.address;
 	int max_namelen = PAGE_SIZE;
 	int max_pathlen = NFS_MAXPATHLEN;
-	struct sockaddr *sap = (struct sockaddr *)&cfg->nfs_server.address;
+	int port = 0;
+	int ret;
+
+	if (cfg->sc.purpose == SB_CONFIG_FOR_REMOUNT)
+		return 0;
 
-	if (nfs_parse_mount_options((char *)options, cfg) == 0)
-		return -EINVAL;
+	if (!cfg->sc.device)
+		goto out_no_device_name;
+
+	/* Check for sanity first. */
+	if (cfg->minorversion && cfg->version != 4)
+		goto out_minorversion_mismatch;
+
+	if (cfg->options & NFS_OPTION_MIGRATION &&
+	    (cfg->version != 4 || cfg->minorversion != 0))
+		goto out_migration_misuse;
+
+	/* Verify that any proto=/mountproto= options match the address
+	 * families in the addr=/mountaddr= options.
+	 */
+	if (cfg->protofamily != AF_UNSPEC &&
+	    cfg->protofamily != cfg->nfs_server.address.sa_family)
+		goto out_proto_mismatch;
+
+	if (cfg->mountfamily != AF_UNSPEC) {
+		if (cfg->mount_server.addrlen) {
+			if (cfg->mountfamily != cfg->mount_server.address.sa_family)
+				goto out_mountproto_mismatch;
+		} else {
+			if (cfg->mountfamily != cfg->nfs_server.address.sa_family)
+				goto out_mountproto_mismatch;
+		}
+	}
 
 	if (!nfs_verify_server_address(sap))
 		goto out_no_address;
 
 	if (cfg->version == 4) {
-#if IS_ENABLED(CONFIG_NFS_V4)
-		port = NFS_PORT;
-		max_namelen = NFS4_MAXNAMLEN;
-		max_pathlen = NFS4_MAXPATHLEN;
-		nfs_validate_transport_protocol(cfg);
-		if (cfg->nfs_server.protocol == XPRT_TRANSPORT_UDP)
-			goto out_invalid_transport_udp;
-		nfs4_validate_mount_flags(cfg);
-#else
-		goto out_v4_not_compiled;
-#endif /* CONFIG_NFS_V4 */
-	} else
+		if (IS_ENABLED(CONFIG_NFS_V4)) {
+			port = NFS_PORT;
+			max_namelen = NFS4_MAXNAMLEN;
+			max_pathlen = NFS4_MAXPATHLEN;
+			nfs_validate_transport_protocol(cfg);
+			if (cfg->nfs_server.protocol == XPRT_TRANSPORT_UDP)
+				goto out_invalid_transport_udp;
+			cfg->flags &= ~(NFS_MOUNT_NONLM | NFS_MOUNT_NOACL |
+					 NFS_MOUNT_VER3 | NFS_MOUNT_LOCAL_FLOCK |
+					 NFS_MOUNT_LOCAL_FCNTL);
+		} else {
+			goto out_v4_not_compiled;
+		}
+	} else {
 		nfs_set_mount_transport_protocol(cfg);
+	}
 
 	nfs_set_port(sap, &cfg->nfs_server.port, port);
 
-	return nfs_parse_devname(cfg, dev_name, max_namelen, max_pathlen);
+	ret = nfs_parse_devname(cfg, max_namelen, max_pathlen);
+	if (ret < 0)
+		return ret;
+
+	/* Load the NFS protocol module if we haven't done so yet */
+	if (!cfg->nfs_mod) {
+		nfs_mod = get_nfs_version(cfg->version);
+		if (IS_ERR(nfs_mod)) {
+			ret = PTR_ERR(nfs_mod);
+			goto out_version_unavailable;
+		}
+		cfg->nfs_mod = nfs_mod;
+	}
+	return 0;
 
-#if !IS_ENABLED(CONFIG_NFS_V4)
+out_no_device_name:
+	return nfs_cfg_inval(cfg, "NFS: Device name not specified");
 out_v4_not_compiled:
-	dfprintk(MOUNT, "NFS: NFSv4 is not compiled into kernel\n");
+	nfs_cfg_error(cfg, "NFS: NFSv4 is not compiled into kernel");
 	return -EPROTONOSUPPORT;
-#else
 out_invalid_transport_udp:
-	dfprintk(MOUNT, "NFSv4: Unsupported transport protocol udp\n");
-	return -EINVAL;
-#endif /* !CONFIG_NFS_V4 */
-
+	return nfs_cfg_inval(cfg, "NFSv4: Unsupported transport protocol udp");
 out_no_address:
-	dfprintk(MOUNT, "NFS: mount program didn't pass remote address\n");
-	return -EINVAL;
+	return nfs_cfg_inval(cfg, "NFS: mount program didn't pass remote address");
+out_mountproto_mismatch:
+	return nfs_cfg_inval(cfg, "NFS: Mount server address does not match mountproto= option");
+out_proto_mismatch:
+	return nfs_cfg_inval(cfg, "NFS: Server address does not match proto= option");
+out_minorversion_mismatch:
+	return nfs_cfg_inval(cfg, "NFS: Mount option does not support minorversion");
+out_migration_misuse:
+	return nfs_cfg_inval(cfg, "NFS: 'Migration' not supported for this NFS version");
+out_version_unavailable:
+	nfs_cfg_inval(cfg, "NFS: Version unavailable");
+	return ret;
+}
+
+/*
+ * Use the preparsed information in the mount context to effect a mount.
+ */
+static struct dentry *nfs_ordinary_mount(struct nfs_sb_config *cfg)
+{
+	cfg->set_security = nfs_set_sb_security;
+
+	return cfg->nfs_mod->rpc_ops->try_mount(cfg);
+}
+
+/*
+ * Clone an NFS2/3/4 server record on xdev traversal (FSID-change)
+ */
+static struct dentry *nfs_xdev_mount(struct nfs_sb_config *cfg)
+{
+	struct nfs_server *server;
+	struct dentry *mntroot = ERR_PTR(-ENOMEM);
+
+	dprintk("--> nfs_xdev_mount()\n");
+
+	cfg->set_security = nfs_clone_sb_security;
+
+	/* create a new volume representation */
+	server = cfg->nfs_mod->rpc_ops->clone_server(NFS_SB(cfg->clone_data.sb),
+						     cfg->mntfh,
+						     cfg->clone_data.fattr,
+						     cfg->selected_flavor);
+
+	if (IS_ERR(server))
+		mntroot = ERR_CAST(server);
+	else
+		mntroot = nfs_fs_mount_common(server, cfg);
+
+	dprintk("<-- nfs_xdev_mount() = %ld\n",
+			IS_ERR(mntroot) ? PTR_ERR(mntroot) : 0L);
+	return mntroot;
+}
+
+/*
+ * Handle ordinary mounts inspired by the user and cross-FSID mounts.
+ */
+struct dentry *nfs_general_mount(struct nfs_sb_config *cfg)
+{
+	switch (cfg->mount_type) {
+	case NFS_MOUNT_ORDINARY:
+		return nfs_ordinary_mount(cfg);
+
+	case NFS_MOUNT_CROSS_DEV:
+		return nfs_xdev_mount(cfg);
+
+	default:
+		nfs_cfg_error(cfg, "NFS: Unknown mount type");
+		return ERR_PTR(-ENOTSUPP);
+	}
+}
+EXPORT_SYMBOL_GPL(nfs_general_mount);
+
+static struct dentry *nfs_fs_mount(struct sb_config *sc)
+{
+	struct nfs_sb_config *cfg = container_of(sc, struct nfs_sb_config, sc);
+
+	if (!cfg->nfs_mod) {
+		pr_warn("Missing nfs_mod\n");
+		return ERR_PTR(-EINVAL);
+	}
+	if (!cfg->nfs_mod->rpc_ops) {
+		pr_warn("Missing rpc_ops\n");
+		return ERR_PTR(-EINVAL);
+	}
+	if (!cfg->nfs_mod->rpc_ops->mount) {
+		pr_warn("Missing mount\n");
+		return ERR_PTR(-EINVAL);
+	}
+
+	return cfg->nfs_mod->rpc_ops->mount(cfg);
+}
+
+/*
+ * Handle duplication of a mount context.  The caller copied *src into *mc, but
+ * it can't deal with resource pointers in the filesystem context, so we have
+ * to do that.  We need to clear pointers, copy data or get extra refs as
+ * appropriate.
+ */
+static int nfs_sb_config_dup(struct sb_config *sc, struct sb_config *src)
+{
+	struct nfs_sb_config *cfg = container_of(sc, struct nfs_sb_config, sc);
+
+	__module_get(cfg->nfs_mod->owner);
+	cfg->client_address		= NULL;
+	cfg->mount_server.hostname	= NULL;
+	cfg->nfs_server.export_path	= NULL;
+	cfg->nfs_server.hostname	= NULL;
+	cfg->fscache_uniq		= NULL;
+
+	cfg->mntfh = nfs_alloc_fhandle();
+	if (!cfg->mntfh)
+		return -ENOMEM;
+	return 0;
+}
+
+static void nfs_sb_config_free(struct sb_config *sc)
+{
+	struct nfs_sb_config *cfg = container_of(sc, struct nfs_sb_config, sc);
+
+	if (cfg->nfs_mod)
+		put_nfs_version(cfg->nfs_mod);
+	kfree(cfg->client_address);
+	kfree(cfg->mount_server.hostname);
+	if (cfg->nfs_server.export_path != nfs_slash)
+		kfree(cfg->nfs_server.export_path);
+	kfree(cfg->nfs_server.hostname);
+	kfree(cfg->fscache_uniq);
+	nfs_free_fhandle(cfg->mntfh);
 }
+
+static const struct sb_config_operations nfs_sb_config_ops = {
+	.free			= nfs_sb_config_free,
+	.dup			= nfs_sb_config_dup,
+	.parse_option		= nfs_sb_config_parse_option,
+	.monolithic_mount_data	= nfs_monolithic_mount_data,
+	.validate		= nfs_sb_config_validate,
+	.mount			= nfs_fs_mount,
+};
+
+/*
+ * Initialise a mount context from an extant superblock for remounting.
+ */
+static int nfs_mount_init_from_sb(struct sb_config *sc,
+				  struct super_block *sb)
+{
+	struct nfs_sb_config *cfg = container_of(sc, struct nfs_sb_config, sc);
+	struct nfs_server *nfss = sb->s_fs_info;
+	struct net *net = nfss->nfs_client->cl_net;
+
+	cfg->flags		= nfss->flags;
+	cfg->rsize		= nfss->rsize;
+	cfg->wsize		= nfss->wsize;
+	cfg->retrans		= nfss->client->cl_timeout->to_retries;
+	cfg->selected_flavor	= nfss->client->cl_auth->au_flavor;
+	cfg->acregmin		= nfss->acregmin / HZ;
+	cfg->acregmax		= nfss->acregmax / HZ;
+	cfg->acdirmin		= nfss->acdirmin / HZ;
+	cfg->acdirmax		= nfss->acdirmax / HZ;
+	cfg->timeo		= 10U * nfss->client->cl_timeout->to_initval / HZ;
+	cfg->nfs_server.port	= nfss->port;
+	cfg->nfs_server.addrlen	= nfss->nfs_client->cl_addrlen;
+	cfg->version		= nfss->nfs_client->rpc_ops->version;
+	cfg->minorversion	= nfss->nfs_client->cl_minorversion;
+
+	memcpy(&cfg->nfs_server.address, &nfss->nfs_client->cl_addr,
+		cfg->nfs_server.addrlen);
+
+	if (cfg->sc.net_ns != net) {
+		put_net(cfg->sc.net_ns);
+		cfg->sc.net_ns = get_net(net);
+	}
+
+	cfg->nfs_mod = nfss->nfs_client->cl_nfs_mod;
+	if (!try_module_get(cfg->nfs_mod->owner)) {
+		cfg->nfs_mod = NULL;
+		nfs_cfg_error(cfg, "NFS: Protocol module not available");
+		return -ENOENT;
+	}
+
+	return 0;
+}
+
+/*
+ * Prepare mount context.  We use the namespaces attached to the context.  This
+ * may be the current process's namespaces, or it may be a container's
+ * namespaces.
+ */
+static int nfs_init_sb_config(struct sb_config *sc, struct super_block *src_sb)
+{
+	struct nfs_sb_config *cfg = container_of(sc, struct nfs_sb_config, sc);
+
+	cfg->mntfh = nfs_alloc_fhandle();
+	if (!cfg->mntfh)
+		return -ENOMEM;
+
+	cfg->sc.ops		= &nfs_sb_config_ops;
+	cfg->mount_type		= NFS_MOUNT_ORDINARY;
+	cfg->protofamily	= AF_UNSPEC;
+	cfg->mountfamily	= AF_UNSPEC;
+	cfg->mount_server.port	= NFS_UNSPEC_PORT;
+
+	if (!src_sb) {
+		cfg->timeo		= NFS_UNSPEC_TIMEO;
+		cfg->retrans		= NFS_UNSPEC_RETRANS;
+		cfg->acregmin		= NFS_DEF_ACREGMIN;
+		cfg->acregmax		= NFS_DEF_ACREGMAX;
+		cfg->acdirmin		= NFS_DEF_ACDIRMIN;
+		cfg->acdirmax		= NFS_DEF_ACDIRMAX;
+		cfg->nfs_server.port	= NFS_UNSPEC_PORT;
+		cfg->nfs_server.protocol = XPRT_TRANSPORT_TCP;
+		cfg->selected_flavor	= RPC_AUTH_MAXFLAVOR;
+		cfg->minorversion	= 0;
+		cfg->need_mount		= true;
+		return 0;
+	}
+
+	return nfs_mount_init_from_sb(sc, src_sb);
+}
+
+struct file_system_type nfs_fs_type = {
+	.owner		= THIS_MODULE,
+	.name		= "nfs",
+	.init_sb_config	= nfs_init_sb_config,
+	.sb_config_size	= sizeof(struct nfs_sb_config),
+	.kill_sb	= nfs_kill_super,
+	.fs_flags	= FS_RENAME_DOES_D_MOVE|FS_BINARY_MOUNTDATA,
+};
+MODULE_ALIAS_FS("nfs");
+EXPORT_SYMBOL_GPL(nfs_fs_type);
+
+#if IS_ENABLED(CONFIG_NFS_V4)
+struct file_system_type nfs4_fs_type = {
+	.owner		= THIS_MODULE,
+	.name		= "nfs4",
+	.sb_config_size	= sizeof(struct nfs_sb_config),
+	.init_sb_config	= nfs_init_sb_config,
+	.kill_sb	= nfs_kill_super,
+	.fs_flags	= FS_RENAME_DOES_D_MOVE|FS_BINARY_MOUNTDATA,
+};
+MODULE_ALIAS_FS("nfs4");
+MODULE_ALIAS("nfs4");
+EXPORT_SYMBOL_GPL(nfs4_fs_type);
+#endif /* CONFIG_NFS_V4 */
diff --git a/fs/nfs/namespace.c b/fs/nfs/namespace.c
index 1a224a33a6c2..7f8775bd28a8 100644
--- a/fs/nfs/namespace.c
+++ b/fs/nfs/namespace.c
@@ -18,6 +18,7 @@
 #include <linux/vfs.h>
 #include <linux/sunrpc/gss_api.h>
 #include "internal.h"
+#include "nfs.h"
 
 #define NFSDBG_FACILITY		NFSDBG_VFS
 
@@ -213,10 +214,9 @@ void nfs_release_automount_timer(void)
  * Clone a mountpoint of the appropriate type
  */
 static struct vfsmount *nfs_do_clone_mount(struct nfs_server *server,
-					   const char *devname,
-					   struct nfs_clone_mount *mountdata)
+					   struct nfs_sb_config *cfg)
 {
-	return vfs_submount(mountdata->dentry, &nfs_xdev_fs_type, devname, mountdata);
+	return vfs_submount_sc(cfg->clone_data.dentry, &cfg->sc);
 }
 
 /**
@@ -230,27 +230,53 @@ static struct vfsmount *nfs_do_clone_mount(struct nfs_server *server,
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
+	struct nfs_sb_config *cfg;
+	struct sb_config *sc;
 	struct vfsmount *mnt;
-	char *page = (char *) __get_free_page(GFP_USER);
-	char *devname;
+	char *buffer, *p;
 
-	if (page == NULL)
-		return ERR_PTR(-ENOMEM);
+	/* Open a new mount context, transferring parameters from the parent
+	 * superblock, including the network namespace.
+	 */
+	sc = __vfs_new_sb_config(&nfs_fs_type, dentry->d_sb, 0,
+				 SB_CONFIG_FOR_SUBMOUNT);
+	if (IS_ERR(sc))
+		return ERR_CAST(sc);
+	cfg = container_of(sc, struct nfs_sb_config, sc);
 
-	devname = nfs_devname(dentry, page, PAGE_SIZE);
-	if (IS_ERR(devname))
-		mnt = (struct vfsmount *)devname;
-	else
-		mnt = nfs_do_clone_mount(NFS_SB(dentry->d_sb), devname, &mountdata);
+	mnt = ERR_PTR(-ENOMEM);
+	buffer = kmalloc(4096, GFP_USER);
+	if (!buffer)
+		goto err_sc;
+
+	cfg->mount_type		= NFS_MOUNT_CROSS_DEV;
+	cfg->selected_flavor	= authflavor;
+	cfg->clone_data.sb	= dentry->d_sb;
+	cfg->clone_data.dentry	= dentry;
+	cfg->clone_data.fattr	= fattr;
+	cfg->clone_data.cloned	= true;
+
+	nfs_copy_fh(cfg->mntfh, fh);
+
+	p = nfs_devname(dentry, buffer, 4096);
+	if (IS_ERR(p)) {
+		nfs_cfg_error(cfg, "NFS: Couldn't determine submount pathname");
+		mnt = ERR_CAST(p);
+		goto err_buffer;
+	}
+
+	cfg->sc.device = kmemdup(p, buffer + 4096 - p, GFP_KERNEL);
+	if (!cfg->sc.device)
+		goto err_buffer;
+	kfree(buffer);
+
+	mnt = nfs_do_clone_mount(NFS_SB(dentry->d_sb), cfg);
+	goto err_sc;
 
-	free_page((unsigned long)page);
+err_buffer:
+	kfree(buffer);
+err_sc:
+	put_sb_config(sc);
 	return mnt;
 }
 EXPORT_SYMBOL_GPL(nfs_do_submount);
diff --git a/fs/nfs/nfs3_fs.h b/fs/nfs/nfs3_fs.h
index e134d6548ab7..7187e2e28a65 100644
--- a/fs/nfs/nfs3_fs.h
+++ b/fs/nfs/nfs3_fs.h
@@ -26,7 +26,7 @@ static inline int nfs3_proc_setacls(struct inode *inode, struct posix_acl *acl,
 #endif /* CONFIG_NFS_V3_ACL */
 
 /* nfs3client.c */
-struct nfs_server *nfs3_create_server(struct nfs_mount_info *, struct nfs_subversion *);
+struct nfs_server *nfs3_create_server(struct nfs_sb_config *);
 struct nfs_server *nfs3_clone_server(struct nfs_server *, struct nfs_fh *,
 				     struct nfs_fattr *, rpc_authflavor_t);
 
diff --git a/fs/nfs/nfs3client.c b/fs/nfs/nfs3client.c
index 7879f2a0fcfd..8b688d71c37c 100644
--- a/fs/nfs/nfs3client.c
+++ b/fs/nfs/nfs3client.c
@@ -45,10 +45,10 @@ static inline void nfs_init_server_aclclient(struct nfs_server *server)
 }
 #endif
 
-struct nfs_server *nfs3_create_server(struct nfs_mount_info *mount_info,
-				      struct nfs_subversion *nfs_mod)
+struct nfs_server *nfs3_create_server(struct nfs_sb_config *cfg)
 {
-	struct nfs_server *server = nfs_create_server(mount_info, nfs_mod);
+	struct nfs_server *server = nfs_create_server(cfg);
+
 	/* Create a client RPC handle for the NFS v3 ACL management interface */
 	if (!IS_ERR(server))
 		nfs_init_server_aclclient(server);
diff --git a/fs/nfs/nfs3proc.c b/fs/nfs/nfs3proc.c
index 0c07b567118d..ce926c8431d4 100644
--- a/fs/nfs/nfs3proc.c
+++ b/fs/nfs/nfs3proc.c
@@ -974,6 +974,7 @@ const struct nfs_rpc_ops nfs_v3_clientops = {
 	.file_ops	= &nfs_file_operations,
 	.nlmclnt_ops	= &nlmclnt_fl_close_lock_ops,
 	.getroot	= nfs3_proc_get_root,
+	.mount		= nfs_general_mount,
 	.submount	= nfs_submount,
 	.try_mount	= nfs_try_mount,
 	.getattr	= nfs3_proc_getattr,
diff --git a/fs/nfs/nfs4_fs.h b/fs/nfs/nfs4_fs.h
index af285cc27ccf..05769b633b76 100644
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
 
+extern struct dentry *nfs4_try_mount(struct nfs_sb_config *);
+extern struct dentry *nfs4_mount(struct nfs_sb_config *);
+
 /* nfs4sysctl.c */
 #ifdef CONFIG_SYSCTL
 int nfs4_register_sysctl(void);
diff --git a/fs/nfs/nfs4client.c b/fs/nfs/nfs4client.c
index ec0c112d8148..f1b9b9c7db12 100644
--- a/fs/nfs/nfs4client.c
+++ b/fs/nfs/nfs4client.c
@@ -1033,14 +1033,14 @@ static int nfs4_init_server(struct nfs_server *server,
 
 	/* Get a client record */
 	error = nfs4_set_client(server,
-			cfg->nfs_server.hostname,
-			(const struct sockaddr *)&cfg->nfs_server.address,
-			cfg->nfs_server.addrlen,
-			cfg->client_address,
-			cfg->nfs_server.protocol,
-			&timeparms,
-			cfg->minorversion,
-			cfg->net);
+				cfg->nfs_server.hostname,
+				&cfg->nfs_server.address,
+				cfg->nfs_server.addrlen,
+				cfg->client_address,
+				cfg->nfs_server.protocol,
+				&timeparms,
+				cfg->minorversion,
+				cfg->sc.net_ns);
 	if (error < 0)
 		return error;
 
@@ -1063,10 +1063,7 @@ static int nfs4_init_server(struct nfs_server *server,
  * Create a version 4 volume record
  * - keyed on server and FSID
  */
-/*struct nfs_server *nfs4_create_server(const struct nfs_sb_config *data,
-				      struct nfs_fh *mntfh)*/
-struct nfs_server *nfs4_create_server(struct nfs_mount_info *mount_info,
-				      struct nfs_subversion *nfs_mod)
+struct nfs_server *nfs4_create_server(struct nfs_sb_config *cfg)
 {
 	struct nfs_server *server;
 	bool auth_probe;
@@ -1076,14 +1073,14 @@ struct nfs_server *nfs4_create_server(struct nfs_mount_info *mount_info,
 	if (!server)
 		return ERR_PTR(-ENOMEM);
 
-	auth_probe = mount_info->cfg->auth_info.flavor_len < 1;
+	auth_probe = cfg->auth_info.flavor_len < 1;
 
 	/* set up the general RPC client */
-	error = nfs4_init_server(server, mount_info->cfg);
+	error = nfs4_init_server(server, cfg);
 	if (error < 0)
 		goto error;
 
-	error = nfs4_server_common_setup(server, mount_info->mntfh, auth_probe);
+	error = nfs4_server_common_setup(server, cfg->mntfh, auth_probe);
 	if (error < 0)
 		goto error;
 
@@ -1097,8 +1094,7 @@ struct nfs_server *nfs4_create_server(struct nfs_mount_info *mount_info,
 /*
  * Create an NFS4 referral server record
  */
-struct nfs_server *nfs4_create_referral_server(struct nfs_clone_mount *data,
-					       struct nfs_fh *mntfh)
+struct nfs_server *nfs4_create_referral_server(struct nfs_sb_config *cfg)
 {
 	struct nfs_client *parent_client;
 	struct nfs_server *server, *parent_server;
@@ -1109,7 +1105,7 @@ struct nfs_server *nfs4_create_referral_server(struct nfs_clone_mount *data,
 	if (!server)
 		return ERR_PTR(-ENOMEM);
 
-	parent_server = NFS_SB(data->sb);
+	parent_server = NFS_SB(cfg->clone_data.sb);
 	parent_client = parent_server->nfs_client;
 
 	/* Initialise the client representation from the parent server */
@@ -1117,9 +1113,10 @@ struct nfs_server *nfs4_create_referral_server(struct nfs_clone_mount *data,
 
 	/* Get a client representation.
 	 * Note: NFSv4 always uses TCP, */
-	error = nfs4_set_client(server, data->hostname,
-				data->addr,
-				data->addrlen,
+	error = nfs4_set_client(server,
+				cfg->nfs_server.hostname,
+				&cfg->nfs_server.address,
+				cfg->nfs_server.addrlen,
 				parent_client->cl_ipaddr,
 				rpc_protocol(parent_server->client),
 				parent_server->client->cl_timeout,
@@ -1128,13 +1125,14 @@ struct nfs_server *nfs4_create_referral_server(struct nfs_clone_mount *data,
 	if (error < 0)
 		goto error;
 
-	error = nfs_init_server_rpcclient(server, parent_server->client->cl_timeout, data->authflavor);
+	error = nfs_init_server_rpcclient(server, parent_server->client->cl_timeout,
+					  cfg->selected_flavor);
 	if (error < 0)
 		goto error;
 
 	auth_probe = parent_server->auth_info.flavor_len < 1;
 
-	error = nfs4_server_common_setup(server, mntfh, auth_probe);
+	error = nfs4_server_common_setup(server, cfg->mntfh, auth_probe);
 	if (error < 0)
 		goto error;
 
diff --git a/fs/nfs/nfs4namespace.c b/fs/nfs/nfs4namespace.c
index 7d531da1bae3..45c9d808e7f1 100644
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
+				struct nfs_sb_config *ctx)
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
+				     struct nfs_sb_config *ctx,
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
 
+	ctx->sc.device = kmalloc(len + 1 + ctx->nfs_server.export_path_len + 1,
+				 GFP_KERNEL);
+	if (!ctx->sc.device)
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
+		p = ctx->sc.device;
+		memcpy(p, buf->data, buf->len);
+		p += buf->len;
+		*p++ = ':';
+		memcpy(p, ctx->nfs_server.export_path, ctx->nfs_server.export_path_len);
+		p += ctx->nfs_server.export_path_len;
+		*p = 0;
 
-		mnt = vfs_submount(mountdata->dentry, &nfs4_referral_fs_type, page, mountdata);
+		mnt = vfs_submount_sc(ctx->clone_data.dentry, &ctx->sc);
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
+	struct nfs_sb_config *cfg;
+	struct sb_config *sc;
+	struct vfsmount *mnt;
+	char *export_path;
 	int loc, error;
 
 	if (locations == NULL || locations->nlocations <= 0)
 		goto out;
 
+	sc = __vfs_new_sb_config(&nfs4_fs_type, dentry->d_sb, 0,
+				 SB_CONFIG_FOR_SUBMOUNT);
+	if (IS_ERR(sc)) {
+		mnt = ERR_CAST(sc);
+		goto out;
+	}
+	cfg = container_of(sc, struct nfs_sb_config, sc);
+
 	dprintk("%s: referral at %pd2\n", __func__, dentry);
 
-	page = (char *) __get_free_page(GFP_USER);
-	if (!page)
-		goto out;
+	cfg->mount_type		= NFS4_MOUNT_REFERRAL;
+	cfg->clone_data.sb	= dentry->d_sb;
+	cfg->clone_data.dentry	= dentry;
+	cfg->clone_data.cloned	= true;
 
-	page2 = (char *) __get_free_page(GFP_USER);
-	if (!page2)
-		goto out;
+	export_path = nfs4_pathname_string(&locations->fs_path,
+					   &cfg->nfs_server.export_path_len);
+	if (IS_ERR(export_path)) {
+		mnt = ERR_CAST(export_path);
+		goto out_sc;
+	}
+	cfg->nfs_server.export_path = export_path;
 
 	/* Ensure fs path is a prefix of current dentry path */
-	error = nfs4_validate_fspath(dentry, locations, page, page2);
+	error = nfs4_validate_fspath(dentry, locations, cfg);
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
+		mnt = try_location(cfg->clone_data.dentry, cfg, location);
 		if (!IS_ERR(mnt))
 			break;
 	}
 
+out_sc:
+	put_sb_config(sc);
 out:
-	free_page((unsigned long) page);
-	free_page((unsigned long) page2);
 	return mnt;
 }
 
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index c08c46a3b8cd..9f9bacdf6f86 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -9307,6 +9307,7 @@ const struct nfs_rpc_ops nfs_v4_clientops = {
 	.file_inode_ops	= &nfs4_file_inode_operations,
 	.file_ops	= &nfs4_file_operations,
 	.getroot	= nfs4_proc_get_root,
+	.mount		= nfs4_mount,
 	.submount	= nfs4_submount,
 	.try_mount	= nfs4_try_mount,
 	.getattr	= nfs4_proc_getattr,
diff --git a/fs/nfs/nfs4super.c b/fs/nfs/nfs4super.c
index 5f5debfd4007..7bc27a28d5da 100644
--- a/fs/nfs/nfs4super.c
+++ b/fs/nfs/nfs4super.c
@@ -18,36 +18,9 @@
 
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
+static struct dentry *nfs4_remote_mount(struct nfs_sb_config *cfg);
+static struct dentry *nfs4_referral_mount(struct nfs_sb_config *cfg);
+static struct dentry *nfs4_remote_referral_mount(struct nfs_sb_config *cfg);
 
 static const struct super_operations nfs4_sops = {
 	.alloc_inode	= nfs_alloc_inode,
@@ -61,16 +34,16 @@ static const struct super_operations nfs4_sops = {
 	.show_devname	= nfs_show_devname,
 	.show_path	= nfs_show_path,
 	.show_stats	= nfs_show_stats,
-	.remount_fs	= nfs_remount,
+	.remount_fs_sc	= nfs_remount,
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
@@ -104,47 +77,58 @@ static void nfs4_evict_inode(struct inode *inode)
 /*
  * Get the superblock for the NFS4 root partition
  */
-static struct dentry *
-nfs4_remote_mount(struct file_system_type *fs_type, int flags,
-		  const char *dev_name, void *info)
+static struct dentry *nfs4_remote_mount(struct nfs_sb_config *cfg)
 {
-	struct nfs_mount_info *mount_info = info;
 	struct nfs_server *server;
-	struct dentry *mntroot = ERR_PTR(-ENOMEM);
 
-	mount_info->set_security = nfs_set_sb_security;
+	cfg->set_security = nfs_set_sb_security;
 
 	/* Get a volume representation */
-	server = nfs4_create_server(mount_info, &nfs_v4);
-	if (IS_ERR(server)) {
-		mntroot = ERR_CAST(server);
-		goto out;
-	}
-
-	mntroot = nfs_fs_mount_common(server, flags, dev_name, mount_info, &nfs_v4);
+	server = nfs4_create_server(cfg);
+	if (IS_ERR(server))
+		return ERR_CAST(server);
 
-out:
-	return mntroot;
+	return nfs_fs_mount_common(server, cfg);
 }
 
-static struct vfsmount *nfs_do_root_mount(struct file_system_type *fs_type,
-		int flags, void *data, const char *hostname)
+/*
+ * Create a mount for the root of the server.  We copy the mount context we
+ * have for the parameters and set its hostname, path and type.
+ */
+static struct vfsmount *nfs_do_root_mount(struct nfs_sb_config *cfg,
+					  const char *hostname,
+					  enum nfs_mount_type type)
 {
+	struct nfs_sb_config *root_cfg;
+	struct sb_config *root_sc;
 	struct vfsmount *root_mnt;
 	char *root_devname;
 	size_t len;
 
+	root_sc = vfs_dup_sb_config(&cfg->sc);
+	if (IS_ERR(root_sc))
+		return ERR_CAST(root_sc);
+	root_cfg = container_of(root_sc, struct nfs_sb_config, sc);
+
+	root_cfg->mount_type = type;
+	root_cfg->nfs_server.export_path = (char *)nfs_slash;
+
 	len = strlen(hostname) + 5;
+	root_mnt = ERR_PTR(-ENOMEM);
 	root_devname = kmalloc(len, GFP_KERNEL);
 	if (root_devname == NULL)
-		return ERR_PTR(-ENOMEM);
+		goto out_sc;
+
 	/* Does hostname needs to be enclosed in brackets? */
 	if (strchr(hostname, ':'))
 		snprintf(root_devname, len, "[%s]:/", hostname);
 	else
 		snprintf(root_devname, len, "%s:/", hostname);
-	root_mnt = vfs_kern_mount(fs_type, flags, root_devname, data);
-	kfree(root_devname);
+	root_cfg->sc.device = root_devname;
+
+	root_mnt = vfs_kern_mount_sc(&root_cfg->sc);
+out_sc:
+	put_sb_config(root_sc);
 	return root_mnt;
 }
 
@@ -235,24 +219,24 @@ static struct dentry *nfs_follow_remote_path(struct vfsmount *root_mnt,
 	return dentry;
 }
 
-struct dentry *nfs4_try_mount(int flags, const char *dev_name,
-			      struct nfs_mount_info *mount_info,
-			      struct nfs_subversion *nfs_mod)
+struct dentry *nfs4_try_mount(struct nfs_sb_config *cfg)
 {
-	char *export_path;
 	struct vfsmount *root_mnt;
 	struct dentry *res;
-	struct nfs_sb_config *cfg = mount_info->cfg;
 
 	dfprintk(MOUNT, "--> nfs4_try_mount()\n");
 
-	export_path = cfg->nfs_server.export_path;
-	cfg->nfs_server.export_path = "/";
-	root_mnt = nfs_do_root_mount(&nfs4_remote_fs_type, flags, mount_info,
-			cfg->nfs_server.hostname);
-	cfg->nfs_server.export_path = export_path;
+	/* We create a mount for the server's root, walk to the requested
+	 * location and then create another mount for that.
+	 */
+	root_mnt = nfs_do_root_mount(cfg, cfg->nfs_server.hostname,
+				     NFS4_MOUNT_REMOTE);
+	if (IS_ERR(root_mnt))
+		return ERR_CAST(root_mnt);
 
-	res = nfs_follow_remote_path(root_mnt, export_path);
+	res = nfs_follow_remote_path(root_mnt, cfg->nfs_server.export_path);
+	if (IS_ERR(res))
+		nfs_cfg_error(cfg, "NFS4: Couldn't follow remote path");
 
 	dfprintk(MOUNT, "<-- nfs4_try_mount() = %d%s\n",
 		 PTR_ERR_OR_ZERO(res),
@@ -260,64 +244,64 @@ struct dentry *nfs4_try_mount(int flags, const char *dev_name,
 	return res;
 }
 
-static struct dentry *
-nfs4_remote_referral_mount(struct file_system_type *fs_type, int flags,
-			   const char *dev_name, void *raw_data)
+static struct dentry *nfs4_remote_referral_mount(struct nfs_sb_config *cfg)
 {
-	struct nfs_mount_info mount_info = {
-		.fill_super = nfs_fill_super,
-		.set_security = nfs_clone_sb_security,
-		.cloned = raw_data,
-	};
 	struct nfs_server *server;
-	struct dentry *mntroot = ERR_PTR(-ENOMEM);
 
 	dprintk("--> nfs4_referral_get_sb()\n");
 
-	mount_info.mntfh = nfs_alloc_fhandle();
-	if (mount_info.cloned == NULL || mount_info.mntfh == NULL)
-		goto out;
+	cfg->set_security = nfs_clone_sb_security;
+
+	if (!cfg->clone_data.cloned)
+		return ERR_PTR(-EINVAL);
 
 	/* create a new volume representation */
-	server = nfs4_create_referral_server(mount_info.cloned, mount_info.mntfh);
-	if (IS_ERR(server)) {
-		mntroot = ERR_CAST(server);
-		goto out;
-	}
+	server = nfs4_create_referral_server(cfg);
+	if (IS_ERR(server))
+		return ERR_CAST(server);
 
-	mntroot = nfs_fs_mount_common(server, flags, dev_name, &mount_info, &nfs_v4);
-out:
-	nfs_free_fhandle(mount_info.mntfh);
-	return mntroot;
+	return nfs_fs_mount_common(server, cfg);
 }
 
 /*
  * Create an NFS4 server record on referral traversal
  */
-static struct dentry *nfs4_referral_mount(struct file_system_type *fs_type,
-		int flags, const char *dev_name, void *raw_data)
+static struct dentry *nfs4_referral_mount(struct nfs_sb_config *cfg)
 {
-	struct nfs_clone_mount *data = raw_data;
-	char *export_path;
 	struct vfsmount *root_mnt;
 	struct dentry *res;
 
 	dprintk("--> nfs4_referral_mount()\n");
 
-	export_path = data->mnt_path;
-	data->mnt_path = "/";
-
-	root_mnt = nfs_do_root_mount(&nfs4_remote_referral_fs_type,
-			flags, data, data->hostname);
-	data->mnt_path = export_path;
+	root_mnt = nfs_do_root_mount(cfg, cfg->nfs_server.hostname,
+				     NFS4_MOUNT_REMOTE_REFERRAL);
 
-	res = nfs_follow_remote_path(root_mnt, export_path);
+	res = nfs_follow_remote_path(root_mnt, cfg->nfs_server.export_path);
 	dprintk("<-- nfs4_referral_mount() = %d%s\n",
 		PTR_ERR_OR_ZERO(res),
 		IS_ERR(res) ? " [error]" : "");
 	return res;
 }
 
+/*
+ * Handle special NFS4 mount types.
+ */
+struct dentry *nfs4_mount(struct nfs_sb_config *cfg)
+{
+	switch (cfg->mount_type) {
+	case NFS4_MOUNT_REMOTE:
+		return nfs4_remote_mount(cfg);
+
+	case NFS4_MOUNT_REFERRAL:
+		return nfs4_referral_mount(cfg);
+
+	case NFS4_MOUNT_REMOTE_REFERRAL:
+		return nfs4_remote_referral_mount(cfg);
+
+	default:
+		return nfs_general_mount(cfg);
+	}
+}
 
 static int __init init_nfs_v4(void)
 {
diff --git a/fs/nfs/proc.c b/fs/nfs/proc.c
index 9872cf676a50..aab90fd09e75 100644
--- a/fs/nfs/proc.c
+++ b/fs/nfs/proc.c
@@ -704,6 +704,7 @@ const struct nfs_rpc_ops nfs_v2_clientops = {
 	.file_inode_ops	= &nfs_file_inode_operations,
 	.file_ops	= &nfs_file_operations,
 	.getroot	= nfs_proc_get_root,
+	.mount		= nfs_general_mount,
 	.submount	= nfs_submount,
 	.try_mount	= nfs_try_mount,
 	.getattr	= nfs_proc_getattr,
diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index acf935a6438d..a705d6730921 100644
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
+	.remount_fs_sc	= nfs_remount,
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
@@ -772,7 +740,7 @@ static int nfs_request_mount(struct nfs_sb_config *cfg,
 		.noresvport	= cfg->flags & NFS_MOUNT_NORESVPORT,
 		.auth_flav_len	= server_authlist_len,
 		.auth_flavs	= server_authlist,
-		.net		= cfg->net,
+		.net		= cfg->sc.net_ns,
 	};
 	int status;
 
@@ -817,20 +785,17 @@ static int nfs_request_mount(struct nfs_sb_config *cfg,
 	return 0;
 }
 
-static struct nfs_server *nfs_try_mount_request(struct nfs_mount_info *mount_info,
-					struct nfs_subversion *nfs_mod)
+static struct nfs_server *nfs_try_mount_request(struct nfs_sb_config *cfg)
 {
 	int status;
 	unsigned int i;
 	bool tried_auth_unix = false;
 	bool auth_null_in_list = false;
 	struct nfs_server *server = ERR_PTR(-EACCES);
-	struct nfs_sb_config *cfg = mount_info->cfg;
 	rpc_authflavor_t authlist[NFS_MAX_SECFLAVORS];
 	unsigned int authlist_len = ARRAY_SIZE(authlist);
 
-	status = nfs_request_mount(cfg, mount_info->mntfh, authlist,
-					&authlist_len);
+	status = nfs_request_mount(cfg, cfg->mntfh, authlist, &authlist_len);
 	if (status)
 		return ERR_PTR(status);
 
@@ -844,7 +809,7 @@ static struct nfs_server *nfs_try_mount_request(struct nfs_mount_info *mount_inf
 			 cfg->selected_flavor);
 		if (status)
 			return ERR_PTR(status);
-		return nfs_mod->rpc_ops->create_server(mount_info, nfs_mod);
+		return cfg->nfs_mod->rpc_ops->create_server(cfg);
 	}
 
 	/*
@@ -871,7 +836,7 @@ static struct nfs_server *nfs_try_mount_request(struct nfs_mount_info *mount_inf
 		}
 		dfprintk(MOUNT, "NFS: attempting to use auth flavor %u\n", flavor);
 		cfg->selected_flavor = flavor;
-		server = nfs_mod->rpc_ops->create_server(mount_info, nfs_mod);
+		server = cfg->nfs_mod->rpc_ops->create_server(cfg);
 		if (!IS_ERR(server))
 			return server;
 	}
@@ -887,27 +852,28 @@ static struct nfs_server *nfs_try_mount_request(struct nfs_mount_info *mount_inf
 	/* Last chance! Try AUTH_UNIX */
 	dfprintk(MOUNT, "NFS: attempting to use auth flavor %u\n", RPC_AUTH_UNIX);
 	cfg->selected_flavor = RPC_AUTH_UNIX;
-	return nfs_mod->rpc_ops->create_server(mount_info, nfs_mod);
+	return cfg->nfs_mod->rpc_ops->create_server(cfg);
 }
 
-struct dentry *nfs_try_mount(int flags, const char *dev_name,
-			     struct nfs_mount_info *mount_info,
-			     struct nfs_subversion *nfs_mod)
+struct dentry *nfs_try_mount(struct nfs_sb_config *cfg)
 {
 	struct nfs_server *server;
 
-	if (mount_info->cfg->need_mount)
-		server = nfs_try_mount_request(mount_info, nfs_mod);
+	if (cfg->need_mount)
+		server = nfs_try_mount_request(cfg);
 	else
-		server = nfs_mod->rpc_ops->create_server(mount_info, nfs_mod);
+		server = cfg->nfs_mod->rpc_ops->create_server(cfg);
 
-	if (IS_ERR(server))
+	if (IS_ERR(server)) {
+		nfs_cfg_error(cfg, "NFS: Couldn't create server");
 		return ERR_CAST(server);
+	}
 
-	return nfs_fs_mount_common(server, flags, dev_name, mount_info, nfs_mod);
+	return nfs_fs_mount_common(server, cfg);
 }
 EXPORT_SYMBOL_GPL(nfs_try_mount);
 
+
 #define NFS_REMOUNT_CMP_FLAGMASK ~(NFS_MOUNT_INTR \
 		| NFS_MOUNT_SECURE \
 		| NFS_MOUNT_TCP \
@@ -946,15 +912,11 @@ nfs_compare_remount_data(struct nfs_server *nfss,
 	return 0;
 }
 
-int
-nfs_remount(struct super_block *sb, int *flags, char *raw_data)
+int nfs_remount(struct super_block *sb, struct sb_config *sc)
 {
-	int error;
+	struct nfs_sb_config *cfg =
+		container_of(sc, struct nfs_sb_config, sc);
 	struct nfs_server *nfss = sb->s_fs_info;
-	struct nfs_sb_config *cfg;
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
+	if (cfg->skip_remount_option_check)
 		return 0;
 
-	cfg = kzalloc(sizeof(*cfg), GFP_KERNEL);
-	if (cfg == NULL)
-		return -ENOMEM;
-
-	/* fill out struct with values from existing mount */
-	cfg->flags = nfss->flags;
-	cfg->rsize = nfss->rsize;
-	cfg->wsize = nfss->wsize;
-	cfg->retrans = nfss->client->cl_timeout->to_retries;
-	cfg->selected_flavor = nfss->client->cl_auth->au_flavor;
-	cfg->acregmin = nfss->acregmin / HZ;
-	cfg->acregmax = nfss->acregmax / HZ;
-	cfg->acdirmin = nfss->acdirmin / HZ;
-	cfg->acdirmax = nfss->acdirmax / HZ;
-	cfg->timeo = 10U * nfss->client->cl_timeout->to_initval / HZ;
-	cfg->nfs_server.port = nfss->port;
-	cfg->nfs_server.addrlen = nfss->nfs_client->cl_addrlen;
-	cfg->version = nfsvers;
-	cfg->minorversion = nfss->nfs_client->cl_minorversion;
-	cfg->net = current->nsproxy->net_ns;
-	memcpy(&cfg->nfs_server.address, &nfss->nfs_client->cl_addr,
-		cfg->nfs_server.addrlen);
-
-	/* overwrite those values with any that were specified */
-	error = -EINVAL;
-	if (!nfs_parse_mount_options((char *)options, cfg))
-		goto out;
-
 	/*
 	 * noac is a special case. It implies -o sync, but that's not
 	 * necessarily reflected in the mtab options. do_remount_sb
@@ -1004,20 +936,17 @@ nfs_remount(struct super_block *sb, int *flags, char *raw_data)
 	 * remount options, so we have to explicitly reset it.
 	 */
 	if (cfg->flags & NFS_MOUNT_NOAC)
-		*flags |= MS_SYNCHRONOUS;
+		cfg->sc.ms_flags |= MS_SYNCHRONOUS;
 
 	/* compare new mount options with old ones */
-	error = nfs_compare_remount_data(nfss, cfg);
-out:
-	kfree(cfg);
-	return error;
+	return nfs_compare_remount_data(nfss, cfg);
 }
 EXPORT_SYMBOL_GPL(nfs_remount);
 
 /*
  * Initialise the common bits of the superblock
  */
-inline void nfs_initialise_sb(struct super_block *sb)
+static inline void nfs_initialise_sb(struct super_block *sb)
 {
 	struct nfs_server *server = NFS_SB(sb);
 
@@ -1037,9 +966,8 @@ inline void nfs_initialise_sb(struct super_block *sb)
 /*
  * Finish setting up an NFS2/3 superblock
  */
-void nfs_fill_super(struct super_block *sb, struct nfs_mount_info *mount_info)
+static void nfs_fill_super(struct super_block *sb, struct nfs_sb_config *cfg)
 {
-	struct nfs_sb_config *cfg = mount_info->cfg;
 	struct nfs_server *server = NFS_SB(sb);
 
 	sb->s_blocksize_bits = 0;
@@ -1059,14 +987,13 @@ void nfs_fill_super(struct super_block *sb, struct nfs_mount_info *mount_info)
 
  	nfs_initialise_sb(sb);
 }
-EXPORT_SYMBOL_GPL(nfs_fill_super);
 
 /*
  * Finish setting up a cloned NFS2/3/4 superblock
  */
-void nfs_clone_super(struct super_block *sb, struct nfs_mount_info *mount_info)
+static void nfs_clone_super(struct super_block *sb, struct nfs_sb_config *cfg)
 {
-	const struct super_block *old_sb = mount_info->cloned->sb;
+	const struct super_block *old_sb = cfg->clone_data.sb;
 	struct nfs_server *server = NFS_SB(sb);
 
 	sb->s_blocksize_bits = old_sb->s_blocksize_bits;
@@ -1198,8 +1125,7 @@ static int nfs_compare_super(struct super_block *sb, void *data)
 
 #ifdef CONFIG_NFS_FSCACHE
 static void nfs_get_cache_cookie(struct super_block *sb,
-				 struct nfs_sb_config *cfg,
-				 struct nfs_clone_mount *cloned)
+				 struct nfs_sb_config *cfg)
 {
 	struct nfs_server *nfss = NFS_SB(sb);
 	char *uniq = NULL;
@@ -1208,44 +1134,47 @@ static void nfs_get_cache_cookie(struct super_block *sb,
 	nfss->fscache_key = NULL;
 	nfss->fscache = NULL;
 
-	if (cfg) {
+	if (!cfg)
+		return;
+
+	if (cfg->clone_data.cloned) {
+		struct nfs_server *mnt_s = NFS_SB(cfg->clone_data.sb);
+		if (!(mnt_s->options & NFS_OPTION_FSCACHE))
+			return;
+		if (mnt_s->fscache_key) {
+			uniq = mnt_s->fscache_key->key.uniquifier;
+			ulen = mnt_s->fscache_key->key.uniq_len;
+		}
+	} else {
 		if (!(cfg->options & NFS_OPTION_FSCACHE))
 			return;
 		if (cfg->fscache_uniq) {
 			uniq = cfg->fscache_uniq;
 			ulen = strlen(cfg->fscache_uniq);
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
-				 struct nfs_sb_config *parsed,
-				 struct nfs_clone_mount *cloned)
+				 struct nfs_sb_config *cfg)
 {
 }
 #endif
 
 int nfs_set_sb_security(struct super_block *s, struct dentry *mntroot,
-			struct nfs_mount_info *mount_info)
+			struct nfs_sb_config *cfg)
 {
 	int error;
 	unsigned long kflags = 0, kflags_out = 0;
+
 	if (NFS_SB(s)->caps & NFS_CAP_SECURITY_LABEL)
 		kflags |= SECURITY_LSM_NATIVE_LABELS;
 
-	error = security_sb_set_mnt_opts(s, &mount_info->cfg->lsm_opts,
-						kflags, &kflags_out);
+	error = security_sb_set_mnt_opts(s, cfg->sc.security,
+					 kflags, &kflags_out);
 	if (error)
 		goto err;
 
@@ -1258,25 +1187,23 @@ int nfs_set_sb_security(struct super_block *s, struct dentry *mntroot,
 EXPORT_SYMBOL_GPL(nfs_set_sb_security);
 
 int nfs_clone_sb_security(struct super_block *s, struct dentry *mntroot,
-			  struct nfs_mount_info *mount_info)
+			  struct nfs_sb_config *cfg)
 {
 	/* clone any lsm security options from the parent to the new sb */
 	if (d_inode(mntroot)->i_op != NFS_SB(s)->nfs_client->rpc_ops->dir_inode_ops)
 		return -ESTALE;
-	return security_sb_clone_mnt_opts(mount_info->cloned->sb, s);
+	return security_sb_clone_mnt_opts(cfg->clone_data.sb, s);
 }
 EXPORT_SYMBOL_GPL(nfs_clone_sb_security);
 
 struct dentry *nfs_fs_mount_common(struct nfs_server *server,
-				   int flags, const char *dev_name,
-				   struct nfs_mount_info *mount_info,
-				   struct nfs_subversion *nfs_mod)
+				   struct nfs_sb_config *cfg)
 {
 	struct super_block *s;
 	struct dentry *mntroot = ERR_PTR(-ENOMEM);
 	int (*compare_super)(struct super_block *, void *) = nfs_compare_super;
 	struct nfs_sb_mountdata sb_mntdata = {
-		.mntflags = flags,
+		.mntflags = cfg->sc.ms_flags,
 		.server = server,
 	};
 	int error;
@@ -1288,14 +1215,16 @@ struct dentry *nfs_fs_mount_common(struct nfs_server *server,
 	if (server->flags & NFS_MOUNT_NOAC)
 		sb_mntdata.mntflags |= MS_SYNCHRONOUS;
 
-	if (mount_info->cloned != NULL && mount_info->cloned->sb != NULL)
-		if (mount_info->cloned->sb->s_flags & MS_SYNCHRONOUS)
+	if (cfg->clone_data.cloned && cfg->clone_data.sb != NULL)
+		if (cfg->clone_data.sb->s_flags & MS_SYNCHRONOUS)
 			sb_mntdata.mntflags |= MS_SYNCHRONOUS;
 
 	/* Get a superblock - note that we may end up sharing one that already exists */
-	s = sget(nfs_mod->nfs_fs, compare_super, nfs_set_super, flags, &sb_mntdata);
+	s = sget(cfg->nfs_mod->nfs_fs, compare_super, nfs_set_super, cfg->sc.ms_flags,
+		 &sb_mntdata);
 	if (IS_ERR(s)) {
 		mntroot = ERR_CAST(s);
+		nfs_cfg_error(cfg, "NFS: Couldn't get superblock");
 		goto out_err_nosb;
 	}
 
@@ -1315,15 +1244,20 @@ struct dentry *nfs_fs_mount_common(struct nfs_server *server,
 
 	if (!s->s_root) {
 		/* initial superblock/root creation */
-		mount_info->fill_super(s, mount_info);
-		nfs_get_cache_cookie(s, mount_info->cfg, mount_info->cloned);
+		if (cfg->clone_data.sb)
+			nfs_clone_super(s, cfg);
+		else
+			nfs_fill_super(s, cfg);
+		nfs_get_cache_cookie(s, cfg);
 	}
 
-	mntroot = nfs_get_root(s, mount_info->mntfh, dev_name);
-	if (IS_ERR(mntroot))
+	mntroot = nfs_get_root(s, cfg->mntfh, cfg->sc.device);
+	if (IS_ERR(mntroot)) {
+		nfs_cfg_error(cfg, "NFS: Couldn't get root dentry");
 		goto error_splat_super;
+	}
 
-	error = mount_info->set_security(s, mntroot, mount_info);
+	error = cfg->set_security(s, mntroot, cfg);
 	if (error)
 		goto error_splat_root;
 
@@ -1345,47 +1279,6 @@ struct dentry *nfs_fs_mount_common(struct nfs_server *server,
 }
 EXPORT_SYMBOL_GPL(nfs_fs_mount_common);
 
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
-	mount_info.cfg = nfs_alloc_parsed_mount_data();
-	mount_info.mntfh = nfs_alloc_fhandle();
-	if (mount_info.cfg == NULL || mount_info.mntfh == NULL)
-		goto out;
-
-	/* Validate the mount data */
-	error = nfs_validate_mount_data(fs_type, raw_data, mount_info.cfg, mount_info.mntfh, dev_name);
-	if (error == NFS_TEXT_DATA)
-		error = nfs_validate_text_mount_data(raw_data, mount_info.cfg, dev_name);
-	if (error < 0) {
-		mntroot = ERR_PTR(error);
-		goto out;
-	}
-
-	nfs_mod = get_nfs_version(mount_info.cfg->version);
-	if (IS_ERR(nfs_mod)) {
-		mntroot = ERR_CAST(nfs_mod);
-		goto out;
-	}
-
-	mntroot = nfs_mod->rpc_ops->try_mount(flags, dev_name, &mount_info, nfs_mod);
-
-	put_nfs_version(nfs_mod);
-out:
-	nfs_free_parsed_mount_data(mount_info.cfg);
-	nfs_free_fhandle(mount_info.mntfh);
-	return mntroot;
-}
-EXPORT_SYMBOL_GPL(nfs_fs_mount);
-
 /*
  * Destroy an NFS2/3 superblock
  */
@@ -1403,41 +1296,6 @@ void nfs_kill_super(struct super_block *s)
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
index b28c83475ee8..250d27088309 100644
--- a/include/linux/nfs_xdr.h
+++ b/include/linux/nfs_xdr.h
@@ -1542,6 +1542,7 @@ struct nfs_subversion;
 struct nfs_mount_info;
 struct nfs_client_initdata;
 struct nfs_pageio_descriptor;
+struct nfs_sb_config;
 
 /*
  * RPC procedure vector for NFSv2/NFSv3 demuxing
@@ -1556,10 +1557,10 @@ struct nfs_rpc_ops {
 
 	int	(*getroot) (struct nfs_server *, struct nfs_fh *,
 			    struct nfs_fsinfo *);
+	struct dentry *(*mount)(struct nfs_sb_config *);
 	struct vfsmount *(*submount) (struct nfs_server *, struct dentry *,
 				      struct nfs_fh *, struct nfs_fattr *);
-	struct dentry *(*try_mount) (int, const char *, struct nfs_mount_info *,
-				     struct nfs_subversion *);
+	struct dentry *(*try_mount) (struct nfs_sb_config *);
 	int	(*getattr) (struct nfs_server *, struct nfs_fh *,
 			    struct nfs_fattr *, struct nfs4_label *);
 	int	(*setattr) (struct dentry *, struct nfs_fattr *,
@@ -1620,7 +1621,7 @@ struct nfs_rpc_ops {
 	struct nfs_client *(*init_client) (struct nfs_client *,
 				const struct nfs_client_initdata *);
 	void	(*free_client) (struct nfs_client *);
-	struct nfs_server *(*create_server)(struct nfs_mount_info *, struct nfs_subversion *);
+	struct nfs_server *(*create_server)(struct nfs_sb_config *);
 	struct nfs_server *(*clone_server)(struct nfs_server *, struct nfs_fh *,
 					   struct nfs_fattr *, rpc_authflavor_t);
 };

