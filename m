Return-Path: <linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-13.8 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_CR_TRAILER,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 71492C433DB
	for <linux-nfs@archiver.kernel.org>; Wed,  3 Feb 2021 20:08:30 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by mail.kernel.org (Postfix) with ESMTP id 156CF64F68
	for <linux-nfs@archiver.kernel.org>; Wed,  3 Feb 2021 20:08:30 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S231638AbhBCUIL (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 3 Feb 2021 15:08:11 -0500
Received: from mail.kernel.org ([198.145.29.99]:47812 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S231710AbhBCUIG (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 3 Feb 2021 15:08:06 -0500
Received: by mail.kernel.org (Postfix) with ESMTPSA id 17E1B64F8C;
        Wed,  3 Feb 2021 20:07:23 +0000 (UTC)
Subject: [PATCH v3 6/6] rpcrdma: Capture bytes received in Receive completion
 tracepoints
From:   Chuck Lever <chuck.lever@oracle.com>
To:     linux-nfs@vger.kernel.org, linux-rdma@vger.kernel.org
Date:   Wed, 03 Feb 2021 15:07:22 -0500
Message-ID: <161238284222.946943.6448113979992092756.stgit@manet.1015granger.net>
In-Reply-To: <161238257595.946943.6571271028482175652.stgit@manet.1015granger.net>
References: <161238257595.946943.6571271028482175652.stgit@manet.1015granger.net>
User-Agent: StGit/0.23-29-ga622f1
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Make it easier to spot messages of an unusual size.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
Acked-by: Tom Talpey <tom@talpey.com>
---
 include/trace/events/rpcrdma.h |   50 ++++++++++++++++++++++++++++++++++++++--
 1 file changed, 48 insertions(+), 2 deletions(-)

diff --git a/include/trace/events/rpcrdma.h b/include/trace/events/rpcrdma.h
index 76e85e16854b..c838e7ac1c2d 100644
--- a/include/trace/events/rpcrdma.h
+++ b/include/trace/events/rpcrdma.h
@@ -60,6 +60,51 @@ DECLARE_EVENT_CLASS(rpcrdma_completion_class,
 				),					\
 				TP_ARGS(wc, cid))
 
+DECLARE_EVENT_CLASS(rpcrdma_receive_completion_class,
+	TP_PROTO(
+		const struct ib_wc *wc,
+		const struct rpc_rdma_cid *cid
+	),
+
+	TP_ARGS(wc, cid),
+
+	TP_STRUCT__entry(
+		__field(u32, cq_id)
+		__field(int, completion_id)
+		__field(u32, received)
+		__field(unsigned long, status)
+		__field(unsigned int, vendor_err)
+	),
+
+	TP_fast_assign(
+		__entry->cq_id = cid->ci_queue_id;
+		__entry->completion_id = cid->ci_completion_id;
+		__entry->status = wc->status;
+		if (wc->status) {
+			__entry->received = 0;
+			__entry->vendor_err = wc->vendor_err;
+		} else {
+			__entry->received = wc->byte_len;
+			__entry->vendor_err = 0;
+		}
+	),
+
+	TP_printk("cq.id=%u cid=%d status=%s (%lu/0x%x) received=%u",
+		__entry->cq_id, __entry->completion_id,
+		rdma_show_wc_status(__entry->status),
+		__entry->status, __entry->vendor_err,
+		__entry->received
+	)
+);
+
+#define DEFINE_RECEIVE_COMPLETION_EVENT(name)				\
+		DEFINE_EVENT(rpcrdma_receive_completion_class, name,	\
+				TP_PROTO(				\
+					const struct ib_wc *wc,		\
+					const struct rpc_rdma_cid *cid	\
+				),					\
+				TP_ARGS(wc, cid))
+
 DECLARE_EVENT_CLASS(xprtrdma_reply_class,
 	TP_PROTO(
 		const struct rpcrdma_rep *rep
@@ -838,7 +883,8 @@ TRACE_EVENT(xprtrdma_post_linv_err,
  ** Completion events
  **/
 
-DEFINE_COMPLETION_EVENT(xprtrdma_wc_receive);
+DEFINE_RECEIVE_COMPLETION_EVENT(xprtrdma_wc_receive);
+
 DEFINE_COMPLETION_EVENT(xprtrdma_wc_send);
 DEFINE_COMPLETION_EVENT(xprtrdma_wc_fastreg);
 DEFINE_COMPLETION_EVENT(xprtrdma_wc_li);
@@ -1790,7 +1836,7 @@ TRACE_EVENT(svcrdma_post_recv,
 	)
 );
 
-DEFINE_COMPLETION_EVENT(svcrdma_wc_receive);
+DEFINE_RECEIVE_COMPLETION_EVENT(svcrdma_wc_receive);
 
 TRACE_EVENT(svcrdma_rq_post_err,
 	TP_PROTO(


