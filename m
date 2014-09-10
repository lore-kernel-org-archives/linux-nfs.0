Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qc0-f170.google.com ([209.85.216.170]:52920 "EHLO
	mail-qc0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750937AbaIJNEE (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 10 Sep 2014 09:04:04 -0400
Received: by mail-qc0-f170.google.com with SMTP id l6so1005615qcy.1
        for <linux-nfs@vger.kernel.org>; Wed, 10 Sep 2014 06:04:02 -0700 (PDT)
From: Jeff Layton <jlayton@primarydata.com>
To: trond.myklebust@primarydata.com
Cc: linux-nfs@vger.kernel.org, mgorman@suse.de
Subject: [PATCH] nfs: fix RCU cl_xprt handling in nfs_swap_activate/deactivate
Date: Wed, 10 Sep 2014 09:03:55 -0400
Message-Id: <1410354235-24315-1-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

sparse says:

fs/nfs/file.c:543:60: warning: incorrect type in argument 1 (different address spaces)
fs/nfs/file.c:543:60:    expected struct rpc_xprt *xprt
fs/nfs/file.c:543:60:    got struct rpc_xprt [noderef] <asn:4>*cl_xprt
fs/nfs/file.c:548:53: warning: incorrect type in argument 1 (different address spaces)
fs/nfs/file.c:548:53:    expected struct rpc_xprt *xprt
fs/nfs/file.c:548:53:    got struct rpc_xprt [noderef] <asn:4>*cl_xprt

cl_xprt is RCU-managed, so we need to take care to dereference and use
it while holding the RCU read lock.

Cc: Mel Gorman <mgorman@suse.de>
Signed-off-by: Jeff Layton <jlayton@primarydata.com>
---
 fs/nfs/file.c | 16 ++++++++++++++--
 1 file changed, 14 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/file.c b/fs/nfs/file.c
index 524dd80d1898..fe7f6126a7d2 100644
--- a/fs/nfs/file.c
+++ b/fs/nfs/file.c
@@ -539,13 +539,25 @@ static int nfs_launder_page(struct page *page)
 static int nfs_swap_activate(struct swap_info_struct *sis, struct file *file,
 						sector_t *span)
 {
+	int ret;
+	struct rpc_clnt *clnt = NFS_CLIENT(file->f_mapping->host);
+
 	*span = sis->pages;
-	return xs_swapper(NFS_CLIENT(file->f_mapping->host)->cl_xprt, 1);
+
+	rcu_read_lock();
+	ret = xs_swapper(rcu_dereference(clnt->cl_xprt), 1);
+	rcu_read_unlock();
+
+	return ret;
 }
 
 static void nfs_swap_deactivate(struct file *file)
 {
-	xs_swapper(NFS_CLIENT(file->f_mapping->host)->cl_xprt, 0);
+	struct rpc_clnt *clnt = NFS_CLIENT(file->f_mapping->host);
+
+	rcu_read_lock();
+	xs_swapper(rcu_dereference(clnt->cl_xprt), 0);
+	rcu_read_unlock();
 }
 #endif
 
-- 
1.9.3

