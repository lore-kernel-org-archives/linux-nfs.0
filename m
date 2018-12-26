Return-Path: <SRS0=jCTp=PD=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.6 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5BFAFC43444
	for <linux-nfs@archiver.kernel.org>; Wed, 26 Dec 2018 22:55:58 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 217DF214D8
	for <linux-nfs@archiver.kernel.org>; Wed, 26 Dec 2018 22:55:58 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1545864958;
	bh=4keKyb6ZHgwVJM5+Aw6qCFuQPEmhGlpyEpRoGrG6sLA=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References:List-ID:From;
	b=rgOMI/zAAF70svcHjgEZB6flrBW1S98/JbL7hj2OiZefEutp0upVCaMEPnaNEPVa8
	 TXGVp0oH3vuZ06oG9U7dDCbR9Kk5ZliruewgWkqdkgcFl2BSG33JpffNtIIVYTyc/V
	 cL1ghGUI1Du9/UD+pizg3x6wV0MKh1CqjnFNaSzs=
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1728056AbeLZWzs (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 26 Dec 2018 17:55:48 -0500
Received: from mail.kernel.org ([198.145.29.99]:56162 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1730228AbeLZWyu (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 26 Dec 2018 17:54:50 -0500
Received: from sasha-vm.mshome.net (c-73-47-72-35.hsd1.nh.comcast.net [73.47.72.35])
        (using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
        (No client certificate requested)
        by mail.kernel.org (Postfix) with ESMTPSA id 4E10321741;
        Wed, 26 Dec 2018 22:54:49 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
        s=default; t=1545864890;
        bh=4keKyb6ZHgwVJM5+Aw6qCFuQPEmhGlpyEpRoGrG6sLA=;
        h=From:To:Cc:Subject:Date:In-Reply-To:References:From;
        b=hKmeBAtfqD8eRQWStnxg5JPBZa6gi0LMdEMB/mRc2KOatvD0HS4q++niwAiUgifFk
         OTQFetnjSla3q3m+SRUhyupklHN/KmE8ljjzX2ld2OSPLNrPq4hQwzws8VUQ4clMXe
         Pn193YVcenMp7DRRT61KmuG86pjJcp4CJzKhegHs=
From:   Sasha Levin <sashal@kernel.org>
To:     stable@vger.kernel.org, linux-kernel@vger.kernel.org
Cc:     Trond Myklebust <trond.myklebust@hammerspace.com>,
        Sasha Levin <sashal@kernel.org>, linux-nfs@vger.kernel.org,
        netdev@vger.kernel.org
Subject: [PATCH AUTOSEL 4.9 29/35] SUNRPC: Fix a race with XPRT_CONNECTING
Date:   Wed, 26 Dec 2018 17:41:36 -0500
Message-Id: <20181226224142.150866-29-sashal@kernel.org>
X-Mailer: git-send-email 2.19.1
In-Reply-To: <20181226224142.150866-1-sashal@kernel.org>
References: <20181226224142.150866-1-sashal@kernel.org>
MIME-Version: 1.0
X-Patchwork-Hint: Ignore
Content-Transfer-Encoding: 8bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

From: Trond Myklebust <trond.myklebust@hammerspace.com>

[ Upstream commit cf76785d30712d90185455e752337acdb53d2a5d ]

Ensure that we clear XPRT_CONNECTING before releasing the XPRT_LOCK so that
we don't have races between the (asynchronous) socket setup code and
tasks in xprt_connect().

Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>
Tested-by: Chuck Lever <chuck.lever@oracle.com>
Signed-off-by: Sasha Levin <sashal@kernel.org>
---
 net/sunrpc/xprtsock.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
index 1bf9153004cd..280fb3178708 100644
--- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -2209,8 +2209,8 @@ static void xs_udp_setup_socket(struct work_struct *work)
 	trace_rpc_socket_connect(xprt, sock, 0);
 	status = 0;
 out:
-	xprt_unlock_connect(xprt, transport);
 	xprt_clear_connecting(xprt);
+	xprt_unlock_connect(xprt, transport);
 	xprt_wake_pending_tasks(xprt, status);
 }
 
@@ -2395,8 +2395,8 @@ static void xs_tcp_setup_socket(struct work_struct *work)
 	}
 	status = -EAGAIN;
 out:
-	xprt_unlock_connect(xprt, transport);
 	xprt_clear_connecting(xprt);
+	xprt_unlock_connect(xprt, transport);
 	xprt_wake_pending_tasks(xprt, status);
 }
 
-- 
2.19.1

