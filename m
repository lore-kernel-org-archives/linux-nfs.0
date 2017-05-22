Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:58414 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S935583AbdEVPyu (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 22 May 2017 11:54:50 -0400
Subject: [PATCH 22/23] NFS: Do some tidying of the parsing code [ver #4]
From: David Howells <dhowells@redhat.com>
To: mszeredi@redhat.com, viro@zeniv.linux.org.uk, jlayton@redhat.com
Cc: dhowells@redhat.com, linux-fsdevel@vger.kernel.org,
        linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Date: Mon, 22 May 2017 16:54:47 +0100
Message-ID: <149546848747.9289.4345614529063951174.stgit@warthog.procyon.org.uk>
In-Reply-To: <149546825563.9289.9065118651584207610.stgit@warthog.procyon.org.uk>
References: <149546825563.9289.9065118651584207610.stgit@warthog.procyon.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Do some tidying of the parsing code, including:

 (*) Returning 0/error rather than true/false.

 (*) Putting the nfs_sb_config pointer first in some arg lists.

 (*) Unwrap some lines that will now fit on one line.

 (*) Provide unioned sockaddr/sockaddr_storage fields to avoid casts.

 (*) nfs_parse_devname() can paste its return values directly into the
     nfs_sb_config struct as that's where the caller puts them.

Signed-off-by: David Howells <dhowells@redhat.com>
---

 fs/nfs/internal.h |   16 +++++--
 fs/nfs/mount.c    |  128 +++++++++++++++++++++++------------------------------
 fs/nfs/super.c    |    2 -
 3 files changed, 67 insertions(+), 79 deletions(-)

diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
index 52242240933f..79e77ff2061c 100644
--- a/fs/nfs/internal.h
+++ b/fs/nfs/internal.h
@@ -86,11 +86,11 @@ struct nfs_client_initdata {
  * In-kernel mount arguments
  */
 struct nfs_sb_config {
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
@@ -106,7 +106,10 @@ struct nfs_sb_config {
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
@@ -115,7 +118,10 @@ struct nfs_sb_config {
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
diff --git a/fs/nfs/mount.c b/fs/nfs/mount.c
index e5593070422d..025525c8eb90 100644
--- a/fs/nfs/mount.c
+++ b/fs/nfs/mount.c
@@ -341,8 +341,9 @@ static void nfs_set_mount_transport_protocol(struct nfs_sb_config *cfg)
  * Add 'flavor' to 'auth_info' if not already present.
  * Returns true if 'flavor' ends up in the list, false otherwise
  */
-static bool nfs_auth_info_add(struct nfs_auth_info *auth_info,
-			      rpc_authflavor_t flavor)
+static int nfs_auth_info_add(struct nfs_sb_config *cfg,
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
-static int nfs_parse_security_flavors(char *value, struct nfs_sb_config *cfg)
+static int nfs_parse_security_flavors(struct nfs_sb_config *cfg, char *value)
 {
 	substring_t args[MAX_OPT_ARGS];
 	rpc_authflavor_t pseudoflavor;
 	char *p;
+	int ret;
 
 	dfprintk(MOUNT, "NFS: parsing sec=%s option\n", value);
 
@@ -411,19 +413,20 @@ static int nfs_parse_security_flavors(char *value, struct nfs_sb_config *cfg)
 		default:
 			dfprintk(MOUNT,
 				 "NFS: sec= option '%s' not recognized\n", p);
-			return 0;
+			return -EINVAL;
 		}
 
-		if (!nfs_auth_info_add(&cfg->auth_info, pseudoflavor))
-			return 0;
+		ret = nfs_auth_info_add(cfg, &cfg->auth_info, pseudoflavor);
+		if (ret < 0)
+			return ret;
 	}
 
-	return 1;
+	return 0;
 }
 
-static int nfs_parse_version_string(char *string,
-		struct nfs_sb_config *cfg,
-		substring_t *args)
+static int nfs_parse_version_string(struct nfs_sb_config *cfg,
+				    char *string,
+				    substring_t *args)
 {
 	cfg->flags &= ~NFS_MOUNT_VER3;
 	switch (match_token(string, nfs_vers_tokens, args)) {
@@ -454,9 +457,10 @@ static int nfs_parse_version_string(char *string,
 		cfg->minorversion = 2;
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
@@ -495,7 +499,7 @@ static int nfs_sb_config_parse_option(struct nfs_sb_config *cfg, char *p)
 {
 	substring_t args[MAX_OPT_ARGS];
 	char *string;
-	int rc, token;
+	int ret, token;
 
 	dfprintk(MOUNT, "NFS:   parsing nfs mount option '%s'\n", p);
 
@@ -530,13 +534,11 @@ static int nfs_sb_config_parse_option(struct nfs_sb_config *cfg, char *p)
 		break;
 	case Opt_lock:
 		cfg->flags &= ~NFS_MOUNT_NONLM;
-		cfg->flags &= ~(NFS_MOUNT_LOCAL_FLOCK |
-				NFS_MOUNT_LOCAL_FCNTL);
+		cfg->flags &= ~(NFS_MOUNT_LOCAL_FLOCK | NFS_MOUNT_LOCAL_FCNTL);
 		break;
 	case Opt_nolock:
 		cfg->flags |= NFS_MOUNT_NONLM;
-		cfg->flags |= (NFS_MOUNT_LOCAL_FLOCK |
-			       NFS_MOUNT_LOCAL_FCNTL);
+		cfg->flags |= (NFS_MOUNT_LOCAL_FLOCK | NFS_MOUNT_LOCAL_FCNTL);
 		break;
 	case Opt_udp:
 		cfg->flags &= ~NFS_MOUNT_TCP;
@@ -669,29 +671,25 @@ static int nfs_sb_config_parse_option(struct nfs_sb_config *cfg, char *p)
 		string = match_strdup(args);
 		if (string == NULL)
 			goto out_nomem;
-		rc = nfs_parse_version_string(string, cfg, args);
+		ret = nfs_parse_version_string(cfg, string, args);
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
-		rc = nfs_parse_security_flavors(string, cfg);
+		ret = nfs_parse_security_flavors(cfg, string);
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
 
 		cfg->protofamily = AF_INET;
 		switch (token) {
@@ -716,9 +714,8 @@ static int nfs_sb_config_parse_option(struct nfs_sb_config *cfg, char *p)
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
@@ -727,8 +724,7 @@ static int nfs_sb_config_parse_option(struct nfs_sb_config *cfg, char *p)
 		string = match_strdup(args);
 		if (string == NULL)
 			goto out_nomem;
-		token = match_token(string,
-				    nfs_xprt_protocol_tokens, args);
+		token = match_token(string, nfs_xprt_protocol_tokens, args);
 		kfree(string);
 
 		cfg->mountfamily = AF_INET;
@@ -745,8 +741,7 @@ static int nfs_sb_config_parse_option(struct nfs_sb_config *cfg, char *p)
 			break;
 		case Opt_xprt_rdma: /* not used for side protocols */
 		default:
-			dfprintk(MOUNT, "NFS:   unrecognized "
-				 "transport protocol\n");
+			dfprintk(MOUNT, "NFS:   unrecognized transport protocol\n");
 			return -EINVAL;
 		}
 		break;
@@ -756,9 +751,8 @@ static int nfs_sb_config_parse_option(struct nfs_sb_config *cfg, char *p)
 			goto out_nomem;
 		cfg->nfs_server.addrlen =
 			rpc_pton(cfg->net, string, strlen(string),
-				 (struct sockaddr *)
 				 &cfg->nfs_server.address,
-				 sizeof(cfg->nfs_server.address));
+				 sizeof(cfg->nfs_server._address));
 		kfree(string);
 		if (cfg->nfs_server.addrlen == 0)
 			goto out_invalid_address;
@@ -768,8 +762,7 @@ static int nfs_sb_config_parse_option(struct nfs_sb_config *cfg, char *p)
 			goto out_nomem;
 		break;
 	case Opt_mounthost:
-		if (nfs_get_option_str(args,
-				       &cfg->mount_server.hostname))
+		if (nfs_get_option_str(args, &cfg->mount_server.hostname))
 			goto out_nomem;
 		break;
 	case Opt_mountaddr:
@@ -778,9 +771,8 @@ static int nfs_sb_config_parse_option(struct nfs_sb_config *cfg, char *p)
 			goto out_nomem;
 		cfg->mount_server.addrlen =
 			rpc_pton(cfg->net, string, strlen(string),
-				 (struct sockaddr *)
 				 &cfg->mount_server.address,
-				 sizeof(cfg->mount_server.address));
+				 sizeof(cfg->mount_server._address));
 		kfree(string);
 		if (cfg->mount_server.addrlen == 0)
 			goto out_invalid_address;
@@ -789,8 +781,7 @@ static int nfs_sb_config_parse_option(struct nfs_sb_config *cfg, char *p)
 		string = match_strdup(args);
 		if (string == NULL)
 			goto out_nomem;
-		token = match_token(string,
-				    nfs_lookupcache_tokens, args);
+		token = match_token(string, nfs_lookupcache_tokens, args);
 		kfree(string);
 		switch (token) {
 		case Opt_lookupcache_all:
@@ -804,10 +795,9 @@ static int nfs_sb_config_parse_option(struct nfs_sb_config *cfg, char *p)
 			cfg->flags |= NFS_MOUNT_LOOKUP_CACHE_NONEG|NFS_MOUNT_LOOKUP_CACHE_NONE;
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
 		if (nfs_get_option_str(args, &cfg->fscache_uniq))
@@ -818,8 +808,7 @@ static int nfs_sb_config_parse_option(struct nfs_sb_config *cfg, char *p)
 		string = match_strdup(args);
 		if (string == NULL)
 			goto out_nomem;
-		token = match_token(string, nfs_local_lock_tokens,
-				    args);
+		token = match_token(string, nfs_local_lock_tokens, args);
 		kfree(string);
 		switch (token) {
 		case Opt_local_lock_all:
@@ -837,8 +826,7 @@ static int nfs_sb_config_parse_option(struct nfs_sb_config *cfg, char *p)
 					NFS_MOUNT_LOCAL_FCNTL);
 			break;
 		default:
-			dfprintk(MOUNT, "NFS:	invalid	"
-				 "local_lock argument\n");
+			dfprintk(MOUNT, "NFS:	invalid	local_lock argument\n");
 			return -EINVAL;
 		};
 		break;
@@ -852,13 +840,11 @@ static int nfs_sb_config_parse_option(struct nfs_sb_config *cfg, char *p)
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
 
@@ -928,15 +914,15 @@ int nfs_parse_mount_options(char *raw, struct nfs_sb_config *cfg)
 	 * families in the addr=/mountaddr= options.
 	 */
 	if (cfg->protofamily != AF_UNSPEC &&
-	    cfg->protofamily != cfg->nfs_server.address.ss_family)
+	    cfg->protofamily != cfg->nfs_server.address.sa_family)
 		goto out_proto_mismatch;
 
 	if (cfg->mountfamily != AF_UNSPEC) {
 		if (cfg->mount_server.addrlen) {
-			if (cfg->mountfamily != cfg->mount_server.address.ss_family)
+			if (cfg->mountfamily != cfg->mount_server.address.sa_family)
 				goto out_mountproto_mismatch;
 		} else {
-			if (cfg->mountfamily != cfg->nfs_server.address.ss_family)
+			if (cfg->mountfamily != cfg->nfs_server.address.sa_family)
 				goto out_mountproto_mismatch;
 		}
 	}
@@ -976,9 +962,9 @@ int nfs_parse_mount_options(char *raw, struct nfs_sb_config *cfg)
  *
  * Note: caller frees hostname and export path, even on error.
  */
-static int nfs_parse_devname(const char *dev_name,
-			     char **hostname, size_t maxnamlen,
-			     char **export_path, size_t maxpathlen)
+static int nfs_parse_devname(struct nfs_sb_config *cfg,
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
+	cfg->nfs_server.hostname = kmemdup_nul(dev_name, len, GFP_KERNEL);
+	if (!cfg->nfs_server.hostname)
 		goto out_nomem;
 	len = strlen(++end);
 	if (len > maxpathlen)
 		goto out_path;
-	*export_path = kstrndup(end, len, GFP_KERNEL);
-	if (!*export_path)
+	cfg->nfs_server.export_path = kmemdup_nul(end, len, GFP_KERNEL);
+	if (!cfg->nfs_server.export_path)
 		goto out_nomem;
 
-	dfprintk(MOUNT, "NFS: MNTPATH: '%s'\n", *export_path);
+	dfprintk(MOUNT, "NFS: MNTPATH: '%s'\n", cfg->nfs_server.export_path);
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
 
 	nfs_set_port(sap, &cfg->nfs_server.port, port);
 
-	return nfs_parse_devname(dev_name,
-				   &cfg->nfs_server.hostname,
-				   max_namelen,
-				   &cfg->nfs_server.export_path,
-				   max_pathlen);
+	return nfs_parse_devname(cfg, dev_name, max_namelen, max_pathlen);
 
 #if !IS_ENABLED(CONFIG_NFS_V4)
 out_v4_not_compiled:
diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index 26c1fca31e6b..acf935a6438d 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -795,7 +795,7 @@ static int nfs_request_mount(struct nfs_sb_config *cfg,
 	/*
 	 * Construct the mount server's address.
 	 */
-	if (cfg->mount_server.address.ss_family == AF_UNSPEC) {
+	if (cfg->mount_server.address.sa_family == AF_UNSPEC) {
 		memcpy(request.sap, &cfg->nfs_server.address,
 		       cfg->nfs_server.addrlen);
 		cfg->mount_server.addrlen = cfg->nfs_server.addrlen;

