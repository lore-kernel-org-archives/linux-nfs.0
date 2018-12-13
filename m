Return-Path: <SRS0=HBvY=OW=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.3 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8FEB0C67839
	for <linux-nfs@archiver.kernel.org>; Thu, 13 Dec 2018 04:40:44 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 561F620849
	for <linux-nfs@archiver.kernel.org>; Thu, 13 Dec 2018 04:40:44 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1544676044;
	bh=UMQ7CAcx4Xs4fR2Xct2jrydV8zF1+bQV7RhEdOif7Tg=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References:List-ID:From;
	b=kks7Nfm6kXPXRInSvLvyJJCbcym0fyEN5fccxCgN3lp42+oguimGmKI827FwITIaH
	 kv6ocUnHTiMFV9QSZDFttWPR4/1HlsT43xozAroCVhsdMQ9ZHdm0wA+MUvWXPOgWGA
	 fHVrDS12hZAkA4PvED64MhibpwM+mACarx4JNvZ0=
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 561F620849
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1729037AbeLMEcU (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 12 Dec 2018 23:32:20 -0500
Received: from mail.kernel.org ([198.145.29.99]:45228 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1729032AbeLMEcR (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 12 Dec 2018 23:32:17 -0500
Received: from sasha-vm.mshome.net (c-73-47-72-35.hsd1.nh.comcast.net [73.47.72.35])
        (using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
        (No client certificate requested)
        by mail.kernel.org (Postfix) with ESMTPSA id 8C99F20879;
        Thu, 13 Dec 2018 04:32:16 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
        s=default; t=1544675537;
        bh=UMQ7CAcx4Xs4fR2Xct2jrydV8zF1+bQV7RhEdOif7Tg=;
        h=From:To:Cc:Subject:Date:In-Reply-To:References:From;
        b=M6N57AtGfUz1JVEA75c2uCYVBeZ5hzt1xkFiGIyg+zoExJdkuclqMMmLsy4jGN33S
         3IERBVGc1ykpmdSPx+5NOv4R1IUO9QRlNfMg9hA3BtN2Cob96daIU+WxYp8u3o6sq9
         eNcRprHwAmtEAhv/PWufZj6FMAwunzDrJMViF1+8=
From:   Sasha Levin <sashal@kernel.org>
To:     linux-kernel@vger.kernel.org, stable@vger.kernel.org
Cc:     Trond Myklebust <trond.myklebust@hammerspace.com>,
        Sasha Levin <sashal@kernel.org>, linux-nfs@vger.kernel.org,
        netdev@vger.kernel.org
Subject: [PATCH AUTOSEL 4.9 10/34] SUNRPC: Fix a potential race in xprt_connect()
Date:   Wed, 12 Dec 2018 23:31:36 -0500
Message-Id: <20181213043200.76295-10-sashal@kernel.org>
X-Mailer: git-send-email 2.19.1
In-Reply-To: <20181213043200.76295-1-sashal@kernel.org>
References: <20181213043200.76295-1-sashal@kernel.org>
MIME-Version: 1.0
X-Patchwork-Hint: Ignore
Content-Transfer-Encoding: 8bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

From: Trond Myklebust <trond.myklebust@hammerspace.com>

[ Upstream commit 0a9a4304f3614e25d9de9b63502ca633c01c0d70 ]

If an asynchronous connection attempt completes while another task is
in xprt_connect(), then the call to rpc_sleep_on() could end up
racing with the call to xprt_wake_pending_tasks().
So add a second test of the connection state after we've put the
task to sleep and set the XPRT_CONNECTING flag, when we know that there
can be no asynchronous connection attempts still in progress.

Fixes: 0b9e79431377d ("SUNRPC: Move the test for XPRT_CONNECTING into...")
Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>
Signed-off-by: Sasha Levin <sashal@kernel.org>
---
 net/sunrpc/xprt.c | 11 +++++++++--
 1 file changed, 9 insertions(+), 2 deletions(-)

diff --git a/net/sunrpc/xprt.c b/net/sunrpc/xprt.c
index 685e6d225414..1a8df242d26a 100644
--- a/net/sunrpc/xprt.c
+++ b/net/sunrpc/xprt.c
@@ -778,8 +778,15 @@ void xprt_connect(struct rpc_task *task)
 			return;
 		if (xprt_test_and_set_connecting(xprt))
 			return;
-		xprt->stat.connect_start = jiffies;
-		xprt->ops->connect(xprt, task);
+		/* Race breaker */
+		if (!xprt_connected(xprt)) {
+			xprt->stat.connect_start = jiffies;
+			xprt->ops->connect(xprt, task);
+		} else {
+			xprt_clear_connecting(xprt);
+			task->tk_status = 0;
+			rpc_wake_up_queued_task(&xprt->pending, task);
+		}
 	}
 	xprt_release_write(xprt, task);
 }
-- 
2.19.1

