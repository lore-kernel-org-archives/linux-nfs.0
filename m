From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [RFC PATCH 0/2] Fix up the NFS mmap code
Date: Fri, 8 Jan 2010 17:17:14 -0800 (PST)
Message-ID: <alpine.LFD.2.00.1001081709470.7821@localhost.localdomain>
References: <1262913974.2659.101.camel@localhost> <20100109005624.7473.33215.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Andi Kleen <andi@firstfloor.org>, linux-kernel@vger.kernel.org,
	linux-nfs@vger.kernel.org
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:55998 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751644Ab0AIBRu (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 8 Jan 2010 20:17:50 -0500
In-Reply-To: <20100109005624.7473.33215.stgit-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On Fri, 8 Jan 2010, Trond Myklebust wrote:
>
> How about something like the following. I chose to wrap the call to
> do_mmap_pgoff() instead of making a special ->pre_mmap(), since that
> seems more consistent with the way we handle ->read() and ->write().

I still don't think that you can ever do mmap _and_ readdir on the same 
inode, so there's something wrong with the lockdep annotations.

See my earlier mail about putting directory inodes in a different class 
from non-directory inodes, and the email after that that points out that 
we already do:

 - inode_init_always():
	lockdep_set_class(&inode->i_mutex, &sb->s_type->i_mutex_key);

 - unlock_new_inode() (for directories):
	lockdep_set_class(&inode->i_mutex, &type->i_mutex_dir_key);

and I suspect that the reason why NFS triggers lockdep problems is that 
NFS probably plays some game with inodes (presumably the root inode) that 
ends up bypassing the normal new-inode handling.

In short - I really don't think this issue merits VFS-level (or VM, 
whatever you want to call it) hooks. There's a bug there, but I don't 
think you're actually fixing the right thing.

And _especially_ not the way you did it, where the filesystem can wrap the 
whole complex do_mmap_pgoff. The NFS use you have doesn't seem too bad, 
but anybody who tries to be clever and avoid "generic_mmap_do_pgoff()" 
would immediately be a major disaster.

		Linus
