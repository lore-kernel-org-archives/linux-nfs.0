Return-Path: <SRS0=eAd3=PB=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5EDB3C43387
	for <linux-nfs@archiver.kernel.org>; Mon, 24 Dec 2018 11:46:25 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 37D6B2176F
	for <linux-nfs@archiver.kernel.org>; Mon, 24 Dec 2018 11:46:25 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1725899AbeLXLqY (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 24 Dec 2018 06:46:24 -0500
Received: from relay.sw.ru ([185.231.240.75]:50754 "EHLO relay.sw.ru"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1725897AbeLXLqY (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 24 Dec 2018 06:46:24 -0500
Received: from [172.16.24.21]
        by relay.sw.ru with esmtp (Exim 4.91)
        (envelope-from <vvs@virtuozzo.com>)
        id 1gbOgf-0004av-Sg; Mon, 24 Dec 2018 14:46:21 +0300
From:   Vasily Averin <vvs@virtuozzo.com>
Subject: [PATCH v4 10/10] nfs: minor typo in nfs4_callback_up_net()
To:     "J. Bruce Fields" <bfields@fieldses.org>,
        Trond Myklebust <trond.myklebust@hammerspace.com>
Cc:     Jeff Layton <jlayton@kernel.org>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        Chuck Lever <chuck.lever@oracle.com>,
        linux-nfs@vger.kernel.org,
        Evgenii Shatokhin <eshatokhin@virtuozzo.com>
References: <cover.1545648882.git.vvs@virtuozzo.com>
Message-ID: <09831ddc-01c1-160f-bee8-f305d88c11c0@virtuozzo.com>
Date:   Mon, 24 Dec 2018 14:46:21 +0300
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

Closing ")" was lost in debug message.

Signed-off-by: Vasily Averin <vvs@virtuozzo.com>
---
 fs/nfs/callback.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/fs/nfs/callback.c b/fs/nfs/callback.c
index 6dd04774aedc..82fa65da741b 100644
--- a/fs/nfs/callback.c
+++ b/fs/nfs/callback.c
@@ -56,7 +56,7 @@ static int nfs4_callback_up_net(struct svc_serv *serv, struct net *net)
 				nfs_callback_set_tcpport, SVC_SOCK_ANONYMOUS);
 	if (ret > 0) {
 		nn->nfs_callback_tcpport6 = ret;
-		dprintk("NFS: Callback listener port = %u (af %u, net %x\n",
+		dprintk("NFS: Callback listener port = %u (af %u, net %x)\n",
 			nn->nfs_callback_tcpport6, PF_INET6, net->ns.inum);
 	} else if (ret != -EAFNOSUPPORT)
 		goto out_err;
-- 
2.17.1

