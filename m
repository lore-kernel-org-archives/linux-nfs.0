From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: Re: [PATCH 1/6] VFS: Ensure that writeback_single_inode() commits
 unstable writes
Date: Fri, 08 Jan 2010 08:46:46 -0500
Message-ID: <1262958406.19319.4.camel@localhost>
References: <20100106205110.22547.85345.stgit@localhost.localdomain>
	 <20100106205110.22547.17971.stgit@localhost.localdomain>
	 <20100107021849.GC9475@localhost> <1262839082.2185.15.camel@localhost>
	 <20100107145635.GB20300@localhost> <1262877022.3309.11.camel@localhost>
	 <20100108092542.GA27480@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Wu Fengguang <fengguang.wu@intel.com>,
	Peter Zijlstra <peterz@infradead.org>, Jan Kara <jack@suse.cz>,
	Steve Rago <sar@nec-labs.com>,
	"linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
	"jens.axboe" <jens.axboe@oracle.com>,
	Peter Staubach <staubach@redhat.com>,
	Arjan van de Ven <arjan@infradead.org>,
	Ingo Molnar <mingo@elte.hu>,
	"linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>
To: Christoph Hellwig <hch@infradead.org>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
In-Reply-To: <20100108092542.GA27480@infradead.org>
Sender: linux-fsdevel-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 2010-01-08 at 04:25 -0500, Christoph Hellwig wrote: 
> On Thu, Jan 07, 2010 at 10:10:22AM -0500, Trond Myklebust wrote:
> > As I said previously, the write_inode() call is done _before_ you sync
> > the dirty pages to the server, whereas commit_unstable_pages() wants to
> > be done _after_ syncing. So the two are not the same, and we cannot
> > replace commit_unstable_pages() with write_inode().
> 
> But that's more an accident of how this code was written.  The right
> order nees to be to write the pages first, then call write_inode.  Most
> modern filesystems have to work around this in their write_inode method
> by waiting for the pages themselves.  I already fixed the same ordering
> issue in fsync, and the writeback code is next on the agenda.
> 

Could we in that case replace write_inode() with something that takes a
struct writeback_control? It is very useful to have full information
about the write range and flags as it allows us to tweak the COMMIT RPC
call.

Trond
