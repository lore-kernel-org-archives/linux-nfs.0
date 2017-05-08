Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:11159 "EHLO mga03.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752682AbdEHRIk (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 8 May 2017 13:08:40 -0400
Date: Mon, 8 May 2017 11:08:36 -0600
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
Subject: Re: [PATCH v2 1/2] dax: prevent invalidation of mapped DAX entries
Message-ID: <20170508170836.GA19867@linux.intel.com>
References: <20170504195910.11579-1-ross.zwisler@linux.intel.com>
 <20170505072912.GA25424@quack2.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20170505072912.GA25424@quack2.suse.cz>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, May 05, 2017 at 09:29:12AM +0200, Jan Kara wrote:
> On Thu 04-05-17 13:59:09, Ross Zwisler wrote:
> > dax_invalidate_mapping_entry() currently removes DAX exceptional entries
> > only if they are clean and unlocked.  This is done via:
> > 
> > invalidate_mapping_pages()
> >   invalidate_exceptional_entry()
> >     dax_invalidate_mapping_entry()
> > 
> > However, for page cache pages removed in invalidate_mapping_pages() there
> > is an additional criteria which is that the page must not be mapped.  This
> > is noted in the comments above invalidate_mapping_pages() and is checked in
> > invalidate_inode_page().
> > 
> > For DAX entries this means that we can can end up in a situation where a
> > DAX exceptional entry, either a huge zero page or a regular DAX entry,
> > could end up mapped but without an associated radix tree entry. This is
> > inconsistent with the rest of the DAX code and with what happens in the
> > page cache case.
> > 
> > We aren't able to unmap the DAX exceptional entry because according to its
> > comments invalidate_mapping_pages() isn't allowed to block, and
> > unmap_mapping_range() takes a write lock on the mapping->i_mmap_rwsem.
> > 
> > We could potentially do an rmap walk to see if each of the entries actually
> > has any active mappings before we remove it, but this might end up being
> > very expensive and doesn't currently look to be worth it.
> > 
> > So, just remove dax_invalidate_mapping_entry() and leave the DAX entries in
> > the radix tree.
> > 
> > Signed-off-by: Ross Zwisler <ross.zwisler@linux.intel.com>
> > Fixes: c6dcf52c23d2 ("mm: Invalidate DAX radix tree entries only if appropriate")
> > Reported-by: Jan Kara <jack@suse.cz>
> > Reviewed-by: Jan Kara <jack@suse.cz>
> > Cc: <stable@vger.kernel.org>    [4.10+]
> 
> Ah, I've just sent out a series which contains these two patches and
> another two patches which change the entry locking to fix the last spotted
> race...  So either just take my last two patches on top of these two or
> take my series as a whole.

Sounds good. You added a better comment in invalidate_inode_pages2_range(), so
let's just use your version of this series.
