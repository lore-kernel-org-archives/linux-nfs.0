Return-Path: linux-nfs-owner@vger.kernel.org
Received: from e35.co.us.ibm.com ([32.97.110.153]:52611 "EHLO
	e35.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932294Ab2CEUgo (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 5 Mar 2012 15:36:44 -0500
Received: from /spool/local
	by e35.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-nfs@vger.kernel.org> from <treinish@linux.vnet.ibm.com>;
	Mon, 5 Mar 2012 13:36:43 -0700
Received: from d03relay01.boulder.ibm.com (d03relay01.boulder.ibm.com [9.17.195.226])
	by d03dlp01.boulder.ibm.com (Postfix) with ESMTP id 1DB52C40010
	for <linux-nfs@vger.kernel.org>; Mon,  5 Mar 2012 13:27:17 -0700 (MST)
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay01.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q25KR75M113264
	for <linux-nfs@vger.kernel.org>; Mon, 5 Mar 2012 13:27:07 -0700
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q25KR6Wg009859
	for <linux-nfs@vger.kernel.org>; Mon, 5 Mar 2012 13:27:06 -0700
From: Matthew Treinish <treinish@linux.vnet.ibm.com>
To: linux-nfs@vger.kernel.org
Cc: treinish@linux.vnet.ibm.com, Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH/RFC v3 02/10] Save root file handle in nfs_server.
Date: Mon,  5 Mar 2012 15:26:43 -0500
Message-Id: <1330979211-894-3-git-send-email-treinish@linux.vnet.ibm.com>
In-Reply-To: <1330979211-894-1-git-send-email-treinish@linux.vnet.ibm.com>
References: <1330979211-894-1-git-send-email-treinish@linux.vnet.ibm.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Save each FSID's root directory file handle in the
export's local nfs_server structure on the client.
This FH can then be used as the end case for the recursive
walkback during VFH recovery.

This was originally written by Chuck Lever so that
the FH can be used for migration recovery logic.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
Signed-off-by: Matthew Treinish <treinish@linux.vnet.ibm.com>
---
 fs/nfs/client.c           |    1 +
 fs/nfs/getroot.c          |    7 +++++++
 include/linux/nfs_fs_sb.h |    1 +
 3 files changed, 9 insertions(+), 0 deletions(-)

diff --git a/fs/nfs/client.c b/fs/nfs/client.c
index 2f96f9d..7566325 100644
--- a/fs/nfs/client.c
+++ b/fs/nfs/client.c
@@ -1137,6 +1137,7 @@ void nfs_free_server(struct nfs_server *server)
 	ida_destroy(&server->lockowner_id);
 	ida_destroy(&server->openowner_id);
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
index 15a2056..5993319 100644
--- a/include/linux/nfs_fs_sb.h
+++ b/include/linux/nfs_fs_sb.h
@@ -160,6 +160,7 @@ struct nfs_server {
 	struct list_head	layouts;
 	struct list_head	delegations;
 	void (*destroy)(struct nfs_server *);
+	struct nfs_fh		*rootfh;
 
 	atomic_t active; /* Keep trace of any activity to this server */
 
-- 
1.7.4.4

