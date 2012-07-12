Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:39990 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758747Ab2GLGlN (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 12 Jul 2012 02:41:13 -0400
From: Mel Gorman <mgorman@suse.de>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Linux-MM <linux-mm@kvack.org>, Linux-Netdev <netdev@vger.kernel.org>,
        Linux-NFS <linux-nfs@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>,
        David Miller <davem@davemloft.net>,
        Trond Myklebust <Trond.Myklebust@netapp.com>,
        Neil Brown <neilb@suse.de>, Christoph Hellwig <hch@infradead.org>,
        Peter Zijlstra <a.p.zijlstra@chello.nl>,
        Mike Christie <michaelc@cs.wisc.edu>,
        Eric B Munson <emunson@mgebm.net>,
        Sebastian Andrzej Siewior <sebastian@breakpoint.cc>,
        Mel Gorman <mgorman@suse.de>
Subject: [PATCH 02/12] selinux: tag avc cache alloc as non-critical
Date: Thu, 12 Jul 2012 07:40:56 +0100
Message-Id: <1342075266-29593-3-git-send-email-mgorman@suse.de>
In-Reply-To: <1342075266-29593-1-git-send-email-mgorman@suse.de>
References: <1342075266-29593-1-git-send-email-mgorman@suse.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Failing to allocate a cache entry will only harm performance not
correctness.  Do not consume valuable reserve pages for something
like that.

Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
Signed-off-by: Mel Gorman <mgorman@suse.de>
Acked-by: Eric Paris <eparis@redhat.com>
Acked-by: Rik van Riel <riel@redhat.com>
---
 security/selinux/avc.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/security/selinux/avc.c b/security/selinux/avc.c
index 68d82da..4d3fab4 100644
--- a/security/selinux/avc.c
+++ b/security/selinux/avc.c
@@ -274,7 +274,7 @@ static struct avc_node *avc_alloc_node(void)
 {
 	struct avc_node *node;
 
-	node = kmem_cache_zalloc(avc_node_cachep, GFP_ATOMIC);
+	node = kmem_cache_zalloc(avc_node_cachep, GFP_ATOMIC|__GFP_NOMEMALLOC);
 	if (!node)
 		goto out;
 
-- 
1.7.9.2

