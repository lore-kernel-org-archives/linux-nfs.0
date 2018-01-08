Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([65.50.211.133]:44449 "EHLO
        bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756078AbeAHLVM (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 8 Jan 2018 06:21:12 -0500
Received: from clnet-p099-196.ikbnet.co.at ([83.175.99.196] helo=localhost)
        by bombadil.infradead.org with esmtpsa (Exim 4.89 #1 (Red Hat Linux))
        id 1eYVUK-0002qY-8T
        for linux-nfs@vger.kernel.org; Mon, 08 Jan 2018 11:21:08 +0000
From: Christoph Hellwig <hch@lst.de>
To: linux-nfs@vger.kernel.org
Subject: [PATCH] sunrpc: remove dead code in svc_sock_setbufsize
Date: Mon,  8 Jan 2018 12:21:04 +0100
Message-Id: <20180108112104.3006-1-hch@lst.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Setting values in struct sock directly is the usual method.  Remove
the long dead code using set_fs() and the related comment.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 net/sunrpc/svcsock.c | 14 --------------
 1 file changed, 14 deletions(-)

diff --git a/net/sunrpc/svcsock.c b/net/sunrpc/svcsock.c
index ff8e06cd067e..5884583f93a4 100644
--- a/net/sunrpc/svcsock.c
+++ b/net/sunrpc/svcsock.c
@@ -384,25 +384,11 @@ static int svc_partial_recvfrom(struct svc_rqst *rqstp,
 static void svc_sock_setbufsize(struct socket *sock, unsigned int snd,
 				unsigned int rcv)
 {
-#if 0
-	mm_segment_t	oldfs;
-	oldfs = get_fs(); set_fs(KERNEL_DS);
-	sock_setsockopt(sock, SOL_SOCKET, SO_SNDBUF,
-			(char*)&snd, sizeof(snd));
-	sock_setsockopt(sock, SOL_SOCKET, SO_RCVBUF,
-			(char*)&rcv, sizeof(rcv));
-#else
-	/* sock_setsockopt limits use to sysctl_?mem_max,
-	 * which isn't acceptable.  Until that is made conditional
-	 * on not having CAP_SYS_RESOURCE or similar, we go direct...
-	 * DaveM said I could!
-	 */
 	lock_sock(sock->sk);
 	sock->sk->sk_sndbuf = snd * 2;
 	sock->sk->sk_rcvbuf = rcv * 2;
 	sock->sk->sk_write_space(sock->sk);
 	release_sock(sock->sk);
-#endif
 }
 
 static int svc_sock_secure_port(struct svc_rqst *rqstp)
-- 
2.14.2

