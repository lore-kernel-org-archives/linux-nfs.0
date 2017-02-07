Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f68.google.com ([209.85.214.68]:33439 "EHLO
        mail-it0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932163AbdBGQ6u (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 7 Feb 2017 11:58:50 -0500
Subject: [PATCH v3 5/7] svcrdma: Remove unused sc_dto_q field
From: Chuck Lever <chuck.lever@oracle.com>
To: bfields@fieldses.org
Cc: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Tue, 07 Feb 2017 11:58:48 -0500
Message-ID: <20170207165848.14422.69070.stgit@klimt.1015granger.net>
In-Reply-To: <20170207165131.14422.47088.stgit@klimt.1015granger.net>
References: <20170207165131.14422.47088.stgit@klimt.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Clean up. Commit be99bb11400c ("svcrdma: Use new CQ API for
RPC-over-RDMA server send CQs") removed code that used the sc_dto_q
field, but neglected to remove sc_dto_q at the same time.

Fixes: be99bb11400c ("svcrdma: Use new CQ API for RPC-over- ...")
Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
Reviewed-by: Christoph Hellwig <hch@lst.de>
---
 include/linux/sunrpc/svc_rdma.h          |    1 -
 net/sunrpc/xprtrdma/svc_rdma_transport.c |    1 -
 2 files changed, 2 deletions(-)

diff --git a/include/linux/sunrpc/svc_rdma.h b/include/linux/sunrpc/svc_rdma.h
index 25ecf92..f77a7bc 100644
--- a/include/linux/sunrpc/svc_rdma.h
+++ b/include/linux/sunrpc/svc_rdma.h
@@ -172,7 +172,6 @@ struct svcxprt_rdma {
 
 	wait_queue_head_t    sc_send_wait;	/* SQ exhaustion waitlist */
 	unsigned long	     sc_flags;
-	struct list_head     sc_dto_q;		/* DTO tasklet I/O pending Q */
 	struct list_head     sc_read_complete_q;
 	struct work_struct   sc_work;
 };
diff --git a/net/sunrpc/xprtrdma/svc_rdma_transport.c b/net/sunrpc/xprtrdma/svc_rdma_transport.c
index 174928f..023eaa0 100644
--- a/net/sunrpc/xprtrdma/svc_rdma_transport.c
+++ b/net/sunrpc/xprtrdma/svc_rdma_transport.c
@@ -557,7 +557,6 @@ static struct svcxprt_rdma *rdma_create_xprt(struct svc_serv *serv,
 		return NULL;
 	svc_xprt_init(&init_net, &svc_rdma_class, &cma_xprt->sc_xprt, serv);
 	INIT_LIST_HEAD(&cma_xprt->sc_accept_q);
-	INIT_LIST_HEAD(&cma_xprt->sc_dto_q);
 	INIT_LIST_HEAD(&cma_xprt->sc_rq_dto_q);
 	INIT_LIST_HEAD(&cma_xprt->sc_read_complete_q);
 	INIT_LIST_HEAD(&cma_xprt->sc_frmr_q);

