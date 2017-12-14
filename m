Return-Path: <bfields@fieldses.org>
Date: Thu, 14 Dec 2017 11:36:54 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Benjamin Coddington <bcodding@redhat.com>
Cc: linux-nfs@vger.kernel.org, hch@infradead.org
Subject: Re: spurious sillyrename after O_DIRECT writes get ENOSPC
Message-ID: <20171214163654.GD9205@fieldses.org>
References: <20171208221626.GB22508@fieldses.org>
 <20171213171815.GB9205@fieldses.org>
 <9383ABA6-B994-4DB3-95F4-C0D6F59580F9@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <9383ABA6-B994-4DB3-95F4-C0D6F59580F9@redhat.com>
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Dec 14, 2017 at 08:08:53AM -0500, Benjamin Coddington wrote:
> 
> On 13 Dec 2017, at 12:18, J. Bruce Fields wrote:
> 
> > On Fri, Dec 08, 2017 at 05:16:26PM -0500, J. Bruce Fields wrote:
> >> Last year Christoph noticed a bug that could result in a file being
> >> unnecessarily sillyrenamed after O_DIRECT writes get ENOSPC:
> >>
> >> 	http://lkml.kernel.org/r/20160616150146.GA14015@infradead.org
> >>
> >> It's reproduceable on upstream, over v3 or v4.
> >>
> >> I looked into it some more, and it seems to reproduce whenever a write
> >> system call results in multiple WRITE calls, only some of which receive
> >> ENOSPC.  I think that's resulting in a leak of the wb_kref on some
> >> nfs_pages (possibly the ones corresponding to the ENOSPC failures?).
> >> Those nfs_pages in turn hold references on nfs_{lock,open}_contexts.  So
> >> a "rm" on the client (even after the file is closed) results in a
> >> sillyrename.
> >>
> >> I'll keep looking at this, but the relevant code is pretty opaque to me
> >> so far.  Any ideas welcomed.
> >
> > Actually it looks like a leak of dreq->io_count?  That prevents commits
> > from being sent (which I'm also seeing in network traces--the succesfull
> > WRITEs are unstable but never get committed), which means
> > nfs_direct_commit_complete() is never called, and the reference taken on
> > wb_kref in the request_commit case of nfs_direct_write_completion is
> > never put.
> 
> This sounds to me like the problem Scott's working - he sent a patch
> yesterday "nfs/pnfs: fix nfs_direct_req ref leak when i/o falls back to the
> mds".
> 
> I think the the rule should be that once we call
> nfs_pgio_completion_ops->init_hdr, we have to finish with ->completion.
> However, there are some paths where that is not the case.

Yes, I wondered about that....

Unfortunately after some more tests now I was think I was wrong, the
dreq_get()s and put()s are balanced and the bug is somewhere else--in
the case of my particular reproducer.  Argh.  But yes I can easily
believe there could be a leak there.

--b.

> 
> The callgraph in between nfs_pgheader_init() and nfs_initiate_pgio() in
> nfs_generic_pg_pgios() for this case might show where we're bailing out
> early.
