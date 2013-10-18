Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx11.netapp.com ([216.240.18.76]:51129 "EHLO mx11.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753926Ab3JRTPq (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 18 Oct 2013 15:15:46 -0400
From: Weston Andros Adamson <dros@netapp.com>
To: <Trond.Myklebust@netapp.com>
CC: <linux-nfs@vger.kernel.org>, Weston Andros Adamson <dros@netapp.com>
Subject: [PATCH 5/5] NFS: add support for multiple sec= mount options
Date: Fri, 18 Oct 2013 15:15:19 -0400
Message-ID: <1382123719-25194-6-git-send-email-dros@netapp.com>
In-Reply-To: <1382123719-25194-1-git-send-email-dros@netapp.com>
References: <1382123719-25194-1-git-send-email-dros@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This patch adds support for multiple security options which can be
specified using a colon-delimited list of security flavors (the same
syntax as nfsd's exports file).

This is useful, for instance, when NFSv4.x mounts cross SECINFO
boundaries. With this patch a user can use "sec=krb5i,krb5p"
to mount a remote filesystem using krb5i, but can still cross
into krb5p-only exports.

New mounts will try all security options before failing.  NFSv4.x
SECINFO results will be compared against the sec= flavors to
find the first flavor in both lists or if no match is found will
return -EPERM.

Signed-off-by: Weston Andros Adamson <dros@netapp.com>
---
 fs/nfs/internal.h       |   1 +
 fs/nfs/nfs4client.c     |   3 +
 fs/nfs/nfs4namespace.c  |  17 +++--
 fs/nfs/nfs4proc.c       |  32 ++++++----
 fs/nfs/super.c          | 160 +++++++++++++++++++++++++++++++-----------------
 include/linux/nfs_xdr.h |   3 +-
 6 files changed, 145 insertions(+), 71 deletions(-)

diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
index 5de1ef6c..89d7eb6 100644
--- a/fs/nfs/internal.h
+++ b/fs/nfs/internal.h
@@ -323,6 +323,7 @@ extern struct file_system_type nfs_xdev_fs_type;
 extern struct file_system_type nfs4_xdev_fs_type;
 extern struct file_system_type nfs4_referral_fs_type;
 #endif
+bool nfs_auth_info_match(const struct nfs_auth_info *, rpc_authflavor_t);
 struct dentry *nfs_try_mount(int, const char *, struct nfs_mount_info *,
 			struct nfs_subversion *);
 void nfs_initialise_sb(struct super_block *);
diff --git a/fs/nfs/nfs4client.c b/fs/nfs/nfs4client.c
index 0697ef3..2da311c 100644
--- a/fs/nfs/nfs4client.c
+++ b/fs/nfs/nfs4client.c
@@ -963,6 +963,9 @@ static int nfs4_init_server(struct nfs_server *server,
 	server->options = data->options;
 	server->auth_info = data->auth_info;
 
+	/* Use the first specified auth flavor. If this flavor isn't
+	 * allowed by the server, use the SECINFO path to try the
+	 * other specified flavors */
 	if (data->auth_info.flavor_len >= 1)
 		data->selected_flavor = data->auth_info.flavors[0];
 	else
diff --git a/fs/nfs/nfs4namespace.c b/fs/nfs/nfs4namespace.c
index 2d79be2..3ba8e4e 100644
--- a/fs/nfs/nfs4namespace.c
+++ b/fs/nfs/nfs4namespace.c
@@ -137,6 +137,7 @@ static size_t nfs_parse_server_name(char *string, size_t len,
 
 /**
  * nfs_find_best_sec - Find a security mechanism supported locally
+ * @server: NFS server struct
  * @flavors: List of security tuples returned by SECINFO procedure
  *
  * Return the pseudoflavor of the first security mechanism in
@@ -145,7 +146,8 @@ static size_t nfs_parse_server_name(char *string, size_t len,
  * is searched in the order returned from the server, per RFC 3530
  * recommendation.
  */
-static rpc_authflavor_t nfs_find_best_sec(struct nfs4_secinfo_flavors *flavors)
+static rpc_authflavor_t nfs_find_best_sec(struct nfs_server *server,
+					  struct nfs4_secinfo_flavors *flavors)
 {
 	rpc_authflavor_t pseudoflavor;
 	struct nfs4_secinfo4 *secinfo;
@@ -160,12 +162,19 @@ static rpc_authflavor_t nfs_find_best_sec(struct nfs4_secinfo_flavors *flavors)
 		case RPC_AUTH_GSS:
 			pseudoflavor = rpcauth_get_pseudoflavor(secinfo->flavor,
 							&secinfo->flavor_info);
-			if (pseudoflavor != RPC_AUTH_MAXFLAVOR)
+			/* make sure pseudoflavor matches sec= mount opt */
+			if (pseudoflavor != RPC_AUTH_MAXFLAVOR &&
+			    nfs_auth_info_match(&server->auth_info,
+						pseudoflavor))
 				return pseudoflavor;
 			break;
 		}
 	}
 
+	/* if there were any sec= options then nothing matched */
+	if (server->auth_info.flavor_len > 0)
+		return -EPERM;
+
 	return RPC_AUTH_UNIX;
 }
 
@@ -187,7 +196,7 @@ static rpc_authflavor_t nfs4_negotiate_security(struct inode *inode, struct qstr
 		goto out;
 	}
 
-	flavor = nfs_find_best_sec(flavors);
+	flavor = nfs_find_best_sec(NFS_SERVER(inode), flavors);
 
 out:
 	put_page(page);
@@ -390,7 +399,7 @@ struct vfsmount *nfs4_submount(struct nfs_server *server, struct dentry *dentry,
 
 	if (client->cl_auth->au_flavor != flavor)
 		flavor = client->cl_auth->au_flavor;
-	else if (server->auth_info.flavor_len == 0) {
+	else {
 		rpc_authflavor_t new = nfs4_negotiate_security(dir, name);
 		if ((int)new >= 0)
 			flavor = new;
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 9e0c10e..f646487 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -2864,11 +2864,24 @@ static int nfs4_find_root_sec(struct nfs_server *server, struct nfs_fh *fhandle,
 	int status = -EPERM;
 	size_t i;
 
-	for (i = 0; i < ARRAY_SIZE(flav_array); i++) {
-		status = nfs4_lookup_root_sec(server, fhandle, info, flav_array[i]);
-		if (status == -NFS4ERR_WRONGSEC || status == -EACCES)
-			continue;
-		break;
+	if (server->auth_info.flavor_len > 0) {
+		/* try each flavor specified by user */
+		for (i = 0; i < server->auth_info.flavor_len; i++) {
+			status = nfs4_lookup_root_sec(server, fhandle, info,
+						server->auth_info.flavors[i]);
+			if (status == -NFS4ERR_WRONGSEC || status == -EACCES)
+				continue;
+			break;
+		}
+	} else {
+		/* no flavors specified by user, try default list */
+		for (i = 0; i < ARRAY_SIZE(flav_array); i++) {
+			status = nfs4_lookup_root_sec(server, fhandle, info,
+						      flav_array[i]);
+			if (status == -NFS4ERR_WRONGSEC || status == -EACCES)
+				continue;
+			break;
+		}
 	}
 
 	/*
@@ -2910,9 +2923,6 @@ int nfs4_proc_get_rootfh(struct nfs_server *server, struct nfs_fh *fhandle,
 		status = nfs4_lookup_root(server, fhandle, info);
 		if (status != -NFS4ERR_WRONGSEC)
 			break;
-		/* Did user force a 'sec=' mount option? */
-		if (server->auth_info.flavor_len > 0)
-			break;
 	default:
 		status = nfs4_do_find_root_sec(server, fhandle, info);
 	}
@@ -3165,9 +3175,6 @@ static int nfs4_proc_lookup_common(struct rpc_clnt **clnt, struct inode *dir,
 			err = -EPERM;
 			if (client != *clnt)
 				goto out;
-			/* No security negotiation if the user specified 'sec=' */
-			if (NFS_SERVER(dir)->auth_info.flavor_len > 0)
-				goto out;
 			client = nfs4_create_sec_client(client, dir, name);
 			if (IS_ERR(client))
 				return PTR_ERR(client);
@@ -7617,6 +7624,9 @@ nfs41_find_root_sec(struct nfs_server *server, struct nfs_fh *fhandle,
 			break;
 		}
 
+		if (!nfs_auth_info_match(&server->auth_info, flavor))
+			flavor = RPC_AUTH_MAXFLAVOR;
+
 		if (flavor != RPC_AUTH_MAXFLAVOR) {
 			err = nfs4_lookup_root_sec(server, fhandle,
 						   info, flavor);
diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index 1f5b29b..aa377f0 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -497,7 +497,8 @@ static const char *nfs_pseudoflavour_to_name(rpc_authflavor_t flavour)
 	static const struct {
 		rpc_authflavor_t flavour;
 		const char *str;
-	} sec_flavours[] = {
+	} sec_flavours[NFS_AUTH_INFO_MAX_FLAVORS] = {
+		/* update NFS_AUTH_INFO_MAX_FLAVORS when this list changes! */
 		{ RPC_AUTH_NULL, "null" },
 		{ RPC_AUTH_UNIX, "sys" },
 		{ RPC_AUTH_GSS_KRB5, "krb5" },
@@ -1019,6 +1020,52 @@ static void nfs_set_mount_transport_protocol(struct nfs_parsed_mount_data *mnt)
 }
 
 /*
+ * Add 'flavor' to 'auth_info' if not already present.
+ * Returns true if 'flavor' ends up in the list, false otherwise
+ */
+static bool nfs_auth_info_add(struct nfs_auth_info *auth_info,
+			      rpc_authflavor_t flavor)
+{
+	unsigned int i;
+	unsigned int max_flavor_len = (sizeof(auth_info->flavors) /
+				       sizeof(auth_info->flavors[0]));
+
+	/* make sure this flavor isn't already in the list */
+	for (i = 0; i < auth_info->flavor_len; i++) {
+		if (flavor == auth_info->flavors[i])
+			return true;
+	}
+
+	if (auth_info->flavor_len + 1 >= max_flavor_len) {
+		dfprintk(MOUNT, "NFS: too many sec= flavors\n");
+		return false;
+	}
+
+	auth_info->flavors[auth_info->flavor_len++] = flavor;
+	return true;
+}
+
+/*
+ * Return true if 'match' is in auth_info or auth_info is empty.
+ * Return false otherwise.
+ */
+bool nfs_auth_info_match(const struct nfs_auth_info *auth_info,
+			 rpc_authflavor_t match)
+{
+	int i;
+
+	if (!auth_info->flavor_len)
+		return true;
+
+	for (i = 0; i < auth_info->flavor_len; i++) {
+		if (auth_info->flavors[i] == match)
+			return true;
+	}
+	return false;
+}
+EXPORT_SYMBOL_GPL(nfs_auth_info_match);
+
+/*
  * Parse the value of the 'sec=' option.
  */
 static int nfs_parse_security_flavors(char *value,
@@ -1026,49 +1073,55 @@ static int nfs_parse_security_flavors(char *value,
 {
 	substring_t args[MAX_OPT_ARGS];
 	rpc_authflavor_t pseudoflavor;
+	char *p;
 
 	dfprintk(MOUNT, "NFS: parsing sec=%s option\n", value);
 
-	switch (match_token(value, nfs_secflavor_tokens, args)) {
-	case Opt_sec_none:
-		pseudoflavor = RPC_AUTH_NULL;
-		break;
-	case Opt_sec_sys:
-		pseudoflavor = RPC_AUTH_UNIX;
-		break;
-	case Opt_sec_krb5:
-		pseudoflavor = RPC_AUTH_GSS_KRB5;
-		break;
-	case Opt_sec_krb5i:
-		pseudoflavor = RPC_AUTH_GSS_KRB5I;
-		break;
-	case Opt_sec_krb5p:
-		pseudoflavor = RPC_AUTH_GSS_KRB5P;
-		break;
-	case Opt_sec_lkey:
-		pseudoflavor = RPC_AUTH_GSS_LKEY;
-		break;
-	case Opt_sec_lkeyi:
-		pseudoflavor = RPC_AUTH_GSS_LKEYI;
-		break;
-	case Opt_sec_lkeyp:
-		pseudoflavor = RPC_AUTH_GSS_LKEYP;
-		break;
-	case Opt_sec_spkm:
-		pseudoflavor = RPC_AUTH_GSS_SPKM;
-		break;
-	case Opt_sec_spkmi:
-		pseudoflavor = RPC_AUTH_GSS_SPKMI;
-		break;
-	case Opt_sec_spkmp:
-		pseudoflavor = RPC_AUTH_GSS_SPKMP;
-		break;
-	default:
-		return 0;
+	while ((p = strsep(&value, ":")) != NULL) {
+		switch (match_token(p, nfs_secflavor_tokens, args)) {
+		case Opt_sec_none:
+			pseudoflavor = RPC_AUTH_NULL;
+			break;
+		case Opt_sec_sys:
+			pseudoflavor = RPC_AUTH_UNIX;
+			break;
+		case Opt_sec_krb5:
+			pseudoflavor = RPC_AUTH_GSS_KRB5;
+			break;
+		case Opt_sec_krb5i:
+			pseudoflavor = RPC_AUTH_GSS_KRB5I;
+			break;
+		case Opt_sec_krb5p:
+			pseudoflavor = RPC_AUTH_GSS_KRB5P;
+			break;
+		case Opt_sec_lkey:
+			pseudoflavor = RPC_AUTH_GSS_LKEY;
+			break;
+		case Opt_sec_lkeyi:
+			pseudoflavor = RPC_AUTH_GSS_LKEYI;
+			break;
+		case Opt_sec_lkeyp:
+			pseudoflavor = RPC_AUTH_GSS_LKEYP;
+			break;
+		case Opt_sec_spkm:
+			pseudoflavor = RPC_AUTH_GSS_SPKM;
+			break;
+		case Opt_sec_spkmi:
+			pseudoflavor = RPC_AUTH_GSS_SPKMI;
+			break;
+		case Opt_sec_spkmp:
+			pseudoflavor = RPC_AUTH_GSS_SPKMP;
+			break;
+		default:
+			dfprintk(MOUNT,
+				 "NFS: sec= option '%s' not recognized\n", p);
+			return 0;
+		}
+
+		if (!nfs_auth_info_add(&mnt->auth_info, pseudoflavor))
+			return 0;
 	}
 
-	mnt->auth_info.flavors[0] = pseudoflavor;
-	mnt->auth_info.flavor_len = 1;
 	return 1;
 }
 
@@ -1615,12 +1668,14 @@ out_security_failure:
 }
 
 /*
- * Ensure that the specified authtype in args->auth_info is supported by
- * the server. Returns 0 if it's ok, and -EACCES if not.
+ * Ensure that a specified authtype in args->auth_info is supported by
+ * the server. Returns 0 and sets args->selected_flavor if it's ok, and
+ * -EACCES if not.
  */
-static int nfs_verify_authflavor(struct nfs_parsed_mount_data *args,
+static int nfs_verify_authflavors(struct nfs_parsed_mount_data *args,
 			rpc_authflavor_t *server_authlist, unsigned int count)
 {
+	rpc_authflavor_t flavor = RPC_AUTH_MAXFLAVOR;
 	unsigned int i;
 
 	/*
@@ -1632,17 +1687,19 @@ static int nfs_verify_authflavor(struct nfs_parsed_mount_data *args,
 	 * can be used.
 	 */
 	for (i = 0; i < count; i++) {
-		if (args->auth_info.flavors[0] == server_authlist[i] ||
-		    server_authlist[i] == RPC_AUTH_NULL)
+		flavor = server_authlist[i];
+
+		if (nfs_auth_info_match(&args->auth_info, flavor) ||
+		    flavor == RPC_AUTH_NULL)
 			goto out;
 	}
 
-	dfprintk(MOUNT, "NFS: auth flavor %u not supported by server\n",
-		args->auth_info.flavors[0]);
+	dfprintk(MOUNT,
+		 "NFS: specified auth flavors not supported by server\n");
 	return -EACCES;
 
 out:
-	args->selected_flavor = args->auth_info.flavors[0];
+	args->selected_flavor = flavor;
 	dfprintk(MOUNT, "NFS: using auth flavor %u\n", args->selected_flavor);
 	return 0;
 }
@@ -1732,7 +1789,7 @@ static struct nfs_server *nfs_try_mount_request(struct nfs_mount_info *mount_inf
 	 * whether the server supports it, and then just try to use it if so.
 	 */
 	if (args->auth_info.flavor_len > 0) {
-		status = nfs_verify_authflavor(args, authlist, authlist_len);
+		status = nfs_verify_authflavors(args, authlist, authlist_len);
 		dfprintk(MOUNT, "NFS: using auth flavor %u\n",
 			 args->selected_flavor);
 		if (status)
@@ -2102,9 +2159,6 @@ static int nfs_validate_text_mount_data(void *options,
 
 	nfs_set_port(sap, &args->nfs_server.port, port);
 
-	if (args->auth_info.flavor_len > 1)
-		goto out_bad_auth;
-
 	return nfs_parse_devname(dev_name,
 				   &args->nfs_server.hostname,
 				   max_namelen,
@@ -2124,10 +2178,6 @@ out_invalid_transport_udp:
 out_no_address:
 	dfprintk(MOUNT, "NFS: mount program didn't pass remote address\n");
 	return -EINVAL;
-
-out_bad_auth:
-	dfprintk(MOUNT, "NFS: Too many RPC auth flavours specified\n");
-	return -EINVAL;
 }
 
 static int
diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
index 305263a..488ce9d 100644
--- a/include/linux/nfs_xdr.h
+++ b/include/linux/nfs_xdr.h
@@ -592,9 +592,10 @@ struct nfs_renameres {
 };
 
 /* parsed sec= options */
+#define NFS_AUTH_INFO_MAX_FLAVORS 12 /* see fs/nfs/super.c */
 struct nfs_auth_info {
 	unsigned int            flavor_len;
-	rpc_authflavor_t        flavors[1];
+	rpc_authflavor_t        flavors[NFS_AUTH_INFO_MAX_FLAVORS];
 };
 
 /*
-- 
1.7.12.4 (Apple Git-37)

