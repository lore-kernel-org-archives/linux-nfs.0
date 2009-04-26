From: Nick Piggin <npiggin@suse.de>
Subject: Re: NFS BUG_ON in nfs_do_writepage
Date: Sun, 26 Apr 2009 17:13:24 +0200
Message-ID: <20090426151324.GB5588@wotan.suse.de>
References: <alpine.LFD.2.00.0904130145050.4396@centaur.acm.jhu.edu> <20090412235010.c8e3475b.akpm@linux-foundation.org> <1239650202.16771.15.camel@heimdal.trondhjem.org> <5da0588e0904131506k5c58e8ddob9bf38f61da6302a@mail.gmail.com> <5da0588e0904131644g131dc816r61884e83bc4cd006@mail.gmail.com> <5da0588e0904240226j3454941y5f58c17a32a9a23d@mail.gmail.com> <1240671428.6112.1.camel@heimdal.trondhjem.org> <20090426064026.GD28555@wotan.suse.de> <1240755509.5055.34.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-fsdevel@vger.kernel.org, Rince <rincebrain@gmail.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	linux-kernel@vger.kernel.org, linux-nfs@vger.kernel.org
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1755562AbZDZPNo@vger.kernel.org>
In-Reply-To: <1240755509.5055.34.camel@heimdal.trondhjem.org>
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sun, Apr 26, 2009 at 10:18:29AM -0400, Trond Myklebust wrote:
> On Sun, 2009-04-26 at 08:40 +0200, Nick Piggin wrote:
> > On Sat, Apr 25, 2009 at 10:57:08AM -0400, Trond Myklebust wrote:
> > > On Fri, 2009-04-24 at 05:26 -0400, Rince wrote:
> > > > Applied try 3 of Nick Piggin's patch to 2.6.30-rc3 (cleanly, no less!)
> > > > 
> > > > Doesn't appear to have helped at all - I received my favorite BUG ON
> > > > write.c:252 just like always, within 24 hours of booting the kernel,
> > > > even.
> > > 
> > > Can you apply the following incremental patch on top of Nick's. This
> > > appears to suffice to close the race on my setup.
> > 
> > Thanks, yes that looks good. Note: I deliberately didn't try to
> > convert filesystems because it needs much better understanding
> > of each one. So any fs maintainers using page_mkwrite I hope have
> > looked at these patches and considered whether they need to
> > do anything differently (ditto for the page_mkwrite return value
> > fixup patch).
> 
> Note that after applying this, I put a WARN_ON(!PageDirty()) in the NFS
> set_page_dirty() method, and ran some mmap stress tests.
> 
> As far as I can tell, the WARN_ON is never triggering. I take this to
> mean that the remaining cases where the VM is calling set_page_dirty()
> are basically all cases where we've already seen a page fault and set
> the page dirty flag, but haven't yet written it out (i.e. we haven't yet
> called clear_page_dirty_for_io() and so the pte is still marked as
> dirty).
> That again implies that set_page_dirty() is now fully redundant for
> filesystems that define page_mkwrite(), provided that the filesystem
> takes charge of marking the page as dirty.
> 
> This suggests an alternative fix for the stable kernels in the form of
> the following patch.
> Comments?

This doesn't seem to fix the race, though... on kernels with the
race still there, it will just open a window where you can have
a dirty pte but the page not written out.

I don't understand.

> Cheers
>   Trond
> ------------------------------------------------------------------
> commit 684049bf73059aa9be35f9cdf07acda29ebb0340
> Author: Trond Myklebust <Trond.Myklebust@netapp.com>
> Date:   Sun Apr 26 10:14:34 2009 -0400
> 
>     NFS: Fix page dirtying races in NFS
>     
>     If a filesystem defines a page_mkwrite() callback that also marks the page
>     as being dirty, then we don't need to define a set_page_dirty() callback.
>     
>     The following patch fixes http://bugzilla.kernel.org/show_bug.cgi?id=12913
>     by eliminating a race in do_wp_page() and __do_fault(). The latter two
>     mark the page as dirty after the call to page_mkwrite(). Since
>     nfs_vm_page_mkwrite() has already marked the page as dirty, this means that
>     there is a race whereby the filesystem may actually have cleaned the
>     page by the time it is marked as dirty (again) by the VM.
>     
>     Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
> ---
> diff --git a/fs/nfs/file.c b/fs/nfs/file.c
> index 5a97bcf..21bffaf 100644
> --- a/fs/nfs/file.c
> +++ b/fs/nfs/file.c
> @@ -465,10 +465,19 @@ static int nfs_launder_page(struct page *page)
>  	return nfs_wb_page(inode, page);
>  }
>  
> +static int nfs_set_page_dirty(struct page *page)
> +{
> +	/* We don't need to have the VM mark the page as dirty, since
> +	 * nfs_updatepage() will do it. This eliminates the race
> +	 * that caused http://bugzilla.kernel.org/show_bug.cgi?id=12913
> +	 */
> +	return 0;
> +}
> +
>  const struct address_space_operations nfs_file_aops = {
>  	.readpage = nfs_readpage,
>  	.readpages = nfs_readpages,
> -	.set_page_dirty = __set_page_dirty_nobuffers,
> +	.set_page_dirty = nfs_set_page_dirty,
>  	.writepage = nfs_writepage,
>  	.writepages = nfs_writepages,
>  	.write_begin = nfs_write_begin,
> 
