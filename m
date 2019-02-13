Return-Path: <SRS0=saDi=QU=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,USER_AGENT_GIT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1D607C4151A
	for <linux-nfs@archiver.kernel.org>; Wed, 13 Feb 2019 02:54:51 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id D500620835
	for <linux-nfs@archiver.kernel.org>; Wed, 13 Feb 2019 02:54:50 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1550026490;
	bh=G7MTzy0m5hG45uXyJmC9WAK9s0M8b+tp2Q+dKiEwK78=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References:List-ID:From;
	b=iL+dhOvzBqrQqqNIP6hL+VcTVQDMsCNhP///oBC+qmv5lLMeFINSjBQtd4EZPULcj
	 JJfKtsornT673NfXYgWtJy/l7xXlzAUi3KGKwwlnyVrw91U1QhICFBqsfLI+srlpHq
	 4vLpOZ/jNC56nMpwiiwXT52xetdFMLv8HdCuT/hs=
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S2388381AbfBMCyn (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 12 Feb 2019 21:54:43 -0500
Received: from mail.kernel.org ([198.145.29.99]:41180 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S2388359AbfBMChk (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 12 Feb 2019 21:37:40 -0500
Received: from sasha-vm.mshome.net (c-73-47-72-35.hsd1.nh.comcast.net [73.47.72.35])
        (using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
        (No client certificate requested)
        by mail.kernel.org (Postfix) with ESMTPSA id 0FAE4206B6;
        Wed, 13 Feb 2019 02:37:38 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
        s=default; t=1550025459;
        bh=G7MTzy0m5hG45uXyJmC9WAK9s0M8b+tp2Q+dKiEwK78=;
        h=From:To:Cc:Subject:Date:In-Reply-To:References:From;
        b=dstSdJyO7rvewFRhocycG8/uxrtPzDm9eFcPwEwXXy6bfA/FBgZA4NvtH2pHNhcxD
         +BNwDEQBj+Wqr/JyH9e4+1GwWXwPdUzp0iY1B+H8uROoEMsYsQO4g2T8BLyyblx0m2
         4JqRtOxYpnNEYA5sqYJQHgYXIvbBTv0SBEkpJ4m8=
From:   Sasha Levin <sashal@kernel.org>
To:     linux-kernel@vger.kernel.org, stable@vger.kernel.org
Cc:     Dan Carpenter <dan.carpenter@oracle.com>,
        Anna Schumaker <Anna.Schumaker@Netapp.com>,
        Sasha Levin <sashal@kernel.org>, linux-nfs@vger.kernel.org,
        netdev@vger.kernel.org
Subject: [PATCH AUTOSEL 4.19 29/83] xprtrdma: Double free in rpcrdma_sendctxs_create()
Date:   Tue, 12 Feb 2019 21:36:07 -0500
Message-Id: <20190213023701.20286-29-sashal@kernel.org>
X-Mailer: git-send-email 2.19.1
In-Reply-To: <20190213023701.20286-1-sashal@kernel.org>
References: <20190213023701.20286-1-sashal@kernel.org>
MIME-Version: 1.0
X-Patchwork-Hint: Ignore
Content-Transfer-Encoding: 8bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

From: Dan Carpenter <dan.carpenter@oracle.com>

[ Upstream commit 6e17f58c486d9554341f70aa5b63b8fbed07b3fa ]

The clean up is handled by the caller, rpcrdma_buffer_create(), so this
call to rpcrdma_sendctxs_destroy() leads to a double free.

Fixes: ae72950abf99 ("xprtrdma: Add data structure to manage RDMA Send arguments")
Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>
Reviewed-by: Chuck Lever <chuck.lever@oracle.com>
Signed-off-by: Anna Schumaker <Anna.Schumaker@Netapp.com>
Signed-off-by: Sasha Levin <sashal@kernel.org>
---
 net/sunrpc/xprtrdma/verbs.c | 6 +-----
 1 file changed, 1 insertion(+), 5 deletions(-)

diff --git a/net/sunrpc/xprtrdma/verbs.c b/net/sunrpc/xprtrdma/verbs.c
index 956a5ea47b58..3d6bf790cf1f 100644
--- a/net/sunrpc/xprtrdma/verbs.c
+++ b/net/sunrpc/xprtrdma/verbs.c
@@ -872,7 +872,7 @@ static int rpcrdma_sendctxs_create(struct rpcrdma_xprt *r_xprt)
 	for (i = 0; i <= buf->rb_sc_last; i++) {
 		sc = rpcrdma_sendctx_create(&r_xprt->rx_ia);
 		if (!sc)
-			goto out_destroy;
+			return -ENOMEM;
 
 		sc->sc_xprt = r_xprt;
 		buf->rb_sc_ctxs[i] = sc;
@@ -880,10 +880,6 @@ static int rpcrdma_sendctxs_create(struct rpcrdma_xprt *r_xprt)
 	buf->rb_flags = 0;
 
 	return 0;
-
-out_destroy:
-	rpcrdma_sendctxs_destroy(buf);
-	return -ENOMEM;
 }
 
 /* The sendctx queue is not guaranteed to have a size that is a
-- 
2.19.1

