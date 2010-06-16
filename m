Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from citi.umich.edu ([141.212.112.111]:59350 "EHLO citi.umich.edu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752156Ab0FQORb (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 17 Jun 2010 10:17:31 -0400
Received: from localhost.localdomain (netapp-61.citi.umich.edu [141.212.112.250])
	by citi.umich.edu (Postfix) with ESMTP id 235D8180A0
	for <linux-nfs@vger.kernel.org>; Thu, 17 Jun 2010 10:17:31 -0400 (EDT)
From: Fred Isaman <iisaman@netapp.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 1/1] net: fix deliver_no_wcard regression on loopback device
Date: Wed, 16 Jun 2010 09:02:30 -0400
Message-Id: <1276693350-1780-2-git-send-email-iisaman@netapp.com>
In-Reply-To: <1276693350-1780-1-git-send-email-iisaman@netapp.com>
References: <1276693350-1780-1-git-send-email-iisaman@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

From: John Fastabend <john.r.fastabend@intel.com>

deliver_no_wcard is not being set in skb_copy_header.
In the skb_cloned case it is not being cleared and
may cause the skb to be dropped when the loopback device
pushes it back up the stack.

Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
---
 net/core/skbuff.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index 9f07e74..bcf2fa3 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -532,6 +532,7 @@ static void __copy_skb_header(struct sk_buff *new, const struct sk_buff *old)
 	new->ip_summed		= old->ip_summed;
 	skb_copy_queue_mapping(new, old);
 	new->priority		= old->priority;
+	new->deliver_no_wcard	= old->deliver_no_wcard;
 #if defined(CONFIG_IP_VS) || defined(CONFIG_IP_VS_MODULE)
 	new->ipvs_property	= old->ipvs_property;
 #endif
-- 
1.6.6.1

