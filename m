From: William Lee Irwin III <wli@holomorphy.com>
Subject: fix nfs_writeback_done() warning
Date: Fri, 17 Jan 2003 01:15:03 -0800
Sender: linux-kernel-owner@vger.kernel.org
Message-ID: <20030117091503.GE940@holomorphy.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+linux-kernel=40quimby.gnus.org@vger.kernel.org>
To: nfs@lists.sourceforge.net
List-ID: <nfs.lists.sourceforge.net>

I get complaints about an unused variable "inode". This removes
the variable and open-codes the dereference to data->inode, hence
fixing the warning.


diff -urpN mm1-2.5.59/fs/nfs/write.c numaq-2.5.59/fs/nfs/write.c
--- mm1-2.5.59/fs/nfs/write.c	2003-01-16 18:22:26.000000000 -0800
+++ numaq-2.5.59/fs/nfs/write.c	2003-01-17 01:12:29.000000000 -0800
@@ -829,7 +829,6 @@ nfs_writeback_done(struct rpc_task *task
 	struct nfs_write_data	*data = (struct nfs_write_data *) task->tk_calldata;
 	struct nfs_writeargs	*argp = &data->args;
 	struct nfs_writeres	*resp = &data->res;
-	struct inode		*inode = data->inode;
 	struct nfs_page		*req;
 	struct page		*page;
 
@@ -863,7 +862,7 @@ nfs_writeback_done(struct rpc_task *task
 		if (time_before(complain, jiffies)) {
 			dprintk("NFS: faulty NFS server %s:"
 				" (committed = %d) != (stable = %d)\n",
-				NFS_SERVER(inode)->hostname,
+				NFS_SERVER(data->inode)->hostname,
 				data->verf.committed, argp->stable);
 			complain = jiffies + 300 * HZ;
 		}
