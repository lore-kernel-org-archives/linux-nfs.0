Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-wy0-f174.google.com ([74.125.82.174]:33095 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751350Ab1KAGXs (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 1 Nov 2011 02:23:48 -0400
Subject: [PATCH] nfs: Remove unused variable from write.c
From: Rakib Mullick <rakib.mullick@gmail.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org,
        akpm@linux-foundation.org
Content-Type: text/plain; charset="UTF-8"
Date: Tue, 01 Nov 2011 12:23:42 +0600
Message-ID: <1320128622.3340.6.camel@localhost.localdomain>
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

When CONFIG_NFS=y and CONFIG_NFS_V3_{,V4}=n we get the following warning.
	
	fs/nfs/write.c: In function ‘nfs_writeback_done’:
	fs/nfs/write.c:1246:21: warning: unused variable ‘server’

 Remove the variable 'server' to fix the above warning.


Signed-off-by: Rakib Mullick <rakib.mullick@gmail.com>
---

diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index 2219c88..77a8c32 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -1243,7 +1243,6 @@ void nfs_writeback_done(struct rpc_task *task, struct nfs_write_data *data)
 {
 	struct nfs_writeargs	*argp = &data->args;
 	struct nfs_writeres	*resp = &data->res;
-	struct nfs_server	*server = NFS_SERVER(data->inode);
 	int status;
 
 	dprintk("NFS: %5u nfs_writeback_done (status %d)\n",
@@ -1277,7 +1276,7 @@ void nfs_writeback_done(struct rpc_task *task, struct nfs_write_data *data)
 		if (time_before(complain, jiffies)) {
 			dprintk("NFS:       faulty NFS server %s:"
 				" (committed = %d) != (stable = %d)\n",
-				server->nfs_client->cl_hostname,
+			NFS_SERVER(data->inode)->nfs_client->cl_hostname,
 				resp->verf->committed, argp->stable);
 			complain = jiffies + 300 * HZ;
 		}


