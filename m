Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-eopbgr50102.outbound.protection.outlook.com ([40.107.5.102]:35712
        "EHLO EUR03-VE1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1753063AbdDNOIH (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 14 Apr 2017 10:08:07 -0400
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
Subject: [PATCH 3/4] mm/truncate: bail out early from invalidate_inode_pages2_range() if mapping is empty
Date: Fri, 14 Apr 2017 17:07:52 +0300
Message-ID: <20170414140753.16108-4-aryabinin@virtuozzo.com>
In-Reply-To: <20170414140753.16108-1-aryabinin@virtuozzo.com>
References: <20170414140753.16108-1-aryabinin@virtuozzo.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

If mapping is empty (both ->nrpages and ->nrexceptional is zero) we can avoid
pointless lookups in empty radix tree and bail out immediately after cleancache
invalidation.

Signed-off-by: Andrey Ryabinin <aryabinin@virtuozzo.com>
---
 mm/truncate.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/mm/truncate.c b/mm/truncate.c
index 6263aff..8f12b0e 100644
--- a/mm/truncate.c
+++ b/mm/truncate.c
@@ -624,6 +624,9 @@ int invalidate_inode_pages2_range(struct address_space *mapping,
 	int did_range_unmap = 0;
 
 	cleancache_invalidate_inode(mapping);
+	if (mapping->nrpages == 0 && mapping->nrexceptional == 0)
+		return 0;
+
 	pagevec_init(&pvec, 0);
 	index = start;
 	while (index <= end && pagevec_lookup_entries(&pvec, mapping, index,
-- 
2.10.2

