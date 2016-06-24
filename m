Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f194.google.com ([209.85.223.194]:32971 "EHLO
	mail-io0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751410AbcFXO42 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 24 Jun 2016 10:56:28 -0400
Received: by mail-io0-f194.google.com with SMTP id t74so15637528ioi.0
        for <linux-nfs@vger.kernel.org>; Fri, 24 Jun 2016 07:56:27 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 07/10] SUNRPC: Micro optimisation for svc_data_ready
Date: Fri, 24 Jun 2016 10:55:49 -0400
Message-Id: <1466780152-7154-7-git-send-email-trond.myklebust@primarydata.com>
In-Reply-To: <1466780152-7154-6-git-send-email-trond.myklebust@primarydata.com>
References: <1466780152-7154-1-git-send-email-trond.myklebust@primarydata.com>
 <1466780152-7154-2-git-send-email-trond.myklebust@primarydata.com>
 <1466780152-7154-3-git-send-email-trond.myklebust@primarydata.com>
 <1466780152-7154-4-git-send-email-trond.myklebust@primarydata.com>
 <1466780152-7154-5-git-send-email-trond.myklebust@primarydata.com>
 <1466780152-7154-6-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Don't call svc_xprt_enqueue() if the XPT_DATA flag is already set.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 net/sunrpc/svcsock.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/sunrpc/svcsock.c b/net/sunrpc/svcsock.c
index 03134708deeb..338d6fe1103d 100644
--- a/net/sunrpc/svcsock.c
+++ b/net/sunrpc/svcsock.c
@@ -409,8 +409,8 @@ static void svc_data_ready(struct sock *sk)
 			svsk, sk,
 			test_bit(XPT_BUSY, &svsk->sk_xprt.xpt_flags));
 		svsk->sk_odata(sk);
-		set_bit(XPT_DATA, &svsk->sk_xprt.xpt_flags);
-		svc_xprt_enqueue(&svsk->sk_xprt);
+		if (!test_and_set_bit(XPT_DATA, &svsk->sk_xprt.xpt_flags))
+			svc_xprt_enqueue(&svsk->sk_xprt);
 	}
 }
 
-- 
2.7.4

