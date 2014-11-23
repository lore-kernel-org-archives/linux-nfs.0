Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-pa0-f46.google.com ([209.85.220.46]:60591 "EHLO
	mail-pa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752011AbaKWErq (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 22 Nov 2014 23:47:46 -0500
Received: by mail-pa0-f46.google.com with SMTP id lj1so7446668pab.19
        for <linux-nfs@vger.kernel.org>; Sat, 22 Nov 2014 20:47:45 -0800 (PST)
Received: from localhost ([106.120.101.38])
        by mx.google.com with ESMTPSA id c1sm8768813pdl.75.2014.11.22.20.47.44
        for <linux-nfs@vger.kernel.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 22 Nov 2014 20:47:45 -0800 (PST)
From: roy.qing.li@gmail.com
To: linux-nfs@vger.kernel.org
Subject: [PATCH 2/2] nfs: define nfs_inc_fscache_stats and using it as possible
Date: Sun, 23 Nov 2014 12:47:41 +0800
Message-Id: <1416718061-21003-1-git-send-email-roy.qing.li@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Li RongQing <roy.qing.li@gmail.com>

Define and use nfs_inc_fscache_stats when plus one, which can save to
pass one parameter.

Signed-off-by: Li RongQing <roy.qing.li@gmail.com>
---
 fs/nfs/fscache.c | 24 ++++++++++++------------
 fs/nfs/iostat.h  |  5 +++++
 2 files changed, 17 insertions(+), 12 deletions(-)

diff --git a/fs/nfs/fscache.c b/fs/nfs/fscache.c
index 3ef01f0..d63bea8 100644
--- a/fs/nfs/fscache.c
+++ b/fs/nfs/fscache.c
@@ -269,8 +269,8 @@ int nfs_fscache_release_page(struct page *page, gfp_t gfp)
 		if (!fscache_maybe_release_page(cookie, page, gfp))
 			return 0;
 
-		nfs_add_fscache_stats(page->mapping->host,
-				      NFSIOS_FSCACHE_PAGES_UNCACHED, 1);
+		nfs_inc_fscache_stats(page->mapping->host,
+				      NFSIOS_FSCACHE_PAGES_UNCACHED);
 	}
 
 	return 1;
@@ -293,8 +293,8 @@ void __nfs_fscache_invalidate_page(struct page *page, struct inode *inode)
 
 	BUG_ON(!PageLocked(page));
 	fscache_uncache_page(cookie, page);
-	nfs_add_fscache_stats(page->mapping->host,
-			      NFSIOS_FSCACHE_PAGES_UNCACHED, 1);
+	nfs_inc_fscache_stats(page->mapping->host,
+			      NFSIOS_FSCACHE_PAGES_UNCACHED);
 }
 
 /*
@@ -343,19 +343,19 @@ int __nfs_readpage_from_fscache(struct nfs_open_context *ctx,
 	case 0: /* read BIO submitted (page in fscache) */
 		dfprintk(FSCACHE,
 			 "NFS:    readpage_from_fscache: BIO submitted\n");
-		nfs_add_fscache_stats(inode, NFSIOS_FSCACHE_PAGES_READ_OK, 1);
+		nfs_inc_fscache_stats(inode, NFSIOS_FSCACHE_PAGES_READ_OK);
 		return ret;
 
 	case -ENOBUFS: /* inode not in cache */
 	case -ENODATA: /* page not in cache */
-		nfs_add_fscache_stats(inode, NFSIOS_FSCACHE_PAGES_READ_FAIL, 1);
+		nfs_inc_fscache_stats(inode, NFSIOS_FSCACHE_PAGES_READ_FAIL);
 		dfprintk(FSCACHE,
 			 "NFS:    readpage_from_fscache %d\n", ret);
 		return 1;
 
 	default:
 		dfprintk(FSCACHE, "NFS:    readpage_from_fscache %d\n", ret);
-		nfs_add_fscache_stats(inode, NFSIOS_FSCACHE_PAGES_READ_FAIL, 1);
+		nfs_inc_fscache_stats(inode, NFSIOS_FSCACHE_PAGES_READ_FAIL);
 	}
 	return ret;
 }
@@ -429,11 +429,11 @@ void __nfs_readpage_to_fscache(struct inode *inode, struct page *page, int sync)
 
 	if (ret != 0) {
 		fscache_uncache_page(nfs_i_fscache(inode), page);
-		nfs_add_fscache_stats(inode,
-				      NFSIOS_FSCACHE_PAGES_WRITTEN_FAIL, 1);
-		nfs_add_fscache_stats(inode, NFSIOS_FSCACHE_PAGES_UNCACHED, 1);
+		nfs_inc_fscache_stats(inode,
+				      NFSIOS_FSCACHE_PAGES_WRITTEN_FAIL);
+		nfs_inc_fscache_stats(inode, NFSIOS_FSCACHE_PAGES_UNCACHED);
 	} else {
-		nfs_add_fscache_stats(inode,
-				      NFSIOS_FSCACHE_PAGES_WRITTEN_OK, 1);
+		nfs_inc_fscache_stats(inode,
+				      NFSIOS_FSCACHE_PAGES_WRITTEN_OK);
 	}
 }
diff --git a/fs/nfs/iostat.h b/fs/nfs/iostat.h
index c583248..0cb806f 100644
--- a/fs/nfs/iostat.h
+++ b/fs/nfs/iostat.h
@@ -55,6 +55,11 @@ static inline void nfs_add_fscache_stats(struct inode *inode,
 {
 	this_cpu_add(NFS_SERVER(inode)->io_stats->fscache[stat], addend);
 }
+static inline void nfs_inc_fscache_stats(struct inode *inode,
+					 enum nfs_stat_fscachecounters stat)
+{
+	this_cpu_inc(NFS_SERVER(inode)->io_stats->fscache[stat]);
+}
 #endif
 
 static inline struct nfs_iostats __percpu *nfs_alloc_iostats(void)
-- 
2.1.0

