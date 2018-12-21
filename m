Return-Path: <SRS0=HAHT=O6=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 085FDC43387
	for <linux-nfs@archiver.kernel.org>; Fri, 21 Dec 2018 17:36:03 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id D914C21917
	for <linux-nfs@archiver.kernel.org>; Fri, 21 Dec 2018 17:36:02 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S2390932AbeLURgB (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Fri, 21 Dec 2018 12:36:01 -0500
Received: from relay.sw.ru ([185.231.240.75]:40940 "EHLO relay.sw.ru"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1730364AbeLURgB (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 21 Dec 2018 12:36:01 -0500
Received: from [172.16.24.21]
        by relay.sw.ru with esmtp (Exim 4.91)
        (envelope-from <vvs@virtuozzo.com>)
        id 1gaOiM-0004vo-Ax; Fri, 21 Dec 2018 20:35:58 +0300
From:   Vasily Averin <vvs@virtuozzo.com>
Subject: [PATCH v3 6/8] sunrpc: make visible processing error in
 bc_svc_process()
To:     Trond Myklebust <trond.myklebust@hammerspace.com>,
        Anna Schumaker <anna.schumaker@netapp.com>
Cc:     "J. Bruce Fields" <bfields@fieldses.org>,
        Jeff Layton <jlayton@kernel.org>,
        Chuck Lever <chuck.lever@oracle.com>,
        linux-nfs@vger.kernel.org,
        Evgenii Shatokhin <eshatokhin@virtuozzo.com>
References: <cover.1545412216.git.vvs@virtuozzo.com>
Message-ID: <da03cb94-7212-8780-7937-12f206bdc83a@virtuozzo.com>
Date:   Fri, 21 Dec 2018 20:35:57 +0300
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.2.1
MIME-Version: 1.0
In-Reply-To: <cover.1545412216.git.vvs@virtuozzo.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Signed-off-by: Vasily Averin <vvs@virtuozzo.com>
---
 net/sunrpc/svc.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/sunrpc/svc.c b/net/sunrpc/svc.c
index 4cf0f0776179..baeade37b0a0 100644
--- a/net/sunrpc/svc.c
+++ b/net/sunrpc/svc.c
@@ -1507,9 +1507,9 @@ bc_svc_process(struct svc_serv *serv, struct rpc_rqst *req,
 	if (!proc_error) {
 		/* Processing error: drop the request */
 		xprt_free_bc_request(req);
-		return 0;
+		error = -EINVAL;
+		goto out;
 	}
-
 	/* Finally, send the reply synchronously */
 	memcpy(&req->rq_snd_buf, &rqstp->rq_res, sizeof(req->rq_snd_buf));
 	task = rpc_run_bc_task(req);
-- 
2.17.1

