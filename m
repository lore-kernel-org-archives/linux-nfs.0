From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH] improve the performance of large sequential write NFS
	workloads
Date: Fri, 25 Dec 2009 15:37:33 +0800
Message-ID: <20091225073733.GB8595@localhost>
References: <1261015420.1947.54.camel@serenity> <1261037877.27920.36.camel@laptop> <20091219122033.GA11360@localhost> <1261232747.1947.194.camel@serenity> <20091222015907.GA6223@localhost> <1261500113.13028.78.camel@serenity> <20091224012101.GA8486@localhost> <1261666180.13028.175.camel@serenity>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Peter Zijlstra <peterz@infradead.org>,
	"linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"Trond.Myklebust@netapp.com" <Trond.Myklebust@netapp.com>,
	"jens.axboe" <jens.axboe@oracle.com>,
	Peter Staubach <staubach@redhat.com>, Jan Kara <jack@suse.cz>,
	Arjan van de Ven <arjan@infradead.org>,
	Ingo Molnar <mingo@elte.hu>,
	"linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>
To: Steve Rago <sar@nec-labs.com>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
In-Reply-To: <1261666180.13028.175.camel@serenity>
Sender: linux-fsdevel-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Dec 24, 2009 at 10:49:40PM +0800, Steve Rago wrote:
> 
> On Thu, 2009-12-24 at 09:21 +0800, Wu Fengguang wrote:
> 
> > > Commits and writes on the same inode need to be serialized for
> > > consistency (write can change the data and metadata; commit [fsync]
> > > needs to provide guarantees that the written data are stable). The
> > > performance problem arises because NFS writes are fast (they generally
> > > just deposit data into the server's page cache), but commits can take a
> > 
> > Right. 
> > 
> > > long time, especially if there is a lot of cached data to flush to
> > > stable storage.
> > 
> > "a lot of cached data to flush" is not likely with pdflush, since it
> > roughly send one COMMIT per 4MB WRITEs. So in average each COMMIT
> > syncs 4MB at the server side.
> 
> Maybe on paper, but empirically I see anywhere from one commit per 8MB
> to one commit per 64 MB.

Thanks for the data. It seems that your CPU works faster than network,
so that non of the NFS writes (submitted by L543) return by the time we
try to COMMIT at L547.

 543         ret = do_writepages(mapping, wbc);
 544 
 545         /* Don't write the inode if only I_DIRTY_PAGES was set */
 546         if (dirty & (I_DIRTY_SYNC | I_DIRTY_DATASYNC)) {
 547                 int err = write_inode(inode, wait);

Thus pdflush is able to do several rounds of do_writepages() before
write_inode() can actually collect some pages to be COMMITed.

> > 
> > Your patch adds another pre-pdlush async write logic, which greatly
> > reduced the number of COMMITs by pdflush. Can this be the major factor
> > of the performance gain?
> 
> My patch removes pdflush from the picture almost entirely.  See my
> comments below.

Yes for sequential async writes, so I said "pre-pdflush" :)
 
> > 
> > Jan has been proposing to change the pdflush logic from
> > 
> >         loop over dirty files {
> >                 writeback 4MB
> >                 write_inode
> >         }
> > to
> >         loop over dirty files {
> >                 writeback all its dirty pages
> >                 write_inode
> >         }
> > 
> > This should also be able to reduce the COMMIT numbers. I wonder if
> > this (more general) approach can achieve the same performance gain.
> 
> The pdflush mechanism is fine for random writes and small sequential
> writes, because it promotes concurrency -- instead of the application
> blocking while it tries to write and commit its data, the application
> can go on doing other more useful things, and the data gets flushed in
> the background.  There is also a benefit if the application makes
> another modification to a page that is already dirty, because then
> multiple modifications are coalesced into a single write.

Right.

> However, the pdflush mechanism is wrong for large sequential writes
> (like a backup stream, for example).  First, there is no concurrency to
> exploit -- the application is only going to dirty more pages, so
> removing the need for it to block writing the pages out only adds to the
> problem of memory pressure.  Second, the application is not going to go
> back and modify a page it has already written, so leaving it in the
> cache for someone else to write provides no additional benefit.

Well, in general pdflush does more good than bad, that's why we need it. 
The above two reasons are about "pdflush is not as helpful", but not
that it is wrong.

That said, I do agree to limit the per-file dirty pages for NFS -- because
it tends to flush before simple stat/read operations, which could be costly.
 
> Note that this assumes the application actually cares about the
> consistency of its data and will call fsync() when it is done.  If the
> application doesn't call fsync(), then it doesn't matter when the pages
> are written to backing store, because the interface makes no guarantees
> in this case.


Thanks,
Fengguang
