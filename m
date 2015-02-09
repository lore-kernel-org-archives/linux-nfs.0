Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ie0-f176.google.com ([209.85.223.176]:38603 "EHLO
	mail-ie0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933546AbbBIRSy (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 9 Feb 2015 12:18:54 -0500
Received: by iecrd18 with SMTP id rd18so6048667iec.5
        for <linux-nfs@vger.kernel.org>; Mon, 09 Feb 2015 09:18:54 -0800 (PST)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH v2 03/14] SUNRPC: Do not clear the source port in xs_reset_transport
Date: Mon,  9 Feb 2015 12:18:33 -0500
Message-Id: <1423502324-25981-4-git-send-email-trond.myklebust@primarydata.com>
In-Reply-To: <1423502324-25981-3-git-send-email-trond.myklebust@primarydata.com>
References: <1423502324-25981-1-git-send-email-trond.myklebust@primarydata.com>
 <1423502324-25981-2-git-send-email-trond.myklebust@primarydata.com>
 <1423502324-25981-3-git-send-email-trond.myklebust@primarydata.com>
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

