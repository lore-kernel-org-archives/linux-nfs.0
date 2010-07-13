From: Xiaotian Feng <dfeng@redhat.com>
Subject: [PATCH -mmotm 20/30] netfilter: NF_QUEUE vs emergency skbs
Date: Tue, 13 Jul 2010 06:20:37 -0400
Message-ID: <20100713102036.2835.36872.sendpatchset@danny.redhat>
References: <20100713101650.2835.15245.sendpatchset@danny.redhat>
Cc: riel@redhat.com, cl@linux-foundation.org, a.p.zijlstra@chello.nl,
        Xiaotian Feng <dfeng@redhat.com>, linux-kernel@vger.kernel.org,
        lwang@redhat.com, penberg@cs.helsinki.fi, akpm@linux-foundation.org,
        davem@davemloft.net
To: linux-mm@kvack.org, linux-nfs@vger.kernel.org, netdev@vger.kernel.org
Return-path: <owner-linux-mm@kvack.org>
In-Reply-To: <20100713101650.2835.15245.sendpatchset@danny.redhat>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-nfs.vger.kernel.org>

>From 6c5ccad4c45a73a6d9ebecbfcb1bce8ff3ca462f Mon Sep 17 00:00:00 2001
From: Xiaotian Feng <dfeng@redhat.com>
Date: Tue, 13 Jul 2010 11:38:29 +0800
Subject: [PATCH 20/30] netfilter: NF_QUEUE vs emergency skbs

Avoid memory getting stuck waiting for userspace, drop all emergency packets.
This of course requires the regular storage route to not include an NF_QUEUE
target ;-)

Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
Signed-off-by: Suresh Jayaraman <sjayaraman@suse.de>
Signed-off-by: Xiaotian Feng <dfeng@redhat.com>
---
 net/netfilter/core.c |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/net/netfilter/core.c b/net/netfilter/core.c
index 78b505d..cc04549 100644
--- a/net/netfilter/core.c
+++ b/net/netfilter/core.c
@@ -176,9 +176,12 @@ next_hook:
 	if (verdict == NF_ACCEPT || verdict == NF_STOP) {
 		ret = 1;
 	} else if (verdict == NF_DROP) {
+drop:
 		kfree_skb(skb);
 		ret = -EPERM;
 	} else if ((verdict & NF_VERDICT_MASK) == NF_QUEUE) {
+		if (skb_emergency(skb))
+			goto drop;
 		if (!nf_queue(skb, elem, pf, hook, indev, outdev, okfn,
 			      verdict >> NF_VERDICT_BITS))
 			goto next_hook;
-- 
1.7.1.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
