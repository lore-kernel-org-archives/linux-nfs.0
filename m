From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH 1/6] VFS: Ensure that writeback_single_inode() commits
	unstable writes
Date: Fri, 8 Jan 2010 08:54:20 -0500
Message-ID: <20100108135420.GA1806@infradead.org>
References: <20100106205110.22547.85345.stgit@localhost.localdomain> <20100106205110.22547.17971.stgit@localhost.localdomain> <20100107021849.GC9475@localhost> <1262839082.2185.15.camel@localhost> <20100107145635.GB20300@localhost> <1262877022.3309.11.camel@localhost> <20100108092542.GA27480@infradead.org> <1262958406.19319.4.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Christoph Hellwig <hch@infradead.org>,
	Wu Fengguang <fengguang.wu@intel.com>,
	Peter Zijlstra <peterz@infradead.org>, Jan Kara <jack@suse.cz>,
	Steve Rago <sar@nec-labs.com>,
	"linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
	"jens.axboe" <jens.axboe@oracle.com>,
	Peter Staubach <staubach@redhat.com>,
	Arjan van de Ven <arjan@infradead.org>,
	Ingo Molnar <mingo@elte.hu>,
	"linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
In-Reply-To: <1262958406.19319.4.camel@localhost>
Sender: linux-fsdevel-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Jan 08, 2010 at 08:46:46AM -0500, Trond Myklebust wrote:
> Could we in that case replace write_inode() with something that takes a
> struct writeback_control? It is very useful to have full information
> about the write range and flags as it allows us to tweak the COMMIT RPC
> call.

At this point I do not plan to change the write_inode interface.  But
changing the ->write_inode operation to take a writeback control instead
of the sync flag should be a prety easy change if you want to do it.

