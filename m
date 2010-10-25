Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:54552 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752004Ab0JYBVo (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 24 Oct 2010 21:21:44 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: neilb@suse.de, Menyhart Zoltan <Zoltan.Menyhart@bull.net>,
        "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 4/4] svcrpc: svc_tcp_sendto XTP_DEAD check is redundant
Date: Sun, 24 Oct 2010 21:21:33 -0400
Message-Id: <1287969693-12340-4-git-send-email-bfields@redhat.com>
In-Reply-To: <20101025010923.GB11470@fieldses.org>
References: <20101025010923.GB11470@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

The only caller (svc_send) has already checked XPT_DEAD.

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 net/sunrpc/svcsock.c |    3 ---
 1 files changed, 0 insertions(+), 3 deletions(-)

diff --git a/net/sunrpc/svcsock.c b/net/sunrpc/svcsock.c
index 1454739..07919e1 100644
--- a/net/sunrpc/svcsock.c
+++ b/net/sunrpc/svcsock.c
@@ -1135,9 +1135,6 @@ static int svc_tcp_sendto(struct svc_rqst *rqstp)
 	reclen = htonl(0x80000000|((xbufp->len ) - 4));
 	memcpy(xbufp->head[0].iov_base, &reclen, 4);
 
-	if (test_bit(XPT_DEAD, &rqstp->rq_xprt->xpt_flags))
-		return -ENOTCONN;
-
 	sent = svc_sendto(rqstp, &rqstp->rq_res);
 	if (sent != xbufp->len) {
 		printk(KERN_NOTICE
-- 
1.7.1

