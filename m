From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [RFC PATCH 0/2] Fix up the NFS mmap code
Date: Fri, 8 Jan 2010 17:57:27 -0800 (PST)
Message-ID: <alpine.LFD.2.00.1001081750080.7821@localhost.localdomain>
References: <1262913974.2659.101.camel@localhost> <20100109005624.7473.33215.stgit@localhost.localdomain> <alpine.LFD.2.00.1001081709470.7821@localhost.localdomain> <20100109013825.GD30528@ZenIV.linux.org.uk>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>,
	Andi Kleen <andi@firstfloor.org>, linux-kernel@vger.kernel.org,
	linux-nfs@vger.kernel.org
To: Al Viro <viro@ZenIV.linux.org.uk>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1754362Ab0AIB6P@vger.kernel.org>
In-Reply-To: <20100109013825.GD30528@ZenIV.linux.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On Sat, 9 Jan 2010, Al Viro wrote:
> 
> readdir() is certainly a red herring.

That's the one that lockdep reports, though. I still don't see why. Afaik, 
the only place where NFS gets an inode is nfs_fhget(), and that seems to 
do things correctly.

> write(), OTOH, is quite real. And there we do i_mutex followed by 
> pagefaults.

Ho humm.. 

> Could we please get a sane expalanation of the reasons why nfs mmap
> wants i_mutex in the first place?  Before we add yet another hook
> from hell and complicate already overcomplicated area...

Yeah, agreed.

		Linus
