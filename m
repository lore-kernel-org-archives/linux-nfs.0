Return-Path: <SRS0=SG1H=QH=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 04EC1C282D7
	for <linux-nfs@archiver.kernel.org>; Thu, 31 Jan 2019 01:07:54 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id C2C1E20989
	for <linux-nfs@archiver.kernel.org>; Thu, 31 Jan 2019 01:07:53 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726230AbfAaBHx (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 30 Jan 2019 20:07:53 -0500
Received: from gateway31.websitewelcome.com ([192.185.144.91]:42065 "EHLO
        gateway31.websitewelcome.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1725535AbfAaBHw (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 30 Jan 2019 20:07:52 -0500
X-Greylist: delayed 1288 seconds by postgrey-1.27 at vger.kernel.org; Wed, 30 Jan 2019 20:07:52 EST
Received: from cm17.websitewelcome.com (cm17.websitewelcome.com [100.42.49.20])
        by gateway31.websitewelcome.com (Postfix) with ESMTP id 242D63FEC9
        for <linux-nfs@vger.kernel.org>; Wed, 30 Jan 2019 18:46:24 -0600 (CST)
Received: from gator4166.hostgator.com ([108.167.133.22])
        by cmsmtp with SMTP
        id p0UqgbkOO90onp0Uqg1chs; Wed, 30 Jan 2019 18:46:24 -0600
X-Authority-Reason: nr=8
Received: from [189.250.130.205] (port=38528 helo=embeddedor)
        by gator4166.hostgator.com with esmtpa (Exim 4.91)
        (envelope-from <gustavo@embeddedor.com>)
        id 1gp0Up-001ojp-C1; Wed, 30 Jan 2019 18:46:23 -0600
Date:   Wed, 30 Jan 2019 18:46:22 -0600
From:   "Gustavo A. R. Silva" <gustavo@embeddedor.com>
To:     Trond Myklebust <trond.myklebust@hammerspace.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        Jeff Layton <jlayton@kernel.org>,
        "David S. Miller" <davem@davemloft.net>
Cc:     linux-nfs@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org,
        "Gustavo A. R. Silva" <gustavo@embeddedor.com>
Subject: [PATCH net-next] xprtrdma: Use struct_size() in kzalloc()
Message-ID: <20190131004622.GA30261@embeddedor>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
User-Agent: Mutt/1.9.4 (2018-02-28)
X-AntiAbuse: This header was added to track abuse, please include it with any abuse report
X-AntiAbuse: Primary Hostname - gator4166.hostgator.com
X-AntiAbuse: Original Domain - vger.kernel.org
X-AntiAbuse: Originator/Caller UID/GID - [47 12] / [47 12]
X-AntiAbuse: Sender Address Domain - embeddedor.com
X-BWhitelist: no
X-Source-IP: 189.250.130.205
X-Source-L: No
X-Exim-ID: 1gp0Up-001ojp-C1
X-Source: 
X-Source-Args: 
X-Source-Dir: 
X-Source-Sender: (embeddedor) [189.250.130.205]:38528
X-Source-Auth: gustavo@embeddedor.com
X-Email-Count: 27
X-Source-Cap: Z3V6aWRpbmU7Z3V6aWRpbmU7Z2F0b3I0MTY2Lmhvc3RnYXRvci5jb20=
X-Local-Domain: yes
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

One of the more common cases of allocation size calculations is finding
the size of a structure that has a zero-sized array at the end, along
with memory for some number of elements for that array. For example:

struct foo {
    int stuff;
    struct boo entry[];
};

instance = kzalloc(sizeof(struct foo) + count * sizeof(struct boo), GFP_KERNEL);

Instead of leaving these open-coded and prone to type mistakes, we can
now use the new struct_size() helper:

instance = kzalloc(struct_size(instance, entry, count), GFP_KERNEL);

This code was detected with the help of Coccinelle.

Signed-off-by: Gustavo A. R. Silva <gustavo@embeddedor.com>
---
 net/sunrpc/xprtrdma/verbs.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/net/sunrpc/xprtrdma/verbs.c b/net/sunrpc/xprtrdma/verbs.c
index 4994e75945b8..9e8cf7456840 100644
--- a/net/sunrpc/xprtrdma/verbs.c
+++ b/net/sunrpc/xprtrdma/verbs.c
@@ -811,8 +811,7 @@ static struct rpcrdma_sendctx *rpcrdma_sendctx_create(struct rpcrdma_ia *ia)
 {
 	struct rpcrdma_sendctx *sc;
 
-	sc = kzalloc(sizeof(*sc) +
-		     ia->ri_max_send_sges * sizeof(struct ib_sge),
+	sc = kzalloc(struct_size(sc, sc_sges, ia->ri_max_send_sges),
 		     GFP_KERNEL);
 	if (!sc)
 		return NULL;
-- 
2.20.1

