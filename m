Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f182.google.com ([209.85.223.182]:36076 "EHLO
	mail-io0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753593AbbLNVR4 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 14 Dec 2015 16:17:56 -0500
Subject: [PATCH v3 02/11] xprtrdma: xprt_rdma_free() must not release
 backchannel reqs
From: Chuck Lever <chuck.lever@oracle.com>
To: anna.schumaker@netapp.com
Cc: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Mon, 14 Dec 2015 16:17:54 -0500
Message-ID: <20151214211754.16295.84487.stgit@manet.1015granger.net>
In-Reply-To: <20151214211317.16295.70115.stgit@manet.1015granger.net>
References: <20151214211317.16295.70115.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Preserve any rpcrdma_req that is attached to rpc_rqst's allocated
for the backchannel. Otherwise, after all the pre-allocated
backchannel req's are consumed, incoming backward calls start
writing on freed memory.

Somehow this hunk got lost.

Fixes: f531a5dbc451 ('xprtrdma: Pre-allocate backward rpc_rqst')
Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 net/sunrpc/xprtrdma/transport.c |    3 +++
 1 file changed, 3 insertions(+)

diff --git a/net/sunrpc/xprtrdma/transport.c b/net/sunrpc/xprtrdma/transport.c
index 8c545f7..740bddc 100644
--- a/net/sunrpc/xprtrdma/transport.c
+++ b/net/sunrpc/xprtrdma/transport.c
@@ -576,6 +576,9 @@ xprt_rdma_free(void *buffer)
 
 	rb = container_of(buffer, struct rpcrdma_regbuf, rg_base[0]);
 	req = rb->rg_owner;
+	if (req->rl_backchannel)
+		return;
+
 	r_xprt = container_of(req->rl_buffer, struct rpcrdma_xprt, rx_buf);
 
 	dprintk("RPC:       %s: called on 0x%p\n", __func__, req->rl_reply);

