Return-Path: <SRS0=QvV7=PG=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A1913C43387
	for <linux-nfs@archiver.kernel.org>; Sat, 29 Dec 2018 13:38:56 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 642F820855
	for <linux-nfs@archiver.kernel.org>; Sat, 29 Dec 2018 13:38:56 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1725909AbeL2Niz (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Sat, 29 Dec 2018 08:38:55 -0500
Received: from relay.sw.ru ([185.231.240.75]:35428 "EHLO relay.sw.ru"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1725898AbeL2Niz (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Sat, 29 Dec 2018 08:38:55 -0500
Received: from [172.16.24.21]
        by relay.sw.ru with esmtp (Exim 4.91)
        (envelope-from <vvs@virtuozzo.com>)
        id 1gdEpI-0001Tp-I5; Sat, 29 Dec 2018 16:38:52 +0300
From:   Vasily Averin <vvs@virtuozzo.com>
Subject: [PATCH] nfs: fixed broken compilation in nfs_callback_up_net()
To:     "J. Bruce Fields" <bfields@fieldses.org>
Cc:     linux-nfs@vger.kernel.org
Message-ID: <1cd771d8-7c2c-9672-6522-f2a0c46e55fe@virtuozzo.com>
Date:   Sat, 29 Dec 2018 16:38:51 +0300
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.2.1
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Patch fixes compilation error in nfs_callback_up_net()
serv->sv_bc_enabled is defined under enabled CONFIG_SUNRPC_BACKCHANNEL,
however nfs_callback_up_net() can access it even if this config option
was not set.

Fixes ???? ("sunrpc: replace svc_serv->sv_bc_xprt by boolean flag")

Signed-off-by: Vasily Averin <vvs@virtuozzo.com>
---
 fs/nfs/callback.c              | 2 +-
 include/linux/sunrpc/bc_xprt.h | 9 +++++++++
 2 files changed, 10 insertions(+), 1 deletion(-)

diff --git a/fs/nfs/callback.c b/fs/nfs/callback.c
index 82fa65da741b..0b602a39dd71 100644
--- a/fs/nfs/callback.c
+++ b/fs/nfs/callback.c
@@ -210,7 +210,7 @@ static int nfs_callback_up_net(int minorversion, struct svc_serv *serv,
 	if (!IS_ENABLED(CONFIG_NFS_V4_1) || minorversion == 0)
 		ret = nfs4_callback_up_net(serv, net);
 	else if (xprt->ops->bc_setup)
-		serv->sv_bc_enabled = true;
+		set_bc_enabled(serv);
 	else
 		ret = -EPROTONOSUPPORT;
 
diff --git a/include/linux/sunrpc/bc_xprt.h b/include/linux/sunrpc/bc_xprt.h
index 4e8c773d02be..d4229a78524a 100644
--- a/include/linux/sunrpc/bc_xprt.h
+++ b/include/linux/sunrpc/bc_xprt.h
@@ -51,6 +51,11 @@ static inline bool svc_is_backchannel(const struct svc_rqst *rqstp)
 {
 	return rqstp->rq_server->sv_bc_enabled;
 }
+
+static inline void set_bc_enabled(struct svc_serv *serv)
+{
+	serv->sv_bc_enabled = true;
+}
 #else /* CONFIG_SUNRPC_BACKCHANNEL */
 static inline int xprt_setup_backchannel(struct rpc_xprt *xprt,
 					 unsigned int min_reqs)
@@ -63,6 +68,10 @@ static inline bool svc_is_backchannel(const struct svc_rqst *rqstp)
 	return false;
 }
 
+static inline void set_bc_enabled(struct svc_serv *serv)
+{
+}
+
 static inline void xprt_free_bc_request(struct rpc_rqst *req)
 {
 }
-- 
2.17.1

