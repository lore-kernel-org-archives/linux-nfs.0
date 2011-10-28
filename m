Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qw0-f46.google.com ([209.85.216.46]:39864 "EHLO
	mail-qw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752577Ab1J1Kg5 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 28 Oct 2011 06:36:57 -0400
Subject: [PATCH] nfs: Fix unused variable warning.
From: Rakib Mullick <rakib.mullick@gmail.com>
To: linux-kernel@vger.kernel.org
Cc: linux-nfs@vger.kernel.org, Trond Myklebust <Trond.Myklebust@netapp.com>,
        akpm@linux-foundation.org
Content-Type: text/plain; charset="UTF-8"
Date: Fri, 28 Oct 2011 16:36:32 +0600
Message-ID: <1319798192.26450.1.camel@localhost.localdomain>
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

 When CONFIG_NFS=y, but CONFIG_NFS_V3_{,V4}=n we get the following warning:

	fs/nfs/write.c: In function ‘nfs_writeback_done’:
	fs/nfs/write.c:1246:21: warning: unused variable ‘server’

 This patch fixes it.

Signed-off-by: Rakib Mullick <rakib.mullick@gmail.com>
---

diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index 2219c88..e528e5c 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -1243,7 +1243,6 @@ void nfs_writeback_done(struct rpc_task *task, struct nfs_write_data *data)
 {
 	struct nfs_writeargs	*argp = &data->args;
 	struct nfs_writeres	*resp = &data->res;
-	struct nfs_server	*server = NFS_SERVER(data->inode);
 	int status;
 
 	dprintk("NFS: %5u nfs_writeback_done (status %d)\n",
@@ -1272,6 +1271,8 @@ void nfs_writeback_done(struct rpc_task *task, struct nfs_write_data *data)
 		 *	 as a dprintk() in order to avoid filling syslog.
 		 */
 		static unsigned long    complain;
+		struct nfs_server	*server;
+		server = NFS_SERVER(data->inode);
 
 		/* Note this will print the MDS for a DS write */
 		if (time_before(complain, jiffies)) {


