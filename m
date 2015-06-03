Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ie0-f180.google.com ([209.85.223.180]:36268 "EHLO
	mail-ie0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755449AbbFCUOo (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 3 Jun 2015 16:14:44 -0400
Received: by ieclw1 with SMTP id lw1so21847873iec.3
        for <linux-nfs@vger.kernel.org>; Wed, 03 Jun 2015 13:14:43 -0700 (PDT)
From: Jeff Layton <jlayton@poochiereds.net>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: linux-nfs@vger.kernel.org, linux-mm@kvack.org,
        linux-kernel@vger.kernel.org, Mel Gorman <mgorman@suse.de>,
        Jerome Marchand <jmarchan@redhat.com>,
        Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH v3 3/5] sunrpc: if we're closing down a socket, clear memalloc on it first
Date: Wed,  3 Jun 2015 16:14:27 -0400
Message-Id: <1433362469-2615-4-git-send-email-jeff.layton@primarydata.com>
In-Reply-To: <1433362469-2615-1-git-send-email-jeff.layton@primarydata.com>
References: <1433362469-2615-1-git-send-email-jeff.layton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

We currently increment the memalloc_socks counter if we have a xprt that
is associated with a swapfile. That socket can be replaced however
during a reconnect event, and the memalloc_socks counter is never
decremented if that occurs.

When tearing down a xprt socket, check to see if the xprt is set up for
swapping and sk_clear_memalloc before releasing the socket if so.

Acked-by: Mel Gorman <mgorman@suse.de>
Signed-off-by: Jeff Layton <jeff.layton@primarydata.com>
---
 net/sunrpc/xprtsock.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
index 3f34dbcbec6a..cb928ae4e8f4 100644
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
2.4.2

