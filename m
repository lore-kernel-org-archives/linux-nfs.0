Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:46076 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933450Ab1IILBA (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 9 Sep 2011 07:01:00 -0400
From: Mel Gorman <mgorman@suse.de>
To: Linux-MM <linux-mm@kvack.org>
Cc: Linux-Netdev <netdev@vger.kernel.org>,
        Linux-NFS <linux-nfs@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>,
        Andrew Morton <akpm@linux-foundation.org>,
        David Miller <davem@davemloft.net>,
        Trond Myklebust <Trond.Myklebust@netapp.com>,
        Neil Brown <neilb@suse.de>, Peter Zijlstra <a.p.zijlstra@chello.nl>,
        Mel Gorman <mgorman@suse.de>
Subject: [PATCH 02/10] selinux: tag avc cache alloc as non-critical
Date: Fri,  9 Sep 2011 12:00:46 +0100
Message-Id: <1315566054-17209-3-git-send-email-mgorman@suse.de>
In-Reply-To: <1315566054-17209-1-git-send-email-mgorman@suse.de>
References: <1315566054-17209-1-git-send-email-mgorman@suse.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

Failing to allocate a cache entry will only harm performance not
correctness.  Do not consume valuable reserve pages for something
like that.

Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
Signed-off-by: Mel Gorman <mgorman@suse.de>
---
 security/selinux/avc.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/security/selinux/avc.c b/security/selinux/avc.c
index dca1c22..a68d200 100644
--- a/security/selinux/avc.c
+++ b/security/selinux/avc.c
@@ -280,7 +280,7 @@ static struct avc_node *avc_alloc_node(void)
 {
 	struct avc_node *node;
 
-	node = kmem_cache_zalloc(avc_node_cachep, GFP_ATOMIC);
+	node = kmem_cache_zalloc(avc_node_cachep, GFP_ATOMIC|__GFP_NOMEMALLOC);
 	if (!node)
 		goto out;
 
-- 
1.7.3.4

