Return-Path: <SRS0=tdDw=CX=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-14.9 required=3.0 tests=BAYES_00,DKIMWL_WL_HIGH,
	DKIM_SIGNED,DKIM_VALID,DKIM_VALID_AU,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CC189C43461
	for <linux-nfs@archiver.kernel.org>; Mon, 14 Sep 2020 13:18:33 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by mail.kernel.org (Postfix) with ESMTP id 8B62320EDD
	for <linux-nfs@archiver.kernel.org>; Mon, 14 Sep 2020 13:18:33 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1600089513;
	bh=9HbgiSXTTYuKOPK7+OSiQPwOJsg8dQyJD9HsgqPvPss=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References:List-ID:From;
	b=eu4k3Is67K+PAlJK8fNOjfEMxJgwfFQ84+QkCPYFL1EauZ+2lHL/rwZg+KrtzsX/f
	 VLhF4st2eplwvU4QfrqSDaTI5TPF46pj4tkDiXyBga6sGjhLSrkfSoU6+njPudiYk4
	 vPl6PfOPenlixOxasK431oE7EK7gG1VV/MnRryIw=
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726667AbgINNR6 (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 14 Sep 2020 09:17:58 -0400
Received: from mail.kernel.org ([198.145.29.99]:60694 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1726701AbgINNHL (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 14 Sep 2020 09:07:11 -0400
Received: from sasha-vm.mshome.net (c-73-47-72-35.hsd1.nh.comcast.net [73.47.72.35])
        (using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
        (No client certificate requested)
        by mail.kernel.org (Postfix) with ESMTPSA id 9788E2222A;
        Mon, 14 Sep 2020 13:05:52 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
        s=default; t=1600088753;
        bh=9HbgiSXTTYuKOPK7+OSiQPwOJsg8dQyJD9HsgqPvPss=;
        h=From:To:Cc:Subject:Date:In-Reply-To:References:From;
        b=H8hBLEhbBbVDRrkRwr3yAFF2uD8oZQMXMFeD2TLVz39BMeKPHwDC8YavrPwB3sx83
         F7hYbuZqNdCRDXqpb8/zjEJDd+MdpwFyotCWQ/FPj4LCIXFYcgDY8rLlwwd7tWywKL
         xayJrjO4VOe1fl2Kh/Nt98RWfnUbSgD+M1rb43T0=
From:   Sasha Levin <sashal@kernel.org>
To:     linux-kernel@vger.kernel.org, stable@vger.kernel.org
Cc:     "J. Bruce Fields" <bfields@redhat.com>, Zhi Li <yieli@redhat.com>,
        Trond Myklebust <trond.myklebust@hammerspace.com>,
        Sasha Levin <sashal@kernel.org>, linux-nfs@vger.kernel.org,
        netdev@vger.kernel.org
Subject: [PATCH AUTOSEL 4.9 06/10] SUNRPC: stop printk reading past end of string
Date:   Mon, 14 Sep 2020 09:05:41 -0400
Message-Id: <20200914130545.1805084-6-sashal@kernel.org>
X-Mailer: git-send-email 2.25.1
In-Reply-To: <20200914130545.1805084-1-sashal@kernel.org>
References: <20200914130545.1805084-1-sashal@kernel.org>
MIME-Version: 1.0
X-stable: review
X-Patchwork-Hint: Ignore
Content-Transfer-Encoding: 8bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

From: "J. Bruce Fields" <bfields@redhat.com>

[ Upstream commit 8c6b6c793ed32b8f9770ebcdf1ba99af423c303b ]

Since p points at raw xdr data, there's no guarantee that it's NULL
terminated, so we should give a length.  And probably escape any special
characters too.

Reported-by: Zhi Li <yieli@redhat.com>
Signed-off-by: J. Bruce Fields <bfields@redhat.com>
Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>
Signed-off-by: Sasha Levin <sashal@kernel.org>
---
 net/sunrpc/rpcb_clnt.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/sunrpc/rpcb_clnt.c b/net/sunrpc/rpcb_clnt.c
index eafc78e063f1d..185441d7a2814 100644
--- a/net/sunrpc/rpcb_clnt.c
+++ b/net/sunrpc/rpcb_clnt.c
@@ -975,8 +975,8 @@ static int rpcb_dec_getaddr(struct rpc_rqst *req, struct xdr_stream *xdr,
 	p = xdr_inline_decode(xdr, len);
 	if (unlikely(p == NULL))
 		goto out_fail;
-	dprintk("RPC: %5u RPCB_%s reply: %s\n", req->rq_task->tk_pid,
-			req->rq_task->tk_msg.rpc_proc->p_name, (char *)p);
+	dprintk("RPC: %5u RPCB_%s reply: %*pE\n", req->rq_task->tk_pid,
+			req->rq_task->tk_msg.rpc_proc->p_name, len, (char *)p);
 
 	if (rpc_uaddr2sockaddr(req->rq_xprt->xprt_net, (char *)p, len,
 				sap, sizeof(address)) == 0)
-- 
2.25.1

