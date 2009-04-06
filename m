From: Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH 2/2] SQUASHME: nfsd41: define nfsd4_set_statp as noop for !CONFIG_NFSD_V4
Date: Mon,  6 Apr 2009 12:00:49 +0300
Message-ID: <1239008449-8105-1-git-send-email-bhalevy@panasas.com>
References: <49D9C308.6020500@panasas.com>
Cc: Alexander Beregalov <a.beregalov@gmail.com>,
	Stephen Rothwell <sfr@canb.auug.org.au>,
	linux-next@vger.kernel.org, pnfs@linux-nfs.org,
	linux-nfs@vger.kernel.org, Benny Halevy <bhalevy@panasas.com>
To: " J. Bruce Fields" <bfields@fieldses.org>,
	Andy Adamson <andros@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from gw-ca.panasas.com ([209.116.51.66]:3960 "EHLO
	laguna.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751407AbZDFJBQ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 6 Apr 2009 05:01:16 -0400
In-Reply-To: <49D9C308.6020500@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Fixes following modpost error:
ERROR: "nfsd4_set_statp" [fs/nfsd/nfsd.ko] undefined!

Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 include/linux/nfsd/cache.h |    7 +++++++
 1 files changed, 7 insertions(+), 0 deletions(-)

diff --git a/include/linux/nfsd/cache.h b/include/linux/nfsd/cache.h
index a59a2df..5bccaab 100644
--- a/include/linux/nfsd/cache.h
+++ b/include/linux/nfsd/cache.h
@@ -75,6 +75,13 @@ int	nfsd_reply_cache_init(void);
 void	nfsd_reply_cache_shutdown(void);
 int	nfsd_cache_lookup(struct svc_rqst *, int);
 void	nfsd_cache_update(struct svc_rqst *, int, __be32 *);
+
+#ifdef CONFIG_NFSD_V4
 void	nfsd4_set_statp(struct svc_rqst *rqstp, __be32 *statp);
+#else  /* CONFIG_NFSD_V4 */
+static inline void nfsd4_set_statp(struct svc_rqst *rqstp, __be32 *statp)
+{
+}
+#endif /* CONFIG_NFSD_V4 */
 
 #endif /* NFSCACHE_H */
-- 
1.6.2.1

