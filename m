Return-Path: <SRS0=9rdx=U2=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 03F58C48BD6
	for <linux-nfs@archiver.kernel.org>; Thu, 27 Jun 2019 00:44:11 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id C4BBA208E3
	for <linux-nfs@archiver.kernel.org>; Thu, 27 Jun 2019 00:44:10 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1561596250;
	bh=oW5pAeo++OS2RF8UDf8aG6MvZdYNZ5YXKrBU8Px9OA8=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References:List-ID:From;
	b=BSCCKKvfh/oYZZCMQ1Aidy1EeXpyvDniyo4D0TLOelXvZ3EOumI2O6ak0mflR8YoP
	 8ZC2k6jegjHvzRv6vPA3Iool5gPjcgtBanCIafI5sNSn6wi2zGKqP+GhsoV/LHS2r0
	 6mJmRj94+e0FRluX4tEt95R8JuojbO3z9Mt9usC4=
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1729733AbfF0Ami (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 26 Jun 2019 20:42:38 -0400
Received: from mail.kernel.org ([198.145.29.99]:46428 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1729745AbfF0Amf (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 26 Jun 2019 20:42:35 -0400
Received: from sasha-vm.mshome.net (unknown [107.242.116.147])
        (using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
        (No client certificate requested)
        by mail.kernel.org (Postfix) with ESMTPSA id 3CF92205ED;
        Thu, 27 Jun 2019 00:42:31 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
        s=default; t=1561596154;
        bh=oW5pAeo++OS2RF8UDf8aG6MvZdYNZ5YXKrBU8Px9OA8=;
        h=From:To:Cc:Subject:Date:In-Reply-To:References:From;
        b=k/hpDhWult9cVPPHTzNkZJRnYmokeQBeP8slJGsUkRIOdIFm7iI++CgYRmKdFj31t
         5+ToFciD/R+uemA5kcR2XhQcXAR44ggiky2PW0JhQb5+XoSo4WDgNnDR0C+efes4DI
         N+eBDXTDKv9QXQZko8GSwXAR73Y3J5BDs/idc6O4=
From:   Sasha Levin <sashal@kernel.org>
To:     linux-kernel@vger.kernel.org, stable@vger.kernel.org
Cc:     Lin Yi <teroincn@163.com>,
        Anna Schumaker <Anna.Schumaker@Netapp.com>,
        Sasha Levin <sashal@kernel.org>, linux-nfs@vger.kernel.org,
        netdev@vger.kernel.org
Subject: [PATCH AUTOSEL 4.9 21/21] net :sunrpc :clnt :Fix xps refcount imbalance on the error path
Date:   Wed, 26 Jun 2019 20:41:21 -0400
Message-Id: <20190627004122.21671-21-sashal@kernel.org>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190627004122.21671-1-sashal@kernel.org>
References: <20190627004122.21671-1-sashal@kernel.org>
MIME-Version: 1.0
X-stable: review
X-Patchwork-Hint: Ignore
Content-Transfer-Encoding: 8bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

From: Lin Yi <teroincn@163.com>

[ Upstream commit b96226148491505318228ac52624956bd98f9e0c ]

rpc_clnt_add_xprt take a reference to struct rpc_xprt_switch, but forget
to release it before return, may lead to a memory leak.

Signed-off-by: Lin Yi <teroincn@163.com>
Signed-off-by: Anna Schumaker <Anna.Schumaker@Netapp.com>
Signed-off-by: Sasha Levin <sashal@kernel.org>
---
 net/sunrpc/clnt.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
index 244eac1bd648..de18a463ac96 100644
--- a/net/sunrpc/clnt.c
+++ b/net/sunrpc/clnt.c
@@ -2718,6 +2718,7 @@ int rpc_clnt_add_xprt(struct rpc_clnt *clnt,
 	xprt = xprt_iter_xprt(&clnt->cl_xpi);
 	if (xps == NULL || xprt == NULL) {
 		rcu_read_unlock();
+		xprt_switch_put(xps);
 		return -EAGAIN;
 	}
 	resvport = xprt->resvport;
-- 
2.20.1

