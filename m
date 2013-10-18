Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx11.netapp.com ([216.240.18.76]:51129 "EHLO mx11.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753926Ab3JRTPr (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 18 Oct 2013 15:15:47 -0400
From: Weston Andros Adamson <dros@netapp.com>
To: <Trond.Myklebust@netapp.com>
CC: <linux-nfs@vger.kernel.org>, Weston Andros Adamson <dros@netapp.com>
Subject: [PATCH 4/5] NFS: stop using NFS_MOUNT_SECFLAVOUR server flag
Date: Fri, 18 Oct 2013 15:15:18 -0400
Message-ID: <1382123719-25194-5-git-send-email-dros@netapp.com>
In-Reply-To: <1382123719-25194-1-git-send-email-dros@netapp.com>
References: <1382123719-25194-1-git-send-email-dros@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Since the parsed sec= flavor is now stored in nfs_server->auth_info,
we no longer need an nfs_server flag to determine if a sec= option was
used.

This flag has not been completely removed because it is still needed for
the (old but still supported) non-text parsed mount options ABI
compatability.

Signed-off-by: Weston Andros Adamson <dros@netapp.com>
---
 fs/nfs/nfs4client.c            | 6 ++++--
 fs/nfs/nfs4namespace.c         | 2 +-
 fs/nfs/nfs4proc.c              | 4 ++--
 fs/nfs/super.c                 | 3 +--
 include/uapi/linux/nfs_mount.h | 2 +-
 5 files changed, 9 insertions(+), 8 deletions(-)

diff --git a/fs/nfs/nfs4client.c b/fs/nfs/nfs4client.c
index 73899c0..0697ef3 100644
--- a/fs/nfs/nfs4client.c
+++ b/fs/nfs/nfs4client.c
@@ -1050,6 +1050,7 @@ struct nfs_server *nfs4_create_referral_server(struct nfs_clone_mount *data,
 {
 	struct nfs_client *parent_client;
 	struct nfs_server *server, *parent_server;
+	bool auth_probe;
 	int error;
 
 	dprintk("--> nfs4_create_referral_server()\n");
@@ -1082,8 +1083,9 @@ struct nfs_server *nfs4_create_referral_server(struct nfs_clone_mount *data,
 	if (error < 0)
 		goto error;
 
-	error = nfs4_server_common_setup(server, mntfh,
-			!(parent_server->flags & NFS_MOUNT_SECFLAVOUR));
+	auth_probe = parent_server->auth_info.flavor_len < 1;
+
+	error = nfs4_server_common_setup(server, mntfh, auth_probe);
 	if (error < 0)
 		goto error;
 
diff --git a/fs/nfs/nfs4namespace.c b/fs/nfs/nfs4namespace.c
index 62ed517..2d79be2 100644
--- a/fs/nfs/nfs4namespace.c
+++ b/fs/nfs/nfs4namespace.c
@@ -390,7 +390,7 @@ struct vfsmount *nfs4_submount(struct nfs_server *server, struct dentry *dentry,
 
 	if (client->cl_auth->au_flavor != flavor)
 		flavor = client->cl_auth->au_flavor;
-	else if (!(server->flags & NFS_MOUNT_SECFLAVOUR)) {
+	else if (server->auth_info.flavor_len == 0) {
 		rpc_authflavor_t new = nfs4_negotiate_security(dir, name);
 		if ((int)new >= 0)
 			flavor = new;
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index d2b4845..9e0c10e 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -2911,7 +2911,7 @@ int nfs4_proc_get_rootfh(struct nfs_server *server, struct nfs_fh *fhandle,
 		if (status != -NFS4ERR_WRONGSEC)
 			break;
 		/* Did user force a 'sec=' mount option? */
-		if (server->flags & NFS_MOUNT_SECFLAVOUR)
+		if (server->auth_info.flavor_len > 0)
 			break;
 	default:
 		status = nfs4_do_find_root_sec(server, fhandle, info);
@@ -3166,7 +3166,7 @@ static int nfs4_proc_lookup_common(struct rpc_clnt **clnt, struct inode *dir,
 			if (client != *clnt)
 				goto out;
 			/* No security negotiation if the user specified 'sec=' */
-			if (NFS_SERVER(dir)->flags & NFS_MOUNT_SECFLAVOUR)
+			if (NFS_SERVER(dir)->auth_info.flavor_len > 0)
 				goto out;
 			client = nfs4_create_sec_client(client, dir, name);
 			if (IS_ERR(client))
diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index 6c38c2a..1f5b29b 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -1067,7 +1067,6 @@ static int nfs_parse_security_flavors(char *value,
 		return 0;
 	}
 
-	mnt->flags |= NFS_MOUNT_SECFLAVOUR;
 	mnt->auth_info.flavors[0] = pseudoflavor;
 	mnt->auth_info.flavor_len = 1;
 	return 1;
@@ -2328,7 +2327,7 @@ static int nfs_compare_mount_options(const struct super_block *s, const struct n
 		goto Ebusy;
 	if (a->acdirmax != b->acdirmax)
 		goto Ebusy;
-	if (b->flags & NFS_MOUNT_SECFLAVOUR &&
+	if (b->auth_info.flavor_len > 0 &&
 	   clnt_a->cl_auth->au_flavor != clnt_b->cl_auth->au_flavor)
 		goto Ebusy;
 	return 1;
diff --git a/include/uapi/linux/nfs_mount.h b/include/uapi/linux/nfs_mount.h
index 576bddd..64b0f22 100644
--- a/include/uapi/linux/nfs_mount.h
+++ b/include/uapi/linux/nfs_mount.h
@@ -60,7 +60,7 @@ struct nfs_mount_data {
 #define NFS_MOUNT_BROKEN_SUID	0x0400	/* 4 */
 #define NFS_MOUNT_NOACL		0x0800	/* 4 */
 #define NFS_MOUNT_STRICTLOCK	0x1000	/* reserved for NFSv4 */
-#define NFS_MOUNT_SECFLAVOUR	0x2000	/* 5 */
+#define NFS_MOUNT_SECFLAVOUR	0x2000	/* 5 non-text parsed mount data only */
 #define NFS_MOUNT_NORDIRPLUS	0x4000	/* 5 */
 #define NFS_MOUNT_UNSHARED	0x8000	/* 5 */
 #define NFS_MOUNT_FLAGMASK	0xFFFF
-- 
1.7.12.4 (Apple Git-37)

