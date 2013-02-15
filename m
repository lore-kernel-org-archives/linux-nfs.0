Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ye0-f175.google.com ([209.85.213.175]:55334 "EHLO
	mail-ye0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756789Ab3BOSgn (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 15 Feb 2013 13:36:43 -0500
Received: by mail-ye0-f175.google.com with SMTP id q7so597012yen.34
        for <linux-nfs@vger.kernel.org>; Fri, 15 Feb 2013 10:36:41 -0800 (PST)
From: Jeff Layton <jlayton@redhat.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH] nfsd: fix compiler warning about ambiguous types in nfsd_cache_csum
Date: Fri, 15 Feb 2013 13:36:34 -0500
Message-Id: <1360953394-3711-1-git-send-email-jlayton@redhat.com>
In-Reply-To: <511e6d26.xHlK4Y2OCRu6/h4W%fengguang.wu@intel.com>
References: <511e6d26.xHlK4Y2OCRu6/h4W%fengguang.wu@intel.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

kbuild test robot says:

tree:   git://linux-nfs.org/~bfields/linux.git for-3.9
head:   deb4534f4f3be7aea7d9d24c3b0d58f370cbf9ef
commit: 01a7decf75930925322c5efc87af0b5e58eb8650 [32/44] nfsd: keep a checksum of the first 256 bytes of request
config: i386-randconfig-x088 (attached as .config)

All warnings:

   fs/nfsd/nfscache.c: In function 'nfsd_cache_csum':
>> fs/nfsd/nfscache.c:266:9: warning: comparison of distinct pointer types lacks a cast [enabled by default]

vim +266 fs/nfsd/nfscache.c

   250		__wsum csum;
   251		struct xdr_buf *buf = &rqstp->rq_arg;
   252		const unsigned char *p = buf->head[0].iov_base;
   253		size_t csum_len = min_t(size_t, buf->head[0].iov_len + buf->page_len,
   254					RC_CSUMLEN);
   255		size_t len = min(buf->head[0].iov_len, csum_len);
   256
   257		/* rq_arg.head first */
   258		csum = csum_partial(p, len, 0);
   259		csum_len -= len;
   260
   261		/* Continue into page array */
   262		idx = buf->page_base / PAGE_SIZE;
   263		base = buf->page_base & ~PAGE_MASK;
   264		while (csum_len) {
   265			p = page_address(buf->pages[idx]) + base;
 > 266			len = min(PAGE_SIZE - base, csum_len);
   267			csum = csum_partial(p, len, csum);
   268			csum_len -= len;
   269			base = 0;
   270			++idx;
   271		}
   272		return csum;
   273	}
   274

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 fs/nfsd/nfscache.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/fs/nfsd/nfscache.c b/fs/nfsd/nfscache.c
index 40db57e..8d16948 100644
--- a/fs/nfsd/nfscache.c
+++ b/fs/nfsd/nfscache.c
@@ -263,7 +263,7 @@ nfsd_cache_csum(struct svc_rqst *rqstp)
 	base = buf->page_base & ~PAGE_MASK;
 	while (csum_len) {
 		p = page_address(buf->pages[idx]) + base;
-		len = min(PAGE_SIZE - base, csum_len);
+		len = min_t(size_t, PAGE_SIZE - base, csum_len);
 		csum = csum_partial(p, len, csum);
 		csum_len -= len;
 		base = 0;
-- 
1.7.11.7

