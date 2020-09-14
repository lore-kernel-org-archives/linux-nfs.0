Return-Path: <SRS0=tdDw=CX=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-14.9 required=3.0 tests=BAYES_00,DKIMWL_WL_HIGH,
	DKIM_SIGNED,DKIM_VALID,DKIM_VALID_AU,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CE750C433E2
	for <linux-nfs@archiver.kernel.org>; Mon, 14 Sep 2020 17:14:04 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by mail.kernel.org (Postfix) with ESMTP id 89BBB21BE5
	for <linux-nfs@archiver.kernel.org>; Mon, 14 Sep 2020 17:14:04 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1600103644;
	bh=J3gXBR/Gjl3DzX0hS0PTmUv2pIWLYi4Gy2GOp/A5aj8=;
	h=From:To:Cc:Subject:Date:List-ID:From;
	b=mjNQ5JiXnzr3/9GYLVDJEZioCVfobOeDw71x10yn7dj80rvf+Zuxm+PyIFJNp4e15
	 sS8yrNIuwCvoYh9aFZmyKlDgU8QvSZ3qP5iFEd6P0KMxWPRmr3qdJI9O7bHZWBaOlM
	 ai+SwhilUcvvIrvUSR0Tppi5gVfofl/p1lQtzwP0=
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726373AbgINRNu (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 14 Sep 2020 13:13:50 -0400
Received: from mail.kernel.org ([198.145.29.99]:59498 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1726580AbgINNEC (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 14 Sep 2020 09:04:02 -0400
Received: from sasha-vm.mshome.net (c-73-47-72-35.hsd1.nh.comcast.net [73.47.72.35])
        (using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
        (No client certificate requested)
        by mail.kernel.org (Postfix) with ESMTPSA id 9F5D8206B2;
        Mon, 14 Sep 2020 13:03:59 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
        s=default; t=1600088640;
        bh=J3gXBR/Gjl3DzX0hS0PTmUv2pIWLYi4Gy2GOp/A5aj8=;
        h=From:To:Cc:Subject:Date:From;
        b=Ibpqat+v98TEks1nzT76lEahgOWNEOrkmYdVvGTdHzUtrkSJkyddYXw4iUwkWUfmm
         qJk+n5zzwU1qJ3vlreb9UJd5pceP6AgNPQ55FrMLXtfmTkyzG4FYhKf/xrky5y0qCf
         odeaYzv6DsDmUD2AQzXf5/OuTCL+JJPpEC2sitFU=
From:   Sasha Levin <sashal@kernel.org>
To:     linux-kernel@vger.kernel.org, stable@vger.kernel.org
Cc:     Chuck Lever <chuck.lever@oracle.com>, Dan Aloni <dan@kernelim.com>,
        Anna Schumaker <Anna.Schumaker@Netapp.com>,
        Sasha Levin <sashal@kernel.org>, linux-nfs@vger.kernel.org,
        netdev@vger.kernel.org
Subject: [PATCH AUTOSEL 5.8 01/29] xprtrdma: Release in-flight MRs on disconnect
Date:   Mon, 14 Sep 2020 09:03:30 -0400
Message-Id: <20200914130358.1804194-1-sashal@kernel.org>
X-Mailer: git-send-email 2.25.1
MIME-Version: 1.0
X-stable: review
X-Patchwork-Hint: Ignore
Content-Transfer-Encoding: 8bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

From: Chuck Lever <chuck.lever@oracle.com>

[ Upstream commit 5de55ce951a1466e31ff68a7bc6b0a7ce3cb5947 ]

Dan Aloni reports that when a server disconnects abruptly, a few
memory regions are left DMA mapped. Over time this leak could pin
enough I/O resources to slow or even deadlock an NFS/RDMA client.

I found that if a transport disconnects before pending Send and
FastReg WRs can be posted, the to-be-registered MRs are stranded on
the req's rl_registered list and never released -- since they
weren't posted, there's no Send completion to DMA unmap them.

Reported-by: Dan Aloni <dan@kernelim.com>
Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
Signed-off-by: Anna Schumaker <Anna.Schumaker@Netapp.com>
Signed-off-by: Sasha Levin <sashal@kernel.org>
---
 net/sunrpc/xprtrdma/verbs.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/net/sunrpc/xprtrdma/verbs.c b/net/sunrpc/xprtrdma/verbs.c
index 75c646743df3e..ca89f24a1590b 100644
--- a/net/sunrpc/xprtrdma/verbs.c
+++ b/net/sunrpc/xprtrdma/verbs.c
@@ -933,6 +933,8 @@ static void rpcrdma_req_reset(struct rpcrdma_req *req)
 
 	rpcrdma_regbuf_dma_unmap(req->rl_sendbuf);
 	rpcrdma_regbuf_dma_unmap(req->rl_recvbuf);
+
+	frwr_reset(req);
 }
 
 /* ASSUMPTION: the rb_allreqs list is stable for the duration,
-- 
2.25.1

