Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:46803 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758471Ab2HUU5f (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 21 Aug 2012 16:57:35 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 08/14] svcrpc: ignore unknown address type in udp receive
Date: Tue, 21 Aug 2012 16:57:26 -0400
Message-Id: <1345582652-18476-9-git-send-email-bfields@redhat.com>
In-Reply-To: <1345582652-18476-1-git-send-email-bfields@redhat.com>
References: <1345582652-18476-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@redhat.com>

How would this happen?

In any case, it appears this would be returned all the way up to the
caller of svc_recv(), and it's obvious that none of them are equipped to
handle it, and not clear what they would want to do with it anyway.
Let's just drop this and return -EAGAIN.

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 net/sunrpc/svcsock.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/sunrpc/svcsock.c b/net/sunrpc/svcsock.c
index 06ae8a7..97ce23f 100644
--- a/net/sunrpc/svcsock.c
+++ b/net/sunrpc/svcsock.c
@@ -602,7 +602,7 @@ static int svc_udp_recvfrom(struct svc_rqst *rqstp)
 	}
 	len = svc_addr_len(svc_addr(rqstp));
 	if (len == 0)
-		return -EAFNOSUPPORT;
+		return -EAGAIN;
 	rqstp->rq_addrlen = len;
 	if (skb->tstamp.tv64 == 0) {
 		skb->tstamp = ktime_get_real();
-- 
1.7.9.5

