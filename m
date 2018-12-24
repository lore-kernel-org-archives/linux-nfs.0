Return-Path: <SRS0=eAd3=PB=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 299DCC43387
	for <linux-nfs@archiver.kernel.org>; Mon, 24 Dec 2018 11:46:12 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 033B42176F
	for <linux-nfs@archiver.kernel.org>; Mon, 24 Dec 2018 11:46:11 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1725896AbeLXLqL (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 24 Dec 2018 06:46:11 -0500
Received: from relay.sw.ru ([185.231.240.75]:50724 "EHLO relay.sw.ru"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1725864AbeLXLqK (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 24 Dec 2018 06:46:10 -0500
Received: from [172.16.24.21]
        by relay.sw.ru with esmtp (Exim 4.91)
        (envelope-from <vvs@virtuozzo.com>)
        id 1gbOgS-0004aZ-GR; Mon, 24 Dec 2018 14:46:08 +0300
From:   Vasily Averin <vvs@virtuozzo.com>
Subject: [PATCH v4 08/10] sunrpc: make visible processing error in
 bc_svc_process()
To:     "J. Bruce Fields" <bfields@fieldses.org>,
        Trond Myklebust <trond.myklebust@hammerspace.com>
Cc:     Jeff Layton <jlayton@kernel.org>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        Chuck Lever <chuck.lever@oracle.com>,
        linux-nfs@vger.kernel.org,
        Evgenii Shatokhin <eshatokhin@virtuozzo.com>
References: <cover.1545648882.git.vvs@virtuozzo.com>
Message-ID: <670c3c40-e78c-1e53-10d7-d8f81e0442ec@virtuozzo.com>
Date:   Mon, 24 Dec 2018 14:46:08 +0300
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.2.1
MIME-Version: 1.0
In-Reply-To: <cover.1545648882.git.vvs@virtuozzo.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Force bc_svc_process() to generate debug message after processing errors

Signed-off-by: Vasily Averin <vvs@virtuozzo.com>
---
 net/sunrpc/svc.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/sunrpc/svc.c b/net/sunrpc/svc.c
index 1e6701c065f9..e87ddb9f7feb 100644
--- a/net/sunrpc/svc.c
+++ b/net/sunrpc/svc.c
@@ -1511,9 +1511,9 @@ bc_svc_process(struct svc_serv *serv, struct rpc_rqst *req,
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

