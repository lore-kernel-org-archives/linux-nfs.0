Return-Path: <linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-13.8 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_CR_TRAILER,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BD9D6C433ED
	for <linux-nfs@archiver.kernel.org>; Wed, 31 Mar 2021 19:37:31 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by mail.kernel.org (Postfix) with ESMTP id 95C016100C
	for <linux-nfs@archiver.kernel.org>; Wed, 31 Mar 2021 19:37:31 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S236268AbhCaThB (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 31 Mar 2021 15:37:01 -0400
Received: from mail.kernel.org ([198.145.29.99]:44544 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S235975AbhCaTgg (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 31 Mar 2021 15:36:36 -0400
Received: by mail.kernel.org (Postfix) with ESMTPSA id 5F02D6101E;
        Wed, 31 Mar 2021 19:36:36 +0000 (UTC)
Subject: [PATCH v1 6/8] xprtrdma: Improve locking around rpcrdma_rep creation
From:   Chuck Lever <chuck.lever@oracle.com>
To:     linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date:   Wed, 31 Mar 2021 15:36:35 -0400
Message-ID: <161721939561.515226.1183996972792305822.stgit@manet.1015granger.net>
In-Reply-To: <161721926778.515226.9805598788670386587.stgit@manet.1015granger.net>
References: <161721926778.515226.9805598788670386587.stgit@manet.1015granger.net>
User-Agent: StGit/0.23-29-ga622f1
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Serialize the use of the rb_all_reps list during rep creation and
destruction.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 net/sunrpc/xprtrdma/verbs.c |    9 +++++----
 1 file changed, 5 insertions(+), 4 deletions(-)

diff --git a/net/sunrpc/xprtrdma/verbs.c b/net/sunrpc/xprtrdma/verbs.c
index b68fc81a78fb..2fde805edb64 100644
--- a/net/sunrpc/xprtrdma/verbs.c
+++ b/net/sunrpc/xprtrdma/verbs.c
@@ -956,13 +956,11 @@ static void rpcrdma_reqs_reset(struct rpcrdma_xprt *r_xprt)
 		rpcrdma_req_reset(req);
 }
 
-/* No locking needed here. This function is called only by the
- * Receive completion handler.
- */
 static noinline
 struct rpcrdma_rep *rpcrdma_rep_create(struct rpcrdma_xprt *r_xprt,
 				       bool temp)
 {
+	struct rpcrdma_buffer *buf = &r_xprt->rx_buf;
 	struct rpcrdma_rep *rep;
 
 	rep = kzalloc(sizeof(*rep), GFP_KERNEL);
@@ -989,7 +987,10 @@ struct rpcrdma_rep *rpcrdma_rep_create(struct rpcrdma_xprt *r_xprt,
 	rep->rr_recv_wr.sg_list = &rep->rr_rdmabuf->rg_iov;
 	rep->rr_recv_wr.num_sge = 1;
 	rep->rr_temp = temp;
-	list_add(&rep->rr_all, &r_xprt->rx_buf.rb_all_reps);
+
+	spin_lock(&buf->rb_lock);
+	list_add(&rep->rr_all, &buf->rb_all_reps);
+	spin_unlock(&buf->rb_lock);
 	return rep;
 
 out_free_regbuf:


