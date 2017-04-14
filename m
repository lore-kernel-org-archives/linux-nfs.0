Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-eopbgr50104.outbound.protection.outlook.com ([40.107.5.104]:42301
        "EHLO EUR03-VE1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751544AbdDNOH6 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 14 Apr 2017 10:07:58 -0400
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
Subject: [PATCH 0/4] Properly invalidate data in the cleancache.
Date: Fri, 14 Apr 2017 17:07:49 +0300
Message-ID: <20170414140753.16108-1-aryabinin@virtuozzo.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

We've noticed that after direct IO write, buffered read sometimes gets
stale data which is coming from the cleancache.
The reason for this is that some direct write hooks call call invalidate_inode_pages2[_range]()
conditionally iff mapping->nrpages is not zero, so we may not invalidate
data in the cleancache.

Another odd thing is that we check only for ->nrpages and don't check for ->nrexceptional,
but invalidate_inode_pages2[_range] also invalidates exceptional entries as well.
So we invalidate exceptional entries only if ->nrpages != 0? This doesn't feel right.

 - Patch 1 fixes direct IO writes by removing ->nrpages check.
 - Patch 2 fixes similar case in invalidate_bdev(). 
     Note: I only fixed conditional cleancache_invalidate_inode() here.
       Do we also need to add ->nrexceptional check in into invalidate_bdev()?
     
 - Patches 3-4: some optimizations.

Andrey Ryabinin (4):
  fs: fix data invalidation in the cleancache during direct IO
  fs/block_dev: always invalidate cleancache in invalidate_bdev()
  mm/truncate: bail out early from invalidate_inode_pages2_range() if
    mapping is empty
  mm/truncate: avoid pointless cleancache_invalidate_inode() calls.

 fs/9p/vfs_file.c |  2 +-
 fs/block_dev.c   | 11 +++++------
 fs/cifs/inode.c  |  2 +-
 fs/dax.c         |  2 +-
 fs/iomap.c       | 16 +++++++---------
 fs/nfs/direct.c  |  6 ++----
 fs/nfs/inode.c   |  8 +++++---
 mm/filemap.c     | 26 +++++++++++---------------
 mm/truncate.c    | 13 +++++++++----
 9 files changed, 42 insertions(+), 44 deletions(-)

-- 
2.10.2

