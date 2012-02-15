Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-iy0-f174.google.com ([209.85.210.174]:37226 "EHLO
	mail-iy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754658Ab2BOVgK (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 15 Feb 2012 16:36:10 -0500
Received: by mail-iy0-f174.google.com with SMTP id b35so1972889iac.19
        for <linux-nfs@vger.kernel.org>; Wed, 15 Feb 2012 13:36:10 -0800 (PST)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 10/13] NFS: Save root file handle in nfs_server
To: trond.myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org
Date: Wed, 15 Feb 2012 16:36:08 -0500
Message-ID: <20120215213608.3254.11662.stgit@ellison.1015granger.net>
In-Reply-To: <20120215213336.3254.98936.stgit@ellison.1015granger.net>
References: <20120215213336.3254.98936.stgit@ellison.1015granger.net>
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
index 200e1d8..ada7a05 100644
--- a/fs/nfs/client.c
+++ b/fs/nfs/client.c
@@ -1112,6 +1112,7 @@ void nfs_free_server(struct nfs_server *server)
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
index ba4d765..6532d7b 100644
--- a/include/linux/nfs_fs_sb.h
+++ b/include/linux/nfs_fs_sb.h
@@ -157,6 +157,7 @@ struct nfs_server {
 	struct list_head	layouts;
 	struct list_head	delegations;
 	void (*destroy)(struct nfs_server *);
+	struct nfs_fh		*rootfh;
 
 	atomic_t active; /* Keep trace of any activity to this server */
 

