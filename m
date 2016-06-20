Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f196.google.com ([209.85.223.196]:35699 "EHLO
	mail-io0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755799AbcFTQZW (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 20 Jun 2016 12:25:22 -0400
Subject: [PATCH v3 23/25] svc: Avoid garbage replies when pc_func() returns
 rpc_drop_reply
From: Chuck Lever <chuck.lever@oracle.com>
To: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Mon, 20 Jun 2016 12:11:43 -0400
Message-ID: <20160620161143.10809.2958.stgit@manet.1015granger.net>
In-Reply-To: <20160620155751.10809.22262.stgit@manet.1015granger.net>
References: <20160620155751.10809.22262.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

If an RPC program does not set vs_dispatch and pc_func() returns
rpc_drop_reply, the server sends a reply anyway containing a single
word containing the value RPC_DROP_REPLY (in network byte-order, of
course). This is a nonsense RPC message.

Fixes: 9e701c610923 ("svcrpc: simpler request dropping")
Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 net/sunrpc/svc.c |    3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/net/sunrpc/svc.c b/net/sunrpc/svc.c
index cc98528..87290a5 100644
--- a/net/sunrpc/svc.c
+++ b/net/sunrpc/svc.c
@@ -1188,7 +1188,8 @@ svc_process_common(struct svc_rqst *rqstp, struct kvec *argv, struct kvec *resv)
 		*statp = procp->pc_func(rqstp, rqstp->rq_argp, rqstp->rq_resp);
 
 		/* Encode reply */
-		if (test_bit(RQ_DROPME, &rqstp->rq_flags)) {
+		if (*statp == rpc_drop_reply ||
+		    test_bit(RQ_DROPME, &rqstp->rq_flags)) {
 			if (procp->pc_release)
 				procp->pc_release(rqstp, NULL, rqstp->rq_resp);
 			goto dropit;

