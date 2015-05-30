Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-wi0-f182.google.com ([209.85.212.182]:35480 "EHLO
	mail-wi0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757782AbbE3MDi (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 30 May 2015 08:03:38 -0400
Received: by wicmx19 with SMTP id mx19so38731346wic.0
        for <linux-nfs@vger.kernel.org>; Sat, 30 May 2015 05:03:37 -0700 (PDT)
From: Jeff Layton <jlayton@poochiereds.net>
To: trond.myklebust@primarydata.com
Cc: linux-nfs@vger.kernel.org, linux-mm@kvack.org,
        linux-kernel@vger.kernel.org, Mel Gorman <mgorman@suse.de>,
        Jerome Marchand <jmarchan@redhat.com>
Subject: [PATCH 3/4] sunrpc: if we're closing down a socket, clear memalloc on it first
Date: Sat, 30 May 2015 08:03:12 -0400
Message-Id: <1432987393-15604-4-git-send-email-jeff.layton@primarydata.com>
In-Reply-To: <1432987393-15604-1-git-send-email-jeff.layton@primarydata.com>
References: <1432987393-15604-1-git-send-email-jeff.layton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

We currently increment the memalloc_socks counter if we have a xprt that
is associated with a swapfile. That socket can be replaced however
during a reconnect event, and the memalloc_socks counter is never
decremented if that occurs.

When tearing down a xprt socket, check to see if the xprt is set up for
swapping and sk_clear_memalloc before releasing the socket if so.

Cc: Mel Gorman <mgorman@suse.de>
Signed-off-by: Jeff Layton <jeff.layton@primarydata.com>
---
 net/sunrpc/xprtsock.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
index a2861bbfd319..359446442112 100644
--- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -827,6 +827,9 @@ static void xs_reset_transport(struct sock_xprt *transport)
 	if (sk == NULL)
 		return;
 
+	if (atomic_read(&transport->xprt.swapper))
+		sk_clear_memalloc(sk);
+
 	write_lock_bh(&sk->sk_callback_lock);
 	transport->inet = NULL;
 	transport->sock = NULL;
-- 
2.4.1

