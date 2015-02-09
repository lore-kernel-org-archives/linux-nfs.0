Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ie0-f173.google.com ([209.85.223.173]:42298 "EHLO
	mail-ie0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759235AbbBIDHt (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 8 Feb 2015 22:07:49 -0500
Received: by iery20 with SMTP id y20so5074103ier.9
        for <linux-nfs@vger.kernel.org>; Sun, 08 Feb 2015 19:07:48 -0800 (PST)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 03/11] SUNRPC: Do not clear the source port in xs_reset_transport
Date: Sun,  8 Feb 2015 22:07:34 -0500
Message-Id: <1423451262-84493-4-git-send-email-trond.myklebust@primarydata.com>
In-Reply-To: <1423451262-84493-3-git-send-email-trond.myklebust@primarydata.com>
References: <1423451262-84493-1-git-send-email-trond.myklebust@primarydata.com>
 <1423451262-84493-2-git-send-email-trond.myklebust@primarydata.com>
 <1423451262-84493-3-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Now that we can reuse bound ports after a close, we never really want to
clear the transport's source port after it has been set. Doing so really
messes up the NFSv3 DRC on the server.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 net/sunrpc/xprtsock.c | 2 --
 1 file changed, 2 deletions(-)

diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
index 20f25a837e06..ea1882f97912 100644
--- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -811,8 +811,6 @@ static void xs_reset_transport(struct sock_xprt *transport)
 	if (sk == NULL)
 		return;
 
-	transport->srcport = 0;
-
 	write_lock_bh(&sk->sk_callback_lock);
 	transport->inet = NULL;
 	transport->sock = NULL;
-- 
2.1.0

