Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:36744 "EHLO
        userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755869AbdDRPZP (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 18 Apr 2017 11:25:15 -0400
Date: Tue, 18 Apr 2017 11:24:11 -0400
From: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
To: Andrey Ryabinin <aryabinin@virtuozzo.com>
Cc: Alexander Viro <viro@zeniv.linux.org.uk>,
        linux-fsdevel@vger.kernel.org,
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
        v9fs-developer@lists.sourceforge.net, linux-kernel@vger.kernel.org,
        linux-cifs@vger.kernel.org, samba-technical@lists.samba.org,
        linux-nfs@vger.kernel.org, linux-mm@kvack.org
Subject: Re: [PATCH 0/4] Properly invalidate data in the cleancache.
Message-ID: <20170418152411.GC12001@char.us.oracle.com>
References: <20170414140753.16108-1-aryabinin@virtuozzo.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20170414140753.16108-1-aryabinin@virtuozzo.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Apr 14, 2017 at 05:07:49PM +0300, Andrey Ryabinin wrote:
> We've noticed that after direct IO write, buffered read sometimes gets
> stale data which is coming from the cleancache.

That is not good.
> The reason for this is that some direct write hooks call call invalidate_inode_pages2[_range]()
> conditionally iff mapping->nrpages is not zero, so we may not invalidate
> data in the cleancache.
> 
> Another odd thing is that we check only for ->nrpages and don't check for ->nrexceptional,

Yikes.
> but invalidate_inode_pages2[_range] also invalidates exceptional entries as well.
> So we invalidate exceptional entries only if ->nrpages != 0? This doesn't feel right.
> 
>  - Patch 1 fixes direct IO writes by removing ->nrpages check.
>  - Patch 2 fixes similar case in invalidate_bdev(). 
>      Note: I only fixed conditional cleancache_invalidate_inode() here.
>        Do we also need to add ->nrexceptional check in into invalidate_bdev()?
>      
>  - Patches 3-4: some optimizations.

Acked-by: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>

Thanks!
> 
> Andrey Ryabinin (4):
>   fs: fix data invalidation in the cleancache during direct IO
>   fs/block_dev: always invalidate cleancache in invalidate_bdev()
>   mm/truncate: bail out early from invalidate_inode_pages2_range() if
>     mapping is empty
>   mm/truncate: avoid pointless cleancache_invalidate_inode() calls.
> 
>  fs/9p/vfs_file.c |  2 +-
>  fs/block_dev.c   | 11 +++++------
>  fs/cifs/inode.c  |  2 +-
>  fs/dax.c         |  2 +-
>  fs/iomap.c       | 16 +++++++---------
>  fs/nfs/direct.c  |  6 ++----
>  fs/nfs/inode.c   |  8 +++++---
>  mm/filemap.c     | 26 +++++++++++---------------
>  mm/truncate.c    | 13 +++++++++----
>  9 files changed, 42 insertions(+), 44 deletions(-)
> 
> -- 
> 2.10.2
> 
