Return-Path: <linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5707AC19F29
	for <linux-nfs@archiver.kernel.org>; Wed, 27 Jul 2022 19:29:50 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S230057AbiG0T3t (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 27 Jul 2022 15:29:49 -0400
Received: from lindbergh.monkeyblade.net ([23.128.96.19]:48680 "EHLO
        lindbergh.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S229618AbiG0T3s (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 27 Jul 2022 15:29:48 -0400
Received: from dfw.source.kernel.org (dfw.source.kernel.org [139.178.84.217])
        by lindbergh.monkeyblade.net (Postfix) with ESMTPS id 3EE4912D0A
        for <linux-nfs@vger.kernel.org>; Wed, 27 Jul 2022 12:29:48 -0700 (PDT)
Received: from smtp.kernel.org (relay.kernel.org [52.25.139.140])
        (using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
        (No client certificate requested)
        by dfw.source.kernel.org (Postfix) with ESMTPS id D70D361A7C
        for <linux-nfs@vger.kernel.org>; Wed, 27 Jul 2022 19:29:47 +0000 (UTC)
Received: by smtp.kernel.org (Postfix) with ESMTPSA id EE257C433C1
        for <linux-nfs@vger.kernel.org>; Wed, 27 Jul 2022 19:29:46 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
        s=k20201202; t=1658950187;
        bh=UqgQ8vmiIiPJA0Rw8P+Q1Z8dIHqbfKXi6y9/hhmegS0=;
        h=From:To:Subject:Date:From;
        b=N/bbvDcrPtDi16xDNAcNKfObTXwhC3/3NvXLmzzH2pza6Wi8jEkytfNt8RpNISmgy
         RLUu8sYERlg3yBctnjFywLmj+aQh43cxUWrD+KwFr9sKnORUqsodT+G3+aa+8a/p28
         MDaK9Fq4oWK2b/cJ47HIYf12ajD2irDNL16TDYNn86wHgwSDwrKiikuxhjZf88w9Rm
         ujolPnD5txZ7pGZM9xTij7e7Oru2faPGNEE3EXkKY9GOJworT8jWGF5vLowPGnx01L
         zqyvegBcEWG+rchtQzKNRHb734VQzJSTx1Aa8FstKcrjtejc3xu+WCmfs3hB5MIlHF
         0oqUrHiY+9xFg==
From:   trondmy@kernel.org
To:     linux-nfs@vger.kernel.org
Subject: [PATCH] SUNRPC: Reinitialise the backchannel request buffers before reuse
Date:   Wed, 27 Jul 2022 15:23:20 -0400
Message-Id: <20220727192320.404427-1-trondmy@kernel.org>
X-Mailer: git-send-email 2.37.1
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

From: Trond Myklebust <trond.myklebust@hammerspace.com>

When we're reusing the backchannel requests instead of freeing them,
then we should reinitialise any values of the send/receive xdr_bufs so
that they reflect the available space.

Fixes: 0d2a970d0ae5 ("SUNRPC: Fix a backchannel race")
Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>
---
 net/sunrpc/backchannel_rqst.c | 14 ++++++++++++++
 1 file changed, 14 insertions(+)

diff --git a/net/sunrpc/backchannel_rqst.c b/net/sunrpc/backchannel_rqst.c
index 5a6b61dcdf2d..ad8ef1fb08b4 100644
--- a/net/sunrpc/backchannel_rqst.c
+++ b/net/sunrpc/backchannel_rqst.c
@@ -64,6 +64,17 @@ static void xprt_free_allocation(struct rpc_rqst *req)
 	kfree(req);
 }
 
+static void xprt_bc_reinit_xdr_buf(struct xdr_buf *buf)
+{
+	buf->head[0].iov_len = PAGE_SIZE;
+	buf->tail[0].iov_len = 0;
+	buf->pages = NULL;
+	buf->page_len = 0;
+	buf->flags = 0;
+	buf->len = 0;
+	buf->buflen = PAGE_SIZE;
+}
+
 static int xprt_alloc_xdr_buf(struct xdr_buf *buf, gfp_t gfp_flags)
 {
 	struct page *page;
@@ -292,6 +303,9 @@ void xprt_free_bc_rqst(struct rpc_rqst *req)
 	 */
 	spin_lock_bh(&xprt->bc_pa_lock);
 	if (xprt_need_to_requeue(xprt)) {
+		xprt_bc_reinit_xdr_buf(&req->rq_snd_buf);
+		xprt_bc_reinit_xdr_buf(&req->rq_rcv_buf);
+		req->rq_rcv_buf.len = PAGE_SIZE;
 		list_add_tail(&req->rq_bc_pa_list, &xprt->bc_pa_list);
 		xprt->bc_alloc_count++;
 		atomic_inc(&xprt->bc_slot_count);
-- 
2.37.1

