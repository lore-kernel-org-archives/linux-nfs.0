Return-Path: <SRS0=EkhZ=X2=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-10.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4468EECE58A
	for <linux-nfs@archiver.kernel.org>; Tue,  1 Oct 2019 17:03:04 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 11D162086A
	for <linux-nfs@archiver.kernel.org>; Tue,  1 Oct 2019 17:03:04 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1569949384;
	bh=hWFw/mm/IjB//DvfFJsOpdoICftIKYGQelaXG5osxR0=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References:List-ID:From;
	b=o67Tr6miEoEs7CPVrjrmTIalkgI5n2xCFHHGpog+brctuJC1F3XABVieVaX2Q/ZRr
	 Cy1qdF3YUfKrge20yoVz2eVRVn/6q0hutBX9vPuLijhvFbt0DemuoTb+nfxoPY4ufI
	 ceYc4Yqc5knge29yB8V7l/sP1ou4NuTtFkvvv53Y=
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1729042AbfJAQj6 (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 1 Oct 2019 12:39:58 -0400
Received: from mail.kernel.org ([198.145.29.99]:51098 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1728879AbfJAQj6 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 1 Oct 2019 12:39:58 -0400
Received: from sasha-vm.mshome.net (c-73-47-72-35.hsd1.nh.comcast.net [73.47.72.35])
        (using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
        (No client certificate requested)
        by mail.kernel.org (Postfix) with ESMTPSA id 79F25222C3;
        Tue,  1 Oct 2019 16:39:56 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
        s=default; t=1569947997;
        bh=hWFw/mm/IjB//DvfFJsOpdoICftIKYGQelaXG5osxR0=;
        h=From:To:Cc:Subject:Date:In-Reply-To:References:From;
        b=E8sm2+wBGCvobQTuZNtL0uZokilV4a0A8eNwLY6FVOM3JanrYTNhi44DMfLut5l7j
         rzwSyimhfP/3iWCqv8b4m/89tyOfUbVcNLAPCXyOfg+ragQglFrAXKBENM5Ke/JtCu
         rPyytnaZ0pzThZhj+H5BzQOyETsFuiLbArl9pus4=
From:   Sasha Levin <sashal@kernel.org>
To:     linux-kernel@vger.kernel.org, stable@vger.kernel.org
Cc:     Trond Myklebust <trondmy@gmail.com>,
        Trond Myklebust <trond.myklebust@hammerspace.com>,
        Anna Schumaker <Anna.Schumaker@Netapp.com>,
        Sasha Levin <sashal@kernel.org>, linux-nfs@vger.kernel.org,
        netdev@vger.kernel.org
Subject: [PATCH AUTOSEL 5.3 23/71] SUNRPC: Don't try to parse incomplete RPC messages
Date:   Tue,  1 Oct 2019 12:38:33 -0400
Message-Id: <20191001163922.14735-23-sashal@kernel.org>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20191001163922.14735-1-sashal@kernel.org>
References: <20191001163922.14735-1-sashal@kernel.org>
MIME-Version: 1.0
X-stable: review
X-Patchwork-Hint: Ignore
Content-Transfer-Encoding: 8bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

From: Trond Myklebust <trondmy@gmail.com>

[ Upstream commit 9ba828861c56a21d211d5d10f5643774b1ea330d ]

If the copy of the RPC reply into our buffers did not complete, and
we could end up with a truncated message. In that case, just resend
the call.

Fixes: a0584ee9aed80 ("SUNRPC: Use struct xdr_stream when decoding...")
Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>
Signed-off-by: Anna Schumaker <Anna.Schumaker@Netapp.com>
Signed-off-by: Sasha Levin <sashal@kernel.org>
---
 net/sunrpc/clnt.c | 14 +++++++++++++-
 1 file changed, 13 insertions(+), 1 deletion(-)

diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
index 76e745ff78138..d8136b829804f 100644
--- a/net/sunrpc/clnt.c
+++ b/net/sunrpc/clnt.c
@@ -2479,6 +2479,7 @@ call_decode(struct rpc_task *task)
 	struct rpc_clnt	*clnt = task->tk_client;
 	struct rpc_rqst	*req = task->tk_rqstp;
 	struct xdr_stream xdr;
+	int err;
 
 	dprint_status(task);
 
@@ -2501,6 +2502,15 @@ call_decode(struct rpc_task *task)
 	 * before it changed req->rq_reply_bytes_recvd.
 	 */
 	smp_rmb();
+
+	/*
+	 * Did we ever call xprt_complete_rqst()? If not, we should assume
+	 * the message is incomplete.
+	 */
+	err = -EAGAIN;
+	if (!req->rq_reply_bytes_recvd)
+		goto out;
+
 	req->rq_rcv_buf.len = req->rq_private_buf.len;
 
 	/* Check that the softirq receive buffer is valid */
@@ -2509,7 +2519,9 @@ call_decode(struct rpc_task *task)
 
 	xdr_init_decode(&xdr, &req->rq_rcv_buf,
 			req->rq_rcv_buf.head[0].iov_base, req);
-	switch (rpc_decode_header(task, &xdr)) {
+	err = rpc_decode_header(task, &xdr);
+out:
+	switch (err) {
 	case 0:
 		task->tk_action = rpc_exit_task;
 		task->tk_status = rpcauth_unwrap_resp(task, &xdr);
-- 
2.20.1

