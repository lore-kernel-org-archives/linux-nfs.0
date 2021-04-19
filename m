Return-Path: <linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-13.8 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_CR_TRAILER,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D52DDC433B4
	for <linux-nfs@archiver.kernel.org>; Mon, 19 Apr 2021 18:02:56 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by mail.kernel.org (Postfix) with ESMTP id AA32261001
	for <linux-nfs@archiver.kernel.org>; Mon, 19 Apr 2021 18:02:56 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S240548AbhDSSDZ (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 19 Apr 2021 14:03:25 -0400
Received: from mail.kernel.org ([198.145.29.99]:41160 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S240553AbhDSSDZ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 19 Apr 2021 14:03:25 -0400
Received: by mail.kernel.org (Postfix) with ESMTPSA id C2D5261107;
        Mon, 19 Apr 2021 18:02:54 +0000 (UTC)
Subject: [PATCH v3 12/26] xprtrdma: rpcrdma_mr_pop() already does
 list_del_init()
From:   Chuck Lever <chuck.lever@oracle.com>
To:     trondmy@hammerspace.com
Cc:     linux-nfs@vger.kernel.org, linux-rdma@vger.kernel.org
Date:   Mon, 19 Apr 2021 14:02:54 -0400
Message-ID: <161885537399.38598.8518849473861354102.stgit@manet.1015granger.net>
In-Reply-To: <161885481568.38598.16682844600209775665.stgit@manet.1015granger.net>
References: <161885481568.38598.16682844600209775665.stgit@manet.1015granger.net>
User-Agent: StGit/0.23-29-ga622f1
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

The rpcrdma_mr_pop() earlier in the function has already cleared
out mr_list, so it must not be done again in the error path.

Fixes: 847568942f93 ("xprtrdma: Remove fr_state")
Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 net/sunrpc/xprtrdma/frwr_ops.c |    1 -
 1 file changed, 1 deletion(-)

diff --git a/net/sunrpc/xprtrdma/frwr_ops.c b/net/sunrpc/xprtrdma/frwr_ops.c
index 132df9b59ab4..aca2228095db 100644
--- a/net/sunrpc/xprtrdma/frwr_ops.c
+++ b/net/sunrpc/xprtrdma/frwr_ops.c
@@ -576,7 +576,6 @@ void frwr_unmap_sync(struct rpcrdma_xprt *r_xprt, struct rpcrdma_req *req)
 		mr = container_of(frwr, struct rpcrdma_mr, frwr);
 		bad_wr = bad_wr->next;
 
-		list_del_init(&mr->mr_list);
 		frwr_mr_recycle(mr);
 	}
 }


