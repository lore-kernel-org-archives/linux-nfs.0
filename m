Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-iy0-f174.google.com ([209.85.210.174]:51202 "EHLO
	mail-iy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754999Ab2CAWBl (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 1 Mar 2012 17:01:41 -0500
Received: by mail-iy0-f174.google.com with SMTP id z16so1389945iag.19
        for <linux-nfs@vger.kernel.org>; Thu, 01 Mar 2012 14:01:41 -0800 (PST)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 10/15] NFS: Save root file handle in nfs_server
To: trond.myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org
Date: Thu, 01 Mar 2012 17:01:40 -0500
Message-ID: <20120301220139.2138.99499.stgit@degas.1015granger.net>
In-Reply-To: <20120301215755.2138.73488.stgit@degas.1015granger.net>
References: <20120301215755.2138.73488.stgit@degas.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Save each FSID's root directory file handle in the FSID's nfs_server
structure on the client.  For now, only NFSv4 mounts save the root FH.
This is needed for migration recovery.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/nfs/client.c           |    1 +
 fs/nfs/getroot.c          |    5 +++++
 include/linux/nfs_fs_sb.h |    1 +
 3 files changed, 7 insertions(+), 0 deletions(-)

diff --git a/fs/nfs/client.c b/fs/nfs/client.c
index add92d9..c9e1bb4 100644
--- a/fs/nfs/client.c
+++ b/fs/nfs/client.c
@@ -1135,6 +1135,7 @@ void nfs_free_server(struct nfs_server *server)
 	ida_destroy(&server->lockowner_id);
 	ida_destroy(&server->openowner_id);
 	nfs_free_iostats(server->io_stats);
+	nfs_free_fhandle(server->rootfh);
 	bdi_destroy(&server->backing_dev_info);
 	kfree(server);
 	nfs_release_automount_timer();
diff --git a/fs/nfs/getroot.c b/fs/nfs/getroot.c
index dcb6154..8d4fbe1 100644
--- a/fs/nfs/getroot.c
+++ b/fs/nfs/getroot.c
@@ -232,6 +232,11 @@ struct dentry *nfs4_get_root(struct super_block *sb, struct nfs_fh *mntfh,
 		ret = ERR_CAST(inode);
 		goto out;
 	}
+	server->rootfh = nfs_alloc_fhandle();
+	if (server->rootfh != NULL) {
+		nfs_display_fhandle(mntfh, "nfs_get_root: new root FH");
+		nfs_copy_fh(server->rootfh, mntfh);
+	}
 
 	error = nfs_superblock_set_dummy_root(sb, inode);
 	if (error != 0) {
diff --git a/include/linux/nfs_fs_sb.h b/include/linux/nfs_fs_sb.h
index 3bf4766..0a2c826 100644
--- a/include/linux/nfs_fs_sb.h
+++ b/include/linux/nfs_fs_sb.h
@@ -159,6 +159,7 @@ struct nfs_server {
 	struct list_head	layouts;
 	struct list_head	delegations;
 	void (*destroy)(struct nfs_server *);
+	struct nfs_fh		*rootfh;
 
 	atomic_t active; /* Keep trace of any activity to this server */
 

