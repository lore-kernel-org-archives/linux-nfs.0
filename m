From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [NFS] [PATCH,RESEND] make knfsd interact cleanly with HSMs
Date: Tue, 9 May 2006 10:19:29 +0100
Message-ID: <20060509091929.GA26236@infradead.org>
References: <20060505115254.GA13916@sgi.com> <20060508064255.GA8614@infradead.org> <17503.10386.171006.392544@cse.unsw.edu.au> <20060508175515.GA9662@infradead.org> <1147142114.12319.94.camel@hole.melbourne.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Christoph Hellwig <hch@infradead.org>, Neil Brown <neilb@suse.de>,
	Linux NFS Mailing List <nfs@lists.sourceforge.net>,
	Linux Filesystem Mailing List <linux-fsdevel@vger.kernel.org>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
To: Greg Banks <gnb@melbourne.sgi.com>
In-Reply-To: <1147142114.12319.94.camel@hole.melbourne.sgi.com>
Sender: linux-fsdevel-owner@vger.kernel.org
List-ID: <nfs.lists.sourceforge.net>

On Tue, May 09, 2006 at 12:35:15PM +1000, Greg Banks wrote:
> So your only objection is the absence of DMAPI or some equivalent?
> If so, perhaps the best way forward in the short term is for SUSE
> to add it as an out-of-tree patch.

The objection doesn't have anything to do with DMAPI per see.  It has to
do with adding kernel code that's never used in tree and thus bloats the
kernel.   Also it has a fair chance to bitrot as there's no way it can be
tested.

p.s. -fsdevel couldn't care less about what patches you send to SuSE,
please stop posting such things here and talk to your SuSE technical contacts.

> Sure it's ugly, but to be fair it's no worse than SysV semaphores
> and shmem, and it does fill a real (albeit niche) need which nothing
> else does AFAIK.  Compare to TLI, which is pretty much entirely useless.

It's fat worse because it makes assumptions that simply aren't true in
a unix or linux enviroment.  SysV IPC is ugly but doesn't do this.

> >  I don't expect anyone to submit a kernel-based
> > implementation for inclusion, although support for a big enough subset of
> > that standard could be archived by proper kernel <-> userspace cooperation.
> 
> I don't understand what you mean here: surely almost all of what
> DMAPI specifies is for achieving proper kernel/userspace co-operation?

no.  the DMAPI spec doesn't even know about the user <-> kernel boundary
nor should it.

> Do you have some ideas for a better way of doing that?

Yes, and I've written them up quite a few times, please look at the fsdevel
linux-kernel archives and possible some SGI-internal lists from years ago.
