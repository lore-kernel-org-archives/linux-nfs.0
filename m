Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mga05.intel.com ([192.55.52.43]:18527 "EHLO mga05.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1431465AbdDYW7j (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 25 Apr 2017 18:59:39 -0400
Date: Tue, 25 Apr 2017 16:59:36 -0600
From: Ross Zwisler <ross.zwisler@linux.intel.com>
To: Jan Kara <jack@suse.cz>
Cc: Ross Zwisler <ross.zwisler@linux.intel.com>,
        Andrew Morton <akpm@linux-foundation.org>,
        linux-kernel@vger.kernel.org,
        Alexander Viro <viro@zeniv.linux.org.uk>,
        Alexey Kuznetsov <kuznet@virtuozzo.com>,
        Andrey Ryabinin <aryabinin@virtuozzo.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        Christoph Hellwig <hch@lst.de>,
        Dan Williams <dan.j.williams@intel.com>,
        "Darrick J. Wong" <darrick.wong@oracle.com>,
        Eric Van Hensbergen <ericvh@gmail.com>,
        Jens Axboe <axboe@kernel.dk>,
        Johannes Weiner <hannes@cmpxchg.org>,
        Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>,
        Latchesar Ionkov <lucho@ionkov.net>,
        linux-cifs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        linux-mm@kvack.org, linux-nfs@vger.kernel.org,
        linux-nvdimm@lists.01.org, Matthew Wilcox <mawilcox@microsoft.com>,
        Ron Minnich <rminnich@sandia.gov>,
        samba-technical@lists.samba.org, Steve French <sfrench@samba.org>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        v9fs-developer@lists.sourceforge.net
Subject: Re: [PATCH 2/2] dax: fix data corruption due to stale mmap reads
Message-ID: <20170425225936.GA29655@linux.intel.com>
References: <20170420191446.GA21694@linux.intel.com>
 <20170421034437.4359-1-ross.zwisler@linux.intel.com>
 <20170421034437.4359-2-ross.zwisler@linux.intel.com>
 <20170425111043.GH2793@quack2.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20170425111043.GH2793@quack2.suse.cz>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Apr 25, 2017 at 01:10:43PM +0200, Jan Kara wrote:
<>
> Hum, but now thinking more about it I have hard time figuring out why write
> vs fault cannot actually still race:
> 
> CPU1 - write(2)				CPU2 - read fault
> 
> 					dax_iomap_pte_fault()
> 					  ->iomap_begin() - sees hole
> dax_iomap_rw()
>   iomap_apply()
>     ->iomap_begin - allocates blocks
>     dax_iomap_actor()
>       invalidate_inode_pages2_range()
>         - there's nothing to invalidate
> 					  grab_mapping_entry()
> 					  - we add zero page in the radix
> 					    tree & map it to page tables
> 
> Similarly read vs write fault may end up racing in a wrong way and try to
> replace already existing exceptional entry with a hole page?

Yep, this race seems real to me, too.  This seems very much like the issues
that exist when a thread is doing direct I/O.  One thread is doing I/O to an
intermediate buffer (page cache for direct I/O case, zero page for us), and
the other is going around it directly to media, and they can get out of sync.

IIRC the direct I/O code looked something like:

1/ invalidate existing mappings
2/ do direct I/O to media
3/ invalidate mappings again, just in case.  Should be cheap if there weren't
   any conflicting faults.  This makes sure any new allocations we made are
   faulted in.

I guess one option would be to replicate that logic in the DAX I/O path, or we
could try and enhance our locking so page faults can't race with I/O since
both can allocate blocks.

I'm not sure, but will think on it.
