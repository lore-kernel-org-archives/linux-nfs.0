Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:28936 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751545AbaAXR3w (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 24 Jan 2014 12:29:52 -0500
Date: Fri, 24 Jan 2014 12:29:24 -0500
From: Jeff Layton <jlayton@redhat.com>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: Christoph Hellwig <hch@infradead.org>,
        linuxnfs <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 7/7] nfs: page cache invalidation for dio
Message-ID: <20140124122924.0eb2e6bd@tlielax.poochiereds.net>
In-Reply-To: <1C06779A-6513-4460-9A12-6AAE7E6BD446@primarydata.com>
References: <20131114165027.355613182@bombadil.infradead.org>
	<20131114165042.205194841@bombadil.infradead.org>
	<20131114133551.5d08b5cd@tlielax.poochiereds.net>
	<20131115142847.GA1107@infradead.org>
	<20131115095241.2c5e1cfb@tlielax.poochiereds.net>
	<20131115150204.GA8105@infradead.org>
	<20131115103324.6a3cf978@tlielax.poochiereds.net>
	<20140121142159.210ca0b8@tlielax.poochiereds.net>
	<20140122082414.GA12530@infradead.org>
	<20140122070409.503db5c2@tlielax.poochiereds.net>
	<20140124105213.2c40a783@tlielax.poochiereds.net>
	<1C06779A-6513-4460-9A12-6AAE7E6BD446@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 24 Jan 2014 10:11:11 -0700
Trond Myklebust <trond.myklebust@primarydata.com> wrote:

> 
> On Jan 24, 2014, at 8:52, Jeff Layton <jlayton@redhat.com> wrote:
> 
> > On Wed, 22 Jan 2014 07:04:09 -0500
> > Jeff Layton <jlayton@redhat.com> wrote:
> > 
> >> On Wed, 22 Jan 2014 00:24:14 -0800
> >> Christoph Hellwig <hch@infradead.org> wrote:
> >> 
> >>> On Tue, Jan 21, 2014 at 02:21:59PM -0500, Jeff Layton wrote:
> >>>> In any case, this helps but it's a little odd. With this patch, you add
> >>>> an invalidate_inode_pages2 call prior to doing the DIO. But, you've
> >>>> also left in the call to nfs_zap_mapping in the completion codepath.
> >>>> 
> >>>> So now, we shoot down the mapping prior to doing a DIO write, and then
> >>>> mark the mapping for invalidation again when the write completes. Was
> >>>> that intentional?
> >>>> 
> >>>> It seems a little excessive and might hurt performance in some cases.
> >>>> OTOH, if you mix buffered and DIO you're asking for trouble anyway and
> >>>> this approach seems to give better cache coherency.
> >>> 
> >>> Thile follows the model implemented and documented in
> >>> generic_file_direct_write().
> >>> 
> >> 
> >> Ok, thanks. That makes sense, and the problem described in those
> >> comments is almost exactly the one I've seen in practice.
> >> 
> >> I'm still not 100% thrilled with the way that the NFS_INO_INVALID_DATA
> >> flag is handled, but that really has nothing to do with this patchset.
> >> 
> >> You can add my Tested-by to the set if you like...
> >> 
> > 
> > (re-sending with Trond's address fixed)
> > 
> > I may have spoken too soon...
> > 
> > This patchset didn't fix the problem once I cranked up the concurrency
> > from 100 child tasks to 1000. I think that HCH's patchset makes sense
> > and helps narrow the race window some, but the way that
> > nfs_revalidate_mapping/nfs_invalidate_mapping work is just racy.
> > 
> > The following patch does seem to fix it however. It's a combination of
> > a test patch that Trond gave me a while back and another change to
> > serialize the nfs_invalidate_mapping ops.
> > 
> > I think it's a reasonable approach to deal with the problem, but we
> > likely have some other areas that will need similar treatment since
> > they also check NFS_INO_INVALID_DATA: 
> > 
> >    nfs_write_pageuptodate
> >    nfs_readdir_search_for_cookie
> >    nfs_update_inode
> > 
> > Trond, thoughts? It's not quite ready for merge, but I'd like to get an
> > opinion on the basic approach, or whether you have an idea of how
> > better handle the races here:
> 
> I think that it is reasonable for nfs_revalidate_mapping, but I don’t see how it is relevant to nfs_update_inode or nfs_write_pageuptodate.
> Readdir already has its own locking at the VFS level, so we shouldn’t need to care there.
> 


nfs_write_pageuptodate does this:

---------------8<-----------------
        if (NFS_I(inode)->cache_validity & (NFS_INO_INVALID_DATA|NFS_INO_REVAL_PAGECACHE))
                return false;
out:
        return PageUptodate(page) != 0;
---------------8<-----------------

With the proposed patch, NFS_INO_INVALID_DATA would be cleared first and
only later would the page be invalidated. So, there's a race window in
there where the bit could be cleared but the page flag is still set,
even though it's on its way out the cache. So, I think we'd need to do
some similar sort of locking in there to make sure that doesn't happen.

nfs_update_inode just does this:

        if (invalid & NFS_INO_INVALID_DATA)
                nfs_fscache_invalidate(inode);

...again, since we clear the bit first with this patch, I think we have
a potential race window there too. We might not see it set in a
situation where we would have before. That case is a bit more
problematic since we can't sleep to wait on the bitlock there.

It might be best to just get rid of that call altogether and move it
into nfs_invalidate_mapping. It seems to me that we ought to just
handle fscache the same way we do the pagecache when it comes to
invalidation.

As far as the readdir code goes, I haven't looked as closely at that
yet. I just noticed that it checked for NFS_INO_INVALID_DATA. Once we
settle the other two cases, I'll give that closer scrutiny.

Thanks,
-- 
Jeff Layton <jlayton@redhat.com>
