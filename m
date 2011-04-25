Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-iy0-f174.google.com ([209.85.210.174]:41311 "EHLO
	mail-iy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758825Ab1DYSoO (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 25 Apr 2011 14:44:14 -0400
Received: by mail-iy0-f174.google.com with SMTP id 14so2054039iyb.19
        for <linux-nfs@vger.kernel.org>; Mon, 25 Apr 2011 11:44:14 -0700 (PDT)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 06/15] NFS: Save root file handle in nfs_server
To: trond.myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org
Date: Mon, 25 Apr 2011 14:44:11 -0400
Message-ID: <20110425184411.5669.23400.stgit@matisse.1015granger.net>
In-Reply-To: <20110425183405.5669.52507.stgit@matisse.1015granger.net>
References: <20110425183405.5669.52507.stgit@matisse.1015granger.net>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Save each FSID's root directory file handle in the export's local
nfs_server structure on the client.  This file handle can later be
used for migration recovery.

NB: Saving the root FH is done only for NFSv4 mounts.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/nfs/client.c           |    1 +
 fs/nfs/getroot.c          |    5 +++++
 include/linux/nfs_fs_sb.h |    1 +
 3 files changed, 7 insertions(+), 0 deletions(-)

diff --git a/fs/nfs/client.c b/fs/nfs/client.c
index 8f8035e..c23bcf1 100644
--- a/fs/nfs/client.c
+++ b/fs/nfs/client.c
@@ -1101,6 +1101,7 @@ void nfs_free_server(struct nfs_server *server)
 	nfs_put_client(server->nfs_client);
 
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
index 216cea5..33b7459 100644
--- a/include/linux/nfs_fs_sb.h
+++ b/include/linux/nfs_fs_sb.h
@@ -150,6 +150,7 @@ struct nfs_server {
 #endif
 	struct list_head	delegations;
 	void (*destroy)(struct nfs_server *);
+	struct nfs_fh		*rootfh;
 
 	atomic_t active; /* Keep trace of any activity to this server */
 

