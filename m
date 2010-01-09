From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: Re: [RFC PATCH 0/2] Fix up the NFS mmap code
Date: Sat, 9 Jan 2010 01:46:34 +0000
Message-ID: <20100109014634.GE30528@ZenIV.linux.org.uk>
References: <1262913974.2659.101.camel@localhost> <20100109005624.7473.33215.stgit@localhost.localdomain> <alpine.LFD.2.00.1001081709470.7821@localhost.localdomain> <20100109013825.GD30528@ZenIV.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>,
	Andi Kleen <andi@firstfloor.org>, linux-kernel@vger.kernel.org,
	linux-nfs@vger.kernel.org
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from zeniv.linux.org.uk ([195.92.253.2]:47597 "EHLO
	ZenIV.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751916Ab0AIBqi (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 8 Jan 2010 20:46:38 -0500
In-Reply-To: <20100109013825.GD30528@ZenIV.linux.org.uk>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sat, Jan 09, 2010 at 01:38:25AM +0000, Al Viro wrote:
> On Fri, Jan 08, 2010 at 05:17:14PM -0800, Linus Torvalds wrote:
> > 
> > 
> > On Fri, 8 Jan 2010, Trond Myklebust wrote:
> > >
> > > How about something like the following. I chose to wrap the call to
> > > do_mmap_pgoff() instead of making a special ->pre_mmap(), since that
> > > seems more consistent with the way we handle ->read() and ->write().
> > 
> > I still don't think that you can ever do mmap _and_ readdir on the same 
> > inode, so there's something wrong with the lockdep annotations.
> 
> readdir() is certainly a red herring.  write(), OTOH, is quite real.
> And there we do i_mutex followed by pagefaults.
> 
> I *REALLY* dislike Trond's solution, though.
> 
> Could we please get a sane expalanation of the reasons why nfs mmap
> wants i_mutex in the first place?  Before we add yet another hook
> from hell and complicate already overcomplicated area...

PS: mmap/write deadlock is real, AFAICT - unless something very subtle
prevents it, we can get buggered if we have two threads with the same
VM, mmap 1.4Mb from floppy and do
thread A:
	write(fd_on_nfs, buffer_mmaped_from_floppy, 1440 * 1024);
thread B:
	mmap(..., fd_on_nfs, ...)

It's not even particulary narrow.
