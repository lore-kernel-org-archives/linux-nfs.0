Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:61708 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750846Ab3IGXSU (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 7 Sep 2013 19:18:20 -0400
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: <linux-nfs@vger.kernel.org>
Subject: [PATCH 5/6] NFSv4: Allow security autonegotiation for submounts
Date: Sat, 7 Sep 2013 19:18:12 -0400
Message-ID: <1378595893-60395-6-git-send-email-Trond.Myklebust@netapp.com>
In-Reply-To: <1378595893-60395-5-git-send-email-Trond.Myklebust@netapp.com>
References: <1378595893-60395-1-git-send-email-Trond.Myklebust@netapp.com>
 <1378595893-60395-2-git-send-email-Trond.Myklebust@netapp.com>
 <1378595893-60395-3-git-send-email-Trond.Myklebust@netapp.com>
 <1378595893-60395-4-git-send-email-Trond.Myklebust@netapp.com>
 <1378595893-60395-5-git-send-email-Trond.Myklebust@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

In cases where the parent super block was not mounted with a 'sec=' line,
allow autonegotiation of security for the submounts.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 fs/nfs/nfs4client.c    |  3 ++-
 fs/nfs/nfs4namespace.c | 21 +++++++++++++++++----
 2 files changed, 19 insertions(+), 5 deletions(-)

diff --git a/fs/nfs/nfs4client.c b/fs/nfs/nfs4client.c
index cc80085..a860ab5 100644
--- a/fs/nfs/nfs4client.c
+++ b/fs/nfs/nfs4client.c
@@ -1078,7 +1078,8 @@ struct nfs_server *nfs4_create_referral_server(struct nfs_clone_mount *data,
 	if (error < 0)
 		goto error;
 
-	error = nfs4_server_common_setup(server, mntfh, false);
+	error = nfs4_server_common_setup(server, mntfh,
+			!(parent_server->flags & NFS_MOUNT_SECFLAVOUR));
 	if (error < 0)
 		goto error;
 
diff --git a/fs/nfs/nfs4namespace.c b/fs/nfs/nfs4namespace.c
index cdb0b41..2288cd3 100644
--- a/fs/nfs/nfs4namespace.c
+++ b/fs/nfs/nfs4namespace.c
@@ -11,6 +11,7 @@
 #include <linux/mount.h>
 #include <linux/namei.h>
 #include <linux/nfs_fs.h>
+#include <linux/nfs_mount.h>
 #include <linux/slab.h>
 #include <linux/string.h>
 #include <linux/sunrpc/clnt.h>
@@ -369,21 +370,33 @@ out:
 struct vfsmount *nfs4_submount(struct nfs_server *server, struct dentry *dentry,
 			       struct nfs_fh *fh, struct nfs_fattr *fattr)
 {
+	rpc_authflavor_t flavor = server->client->cl_auth->au_flavor;
 	struct dentry *parent = dget_parent(dentry);
+	struct inode *dir = parent->d_inode;
+	struct qstr *name = &dentry->d_name;
 	struct rpc_clnt *client;
 	struct vfsmount *mnt;
 
 	/* Look it up again to get its attributes and sec flavor */
-	client = nfs4_proc_lookup_mountpoint(parent->d_inode, &dentry->d_name, fh, fattr);
+	client = nfs4_proc_lookup_mountpoint(dir, name, fh, fattr);
 	dput(parent);
 	if (IS_ERR(client))
 		return ERR_CAST(client);
 
-	if (fattr->valid & NFS_ATTR_FATTR_V4_REFERRAL)
+	if (fattr->valid & NFS_ATTR_FATTR_V4_REFERRAL) {
 		mnt = nfs_do_refmount(client, dentry);
-	else
-		mnt = nfs_do_submount(dentry, fh, fattr, client->cl_auth->au_flavor);
+		goto out;
+	}
 
+	if (client->cl_auth->au_flavor != flavor)
+		flavor = client->cl_auth->au_flavor;
+	else if (!(server->flags & NFS_MOUNT_SECFLAVOUR)) {
+		rpc_authflavor_t new = nfs4_negotiate_security(dir, name);
+		if ((int)new >= 0)
+			flavor = new;
+	}
+	mnt = nfs_do_submount(dentry, fh, fattr, flavor);
+out:
 	rpc_shutdown_client(client);
 	return mnt;
 }
-- 
1.8.3.1

