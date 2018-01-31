Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f66.google.com ([209.85.214.66]:52984 "EHLO
        mail-it0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753158AbeAaReP (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 31 Jan 2018 12:34:15 -0500
Subject: [PATCH 2/2] xprtrdma: Fix BUG after a device removal
From: Chuck Lever <chuck.lever@oracle.com>
To: anna.schumaker@netapp.com
Cc: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Wed, 31 Jan 2018 12:34:13 -0500
Message-ID: <20180131173413.11367.40311.stgit@manet.1015granger.net>
In-Reply-To: <20180131173308.11367.93367.stgit@manet.1015granger.net>
References: <20180131173308.11367.93367.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Michal Kalderon reports a BUG that occurs just after device removal:

[  169.112490] rpcrdma: removing device qedr0 for 192.168.110.146:20049
[  169.143909] BUG: unable to handle kernel NULL pointer dereference at 0000000000000010
[  169.181837] IP: rpcrdma_dma_unmap_regbuf+0xa/0x60 [rpcrdma]

The RPC/RDMA client transport attempts to allocate some resources
on demand. Registered buffers are one such resource. These are
allocated (or re-allocated) by xprt_rdma_allocate to hold RPC Call
and Reply messages. A hardware resource is associated with each of
these buffers, as they can be used for a Send or Receive Work
Request.

If a device is removed from under an NFS/RDMA mount, the transport
layer is responsible for releasing all hardware resources before
the device can be finally unplugged. A BUG results when the NFS
mount hasn't yet seen much activity: the transport tries to release
resources that haven't yet been allocated.

rpcrdma_free_regbuf() already checks for this case, so just move
that check to cover the DEVICE_REMOVAL case as well.

Reported-by: Michal Kalderon <Michal.Kalderon@cavium.com>
Fixes: bebd031866ca ("xprtrdma: Support unplugging an HCA ...")
Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
Tested-by: Michal Kalderon <Michal.Kalderon@cavium.com>
---
 net/sunrpc/xprtrdma/verbs.c |    6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/net/sunrpc/xprtrdma/verbs.c b/net/sunrpc/xprtrdma/verbs.c
index bb56b9d..e6f84a6 100644
--- a/net/sunrpc/xprtrdma/verbs.c
+++ b/net/sunrpc/xprtrdma/verbs.c
@@ -1502,6 +1502,9 @@ struct rpcrdma_regbuf *
 static void
 rpcrdma_dma_unmap_regbuf(struct rpcrdma_regbuf *rb)
 {
+	if (!rb)
+		return;
+
 	if (!rpcrdma_regbuf_is_mapped(rb))
 		return;
 
@@ -1517,9 +1520,6 @@ struct rpcrdma_regbuf *
 void
 rpcrdma_free_regbuf(struct rpcrdma_regbuf *rb)
 {
-	if (!rb)
-		return;
-
 	rpcrdma_dma_unmap_regbuf(rb);
 	kfree(rb);
 }

