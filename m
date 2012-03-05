Return-Path: linux-nfs-owner@vger.kernel.org
Received: from e32.co.us.ibm.com ([32.97.110.150]:42926 "EHLO
	e32.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932277Ab2CEU1u (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 5 Mar 2012 15:27:50 -0500
Received: from /spool/local
	by e32.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-nfs@vger.kernel.org> from <treinish@linux.vnet.ibm.com>;
	Mon, 5 Mar 2012 13:27:45 -0700
Received: from d01relay05.pok.ibm.com (d01relay05.pok.ibm.com [9.56.227.237])
	by d01dlp03.pok.ibm.com (Postfix) with ESMTP id 2BA97C9005A
	for <linux-nfs@vger.kernel.org>; Mon,  5 Mar 2012 15:27:02 -0500 (EST)
Received: from d03av05.boulder.ibm.com (d03av05.boulder.ibm.com [9.17.195.85])
	by d01relay05.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q25KR1sW209362
	for <linux-nfs@vger.kernel.org>; Mon, 5 Mar 2012 15:27:01 -0500
Received: from d03av05.boulder.ibm.com (loopback [127.0.0.1])
	by d03av05.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q25KQu89007200
	for <linux-nfs@vger.kernel.org>; Mon, 5 Mar 2012 13:26:56 -0700
From: Matthew Treinish <treinish@linux.vnet.ibm.com>
To: linux-nfs@vger.kernel.org
Cc: treinish@linux.vnet.ibm.com
Subject: [PATCH/RFC v3 03/10] Store root dentry in server object
Date: Mon,  5 Mar 2012 15:26:44 -0500
Message-Id: <1330979211-894-4-git-send-email-treinish@linux.vnet.ibm.com>
In-Reply-To: <1330979211-894-1-git-send-email-treinish@linux.vnet.ibm.com>
References: <1330979211-894-1-git-send-email-treinish@linux.vnet.ibm.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This is needed for vfh migration/replication recovery and recovering
from FHEXPIRED returned during getattr. It will be used as
a starting point for dcache traversal.

Signed-off-by: Matthew Treinish <treinish@linux.vnet.ibm.com>
---
 fs/nfs/getroot.c          |    1 +
 fs/nfs/super.c            |    1 +
 include/linux/nfs_fs_sb.h |    1 +
 3 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/fs/nfs/getroot.c b/fs/nfs/getroot.c
index 51ca63b..8d07346 100644
--- a/fs/nfs/getroot.c
+++ b/fs/nfs/getroot.c
@@ -255,6 +255,7 @@ struct dentry *nfs4_get_root(struct super_block *sb, struct nfs_fh *mntfh,
 		dprintk("nfs_get_root: get root dentry failed\n");
 		goto out;
 	}
+	server->rootdentry = dget(ret);
 
 	security_d_instantiate(ret, inode);
 	spin_lock(&ret->d_lock);
diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index 6c0be34e..0b26768 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -2892,6 +2892,7 @@ static void nfs4_kill_super(struct super_block *sb)
 
 	dprintk("--> %s\n", __func__);
 	nfs_super_return_all_delegations(sb);
+	dput(server->rootdentry);
 	kill_anon_super(sb);
 	nfs_fscache_release_super_cookie(sb);
 	nfs_free_server(server);
diff --git a/include/linux/nfs_fs_sb.h b/include/linux/nfs_fs_sb.h
index 5993319..68155b1 100644
--- a/include/linux/nfs_fs_sb.h
+++ b/include/linux/nfs_fs_sb.h
@@ -154,6 +154,7 @@ struct nfs_server {
 	/* the following fields are protected by nfs_client->cl_lock */
 	struct rb_root		state_owners;
 #endif
+	struct dentry		*rootdentry;
 	struct ida		openowner_id;
 	struct ida		lockowner_id;
 	struct list_head	state_owners_lru;
-- 
1.7.4.4

