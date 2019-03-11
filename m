Return-Path: <SRS0=Z4n1=RO=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,USER_AGENT_GIT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id EEA47C43381
	for <linux-nfs@archiver.kernel.org>; Mon, 11 Mar 2019 20:05:46 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id B66062087C
	for <linux-nfs@archiver.kernel.org>; Mon, 11 Mar 2019 20:05:46 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1552334746;
	bh=sJY6DGn4I0zXIEfa+4nEuN1rPEZBTPPQYpVA1B9bSL4=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References:List-ID:From;
	b=uf755kiyPZ+hSBqYiDCEmPX44z3GKLZn59FfeJtazonxsZt38L02voA28pFJEoFGs
	 d12NL9jovUEziNIb/VX6+XnGyp+yF0hJ9jV2dTMpaXOjdrVKruQyX1152bruwVP+uW
	 qAo53spLd02uF4VodwKVXXp1KSyom+jqb4FNlBic=
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727362AbfCKUFh (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 11 Mar 2019 16:05:37 -0400
Received: from mail.kernel.org ([198.145.29.99]:35360 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1729260AbfCKT56 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 11 Mar 2019 15:57:58 -0400
Received: from sasha-vm.mshome.net (c-73-47-72-35.hsd1.nh.comcast.net [73.47.72.35])
        (using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
        (No client certificate requested)
        by mail.kernel.org (Postfix) with ESMTPSA id A34FD2084F;
        Mon, 11 Mar 2019 19:57:57 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
        s=default; t=1552334278;
        bh=sJY6DGn4I0zXIEfa+4nEuN1rPEZBTPPQYpVA1B9bSL4=;
        h=From:To:Cc:Subject:Date:In-Reply-To:References:From;
        b=0RQffLVvE1jXxh0Q0WP+nYU3DiKi21YpRzs1IoLZpksk0TW0VhBXcG3Pu2Bh8BNGr
         2EqQoIMo5x67rg5PT5RnVefJPp5CM55SF4TwkM4sNyQv8OeAGivyACTfFpz3Gp+0eD
         7GiB+IklfCKDcudXXdCvnLrHyxR87LvZM8Y6uSUA=
From:   Sasha Levin <sashal@kernel.org>
To:     linux-kernel@vger.kernel.org, stable@vger.kernel.org
Cc:     Nicolas Morey-Chaisemartin <nmoreychaisemartin@suse.com>,
        Anna Schumaker <Anna.Schumaker@Netapp.com>,
        Sasha Levin <sashal@kernel.org>, linux-nfs@vger.kernel.org,
        netdev@vger.kernel.org
Subject: [PATCH AUTOSEL 4.19 32/44] xprtrdma: Make sure Send CQ is allocated on an existing compvec
Date:   Mon, 11 Mar 2019 15:56:48 -0400
Message-Id: <20190311195700.138462-32-sashal@kernel.org>
X-Mailer: git-send-email 2.19.1
In-Reply-To: <20190311195700.138462-1-sashal@kernel.org>
References: <20190311195700.138462-1-sashal@kernel.org>
MIME-Version: 1.0
X-Patchwork-Hint: Ignore
Content-Transfer-Encoding: 8bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

From: Nicolas Morey-Chaisemartin <nmoreychaisemartin@suse.com>

[ Upstream commit a4cb5bdb754afe21f3e9e7164213e8600cf69427 ]

Make sure the device has at least 2 completion vectors
before allocating to compvec#1

Fixes: a4699f5647f3 (xprtrdma: Put Send CQ in IB_POLL_WORKQUEUE mode)
Signed-off-by: Nicolas Morey-Chaisemartin <nmoreychaisemartin@suse.com>
Reviewed-by: Chuck Lever <chuck.lever@oracle.com>
Signed-off-by: Anna Schumaker <Anna.Schumaker@Netapp.com>
Signed-off-by: Sasha Levin <sashal@kernel.org>
---
 net/sunrpc/xprtrdma/verbs.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/net/sunrpc/xprtrdma/verbs.c b/net/sunrpc/xprtrdma/verbs.c
index 3d6bf790cf1f..5ddbf227e7c6 100644
--- a/net/sunrpc/xprtrdma/verbs.c
+++ b/net/sunrpc/xprtrdma/verbs.c
@@ -546,7 +546,8 @@ rpcrdma_ep_create(struct rpcrdma_ep *ep, struct rpcrdma_ia *ia,
 
 	sendcq = ib_alloc_cq(ia->ri_device, NULL,
 			     ep->rep_attr.cap.max_send_wr + 1,
-			     1, IB_POLL_WORKQUEUE);
+			     ia->ri_device->num_comp_vectors > 1 ? 1 : 0,
+			     IB_POLL_WORKQUEUE);
 	if (IS_ERR(sendcq)) {
 		rc = PTR_ERR(sendcq);
 		dprintk("RPC:       %s: failed to create send CQ: %i\n",
-- 
2.19.1

