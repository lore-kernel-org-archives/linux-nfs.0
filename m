Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-eopbgr50104.outbound.protection.outlook.com ([40.107.5.104]:42301
        "EHLO EUR03-VE1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751544AbdDNOID (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 14 Apr 2017 10:08:03 -0400
From: Andrey Ryabinin <aryabinin@virtuozzo.com>
To: Alexander Viro <viro@zeniv.linux.org.uk>,
        <linux-fsdevel@vger.kernel.org>
CC: Andrey Ryabinin <aryabinin@virtuozzo.com>,
        Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>,
        Eric Van Hensbergen <ericvh@gmail.com>,
        Ron Minnich <rminnich@sandia.gov>,
        Latchesar Ionkov <lucho@ionkov.net>,
        Steve French <sfrench@samba.org>,
        Matthew Wilcox <mawilcox@microsoft.com>,
        Ross Zwisler <ross.zwisler@linux.intel.com>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        Andrew Morton <akpm@linux-foundation.org>,
        Jan Kara <jack@suse.cz>, Jens Axboe <axboe@kernel.dk>,
        Johannes Weiner <hannes@cmpxchg.org>,
        Alexey Kuznetsov <kuznet@virtuozzo.com>,
        Christoph Hellwig <hch@lst.de>,
        <v9fs-developer@lists.sourceforge.net>,
        <linux-kernel@vger.kernel.org>, <linux-cifs@vger.kernel.org>,
        <samba-technical@lists.samba.org>, <linux-nfs@vger.kernel.org>,
        <linux-mm@kvack.org>
Subject: [PATCH 2/4] fs/block_dev: always invalidate cleancache in invalidate_bdev()
Date: Fri, 14 Apr 2017 17:07:51 +0300
Message-ID: <20170414140753.16108-3-aryabinin@virtuozzo.com>
In-Reply-To: <20170414140753.16108-1-aryabinin@virtuozzo.com>
References: <20170414140753.16108-1-aryabinin@virtuozzo.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

invalidate_bdev() calls cleancache_invalidate_inode() iff ->nrpages != 0
which doen't make any sense.
Make invalidate_bdev() always invalidate cleancache data.

Fixes: c515e1fd361c ("mm/fs: add hooks to support cleancache")
Signed-off-by: Andrey Ryabinin <aryabinin@virtuozzo.com>
---
 fs/block_dev.c | 11 +++++------
 1 file changed, 5 insertions(+), 6 deletions(-)

diff --git a/fs/block_dev.c b/fs/block_dev.c
index e405d8e..7af4787 100644
--- a/fs/block_dev.c
+++ b/fs/block_dev.c
@@ -103,12 +103,11 @@ void invalidate_bdev(struct block_device *bdev)
 {
 	struct address_space *mapping = bdev->bd_inode->i_mapping;
 
-	if (mapping->nrpages == 0)
-		return;
-
-	invalidate_bh_lrus();
-	lru_add_drain_all();	/* make sure all lru add caches are flushed */
-	invalidate_mapping_pages(mapping, 0, -1);
+	if (mapping->nrpages) {
+		invalidate_bh_lrus();
+		lru_add_drain_all();	/* make sure all lru add caches are flushed */
+		invalidate_mapping_pages(mapping, 0, -1);
+	}
 	/* 99% of the time, we don't need to flush the cleancache on the bdev.
 	 * But, for the strange corners, lets be cautious
 	 */
-- 
2.10.2

