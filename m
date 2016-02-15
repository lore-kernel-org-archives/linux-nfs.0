Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ig0-f181.google.com ([209.85.213.181]:38612 "EHLO
	mail-ig0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751178AbcBOPYC (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 15 Feb 2016 10:24:02 -0500
Received: by mail-ig0-f181.google.com with SMTP id y8so56945888igp.1
        for <linux-nfs@vger.kernel.org>; Mon, 15 Feb 2016 07:24:02 -0800 (PST)
Subject: [PATCH] xprtrdma: rpcrdma_bc_receive_call() should init
 rq_private_buf.len
From: Chuck Lever <chuck.lever@oracle.com>
To: anna.schumaker@netapp.com
Cc: linux-nfs@vger.kernel.org
Date: Mon, 15 Feb 2016 10:23:59 -0500
Message-ID: <20160215152040.22738.95129.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Some NFSv4.1 OPEN requests were hanging waiting for the NFS server
to finish recalling delegations. Turns out that each NFSv4.1 CB
request on RDMA gets a GARBAGE_ARGS reply from the Linux client.

Commit 756b9b37cfb2e3dc added a line in bc_svc_process that
overwrites the incoming rq_rcv_buf's length with the value in
rq_private_buf.len. But rpcrdma_bc_receive_call() does not invoke
xprt_complete_bc_request(), thus rq_private_buf.len is not
initialized. svc_process_common() is invoked with a zero-length
RPC message, and fails.

Fixes: 756b9b37cfb2e3dc ('SUNRPC: Fix callback channel')
Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
Hi Anna-

Commit 756b9b37cfb2e3dc in v4.5-rc1 introduced a behavior
regression for NFSv4.1-over-RDMA. Would it be possible to merge
this bug fix into 4.5-rc ?


 net/sunrpc/xprtrdma/backchannel.c |    2 ++
 1 file changed, 2 insertions(+)

diff --git a/net/sunrpc/xprtrdma/backchannel.c b/net/sunrpc/xprtrdma/backchannel.c
index cc1251d..2dcd764 100644
--- a/net/sunrpc/xprtrdma/backchannel.c
+++ b/net/sunrpc/xprtrdma/backchannel.c
@@ -341,6 +341,8 @@ void rpcrdma_bc_receive_call(struct rpcrdma_xprt *r_xprt,
 	rqst->rq_reply_bytes_recvd = 0;
 	rqst->rq_bytes_sent = 0;
 	rqst->rq_xid = headerp->rm_xid;
+
+	rqst->rq_private_buf.len = size;
 	set_bit(RPC_BC_PA_IN_USE, &rqst->rq_bc_pa_state);
 
 	buf = &rqst->rq_rcv_buf;

