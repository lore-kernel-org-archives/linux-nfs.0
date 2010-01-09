From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: Re: [RFC PATCH 0/2] Fix up the NFS mmap code
Date: Sat, 9 Jan 2010 01:38:25 +0000
Message-ID: <20100109013825.GD30528@ZenIV.linux.org.uk>
References: <1262913974.2659.101.camel@localhost> <20100109005624.7473.33215.stgit@localhost.localdomain> <alpine.LFD.2.00.1001081709470.7821@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>,
	Andi Kleen <andi@firstfloor.org>, linux-kernel@vger.kernel.org,
	linux-nfs@vger.kernel.org
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from zeniv.linux.org.uk ([195.92.253.2]:46945 "EHLO
	ZenIV.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751135Ab0AIBie (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 8 Jan 2010 20:38:34 -0500
In-Reply-To: <alpine.LFD.2.00.1001081709470.7821-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Jan 08, 2010 at 05:17:14PM -0800, Linus Torvalds wrote:
> 
> 
> On Fri, 8 Jan 2010, Trond Myklebust wrote:
> >
> > How about something like the following. I chose to wrap the call to
> > do_mmap_pgoff() instead of making a special ->pre_mmap(), since that
> > seems more consistent with the way we handle ->read() and ->write().
> 
> I still don't think that you can ever do mmap _and_ readdir on the same 
> inode, so there's something wrong with the lockdep annotations.

readdir() is certainly a red herring.  write(), OTOH, is quite real.
And there we do i_mutex followed by pagefaults.

I *REALLY* dislike Trond's solution, though.

Could we please get a sane expalanation of the reasons why nfs mmap
wants i_mutex in the first place?  Before we add yet another hook
from hell and complicate already overcomplicated area...
