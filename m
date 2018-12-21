Return-Path: <SRS0=HAHT=O6=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id AA140C43387
	for <linux-nfs@archiver.kernel.org>; Fri, 21 Dec 2018 17:32:09 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 79B1921917
	for <linux-nfs@archiver.kernel.org>; Fri, 21 Dec 2018 17:32:09 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1730407AbeLURcI (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Fri, 21 Dec 2018 12:32:08 -0500
Received: from relay.sw.ru ([185.231.240.75]:40682 "EHLO relay.sw.ru"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1730347AbeLURcI (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 21 Dec 2018 12:32:08 -0500
Received: from [172.16.24.21]
        by relay.sw.ru with esmtp (Exim 4.91)
        (envelope-from <vvs@virtuozzo.com>)
        id 1gaOeb-0004sN-Gy; Fri, 21 Dec 2018 20:32:05 +0300
From:   Vasily Averin <vvs@virtuozzo.com>
Subject: [PATCH v3 1/8] sunrpc: use SVC_NET() in svcauth_gss_* functions
To:     Trond Myklebust <trond.myklebust@hammerspace.com>,
        Anna Schumaker <anna.schumaker@netapp.com>
Cc:     "J. Bruce Fields" <bfields@fieldses.org>,
        Jeff Layton <jlayton@kernel.org>,
        Chuck Lever <chuck.lever@oracle.com>,
        linux-nfs@vger.kernel.org,
        Evgenii Shatokhin <eshatokhin@virtuozzo.com>
References: <cover.1545412216.git.vvs@virtuozzo.com>
Message-ID: <5f7937fa-306d-07d5-5d7b-f2bafa85ba43@virtuozzo.com>
Date:   Fri, 21 Dec 2018 20:32:04 +0300
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
 net/sunrpc/auth_gss/svcauth_gss.c | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/net/sunrpc/auth_gss/svcauth_gss.c b/net/sunrpc/auth_gss/svcauth_gss.c
index 1ece4bc3eb8d..152790ed309c 100644
--- a/net/sunrpc/auth_gss/svcauth_gss.c
+++ b/net/sunrpc/auth_gss/svcauth_gss.c
@@ -1142,7 +1142,7 @@ static int svcauth_gss_legacy_init(struct svc_rqst *rqstp,
 	struct kvec *resv = &rqstp->rq_res.head[0];
 	struct rsi *rsip, rsikey;
 	int ret;
-	struct sunrpc_net *sn = net_generic(rqstp->rq_xprt->xpt_net, sunrpc_net_id);
+	struct sunrpc_net *sn = net_generic(SVC_NET(rqstp), sunrpc_net_id);
 
 	memset(&rsikey, 0, sizeof(rsikey));
 	ret = gss_read_verf(gc, argv, authp,
@@ -1253,7 +1253,7 @@ static int svcauth_gss_proxy_init(struct svc_rqst *rqstp,
 	uint64_t handle;
 	int status;
 	int ret;
-	struct net *net = rqstp->rq_xprt->xpt_net;
+	struct net *net = SVC_NET(rqstp);
 	struct sunrpc_net *sn = net_generic(net, sunrpc_net_id);
 
 	memset(&ud, 0, sizeof(ud));
@@ -1444,7 +1444,7 @@ svcauth_gss_accept(struct svc_rqst *rqstp, __be32 *authp)
 	__be32		*rpcstart;
 	__be32		*reject_stat = resv->iov_base + resv->iov_len;
 	int		ret;
-	struct sunrpc_net *sn = net_generic(rqstp->rq_xprt->xpt_net, sunrpc_net_id);
+	struct sunrpc_net *sn = net_generic(SVC_NET(rqstp), sunrpc_net_id);
 
 	dprintk("RPC:       svcauth_gss: argv->iov_len = %zd\n",
 			argv->iov_len);
@@ -1734,7 +1734,7 @@ svcauth_gss_release(struct svc_rqst *rqstp)
 	struct rpc_gss_wire_cred *gc = &gsd->clcred;
 	struct xdr_buf *resbuf = &rqstp->rq_res;
 	int stat = -EINVAL;
-	struct sunrpc_net *sn = net_generic(rqstp->rq_xprt->xpt_net, sunrpc_net_id);
+	struct sunrpc_net *sn = net_generic(SVC_NET(rqstp), sunrpc_net_id);
 
 	if (gc->gc_proc != RPC_GSS_PROC_DATA)
 		goto out;
-- 
2.17.1

