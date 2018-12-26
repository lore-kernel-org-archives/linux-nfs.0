Return-Path: <SRS0=jCTp=PD=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.6 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 00140C43444
	for <linux-nfs@archiver.kernel.org>; Wed, 26 Dec 2018 22:49:35 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id BB28C214D8
	for <linux-nfs@archiver.kernel.org>; Wed, 26 Dec 2018 22:49:35 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1545864575;
	bh=OQWImJeqRvngWR0yc1X/tp0KaoreniDBKTiYGMsYBrE=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References:List-ID:From;
	b=Kxx7R/pgQTYYHe7QWH2nmjbP0rVFVbx2P81v5TkWTb3f8qAEp74xvvPC12/ycu95S
	 p7LAvcVqW8p6NT50sIPsGrmwcVpn4HMCZPctvbQKTszHxaPfpGI0eE7wulYF90tpT0
	 d6w47WTVmPUrCutOtRUyxMpyqvNZcM5QRaOhM82Q=
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727214AbeLZWt1 (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 26 Dec 2018 17:49:27 -0500
Received: from mail.kernel.org ([198.145.29.99]:38048 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1728547AbeLZWhw (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 26 Dec 2018 17:37:52 -0500
Received: from sasha-vm.mshome.net (c-73-47-72-35.hsd1.nh.comcast.net [73.47.72.35])
        (using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
        (No client certificate requested)
        by mail.kernel.org (Postfix) with ESMTPSA id 415DF2054F;
        Wed, 26 Dec 2018 22:37:51 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
        s=default; t=1545863871;
        bh=OQWImJeqRvngWR0yc1X/tp0KaoreniDBKTiYGMsYBrE=;
        h=From:To:Cc:Subject:Date:In-Reply-To:References:From;
        b=2Qjz7lG73pjuJAQH6d5pc6+gttPbh2Q5tQR5K7+dYKVzIO28tVUnjh+9utnG9TDMA
         EfDLcczX4I4YsXQzkulcO7/4AbPD0YoCv/hJPXqyk2YL0cbdN92mcHhFXSygfZ9nrQ
         Gny4758q2sCPEMqeQb31v/NsmyQAzB7VBY8dErqs=
From:   Sasha Levin <sashal@kernel.org>
To:     stable@vger.kernel.org, linux-kernel@vger.kernel.org
Cc:     Trond Myklebust <trond.myklebust@hammerspace.com>,
        Sasha Levin <sashal@kernel.org>, linux-nfs@vger.kernel.org,
        netdev@vger.kernel.org
Subject: [PATCH AUTOSEL 4.19 66/97] SUNRPC: Fix a race with XPRT_CONNECTING
Date:   Wed, 26 Dec 2018 17:35:26 -0500
Message-Id: <20181226223557.149329-66-sashal@kernel.org>
X-Mailer: git-send-email 2.19.1
In-Reply-To: <20181226223557.149329-1-sashal@kernel.org>
References: <20181226223557.149329-1-sashal@kernel.org>
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
index 6b7539c0466e..7d8cce1dfcad 100644
--- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -2244,8 +2244,8 @@ static void xs_udp_setup_socket(struct work_struct *work)
 	trace_rpc_socket_connect(xprt, sock, 0);
 	status = 0;
 out:
-	xprt_unlock_connect(xprt, transport);
 	xprt_clear_connecting(xprt);
+	xprt_unlock_connect(xprt, transport);
 	xprt_wake_pending_tasks(xprt, status);
 }
 
@@ -2480,8 +2480,8 @@ static void xs_tcp_setup_socket(struct work_struct *work)
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

