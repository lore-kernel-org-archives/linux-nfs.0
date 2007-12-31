From: Tom Tucker <tom@opengridcomputing.com>
Subject: [PATCH 12/40] svc: Remove unnecessary call to svc_sock_enqueue
Date: Sun, 30 Dec 2007 21:07:38 -0600
Message-ID: <20071231030738.8430.13238.stgit@dell3.ogc.int>
References: <20071231030712.8430.45576.stgit@dell3.ogc.int>
Content-Type: text/plain; charset=utf-8; format=fixed
Cc: linux-nfs@vger.kernel.org
To: bfields@fieldses.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from 209-198-142-2-host.prismnet.net ([209.198.142.2]:41507 "EHLO
	smtp.opengridcomputing.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752512AbXLaDHi (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 30 Dec 2007 22:07:38 -0500
In-Reply-To: <20071231030712.8430.45576.stgit-gUwIgmpLGaKNDNWfRnPdfg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


The svc_tcp_accept function calls svc_sock_enqueue after setting the
SK_CONN bit. This doesn't actually do anything because the SK_BUSY bit
is still set. The call is unnecessary anyway because the generic code in
svc_recv calls svc_sock_received after calling the accept function.

Signed-off-by: Tom Tucker <tom@opengridcomputing.com>
---

 net/sunrpc/svcsock.c |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)

diff --git a/net/sunrpc/svcsock.c b/net/sunrpc/svcsock.c
index 41d1f81..962dbf4 100644
--- a/net/sunrpc/svcsock.c
+++ b/net/sunrpc/svcsock.c
@@ -1064,7 +1064,6 @@ static struct svc_xprt *svc_tcp_accept(struct svc_xprt *xprt)
 	}
 
 	set_bit(SK_CONN, &svsk->sk_flags);
-	svc_sock_enqueue(svsk);
 
 	err = kernel_getpeername(newsock, sin, &slen);
 	if (err < 0) {
