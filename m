From: Nick Piggin <npiggin@suse.de>
Subject: Re: NFS BUG_ON in nfs_do_writepage
Date: Tue, 28 Apr 2009 13:54:49 +0200
Message-ID: <20090428115449.GD9442@wotan.suse.de>
References: <5da0588e0904131506k5c58e8ddob9bf38f61da6302a@mail.gmail.com> <5da0588e0904131644g131dc816r61884e83bc4cd006@mail.gmail.com> <5da0588e0904240226j3454941y5f58c17a32a9a23d@mail.gmail.com> <1240671428.6112.1.camel@heimdal.trondhjem.org> <20090426064026.GD28555@wotan.suse.de> <1240755509.5055.34.camel@heimdal.trondhjem.org> <20090426151324.GB5588@wotan.suse.de> <1240768522.10548.33.camel@heimdal.trondhjem.org> <20090428042717.GA6304@wotan.suse.de> <1240919117.7376.6.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-fsdevel@vger.kernel.org, Rince <rincebrain@gmail.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	linux-kernel@vger.kernel.org, linux-nfs@vger.kernel.org
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
In-Reply-To: <1240919117.7376.6.camel@heimdal.trondhjem.org>
Sender: linux-fsdevel-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Apr 28, 2009 at 07:45:17AM -0400, Trond Myklebust wrote:
> On Tue, 2009-04-28 at 06:27 +0200, Nick Piggin wrote:
> > On Sun, Apr 26, 2009 at 01:55:22PM -0400, Trond Myklebust wrote:
> > > On Sun, 2009-04-26 at 17:13 +0200, Nick Piggin wrote:
> > > > This doesn't seem to fix the race, though... on kernels with the
> > > > race still there, it will just open a window where you can have
> > > > a dirty pte but the page not written out.
> > > > 
> > > > I don't understand.
> > > 
> > > I'm just pointing out that the NFS client already calls
> > > __set_page_dirty_nobuffers() while holding the page lock inside the
> > > nfs_vm_page_mkwrite() call, so having the VM do it too in the call to
> > > set_page_dirty_balance() is actually redundant. IOW: as far as the NFS
> > > code is concerned, we can get rid of the ->set_page_dirty() callback in
> > > that situation.
> > > 
> > > I couldn't find any other places in the VM code where we can have a
> > > dirty pte without also having called page_mkwrite() (and hence
> > > __set_page_dirty_nobuffers). As I said, adding a WARN_ON(!PageDirty())
> > > in ->set_page_dirty() didn't ever trigger any cases where the
> > > set_page_dirty() was actually setting the dirty bit (except in the case
> > > where we race with page writeout in do_wp_page() and __do_fault()).
> > > 
> > > That's why I believe disabling ->set_page_dirty() is safe here, and will
> > > in fact suffice to fix the page writeout race.
> > 
> > Ah, no I don't think so because it opens another race where the
> > pte is dity but the page is marked clean.
> 
> So how can that happen?

If the page gets cleaned after page_mkwrite and before the page
table locks are taken again in order to set the pte writeable.
(actually, page_mkclean only runs if it finds mapcount elevated,
so it is enough to clean the page even after the locks are taken
and before mapcount is incremented in the case of __do_fault).

 
> AFAICS, when the pte is dirtied, we should get a page fault, which
> causes the page itself to be marked dirty by the nfs_vm_page_mkwrite()
> callback.
> When the page gets written out, the VM calls clear_page_dirty_for_io()
> which also causes the pte to be cleaned.
> 
> At what point can you therefore have a situation where the pte is dirty
> without the page being marked as dirty too?

 
