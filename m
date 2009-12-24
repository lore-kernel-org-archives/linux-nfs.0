From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH] improve the performance of large sequential write NFS
	workloads
Date: Thu, 24 Dec 2009 09:26:06 +0800
Message-ID: <20091224012606.GB8486@localhost>
References: <1261015420.1947.54.camel@serenity> <1261037877.27920.36.camel@laptop> <20091219122033.GA11360@localhost> <1261232747.1947.194.camel@serenity> <20091222015907.GA6223@localhost> <20091222123538.GB604@atrey.karlin.mff.cuni.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Steve Rago <sar@nec-labs.com>,
	Peter Zijlstra <peterz@infradead.org>,
	"linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"Trond.Myklebust@netapp.com" <Trond.Myklebust@netapp.com>,
	"jens.axboe" <jens.axboe@oracle.com>,
	Peter Staubach <staubach@redhat.com>,
	Arjan van de Ven <arjan@infradead.org>,
	Ingo Molnar <mingo@elte.hu>,
	"linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>
To: Jan Kara <jack@suse.cz>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
In-Reply-To: <20091222123538.GB604@atrey.karlin.mff.cuni.cz>
Sender: linux-fsdevel-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Dec 22, 2009 at 08:35:39PM +0800, Jan Kara wrote:
> > 2) NFS commit stops pipeline because it sleep&wait inside i_mutex,
> >    which blocks all other NFSDs trying to write/writeback the inode.
> > 
> >    nfsd_sync:
> >      take i_mutex
> >        filemap_fdatawrite
> >        filemap_fdatawait
> >      drop i_mutex
>   I believe this is unrelated to the problem Steve is trying to solve.
> When we get to doing sync writes the performance is busted so we better
> shouldn't get to that (unless user asked for that of course).

Yes, first priority is always to reduce the COMMITs and the number of
writeback pages they submitted under WB_SYNC_ALL. And I guess the
"increase write chunk beyond 128MB" patches can serve it well.

The i_mutex should impact NFS write performance for single big copy in
this way: pdflush submits many (4MB write, 1 commit) pairs, because
the write and commit each will take i_mutex, it effectively limits the
server side io queue depth to <=4MB: the next 4MB dirty data won't
reach page cache until the previous 4MB is completely synced to disk.

There are two kinds of inefficiency here:
- the small queue depth
- the interleaved use of CPU/DISK:
        loop {
                write 4MB       => normally only CPU
                writeback 4MB   => mostly disk
        }

When writing many small dirty files _plus_ one big file, there will
still be interleaved write/writeback: the 4MB write will be broken
into 8 NFS writes with the default wsize=524288. So there may be one
nfsd doing COMMIT, another 7 nfsd waiting for the big file's i_mutex.
All 8 nfsd are "busy" and pipeline is destroyed. Just a possibility.

> >    If filemap_fdatawait() can be moved out of i_mutex (or just remove
> >    the lock), we solve the root problem:
> > 
> >    nfsd_sync:
> >      [take i_mutex]
> >        filemap_fdatawrite  => can also be blocked, but less a problem
> >      [drop i_mutex]
> >        filemap_fdatawait
> >  
> >    Maybe it's a dumb question, but what's the purpose of i_mutex here?
> >    For correctness or to prevent livelock? I can imagine some livelock
> >    problem here (current implementation can easily wait for extra
> >    pages), however not too hard to fix.
>   Generally, most filesystems take i_mutex during fsync to
> a) avoid all sorts of livelocking problems
> b) serialize fsyncs for one inode (mostly for simplicity)
>   I don't see what advantage would it bring that we get rid of i_mutex
> for fdatawait - only that maybe writers could proceed while we are
> waiting but is that really the problem?

The i_mutex at least has some performance impact. Another one would be
the WB_SYNC_ALL. All are related to the COMMIT/sync write behavior.

Are there some other _direct_ causes?

Thanks,
Fengguang
