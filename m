Return-Path: <SRS0=ChQF=C3=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.1 required=3.0 tests=BAYES_00,DKIMWL_WL_HIGH,
	DKIM_SIGNED,DKIM_VALID,DKIM_VALID_AU,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7270BC43465
	for <linux-nfs@archiver.kernel.org>; Fri, 18 Sep 2020 02:26:14 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by mail.kernel.org (Postfix) with ESMTP id 3285423600
	for <linux-nfs@archiver.kernel.org>; Fri, 18 Sep 2020 02:26:14 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1600395974;
	bh=CM75nd8kgWpkZbuZK2jNXYJcq2Zfe/ixqzZG0K+l4V4=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References:List-ID:From;
	b=xAQ7cYuWeZ3FJlul6k67kvwWKOWCExGaK0J2bHnX4ETFevFvMXFrzc+5bed/NOWJs
	 85taKEHPjQvPJ++SJrcaqYKFrbLqrFko3XA+ReMJOaMBMxsoSazuH3OBJh3ogmyDcq
	 jBKtFtJG3uhg8mKGXS3/0gWzRHBAUFDiVbxP2wvc=
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727143AbgIRC0H (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Thu, 17 Sep 2020 22:26:07 -0400
Received: from mail.kernel.org ([198.145.29.99]:45502 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1729335AbgIRCQG (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 17 Sep 2020 22:16:06 -0400
Received: from sasha-vm.mshome.net (c-73-47-72-35.hsd1.nh.comcast.net [73.47.72.35])
        (using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
        (No client certificate requested)
        by mail.kernel.org (Postfix) with ESMTPSA id 1A18A23787;
        Fri, 18 Sep 2020 02:16:05 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
        s=default; t=1600395365;
        bh=CM75nd8kgWpkZbuZK2jNXYJcq2Zfe/ixqzZG0K+l4V4=;
        h=From:To:Cc:Subject:Date:In-Reply-To:References:From;
        b=ztR+uv1uByWTKGDVLnWN6RRNhzeydPXXm0eoMfVDj1EOVPEsIp8xYJ2ZoeVuEwcby
         1gap9eKXtSbq+CoEWZCpL8Kqv2telN8ZYX+P25Of+1OSnjnFRhOHIWgOlqRfDy9hGH
         SF2EKfZyzaUF+jFnOBPTWNGYtWa5ehQB4B7D+tes=
From:   Sasha Levin <sashal@kernel.org>
To:     linux-kernel@vger.kernel.org, stable@vger.kernel.org
Cc:     Chuck Lever <chuck.lever@oracle.com>,
        Sasha Levin <sashal@kernel.org>, linux-nfs@vger.kernel.org,
        netdev@vger.kernel.org
Subject: [PATCH AUTOSEL 4.9 59/90] svcrdma: Fix leak of transport addresses
Date:   Thu, 17 Sep 2020 22:14:24 -0400
Message-Id: <20200918021455.2067301-59-sashal@kernel.org>
X-Mailer: git-send-email 2.25.1
In-Reply-To: <20200918021455.2067301-1-sashal@kernel.org>
References: <20200918021455.2067301-1-sashal@kernel.org>
MIME-Version: 1.0
X-stable: review
X-Patchwork-Hint: Ignore
Content-Transfer-Encoding: 8bit
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

From: Chuck Lever <chuck.lever@oracle.com>

[ Upstream commit 1a33d8a284b1e85e03b8c7b1ea8fb985fccd1d71 ]

Kernel memory leak detected:

unreferenced object 0xffff888849cdf480 (size 8):
  comm "kworker/u8:3", pid 2086, jiffies 4297898756 (age 4269.856s)
  hex dump (first 8 bytes):
    30 00 cd 49 88 88 ff ff                          0..I....
  backtrace:
    [<00000000acfc370b>] __kmalloc_track_caller+0x137/0x183
    [<00000000a2724354>] kstrdup+0x2b/0x43
    [<0000000082964f84>] xprt_rdma_format_addresses+0x114/0x17d [rpcrdma]
    [<00000000dfa6ed00>] xprt_setup_rdma_bc+0xc0/0x10c [rpcrdma]
    [<0000000073051a83>] xprt_create_transport+0x3f/0x1a0 [sunrpc]
    [<0000000053531a8e>] rpc_create+0x118/0x1cd [sunrpc]
    [<000000003a51b5f8>] setup_callback_client+0x1a5/0x27d [nfsd]
    [<000000001bd410af>] nfsd4_process_cb_update.isra.7+0x16c/0x1ac [nfsd]
    [<000000007f4bbd56>] nfsd4_run_cb_work+0x4c/0xbd [nfsd]
    [<0000000055c5586b>] process_one_work+0x1b2/0x2fe
    [<00000000b1e3e8ef>] worker_thread+0x1a6/0x25a
    [<000000005205fb78>] kthread+0xf6/0xfb
    [<000000006d2dc057>] ret_from_fork+0x3a/0x50

Introduce a call to xprt_rdma_free_addresses() similar to the way
that the TCP backchannel releases a transport's peer address
strings.

Fixes: 5d252f90a800 ("svcrdma: Add class for RDMA backwards direction transport")
Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
Signed-off-by: Sasha Levin <sashal@kernel.org>
---
 net/sunrpc/xprtrdma/svc_rdma_backchannel.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/net/sunrpc/xprtrdma/svc_rdma_backchannel.c b/net/sunrpc/xprtrdma/svc_rdma_backchannel.c
index 6035c5a380a6b..b3d48c6243c80 100644
--- a/net/sunrpc/xprtrdma/svc_rdma_backchannel.c
+++ b/net/sunrpc/xprtrdma/svc_rdma_backchannel.c
@@ -277,6 +277,7 @@ xprt_rdma_bc_put(struct rpc_xprt *xprt)
 {
 	dprintk("svcrdma: %s: xprt %p\n", __func__, xprt);
 
+	xprt_rdma_free_addresses(xprt);
 	xprt_free(xprt);
 	module_put(THIS_MODULE);
 }
-- 
2.25.1

