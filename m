From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 02/24] NFSv4: Eliminate nfs4_path_walk()
Date: Fri, 16 Apr 2010 16:31:00 -0400
Message-ID: <1271449882-8580-3-git-send-email-Trond.Myklebust@netapp.com>
References: <1271449882-8580-1-git-send-email-Trond.Myklebust@netapp.com>
 <1271449882-8580-2-git-send-email-Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:8905 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932446Ab0DPUbY (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 16 Apr 2010 16:31:24 -0400
Received: from localhost.localdomain (marilynd-lxp.hq.netapp.com [10.58.50.136] (may be forged))
	by smtp1.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id o3GKVMkv026251
	for <linux-nfs@vger.kernel.org>; Fri, 16 Apr 2010 13:31:24 -0700 (PDT)
In-Reply-To: <1271449882-8580-2-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

All we really want is the ability to retrieve the root file handle. We no
longer need the ability to walk down the path, since that is now done in
nfs_follow_remote_path().

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 fs/nfs/client.c   |    4 +-
 fs/nfs/getroot.c  |  115 ++++++++++------------------------------------------
 fs/nfs/internal.h |    4 +-
 3 files changed, 25 insertions(+), 98 deletions(-)

diff --git a/fs/nfs/client.c b/fs/nfs/client.c
index a8766c4..48fc680 100644
--- a/fs/nfs/client.c
+++ b/fs/nfs/client.c
@@ -1362,7 +1362,7 @@ struct nfs_server *nfs4_create_server(const struct nfs_parsed_mount_data *data,
 		goto error;
 
 	/* Probe the root fh to retrieve its FSID */
-	error = nfs4_path_walk(server, mntfh, data->nfs_server.export_path);
+	error = nfs4_get_rootfh(server, mntfh);
 	if (error < 0)
 		goto error;
 
@@ -1441,7 +1441,7 @@ struct nfs_server *nfs4_create_referral_server(struct nfs_clone_mount *data,
 	BUG_ON(!server->nfs_client->rpc_ops->file_inode_ops);
 
 	/* Probe the root fh to retrieve its FSID and filehandle */
-	error = nfs4_path_walk(server, mntfh, data->mnt_path);
+	error = nfs4_get_rootfh(server, mntfh);
 	if (error < 0)
 		goto error;
 
diff --git a/fs/nfs/getroot.c b/fs/nfs/getroot.c
index b35d2a6..ada369a 100644
--- a/fs/nfs/getroot.c
+++ b/fs/nfs/getroot.c
@@ -122,115 +122,44 @@ struct dentry *nfs_get_root(struct super_block *sb, struct nfs_fh *mntfh)
 
 #ifdef CONFIG_NFS_V4
 
-/*
- * Do a simple pathwalk from the root FH of the server to the nominated target
- * of the mountpoint
- * - give error on symlinks
- * - give error on ".." occurring in the path
- * - follow traversals
- */
-int nfs4_path_walk(struct nfs_server *server,
-		   struct nfs_fh *mntfh,
-		   const char *path)
+int nfs4_get_rootfh(struct nfs_server *server, struct nfs_fh *mntfh)
 {
 	struct nfs_fsinfo fsinfo;
-	struct nfs_fattr fattr;
-	struct nfs_fh lastfh;
-	struct qstr name;
-	int ret;
+	int ret = -ENOMEM;
 
-	dprintk("--> nfs4_path_walk(,,%s)\n", path);
+	dprintk("--> nfs4_get_rootfh()\n");
 
-	fsinfo.fattr = &fattr;
-	nfs_fattr_init(&fattr);
-
-	/* Eat leading slashes */
-	while (*path == '/')
-		path++;
+	fsinfo.fattr = nfs_alloc_fattr();
+	if (fsinfo.fattr == NULL)
+		goto out;
 
 	/* Start by getting the root filehandle from the server */
 	ret = server->nfs_client->rpc_ops->getroot(server, mntfh, &fsinfo);
 	if (ret < 0) {
-		dprintk("nfs4_get_root: getroot error = %d\n", -ret);
-		return ret;
+		dprintk("nfs4_get_rootfh: getroot error = %d\n", -ret);
+		goto out;
 	}
 
-	if (!S_ISDIR(fattr.mode)) {
-		printk(KERN_ERR "nfs4_get_root:"
+	if (!(fsinfo.fattr->valid & NFS_ATTR_FATTR_MODE)
+			|| !S_ISDIR(fsinfo.fattr->mode)) {
+		printk(KERN_ERR "nfs4_get_rootfh:"
 		       " getroot encountered non-directory\n");
-		return -ENOTDIR;
+		ret = -ENOTDIR;
+		goto out;
 	}
 
-	/* FIXME: It is quite valid for the server to return a referral here */
-	if (fattr.valid & NFS_ATTR_FATTR_V4_REFERRAL) {
-		printk(KERN_ERR "nfs4_get_root:"
+	if (fsinfo.fattr->valid & NFS_ATTR_FATTR_V4_REFERRAL) {
+		printk(KERN_ERR "nfs4_get_rootfh:"
 		       " getroot obtained referral\n");
-		return -EREMOTE;
+		ret = -EREMOTE;
+		goto out;
 	}
 
-next_component:
-	dprintk("Next: %s\n", path);
-
-	/* extract the next bit of the path */
-	if (!*path)
-		goto path_walk_complete;
-
-	name.name = path;
-	while (*path && *path != '/')
-		path++;
-	name.len = path - (const char *) name.name;
-
-	if (name.len > NFS4_MAXNAMLEN)
-		return -ENAMETOOLONG;
-
-eat_dot_dir:
-	while (*path == '/')
-		path++;
-
-	if (path[0] == '.' && (path[1] == '/' || !path[1])) {
-		path += 2;
-		goto eat_dot_dir;
-	}
-
-	/* FIXME: Why shouldn't the user be able to use ".." in the path? */
-	if (path[0] == '.' && path[1] == '.' && (path[2] == '/' || !path[2])
-	    ) {
-		printk(KERN_ERR "nfs4_get_root:"
-		       " Mount path contains reference to \"..\"\n");
-		return -EINVAL;
-	}
-
-	/* lookup the next FH in the sequence */
-	memcpy(&lastfh, mntfh, sizeof(lastfh));
-
-	dprintk("LookupFH: %*.*s [%s]\n", name.len, name.len, name.name, path);
-
-	ret = server->nfs_client->rpc_ops->lookupfh(server, &lastfh, &name,
-						    mntfh, &fattr);
-	if (ret < 0) {
-		dprintk("nfs4_get_root: getroot error = %d\n", -ret);
-		return ret;
-	}
-
-	if (!S_ISDIR(fattr.mode)) {
-		printk(KERN_ERR "nfs4_get_root:"
-		       " lookupfh encountered non-directory\n");
-		return -ENOTDIR;
-	}
-
-	/* FIXME: Referrals are quite valid here too */
-	if (fattr.valid & NFS_ATTR_FATTR_V4_REFERRAL) {
-		printk(KERN_ERR "nfs4_get_root:"
-		       " lookupfh obtained referral\n");
-		return -EREMOTE;
-	}
-
-	goto next_component;
-
-path_walk_complete:
-	memcpy(&server->fsid, &fattr.fsid, sizeof(server->fsid));
-	dprintk("<-- nfs4_path_walk() = 0\n");
-	return 0;
+	memcpy(&server->fsid, &fsinfo.fattr->fsid, sizeof(server->fsid));
+out:
+	nfs_free_fattr(fsinfo.fattr);
+	dprintk("<-- nfs4_get_rootfh() = %d\n", ret);
+	return ret;
 }
 
 /*
diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
index 11f82f0..d8bd619 100644
--- a/fs/nfs/internal.h
+++ b/fs/nfs/internal.h
@@ -244,9 +244,7 @@ extern struct dentry *nfs_get_root(struct super_block *, struct nfs_fh *);
 #ifdef CONFIG_NFS_V4
 extern struct dentry *nfs4_get_root(struct super_block *, struct nfs_fh *);
 
-extern int nfs4_path_walk(struct nfs_server *server,
-			  struct nfs_fh *mntfh,
-			  const char *path);
+extern int nfs4_get_rootfh(struct nfs_server *server, struct nfs_fh *mntfh);
 #endif
 
 /* read.c */
-- 
1.6.6.1

