Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ie0-f169.google.com ([209.85.223.169]:44377 "EHLO
	mail-ie0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933720AbbBIWsS (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 9 Feb 2015 17:48:18 -0500
Received: by iecrl12 with SMTP id rl12so20409441iec.11
        for <linux-nfs@vger.kernel.org>; Mon, 09 Feb 2015 14:48:17 -0800 (PST)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH v3 03/15] SUNRPC: Do not clear the source port in xs_reset_transport
Date: Mon,  9 Feb 2015 17:47:59 -0500
Message-Id: <1423522091-35365-4-git-send-email-trond.myklebust@primarydata.com>
In-Reply-To: <1423522091-35365-3-git-send-email-trond.myklebust@primarydata.com>
References: <1423522091-35365-1-git-send-email-trond.myklebust@primarydata.com>
 <1423522091-35365-2-git-send-email-trond.myklebust@primarydata.com>
 <1423522091-35365-3-git-send-email-trond.myklebust@primarydata.com>
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

