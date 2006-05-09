From: Greg Banks <gnb@melbourne.sgi.com>
Subject: Re: [NFS] [PATCH,RESEND] make knfsd interact cleanly with HSMs
Date: Tue, 09 May 2006 12:35:15 +1000
Message-ID: <1147142114.12319.94.camel@hole.melbourne.sgi.com>
References: <20060505115254.GA13916@sgi.com>
	 <20060508064255.GA8614@infradead.org>
	 <17503.10386.171006.392544@cse.unsw.edu.au>
	 <20060508175515.GA9662@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Neil Brown <neilb@suse.de>,
	Linux NFS Mailing List <nfs@lists.sourceforge.net>,
	Linux Filesystem Mailing List <linux-fsdevel@vger.kernel.org>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
To: Christoph Hellwig <hch@infradead.org>
In-Reply-To: <20060508175515.GA9662@infradead.org>
Sender: linux-fsdevel-owner@vger.kernel.org
List-ID: <nfs.lists.sourceforge.net>

On Tue, 2006-05-09 at 03:55, Christoph Hellwig wrote:
> On Mon, May 08, 2006 at 09:16:34PM +1000, Neil Brown wrote:
> > On Monday May 8, hch@infradead.org wrote:
> > > NACK.  As long as we have no HSM support in the tree there's no reason to
> > > add this.  From the kernel's point it's just untested and unused code that
> > > can break.

So your only objection is the absence of DMAPI or some equivalent?
If so, perhaps the best way forward in the short term is for SUSE
to add it as an out-of-tree patch.

> > Greg: you seemed to suggest that there was already code in XFS that
> > could make use of this.  If that is so: could you point us to it
> > please.
> 
> It's used by SGI's out of tree dmapi implementation.  Because dmapi is such
> an utterly braindead standard

Sure it's ugly, but to be fair it's no worse than SysV semaphores
and shmem, and it does fill a real (albeit niche) need which nothing
else does AFAIK.  Compare to TLI, which is pretty much entirely useless.

>  I don't expect anyone to submit a kernel-based
> implementation for inclusion, although support for a big enough subset of
> that standard could be archived by proper kernel <-> userspace cooperation.

I don't understand what you mean here: surely almost all of what
DMAPI specifies is for achieving proper kernel/userspace co-operation?
Do you have some ideas for a better way of doing that?

Greg.
-- 
Greg Banks, R&D Software Engineer, SGI Australian Software Group.
I don't speak for SGI.


