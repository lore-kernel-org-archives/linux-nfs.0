Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f66.google.com ([209.85.214.66]:33173 "EHLO
        mail-it0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753266AbcHVS7T (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 22 Aug 2016 14:59:19 -0400
Subject: [PATCH v2 3/6] svcrdma: Skip put_page() when send_reply() fails
From: Chuck Lever <chuck.lever@oracle.com>
To: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Mon, 22 Aug 2016 14:57:59 -0400
Message-ID: <20160822185759.12076.92949.stgit@klimt.1015granger.net>
In-Reply-To: <20160822185459.12076.43516.stgit@klimt.1015granger.net>
References: <20160822185459.12076.43516.stgit@klimt.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Message from syslogd@klimt at Aug 18 17:00:37 ...
 kernel:page:ffffea0020639b00 count:0 mapcount:0 mapping:          (null) index:0x0
Aug 18 17:00:37 klimt kernel: flags: 0x2fffff80000000()
Aug 18 17:00:37 klimt kernel: page dumped because: VM_BUG_ON_PAGE(page_ref_count(page) == 0)

Aug 18 17:00:37 klimt kernel: kernel BUG at /home/cel/src/linux/linux-2.6/include/linux/mm.h:445!
Aug 18 17:00:37 klimt kernel: RIP: 0010:[<ffffffffa05c21c1>] svc_rdma_sendto+0x641/0x820 [rpcrdma]

send_reply() assigns its page argument as the first page of ctxt. On
error, send_reply() already invokes svc_rdma_put_context(ctxt, 1);
which does a put_page() on that very page. No need to do that again
as svc_rdma_sendto exits.

Fixes: 3e1eeb980822 ("svcrdma: Close connection when a send error occurs")
Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 net/sunrpc/xprtrdma/svc_rdma_sendto.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/sunrpc/xprtrdma/svc_rdma_sendto.c b/net/sunrpc/xprtrdma/svc_rdma_sendto.c
index e5b49e6..3b95b19 100644
--- a/net/sunrpc/xprtrdma/svc_rdma_sendto.c
+++ b/net/sunrpc/xprtrdma/svc_rdma_sendto.c
@@ -621,7 +621,7 @@ int svc_rdma_sendto(struct svc_rqst *rqstp)
 	ret = send_reply(rdma, rqstp, res_page, rdma_resp, vec,
 			 inline_bytes);
 	if (ret < 0)
-		goto err1;
+		goto err0;
 
 	svc_rdma_put_req_map(rdma, vec);
 	dprintk("svcrdma: send_reply returns %d\n", ret);

