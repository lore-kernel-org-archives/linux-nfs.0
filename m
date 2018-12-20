Return-Path: <SRS0=5+aP=O5=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 48FFCC43387
	for <linux-nfs@archiver.kernel.org>; Thu, 20 Dec 2018 13:56:47 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 1D1C421852
	for <linux-nfs@archiver.kernel.org>; Thu, 20 Dec 2018 13:56:47 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1733203AbeLTN4q (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Thu, 20 Dec 2018 08:56:46 -0500
Received: from relay.sw.ru ([185.231.240.75]:44456 "EHLO relay.sw.ru"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1728803AbeLTN4q (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 20 Dec 2018 08:56:46 -0500
Received: from [172.16.24.21]
        by relay.sw.ru with esmtp (Exim 4.91)
        (envelope-from <vvs@virtuozzo.com>)
        id 1gZyoe-0004xe-Tq; Thu, 20 Dec 2018 16:56:45 +0300
From:   Vasily Averin <vvs@virtuozzo.com>
Subject: [PATCH v2 4/4] nfs: minor typo in nfs4_callback_up_net()
To:     Trond Myklebust <trond.myklebust@hammerspace.com>,
        Anna Schumaker <anna.schumaker@netapp.com>
Cc:     "J. Bruce Fields" <bfields@fieldses.org>,
        Jeff Layton <jlayton@kernel.org>,
        Chuck Lever <chuck.lever@oracle.com>,
        linux-nfs@vger.kernel.org,
        Evgenii Shatokhin <eshatokhin@virtuozzo.com>
References: <cover.1545313300.git.vvs@virtuozzo.com>
Message-ID: <e3749485-6e2c-d430-77f6-a7b574905791@virtuozzo.com>
Date:   Thu, 20 Dec 2018 16:56:44 +0300
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.2.1
MIME-Version: 1.0
In-Reply-To: <cover.1545313300.git.vvs@virtuozzo.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Signed-off-by: Vasily Averin <vvs@virtuozzo.com>
---
 fs/nfs/callback.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/fs/nfs/callback.c b/fs/nfs/callback.c
index 509dc5adeb8f..52d8e1681eec 100644
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

