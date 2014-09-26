Return-Path: linux-nfs-owner@vger.kernel.org
Received: from casper.infradead.org ([85.118.1.10]:53899 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755167AbaIZOAa (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 26 Sep 2014 10:00:30 -0400
From: Christoph Hellwig <hch@lst.de>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH] pnfs/blocklayout: serialize GETDEVICEINFO calls
Date: Fri, 26 Sep 2014 16:02:50 +0200
Message-Id: <1411740170-18611-2-git-send-email-hch@lst.de>
In-Reply-To: <1411740170-18611-1-git-send-email-hch@lst.de>
References: <1411740170-18611-1-git-send-email-hch@lst.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The rpc_pipefs code isn't thread safe, leading to occasional use after
frees when running xfstests generic/241 (dbench).

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 fs/nfs/blocklayout/rpc_pipefs.c | 14 +++++++++-----
 fs/nfs/netns.h                  |  1 +
 2 files changed, 10 insertions(+), 5 deletions(-)

diff --git a/fs/nfs/blocklayout/rpc_pipefs.c b/fs/nfs/blocklayout/rpc_pipefs.c
index 8d04bda..da58ff7 100644
--- a/fs/nfs/blocklayout/rpc_pipefs.c
+++ b/fs/nfs/blocklayout/rpc_pipefs.c
@@ -65,17 +65,18 @@ bl_resolve_deviceid(struct nfs_server *server, struct pnfs_block_volume *b,
 
 	dprintk("%s CREATING PIPEFS MESSAGE\n", __func__);
 
+	mutex_lock(&nn->bl_mutex);
 	bl_pipe_msg.bl_wq = &nn->bl_wq;
 
 	b->simple.len += 4;	/* single volume */
 	if (b->simple.len > PAGE_SIZE)
-		return -EIO;
+		goto out_unlock;
 
 	memset(msg, 0, sizeof(*msg));
 	msg->len = sizeof(*bl_msg) + b->simple.len;
 	msg->data = kzalloc(msg->len, gfp_mask);
 	if (!msg->data)
-		goto out;
+		goto out_free_data;
 
 	bl_msg = msg->data;
 	bl_msg->type = BL_DEVICE_MOUNT,
@@ -87,7 +88,7 @@ bl_resolve_deviceid(struct nfs_server *server, struct pnfs_block_volume *b,
 	rc = rpc_queue_upcall(nn->bl_device_pipe, msg);
 	if (rc < 0) {
 		remove_wait_queue(&nn->bl_wq, &wq);
-		goto out;
+		goto out_free_data;
 	}
 
 	set_current_state(TASK_UNINTERRUPTIBLE);
@@ -98,12 +99,14 @@ bl_resolve_deviceid(struct nfs_server *server, struct pnfs_block_volume *b,
 	if (reply->status != BL_DEVICE_REQUEST_PROC) {
 		printk(KERN_WARNING "%s failed to decode device: %d\n",
 			__func__, reply->status);
-		goto out;
+		goto out_free_data;
 	}
 
 	dev = MKDEV(reply->major, reply->minor);
-out:
+out_free_data:
 	kfree(msg->data);
+out_unlock:
+	mutex_unlock(&nn->bl_mutex);
 	return dev;
 }
 
@@ -233,6 +236,7 @@ static int nfs4blocklayout_net_init(struct net *net)
 	struct nfs_net *nn = net_generic(net, nfs_net_id);
 	struct dentry *dentry;
 
+	mutex_init(&nn->bl_mutex);
 	init_waitqueue_head(&nn->bl_wq);
 	nn->bl_device_pipe = rpc_mkpipe_data(&bl_upcall_ops, 0);
 	if (IS_ERR(nn->bl_device_pipe))
diff --git a/fs/nfs/netns.h b/fs/nfs/netns.h
index ef221fb..f0e06e4 100644
--- a/fs/nfs/netns.h
+++ b/fs/nfs/netns.h
@@ -19,6 +19,7 @@ struct nfs_net {
 	struct rpc_pipe *bl_device_pipe;
 	struct bl_dev_msg bl_mount_reply;
 	wait_queue_head_t bl_wq;
+	struct mutex bl_mutex;
 	struct list_head nfs_client_list;
 	struct list_head nfs_volume_list;
 #if IS_ENABLED(CONFIG_NFS_V4)
-- 
1.9.1

