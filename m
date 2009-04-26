From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: NFS BUG_ON in nfs_do_writepage
Date: Sun, 26 Apr 2009 13:55:22 -0400
Message-ID: <1240768522.10548.33.camel@heimdal.trondhjem.org>
References: <alpine.LFD.2.00.0904130145050.4396@centaur.acm.jhu.edu>
	 <20090412235010.c8e3475b.akpm@linux-foundation.org>
	 <1239650202.16771.15.camel@heimdal.trondhjem.org>
	 <5da0588e0904131506k5c58e8ddob9bf38f61da6302a@mail.gmail.com>
	 <5da0588e0904131644g131dc816r61884e83bc4cd006@mail.gmail.com>
	 <5da0588e0904240226j3454941y5f58c17a32a9a23d@mail.gmail.com>
	 <1240671428.6112.1.camel@heimdal.trondhjem.org>
	 <20090426064026.GD28555@wotan.suse.de>
	 <1240755509.5055.34.camel@heimdal.trondhjem.org>
	 <20090426151324.GB5588@wotan.suse.de>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-fsdevel@vger.kernel.org, Rince <rincebrain@gmail.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	linux-kernel@vger.kernel.org, linux-nfs@vger.kernel.org
To: Nick Piggin <npiggin@suse.de>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1755578AbZDZRzo@vger.kernel.org>
In-Reply-To: <20090426151324.GB5588@wotan.suse.de>
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sun, 2009-04-26 at 17:13 +0200, Nick Piggin wrote:
> On Sun, Apr 26, 2009 at 10:18:29AM -0400, Trond Myklebust wrote:
> > On Sun, 2009-04-26 at 08:40 +0200, Nick Piggin wrote:
> > > On Sat, Apr 25, 2009 at 10:57:08AM -0400, Trond Myklebust wrote:
> > > > On Fri, 2009-04-24 at 05:26 -0400, Rince wrote:
> > > > > Applied try 3 of Nick Piggin's patch to 2.6.30-rc3 (cleanly, no less!)
> > > > > 
> > > > > Doesn't appear to have helped at all - I received my favorite BUG ON
> > > > > write.c:252 just like always, within 24 hours of booting the kernel,
> > > > > even.
> > > > 
> > > > Can you apply the following incremental patch on top of Nick's. This
> > > > appears to suffice to close the race on my setup.
> > > 
> > > Thanks, yes that looks good. Note: I deliberately didn't try to
> > > convert filesystems because it needs much better understanding
> > > of each one. So any fs maintainers using page_mkwrite I hope have
> > > looked at these patches and considered whether they need to
> > > do anything differently (ditto for the page_mkwrite return value
> > > fixup patch).
> > 
> > Note that after applying this, I put a WARN_ON(!PageDirty()) in the NFS
> > set_page_dirty() method, and ran some mmap stress tests.
> > 
> > As far as I can tell, the WARN_ON is never triggering. I take this to
> > mean that the remaining cases where the VM is calling set_page_dirty()
> > are basically all cases where we've already seen a page fault and set
> > the page dirty flag, but haven't yet written it out (i.e. we haven't yet
> > called clear_page_dirty_for_io() and so the pte is still marked as
> > dirty).
> > That again implies that set_page_dirty() is now fully redundant for
> > filesystems that define page_mkwrite(), provided that the filesystem
> > takes charge of marking the page as dirty.
> > 
> > This suggests an alternative fix for the stable kernels in the form of
> > the following patch.
> > Comments?
> 
> This doesn't seem to fix the race, though... on kernels with the
> race still there, it will just open a window where you can have
> a dirty pte but the page not written out.
> 
> I don't understand.

I'm just pointing out that the NFS client already calls
__set_page_dirty_nobuffers() while holding the page lock inside the
nfs_vm_page_mkwrite() call, so having the VM do it too in the call to
set_page_dirty_balance() is actually redundant. IOW: as far as the NFS
code is concerned, we can get rid of the ->set_page_dirty() callback in
that situation.

I couldn't find any other places in the VM code where we can have a
dirty pte without also having called page_mkwrite() (and hence
__set_page_dirty_nobuffers). As I said, adding a WARN_ON(!PageDirty())
in ->set_page_dirty() didn't ever trigger any cases where the
set_page_dirty() was actually setting the dirty bit (except in the case
where we race with page writeout in do_wp_page() and __do_fault()).

That's why I believe disabling ->set_page_dirty() is safe here, and will
in fact suffice to fix the page writeout race.

Cheers
  Trond
