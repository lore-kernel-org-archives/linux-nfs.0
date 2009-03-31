From: Greg Banks <gnb@sgi.com>
Subject: [patch 15/29] knfsd: fix reply cache memory corruption
Date: Wed, 01 Apr 2009 07:28:15 +1100
Message-ID: <20090331202943.252497000@sgi.com>
References: <20090331202800.739621000@sgi.com>
Cc: Linux NFS ML <linux-nfs@vger.kernel.org>
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from [218.185.19.242] ([218.185.19.242]:22585 "EHLO inara.melbourne"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1762419AbZCaVCp (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 31 Mar 2009 17:02:45 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Fix a regression in the reply cache introduced when the code was
converted to use proper Linux lists.  When a new entry needs to be
inserted, the case where all the entries are currently being used
by threads is not correctly detected.  This can result in memory
corruption and a crash.  In the current code this is an extremely
unlikely corner case; it would require the machine to have 1024
nfsd threads and all of them to be busy at the same time.  However,
upcoming reply cache changes make this more likely; a crash due to
this problem was actually observed in field.

Signed-off-by: Greg Banks <gnb@sgi.com>
---

 fs/nfsd/nfscache.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

Index: bfields/fs/nfsd/nfscache.c
===================================================================
--- bfields.orig/fs/nfsd/nfscache.c
+++ bfields/fs/nfsd/nfscache.c
@@ -177,8 +177,8 @@ nfsd_cache_lookup(struct svc_rqst *rqstp
 	}
 	}
 
-	/* This should not happen */
-	if (rp == NULL) {
+	/* All entries on the LRU are in-progress. This should not happen */
+	if (&rp->c_lru == &lru_head) {
 		static int	complaints;
 
 		printk(KERN_WARNING "nfsd: all repcache entries locked!\n");

--
Greg
