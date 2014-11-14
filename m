Return-Path: linux-nfs-owner@vger.kernel.org
Received: from verein.lst.de ([213.95.11.211]:45364 "EHLO newverein.lst.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752632AbaKNHEF (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 14 Nov 2014 02:04:05 -0500
Date: Fri, 14 Nov 2014 08:04:01 +0100
From: Christoph Hellwig <hch@lst.de>
To: Weston Andros Adamson <dros@primarydata.com>
Cc: Peng Tao <bergwolf@primarydata.com>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        linux-nfs list <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] NFS: fix subtle change in COMMIT behavior
Message-ID: <20141114070401.GA3944@lst.de>
References: <1415812080-3033-1-git-send-email-dros@primarydata.com> <CAKVebiX=mRJ7Psc8+FigNLRgGB8vH84vcKdv173HvuT20+eh=w@mail.gmail.com> <20141113110244.GA25709@lst.de> <6E1CB959-CB60-4AE3-9392-65ABDF0DB2F0@primarydata.com>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="AqsLC8rIMeq19msA"
In-Reply-To: <6E1CB959-CB60-4AE3-9392-65ABDF0DB2F0@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


--AqsLC8rIMeq19msA
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

The patch below passes block layout testing for me:

--AqsLC8rIMeq19msA
Content-Type: text/x-patch; charset=us-ascii
Content-Disposition: attachment; filename="0001-pnfs-blocklayout-fix-end-calculation-in-pnfs_num_con.patch"

From: Christoph Hellwig <hch@lst.de>
Subject: pnfs/blocklayout: fix end calculation in pnfs_num_cont_bytes

Use the number of pages in the pagecache mapping instead of the
number of pnfs requests which is only slightly related.

Reported-by: Weston Andros Adamson <dros@primarydata.com>
Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 fs/nfs/blocklayout/blocklayout.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/fs/nfs/blocklayout/blocklayout.c b/fs/nfs/blocklayout/blocklayout.c
index 5228f20..98d4900 100644
--- a/fs/nfs/blocklayout/blocklayout.c
+++ b/fs/nfs/blocklayout/blocklayout.c
@@ -812,7 +812,7 @@ static u64 pnfs_num_cont_bytes(struct inode *inode, pgoff_t idx)
 
 	/* Optimize common case that writes from 0 to end of file */
 	end = DIV_ROUND_UP(i_size_read(inode), PAGE_CACHE_SIZE);
-	if (end != NFS_I(inode)->npages) {
+	if (end != inode->i_mapping->nr_pages) {
 		rcu_read_lock();
 		end = page_cache_next_hole(mapping, idx + 1, ULONG_MAX);
 		rcu_read_unlock();
-- 
1.9.1


--AqsLC8rIMeq19msA--
