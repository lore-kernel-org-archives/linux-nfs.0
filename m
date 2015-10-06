Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ig0-f176.google.com ([209.85.213.176]:34890 "EHLO
	mail-ig0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750810AbbJFO6p (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 6 Oct 2015 10:58:45 -0400
Subject: [PATCH v2 01/16] xprtrdma: Enable swap-on-NFS/RDMA
From: Chuck Lever <chuck.lever@oracle.com>
To: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Tue, 06 Oct 2015 10:58:43 -0400
Message-ID: <20151006145842.11788.90380.stgit@manet.1015granger.net>
In-Reply-To: <20151006142430.11788.42604.stgit@manet.1015granger.net>
References: <20151006142430.11788.42604.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

After adding a swapfile on an NFS/RDMA mount and removing the
normal swap partition, I was able to push the NFS client well
into swap without any issue.

I forgot to swapoff the NFS file before rebooting. This pinned
the NFS mount and the IB core and provider, causing shutdown to
hang. I think this is expected and safe behavior. Probably
shutdown scripts should "swapoff -a" before unmounting any
filesystems.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 net/sunrpc/xprtrdma/transport.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/sunrpc/xprtrdma/transport.c b/net/sunrpc/xprtrdma/transport.c
index 41e452b..e9e5ed7 100644
--- a/net/sunrpc/xprtrdma/transport.c
+++ b/net/sunrpc/xprtrdma/transport.c
@@ -676,7 +676,7 @@ static void xprt_rdma_print_stats(struct rpc_xprt *xprt, struct seq_file *seq)
 static int
 xprt_rdma_enable_swap(struct rpc_xprt *xprt)
 {
-	return -EINVAL;
+	return 0;
 }
 
 static void

