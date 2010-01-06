From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [PATCH 0/6] Re: [PATCH] improve the performance of large
 sequential write NFS workloads
Date: Wed, 06 Jan 2010 17:03:29 -0500
Message-ID: <1262815409.4251.169.camel@localhost>
References: <20100106200928.GB22781@quack.suse.cz>
	 <20100106205110.22547.85345.stgit@localhost.localdomain>
	 <20100106214456.GE22781@quack.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Wu Fengguang <fengguang.wu@intel.com>,
	Peter Zijlstra <peterz@infradead.org>,
	Steve Rago <sar@nec-labs.com>,
	"linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
	"jens.axboe" <jens.axboe@oracle.com>,
	Peter Staubach <staubach@redhat.com>,
	Arjan van de Ven <arjan@infradead.org>,
	Ingo Molnar <mingo@elte.hu>,
	"linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>
To: Jan Kara <jack@suse.cz>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
In-Reply-To: <20100106214456.GE22781@quack.suse.cz>
Sender: linux-fsdevel-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, 2010-01-06 at 22:44 +0100, Jan Kara wrote: 
> On Wed 06-01-10 15:51:10, Trond Myklebust wrote:
> > Peter Zijlstra (1):
> >       VM: Split out the accounting of unstable writes from BDI_RECLAIMABLE
> > 
> > Trond Myklebust (5):
> >       NFS: Run COMMIT as an asynchronous RPC call when wbc->for_background is set
> >       VM: Use per-bdi unstable accounting to improve use of wbc->force_commit
> >       VM: Don't call bdi_stat(BDI_UNSTABLE) on non-nfs backing-devices
> >       VM/NFS: The VM must tell the filesystem when to free reclaimable pages
> >       VFS: Ensure that writeback_single_inode() commits unstable writes
>   I think the series would be nicer if you made Peter's patch #2 and join
> your patches
> "VM/NFS: The VM must tell the filesystem when to free reclaimable pages"
> and
> "VM: Use per-bdi unstable accounting to improve use of wbc->force_commit"
> 
> 									Honza

Indeed, and if everyone is OK with Peter's patch, I'll do that.

Cheers
  Trond

