From: William Lee Irwin III <wli@holomorphy.com>
Subject: nfs/write.c warning
Date: Sat, 4 Jan 2003 03:59:26 -0800
Sender: linux-kernel-owner@vger.kernel.org
Message-ID: <20030104115926.GF10697@holomorphy.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net, trivial@rustcorp.com.au
Return-path: <linux-kernel-owner+linux-kernel=40quimby.gnus.org@vger.kernel.org>
To: linux-kernel@vger.kernel.org
List-ID: <nfs.lists.sourceforge.net>

This trivially corrects an unused variable warning in nfs/write.c:


diff -urpN mm2-2.5.54-1/fs/nfs/write.c mm2-2.5.54-2/fs/nfs/write.c
--- mm2-2.5.54-1/fs/nfs/write.c	2003-01-01 19:22:39.000000000 -0800
+++ mm2-2.5.54-2/fs/nfs/write.c	2003-01-03 03:31:09.000000000 -0800
@@ -828,7 +828,6 @@ nfs_writeback_done(struct rpc_task *task
 	struct nfs_write_data	*data = (struct nfs_write_data *) task->tk_calldata;
 	struct nfs_writeargs	*argp = &data->args;
 	struct nfs_writeres	*resp = &data->res;
-	struct inode		*inode = data->inode;
 	struct nfs_page		*req;
 	struct page		*page;
 
@@ -862,7 +861,7 @@ nfs_writeback_done(struct rpc_task *task
 		if (time_before(complain, jiffies)) {
 			dprintk("NFS: faulty NFS server %s:"
 				" (committed = %d) != (stable = %d)\n",
-				NFS_SERVER(inode)->hostname,
+				NFS_SERVER(data->inode)->hostname,
 				data->verf.committed, argp->stable);
 			complain = jiffies + 300 * HZ;
 		}
