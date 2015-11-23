Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ig0-f169.google.com ([209.85.213.169]:37118 "EHLO
	mail-ig0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932065AbbKWWO4 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 23 Nov 2015 17:14:56 -0500
Subject: [PATCH v1 8/9] xprtrdma: Invalidate in the RPC reply handler
From: Chuck Lever <chuck.lever@oracle.com>
To: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Mon, 23 Nov 2015 17:14:55 -0500
Message-ID: <20151123221454.32702.76062.stgit@manet.1015granger.net>
In-Reply-To: <20151123220627.32702.62667.stgit@manet.1015granger.net>
References: <20151123220627.32702.62667.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

There is a window between the time the RPC reply handler wakes the
waiting RPC task and when xprt_release() invokes ops->buf_free.
During this time, memory regions containing the data payload may
still be accessed by a broken or malicious server, but the RPC
application has already been allowed access to the memory containing
the RPC request's data payloads.

The server should be fenced from client memory containing RPC data
payloads _before_ the RPC application is allowed to continue.

This change also more strongly enforces send queue accounting. There
is a maximum number of RPC calls allowed to be outstanding. When an
RPC/RDMA transport is set up, just enough send queue resources are
allocated to handle registration, Send, and invalidation WRs for
each those RPCs at the same time.

Before, additional RPC calls could be dispatched while invalidation
WRs were still consuming send WQEs. When invalidation WRs backed
up, dispatching additional RPCs resulted in a send queue overrun.

Now, the reply handler prevents RPC dispatch until invalidation is
complete. This prevents RPC call dispatch until there are enough
send queue resources to proceed.

Still to do: If an RPC exits early (say, ^C), the reply handler has
no opportunity to perform invalidation. Currently, xprt_rdma_free()
still frees remaining RDMA resources, which could deadlock.
Additional changes are needed to handle invalidation properly in this
case.

Reported-by: Jason Gunthorpe <jgunthorpe@obsidianresearch.com>
Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 net/sunrpc/xprtrdma/rpc_rdma.c |   10 ++++++++++
 1 file changed, 10 insertions(+)

diff --git a/net/sunrpc/xprtrdma/rpc_rdma.c b/net/sunrpc/xprtrdma/rpc_rdma.c
index d7b9156..4ad72ca 100644
--- a/net/sunrpc/xprtrdma/rpc_rdma.c
+++ b/net/sunrpc/xprtrdma/rpc_rdma.c
@@ -898,6 +898,16 @@ badheader:
 		break;
 	}
 
+	/* Invalidate and flush the data payloads before waking the
+	 * waiting application. This guarantees the memory region is
+	 * properly fenced from the server before the application
+	 * accesses the data. It also ensures proper send flow
+	 * control: waking the next RPC waits until this RPC has
+	 * relinquished all its Send Queue entries.
+	 */
+	if (req->rl_nchunks)
+		r_xprt->rx_ia.ri_ops->ro_unmap_sync(r_xprt, req);
+
 	credits = be32_to_cpu(headerp->rm_credit);
 	if (credits == 0)
 		credits = 1;	/* don't deadlock */

