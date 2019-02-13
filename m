Return-Path: <SRS0=saDi=QU=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1D248C282CA
	for <linux-nfs@archiver.kernel.org>; Wed, 13 Feb 2019 02:35:36 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id D4DDC222C9
	for <linux-nfs@archiver.kernel.org>; Wed, 13 Feb 2019 02:35:35 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1550025335;
	bh=Rglq5lF9ipUgzhoCyZMr5Plx+MCnMfiO3B62xEFU9o4=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References:List-ID:From;
	b=n81bExnTPQc9hXzafCxQR/ctdTDFUDkFIIPZJY6ijxHOD/Lq/CjoNZGdx4MaX+5W9
	 StOHho7qaNrRxencW+KEKGdvR5LKbG8tFl7OsP/4tfmHjRUQHNv0bPpwArQIAgWFfE
	 26HRrpt1qvqx1Rh/uSjT90Ue5Zc4UeoEBPIFyEGI=
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1730063AbfBMCff (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 12 Feb 2019 21:35:35 -0500
Received: from mail.kernel.org ([198.145.29.99]:39296 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S2388039AbfBMCfe (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 12 Feb 2019 21:35:34 -0500
Received: from sasha-vm.mshome.net (c-73-47-72-35.hsd1.nh.comcast.net [73.47.72.35])
        (using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
        (No client certificate requested)
        by mail.kernel.org (Postfix) with ESMTPSA id 90C47222C9;
        Wed, 13 Feb 2019 02:35:32 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
        s=default; t=1550025333;
        bh=Rglq5lF9ipUgzhoCyZMr5Plx+MCnMfiO3B62xEFU9o4=;
        h=From:To:Cc:Subject:Date:In-Reply-To:References:From;
        b=2AA155LvomHNAtaYhRY/B2UHliO2Z71DHAQ6NlchUNUGUrpXR84/1TDaou61BP05y
         fQJaeDr9KmKZT73WhJStEXJMI4XNE7qMgvnrlQcqAfE4nEpiN2rlM6SmXl8WsvWKJI
         wZR6n/IBAFmvNJdDLCU2GeVXspKhd90ZFNd0WNwY=
From:   Sasha Levin <sashal@kernel.org>
To:     linux-kernel@vger.kernel.org, stable@vger.kernel.org
Cc:     Trond Myklebust <trondmy@gmail.com>,
        Trond Myklebust <trond.myklebust@hammerspace.com>,
        Anna Schumaker <Anna.Schumaker@Netapp.com>,
        Sasha Levin <sashal@kernel.org>, linux-nfs@vger.kernel.org,
        netdev@vger.kernel.org
Subject: [PATCH AUTOSEL 4.20 075/105] SUNRPC: Ensure rq_bytes_sent is reset before request transmission
Date:   Tue, 12 Feb 2019 21:33:06 -0500
Message-Id: <20190213023336.19019-75-sashal@kernel.org>
X-Mailer: git-send-email 2.19.1
In-Reply-To: <20190213023336.19019-1-sashal@kernel.org>
References: <20190213023336.19019-1-sashal@kernel.org>
MIME-Version: 1.0
X-Patchwork-Hint: Ignore
Content-Transfer-Encoding: 8bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

From: Trond Myklebust <trondmy@gmail.com>

[ Upstream commit e66721f0436396f779291a29616858b76bfd9415 ]

When we resend a request, ensure that the 'rq_bytes_sent' is reset
to zero.

Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>
Signed-off-by: Anna Schumaker <Anna.Schumaker@Netapp.com>
Signed-off-by: Sasha Levin <sashal@kernel.org>
---
 net/sunrpc/clnt.c | 1 -
 net/sunrpc/xprt.c | 1 +
 2 files changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
index 24cbddc44c88..2189fbc4c570 100644
--- a/net/sunrpc/clnt.c
+++ b/net/sunrpc/clnt.c
@@ -1738,7 +1738,6 @@ rpc_xdr_encode(struct rpc_task *task)
 	xdr_buf_init(&req->rq_rcv_buf,
 		     req->rq_rbuffer,
 		     req->rq_rcvsize);
-	req->rq_bytes_sent = 0;
 
 	p = rpc_encode_header(task);
 	if (p == NULL) {
diff --git a/net/sunrpc/xprt.c b/net/sunrpc/xprt.c
index 943f08be7c38..f1ec2110efeb 100644
--- a/net/sunrpc/xprt.c
+++ b/net/sunrpc/xprt.c
@@ -1151,6 +1151,7 @@ xprt_request_enqueue_transmit(struct rpc_task *task)
 	struct rpc_xprt *xprt = req->rq_xprt;
 
 	if (xprt_request_need_enqueue_transmit(task, req)) {
+		req->rq_bytes_sent = 0;
 		spin_lock(&xprt->queue_lock);
 		/*
 		 * Requests that carry congestion control credits are added
-- 
2.19.1

