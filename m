Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-iy0-f174.google.com ([209.85.210.174]:52145 "EHLO
	mail-iy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753096Ab1CNM5N (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 14 Mar 2011 08:57:13 -0400
Received: by mail-iy0-f174.google.com with SMTP id 26so4900509iyb.19
        for <linux-nfs@vger.kernel.org>; Mon, 14 Mar 2011 05:57:13 -0700 (PDT)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 05/12] NFS: Save root file handle in nfs_server
To: trond.myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org
Date: Mon, 14 Mar 2011 08:57:10 -0400
Message-ID: <20110314125710.2413.18253.stgit@matisse.1015granger.net>
In-Reply-To: <20110314125204.2413.8870.stgit@matisse.1015granger.net>
References: <20110314125204.2413.8870.stgit@matisse.1015granger.net>
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
 fs/nfs/getroot.c          |    5 +++++
 include/linux/nfs_fs_sb.h |    1 +
 3 files changed, 7 insertions(+), 0 deletions(-)

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
index b5ffe8f..437d1a1 100644
--- a/fs/nfs/getroot.c
+++ b/fs/nfs/getroot.c
@@ -205,6 +205,11 @@ struct dentry *nfs4_get_root(struct super_block *sb, struct nfs_fh *mntfh)
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
index b197563..961ee85 100644
--- a/include/linux/nfs_fs_sb.h
+++ b/include/linux/nfs_fs_sb.h
@@ -153,6 +153,7 @@ struct nfs_server {
 #endif
 	struct list_head	delegations;
 	void (*destroy)(struct nfs_server *);
+	struct nfs_fh		*rootfh;
 
 	atomic_t active; /* Keep trace of any activity to this server */
 

