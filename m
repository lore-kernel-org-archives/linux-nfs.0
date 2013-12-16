Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-pb0-f49.google.com ([209.85.160.49]:38755 "EHLO
	mail-pb0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751998Ab3LPCtD (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 15 Dec 2013 21:49:03 -0500
Received: by mail-pb0-f49.google.com with SMTP id jt11so4871500pbb.36
        for <linux-nfs@vger.kernel.org>; Sun, 15 Dec 2013 18:49:01 -0800 (PST)
Message-ID: <52AE6A11.3020307@gmail.com>
Date: Mon, 16 Dec 2013 10:48:49 +0800
From: Kinglong Mee <kinglongmee@gmail.com>
MIME-Version: 1.0
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: linux-nfs@vger.kernel.org
Subject: [PATCH] nfsd: get rid of unused function definition
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

commit 557ce2646e775f6bda734dd92b10d4780874b9c7 
"nfsd41: replace page based DRC with buffer based DRC"
have remove unused nfsd4_set_statp, but miss the function definition.

Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>
---
 fs/nfsd/cache.h | 8 --------
 1 file changed, 8 deletions(-)

diff --git a/fs/nfsd/cache.h b/fs/nfsd/cache.h
index d5c5b3e..b582f9a 100644
--- a/fs/nfsd/cache.h
+++ b/fs/nfsd/cache.h
@@ -84,12 +84,4 @@ int	nfsd_cache_lookup(struct svc_rqst *);
 void	nfsd_cache_update(struct svc_rqst *, int, __be32 *);
 int	nfsd_reply_cache_stats_open(struct inode *, struct file *);
 
-#ifdef CONFIG_NFSD_V4
-void	nfsd4_set_statp(struct svc_rqst *rqstp, __be32 *statp);
-#else  /* CONFIG_NFSD_V4 */
-static inline void nfsd4_set_statp(struct svc_rqst *rqstp, __be32 *statp)
-{
-}
-#endif /* CONFIG_NFSD_V4 */
-
 #endif /* NFSCACHE_H */
-- 
1.8.4.2
