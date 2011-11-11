Return-Path: linux-nfs-owner@vger.kernel.org
Received: from e34.co.us.ibm.com ([32.97.110.152]:54590 "EHLO
	e34.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754032Ab1KKXGR (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 11 Nov 2011 18:06:17 -0500
Received: from /spool/local
	by e34.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-nfs@vger.kernel.org> from <treinish@linux.vnet.ibm.com>;
	Fri, 11 Nov 2011 16:06:16 -0700
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by d03relay05.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id pABN5oY1031488
	for <linux-nfs@vger.kernel.org>; Fri, 11 Nov 2011 16:05:51 -0700
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id pABN5oQv003209
	for <linux-nfs@vger.kernel.org>; Fri, 11 Nov 2011 16:05:50 -0700
From: Matthew Treinish <treinish@linux.vnet.ibm.com>
To: linux-nfs@vger.kernel.org
Cc: treinish@linux.vnet.ibm.com, Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH/RFC 4/7] Save root file handle in nfs_server.
Date: Fri, 11 Nov 2011 18:04:29 -0500
Message-Id: <1321052673-22171-5-git-send-email-treinish@linux.vnet.ibm.com>
In-Reply-To: <1321052673-22171-1-git-send-email-treinish@linux.vnet.ibm.com>
References: <1321052673-22171-1-git-send-email-treinish@linux.vnet.ibm.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Save each FSID's root directory file handle in the
export's local nfs_server structure on the client.
This FH can later be used by the migration recovery
logic.

NB: Saving the root FH is done only for NFSv4 mounts.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
Signed-off-by: Matthew Treinish <treinish@linux.vnet.ibm.com>
---
 fs/nfs/client.c           |    1 +
 fs/nfs/getroot.c          |    7 +++++++
 include/linux/nfs_fs_sb.h |    1 +
 3 files changed, 9 insertions(+), 0 deletions(-)

diff --git a/fs/nfs/client.c b/fs/nfs/client.c
index 44dedfe..641f69f 100644
--- a/fs/nfs/client.c
+++ b/fs/nfs/client.c
@@ -1108,6 +1108,7 @@ void nfs_free_server(struct nfs_server *server)
 	nfs_put_client(server->nfs_client);
 
 	nfs_free_iostats(server->io_stats);
+	nfs_free_fhandle(server->rootfh);
 	bdi_destroy(&server->backing_dev_info);
 	kfree(server);
 	nfs_release_automount_timer();
diff --git a/fs/nfs/getroot.c b/fs/nfs/getroot.c
index dcb6154..51ca63b 100644
--- a/fs/nfs/getroot.c
+++ b/fs/nfs/getroot.c
@@ -232,6 +232,13 @@ struct dentry *nfs4_get_root(struct super_block *sb, struct nfs_fh *mntfh,
 		ret = ERR_CAST(inode);
 		goto out;
 	}
+	server->rootfh = nfs_alloc_fhandle();
+	if (server->rootfh == NULL) {
+		dprintk("nfs_get_root: alloc rootfh failed\n");
+		ret = ERR_PTR(-ENOMEM);
+		goto out;
+	}
+	nfs_copy_fh(server->rootfh, mntfh);
 
 	error = nfs_superblock_set_dummy_root(sb, inode);
 	if (error != 0) {
diff --git a/include/linux/nfs_fs_sb.h b/include/linux/nfs_fs_sb.h
index 706c92b..5261fa1 100644
--- a/include/linux/nfs_fs_sb.h
+++ b/include/linux/nfs_fs_sb.h
@@ -157,6 +157,7 @@ struct nfs_server {
 	struct list_head	layouts;
 	struct list_head	delegations;
 	void (*destroy)(struct nfs_server *);
+	struct nfs_fh		*rootfh;
 
 	atomic_t active; /* Keep trace of any activity to this server */
 
-- 
1.7.4.4

