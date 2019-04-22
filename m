Return-Path: <SRS0=DK+G=SY=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id ECB80C282CE
	for <linux-nfs@archiver.kernel.org>; Mon, 22 Apr 2019 19:44:16 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id B9B2D218FF
	for <linux-nfs@archiver.kernel.org>; Mon, 22 Apr 2019 19:44:16 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1555962256;
	bh=YVAge1jwdxc8jahHy6wegdv2f2qIzEVhckJcPKeB2t4=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References:List-ID:From;
	b=n3QEk/Ayhmy/5mFeqs4dSAr9ZmFVh1mykSxyufP+mM2LLdxfH3bgHT5GOGSHfwhCA
	 FPlAFFTx/yccC2thybpCf0vLXu6xaY59Nd6eAaQx4GSpTfvyTJoCXYIZaGsBmbblZL
	 sj6B18mfnhNkWs1Ci7Vxuwx/q5nkN5h8lJP6x5aY=
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1728929AbfDVToP (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 22 Apr 2019 15:44:15 -0400
Received: from mail.kernel.org ([198.145.29.99]:45226 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1728886AbfDVToP (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 22 Apr 2019 15:44:15 -0400
Received: from sasha-vm.mshome.net (c-73-47-72-35.hsd1.nh.comcast.net [73.47.72.35])
        (using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
        (No client certificate requested)
        by mail.kernel.org (Postfix) with ESMTPSA id 45940218D9;
        Mon, 22 Apr 2019 19:44:13 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
        s=default; t=1555962254;
        bh=YVAge1jwdxc8jahHy6wegdv2f2qIzEVhckJcPKeB2t4=;
        h=From:To:Cc:Subject:Date:In-Reply-To:References:From;
        b=iAmSpuowSJQs/bYsRx/SnSXxRKVHi44cfhmX1h4RKYbegMMh5eG34fabs360Upv8p
         RnenQxiIazyeZ1E6vOauQfQbcc5YOLhoscsFoK25Yo92QBP47WSgMk2aaiqk38Y1eC
         hiDpN3MgyPkF2xcA7vpA4pSU28ZVInqglIRj7qmI=
From:   Sasha Levin <sashal@kernel.org>
To:     linux-kernel@vger.kernel.org, stable@vger.kernel.org
Cc:     Alakesh Haloi <alakesh.haloi@gmail.com>,
        Trond Myklebust <trond.myklebust@hammerspace.com>,
        Sasha Levin <sashal@kernel.org>, linux-nfs@vger.kernel.org,
        netdev@vger.kernel.org
Subject: [PATCH AUTOSEL 5.0 67/98] SUNRPC: fix uninitialized variable warning
Date:   Mon, 22 Apr 2019 15:41:34 -0400
Message-Id: <20190422194205.10404-67-sashal@kernel.org>
X-Mailer: git-send-email 2.19.1
In-Reply-To: <20190422194205.10404-1-sashal@kernel.org>
References: <20190422194205.10404-1-sashal@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
X-stable: review
X-Patchwork-Hint: Ignore
Content-Transfer-Encoding: 8bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

From: Alakesh Haloi <alakesh.haloi@gmail.com>

[ Upstream commit 01f2f5b82a2b523ae76af53f2ff43c48dde10a00 ]

Avoid following compiler warning on uninitialized variable

net/sunrpc/xprtsock.c: In function ‘xs_read_stream_request.constprop’:
net/sunrpc/xprtsock.c:525:10: warning: ‘read’ may be used uninitialized in this function [-Wmaybe-uninitialized]
   return read;
          ^~~~
net/sunrpc/xprtsock.c:529:23: warning: ‘ret’ may be used uninitialized in this function [-Wmaybe-uninitialized]
  return ret < 0 ? ret : read;
         ~~~~~~~~~~~~~~^~~~~~

Signed-off-by: Alakesh Haloi <alakesh.haloi@gmail.com>
Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>
Signed-off-by: Sasha Levin (Microsoft) <sashal@kernel.org>
---
 net/sunrpc/xprtsock.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
index 7754aa3e434f..f88c2bd1335a 100644
--- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -486,8 +486,8 @@ xs_read_stream_request(struct sock_xprt *transport, struct msghdr *msg,
 		int flags, struct rpc_rqst *req)
 {
 	struct xdr_buf *buf = &req->rq_private_buf;
-	size_t want, read;
-	ssize_t ret;
+	size_t want, uninitialized_var(read);
+	ssize_t uninitialized_var(ret);
 
 	xs_read_header(transport, buf);
 
-- 
2.19.1

