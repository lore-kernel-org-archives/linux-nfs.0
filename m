From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [RFC PATCH 0/2] Fix up the NFS mmap code
Date: Fri, 8 Jan 2010 18:22:01 -0800 (PST)
Message-ID: <alpine.LFD.2.00.1001081814240.7821@localhost.localdomain>
References: <1262913974.2659.101.camel@localhost> <20100109005624.7473.33215.stgit@localhost.localdomain> <alpine.LFD.2.00.1001081709470.7821@localhost.localdomain> <20100109013825.GD30528@ZenIV.linux.org.uk> <alpine.LFD.2.00.1001081750080.7821@localhost.localdomain>
 <20100109021124.GG30528@ZenIV.linux.org.uk>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>,
	Andi Kleen <andi@firstfloor.org>, linux-kernel@vger.kernel.org,
	linux-nfs@vger.kernel.org
To: Al Viro <viro@ZenIV.linux.org.uk>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1754520Ab0AICWi@vger.kernel.org>
In-Reply-To: <20100109021124.GG30528@ZenIV.linux.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On Sat, 9 Jan 2010, Al Viro wrote:
> 
> Well, sure - it steps on i_mutex-before-mmmap_sem first from ls somewhere and
> records the ordering for posterity.  Then NFS steps into mmap() (on a
> different inode) and gets conflicting ordering.

Look closer: the inodes for directories and for non-directories have 
i_mutex in different lockdep classes.

So that "on a different inode" thing should have made it a non-issue, 
since there is no actual chain back. There is "mmap_sem -> 
i_mutex_regular_file" (for mmap) and there is "i_mutex_directory -> 
mmap_sem" (for filldir), but that isn't an ABBA.

The problem _seems_ to be (if I read Andi's chain correctly) that a 
directory hasn't gone through the i_mutex_dir_key change, so filldir ends 
up being counted against the default i_mutex_key.


		Linus
