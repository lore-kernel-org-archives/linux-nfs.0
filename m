Return-Path: <SRS0=HAHT=O6=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0F986C43387
	for <linux-nfs@archiver.kernel.org>; Fri, 21 Dec 2018 17:32:37 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id CBD4321917
	for <linux-nfs@archiver.kernel.org>; Fri, 21 Dec 2018 17:32:36 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1729637AbeLURcg (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Fri, 21 Dec 2018 12:32:36 -0500
Received: from relay.sw.ru ([185.231.240.75]:40704 "EHLO relay.sw.ru"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1729523AbeLURcg (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 21 Dec 2018 12:32:36 -0500
Received: from [172.16.24.21]
        by relay.sw.ru with esmtp (Exim 4.91)
        (envelope-from <vvs@virtuozzo.com>)
        id 1gaOf2-0004sh-V2; Fri, 21 Dec 2018 20:32:33 +0300
From:   Vasily Averin <vvs@virtuozzo.com>
Subject: [PATCH v3 2/8] sunrpc: introduce svc_rqst->rq_bc_net
To:     Trond Myklebust <trond.myklebust@hammerspace.com>,
        Anna Schumaker <anna.schumaker@netapp.com>
Cc:     "J. Bruce Fields" <bfields@fieldses.org>,
        Jeff Layton <jlayton@kernel.org>,
        Chuck Lever <chuck.lever@oracle.com>,
        linux-nfs@vger.kernel.org,
        Evgenii Shatokhin <eshatokhin@virtuozzo.com>
References: <cover.1545412216.git.vvs@virtuozzo.com>
Message-ID: <9d1cc004-c43e-b4c3-159c-77bd6efec1a9@virtuozzo.com>
Date:   Fri, 21 Dec 2018 20:32:32 +0300
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

svc_rqst->rq_bc_net points to net namespace used during
backchannel's request processing

Signed-off-by: Vasily Averin <vvs@virtuozzo.com>
---
 include/linux/sunrpc/svc.h | 4 +++-
 net/sunrpc/svc.c           | 1 +
 2 files changed, 4 insertions(+), 1 deletion(-)

diff --git a/include/linux/sunrpc/svc.h b/include/linux/sunrpc/svc.h
index 73e130a840ce..23e33f8f0507 100644
--- a/include/linux/sunrpc/svc.h
+++ b/include/linux/sunrpc/svc.h
@@ -295,10 +295,12 @@ struct svc_rqst {
 	struct svc_cacherep *	rq_cacherep;	/* cache info */
 	struct task_struct	*rq_task;	/* service thread */
 	spinlock_t		rq_lock;	/* per-request lock */
+	struct net *		rq_bc_net;	/* pointer to backchannel's
+						 * net namespace
+						 */
 };
 
 #define SVC_NET(svc_rqst)	(svc_rqst->rq_xprt->xpt_net)
-
 /*
  * Rigorous type checking on sockaddr type conversions
  */
diff --git a/net/sunrpc/svc.c b/net/sunrpc/svc.c
index d13e05f1a990..94a2a85c078b 100644
--- a/net/sunrpc/svc.c
+++ b/net/sunrpc/svc.c
@@ -1463,6 +1463,7 @@ bc_svc_process(struct svc_serv *serv, struct rpc_rqst *req,
 	rqstp->rq_xid = req->rq_xid;
 	rqstp->rq_prot = req->rq_xprt->prot;
 	rqstp->rq_server = serv;
+	rqstp->rq_bc_net = req->rq_xprt->xprt_net;
 
 	rqstp->rq_addrlen = sizeof(req->rq_xprt->addr);
 	memcpy(&rqstp->rq_addr, &req->rq_xprt->addr, rqstp->rq_addrlen);
-- 
2.17.1

