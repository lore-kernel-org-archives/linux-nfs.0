Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:46804 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758500Ab2HUU5f (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 21 Aug 2012 16:57:35 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 07/14] svcrpc: minor udp code cleanup
Date: Tue, 21 Aug 2012 16:57:25 -0400
Message-Id: <1345582652-18476-8-git-send-email-bfields@redhat.com>
In-Reply-To: <1345582652-18476-1-git-send-email-bfields@redhat.com>
References: <1345582652-18476-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@redhat.com>

Order the code in a more boring way.

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 net/sunrpc/svcsock.c |    9 +++++----
 1 file changed, 5 insertions(+), 4 deletions(-)

diff --git a/net/sunrpc/svcsock.c b/net/sunrpc/svcsock.c
index c7a7b14..06ae8a7 100644
--- a/net/sunrpc/svcsock.c
+++ b/net/sunrpc/svcsock.c
@@ -620,10 +620,7 @@ static int svc_udp_recvfrom(struct svc_rqst *rqstp)
 	if (!svc_udp_get_dest_address(rqstp, cmh)) {
 		net_warn_ratelimited("svc: received unknown control message %d/%d; dropping RPC reply datagram\n",
 				     cmh->cmsg_level, cmh->cmsg_type);
-out_free:
-		trace_kfree_skb(skb, svc_udp_recvfrom);
-		skb_free_datagram_locked(svsk->sk_sk, skb);
-		return 0;
+		goto out_free;
 	}
 	rqstp->rq_daddrlen = svc_addr_len(svc_daddr(rqstp));
 
@@ -662,6 +659,10 @@ out_free:
 		serv->sv_stats->netudpcnt++;
 
 	return len;
+out_free:
+	trace_kfree_skb(skb, svc_udp_recvfrom);
+	skb_free_datagram_locked(svsk->sk_sk, skb);
+	return 0;
 }
 
 static int
-- 
1.7.9.5

