Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f66.google.com ([209.85.214.66]:36141 "EHLO
	mail-it0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932285AbcFGTsb (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 7 Jun 2016 15:48:31 -0400
Subject: [PATCH v1 16/20] svc: Avoid garbage replies when pc_func() returns
 rpc_drop_reply
From: Chuck Lever <chuck.lever@oracle.com>
To: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Tue, 07 Jun 2016 15:48:30 -0400
Message-ID: <20160607194830.18401.33339.stgit@manet.1015granger.net>
In-Reply-To: <20160607194001.18401.88592.stgit@manet.1015granger.net>
References: <20160607194001.18401.88592.stgit@manet.1015granger.net>
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

