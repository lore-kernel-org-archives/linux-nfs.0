Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-iw0-f174.google.com ([209.85.214.174]:56623 "EHLO
	mail-iw0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753005Ab1CJR3w (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 10 Mar 2011 12:29:52 -0500
Received: by iwn34 with SMTP id 34so1743856iwn.19
        for <linux-nfs@vger.kernel.org>; Thu, 10 Mar 2011 09:29:52 -0800 (PST)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 2/8] NFS: Save root file handle in nfs_server
To: linux-nfs@vger.kernel.org
Date: Thu, 10 Mar 2011 12:29:49 -0500
Message-ID: <20110310172949.8878.82487.stgit@matisse.1015granger.net>
In-Reply-To: <20110310171345.8878.25548.stgit@matisse.1015granger.net>
References: <20110310171345.8878.25548.stgit@matisse.1015granger.net>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Save each FSID's root directory file handle in the export's local
nfs_server structure on the client.  This FH can later be used by the
migration recovery logic.

NB: Saving the root FH is done only for NFSv4 mounts.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/nfs/client.c           |    1 +
 fs/nfs/getroot.c          |    6 ++++++
 include/linux/nfs_fs_sb.h |    1 +
 3 files changed, 8 insertions(+), 0 deletions(-)

diff --git a/fs/nfs/client.c b/fs/nfs/client.c
index f8c95e4..a2f016a 100644
--- a/fs/nfs/client.c
+++ b/fs/nfs/client.c
@@ -1081,6 +1081,7 @@ void nfs_free_server(struct nfs_server *server)
 	nfs_put_client(server->nfs_client);
 
 	nfs_free_iostats(server->io_stats);
+	nfs_free_fhandle(server->rootfh);
 	bdi_destroy(&server->backing_dev_info);
 	kfree(server);
 	nfs_release_automount_timer();
diff --git a/fs/nfs/getroot.c b/fs/nfs/getroot.c
index b5ffe8f..4b9fc6e 100644
--- a/fs/nfs/getroot.c
+++ b/fs/nfs/getroot.c
@@ -205,6 +205,12 @@ struct dentry *nfs4_get_root(struct super_block *sb, struct nfs_fh *mntfh)
 		ret = ERR_CAST(inode);
 		goto out;
 	}
+	server->rootfh = nfs_alloc_fhandle();
+	if (server->rootfh != NULL) {
+		dprintk("nfs_get_root: saving root FH\n");
+		nfs_display_fhandle(mntfh);
+		nfs_copy_fh(server->rootfh, mntfh);
+	}
 
 	error = nfs_superblock_set_dummy_root(sb, inode);
 	if (error != 0) {
diff --git a/include/linux/nfs_fs_sb.h b/include/linux/nfs_fs_sb.h
index b197563..961ee85 100644
--- a/include/linux/nfs_fs_sb.h
+++ b/include/linux/nfs_fs_sb.h
@@ -153,6 +153,7 @@ struct nfs_server {
 #endif
 	struct list_head	delegations;
 	void (*destroy)(struct nfs_server *);
+	struct nfs_fh		*rootfh;
 
 	atomic_t active; /* Keep trace of any activity to this server */
 

