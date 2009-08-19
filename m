From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 20/32] NFSD: Clean up the idmapper warning...
Date: Wed, 19 Aug 2009 19:38:43 -0400
Message-ID: <1250725135-14632-21-git-send-email-Trond.Myklebust@netapp.com>
References: <1250725135-14632-1-git-send-email-Trond.Myklebust@netapp.com>
	 <1250725135-14632-2-git-send-email-Trond.Myklebust@netapp.com>
	 <1250725135-14632-3-git-send-email-Trond.Myklebust@netapp.com>
	 <1250725135-14632-4-git-send-email-Trond.Myklebust@netapp.com>
	 <1250725135-14632-5-git-send-email-Trond.Myklebust@netapp.com>
	 <1250725135-14632-6-git-send-email-Trond.Myklebust@netapp.com>
	 <1250725135-14632-7-git-send-email-Trond.Myklebust@netapp.com>
	 <1250725135-14632-8-git-send-email-Trond.Myklebust@netapp.com>
	 <1250725135-14632-9-git-send-email-Trond.Myklebust@netapp.com>
	 <1250725135-14632-10-git-send-email-Trond.Myklebust@netapp.com>
	 <1250725135-14632-11-git-send-email-Trond.Myklebust@netapp.com>
	 <1250725135-14632-12-git-send-email-Trond.Myklebust@netapp.com>
	 <1250725135-14632-13-git-send-email-Trond.Myklebust@netapp.com>
	 <1250725135-14632-14-git-send-email-Trond.Myklebust@netapp.com>
	 <1250725135-14632-15-git-send-email-Trond.Myklebust@netapp.com>
	 <1250725135-14632-16-git-send-email-Trond.Myklebust@netapp.com>
	 <1250725135-14632-17-git-send-email-Trond.Myklebust@netapp.com>
	 <1250725135-14632-18-git-send-email-Trond.Myklebust@netapp.com>
	 <1250725135-14632-19-git-send-email-Trond.Myklebust@netapp.com>
	 <1250725135-14632-20-git-send-email-Trond.Myklebust@netapp.com>
Mime-Version: 1.0
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:32245 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754064AbZHSXky (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 19 Aug 2009 19:40:54 -0400
Received: from sacrsexc2-prd.hq.netapp.com (sacrsexc2-prd.hq.netapp.com [10.99.115.28])
	by smtp1.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id n7JNePRR001724
	for <linux-nfs@vger.kernel.org>; Wed, 19 Aug 2009 16:40:43 -0700 (PDT)
In-Reply-To: <1250725135-14632-20-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

What part of 'internal use' is so hard to understand?

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 fs/nfsd/nfs4idmap.c          |    4 ++--
 include/linux/sunrpc/cache.h |    3 ++-
 net/sunrpc/cache.c           |    2 +-
 3 files changed, 5 insertions(+), 4 deletions(-)

diff --git a/fs/nfsd/nfs4idmap.c b/fs/nfsd/nfs4idmap.c
index 5b39842..e9012ad 100644
--- a/fs/nfsd/nfs4idmap.c
+++ b/fs/nfsd/nfs4idmap.c
@@ -175,10 +175,10 @@ idtoname_show(struct seq_file *m, struct cache_detail *cd, struct cache_head *h)
 }
 
 static void
-warn_no_idmapd(struct cache_detail *detail)
+warn_no_idmapd(struct cache_detail *detail, int has_died)
 {
 	printk("nfsd: nfsv4 idmapping failing: has idmapd %s?\n",
-			detail->last_close? "died" : "not been started");
+			has_died ? "died" : "not been started");
 }
 
 
diff --git a/include/linux/sunrpc/cache.h b/include/linux/sunrpc/cache.h
index 2d8b211..3d1fad2 100644
--- a/include/linux/sunrpc/cache.h
+++ b/include/linux/sunrpc/cache.h
@@ -79,6 +79,8 @@ struct cache_detail {
 	int			(*cache_show)(struct seq_file *m,
 					      struct cache_detail *cd,
 					      struct cache_head *h);
+	void			(*warn_no_listener)(struct cache_detail *cd,
+					      int has_died);
 
 	struct cache_head *	(*alloc)(void);
 	int			(*match)(struct cache_head *orig, struct cache_head *new);
@@ -102,7 +104,6 @@ struct cache_detail {
 	atomic_t		readers;		/* how many time is /chennel open */
 	time_t			last_close;		/* if no readers, when did last close */
 	time_t			last_warn;		/* when we last warned about no readers */
-	void			(*warn_no_listener)(struct cache_detail *cd);
 };
 
 
diff --git a/net/sunrpc/cache.c b/net/sunrpc/cache.c
index ff0c230..8ede4a6 100644
--- a/net/sunrpc/cache.c
+++ b/net/sunrpc/cache.c
@@ -1020,7 +1020,7 @@ static void warn_no_listener(struct cache_detail *detail)
 	if (detail->last_warn != detail->last_close) {
 		detail->last_warn = detail->last_close;
 		if (detail->warn_no_listener)
-			detail->warn_no_listener(detail);
+			detail->warn_no_listener(detail, detail->last_close != 0);
 	}
 }
 
-- 
1.6.0.4
