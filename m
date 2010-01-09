From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: Re: [RFC PATCH 0/2] Fix up the NFS mmap code
Date: Sat, 9 Jan 2010 02:30:35 +0000
Message-ID: <20100109023035.GH30528@ZenIV.linux.org.uk>
References: <1262913974.2659.101.camel@localhost> <20100109005624.7473.33215.stgit@localhost.localdomain> <alpine.LFD.2.00.1001081709470.7821@localhost.localdomain> <20100109013825.GD30528@ZenIV.linux.org.uk> <alpine.LFD.2.00.1001081750080.7821@localhost.localdomain> <20100109021124.GG30528@ZenIV.linux.org.uk> <alpine.LFD.2.00.1001081814240.7821@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>,
	Andi Kleen <andi@firstfloor.org>, linux-kernel@vger.kernel.org,
	linux-nfs@vger.kernel.org
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from zeniv.linux.org.uk ([195.92.253.2]:36648 "EHLO
	ZenIV.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752519Ab0AICaj (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 8 Jan 2010 21:30:39 -0500
In-Reply-To: <alpine.LFD.2.00.1001081814240.7821-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Jan 08, 2010 at 06:22:01PM -0800, Linus Torvalds wrote:
> 
> 
> On Sat, 9 Jan 2010, Al Viro wrote:
> > 
> > Well, sure - it steps on i_mutex-before-mmmap_sem first from ls somewhere and
> > records the ordering for posterity.  Then NFS steps into mmap() (on a
> > different inode) and gets conflicting ordering.
> 
> Look closer: the inodes for directories and for non-directories have 
> i_mutex in different lockdep classes.
> 
> So that "on a different inode" thing should have made it a non-issue, 
> since there is no actual chain back. There is "mmap_sem -> 
> i_mutex_regular_file" (for mmap) and there is "i_mutex_directory -> 
> mmap_sem" (for filldir), but that isn't an ABBA.
> 
> The problem _seems_ to be (if I read Andi's chain correctly) that a 
> directory hasn't gone through the i_mutex_dir_key change, so filldir ends 
> up being counted against the default i_mutex_key.

Interesting...  There's nfs_update_inode(), but it ought to scream bloody
murder on the type change (and its return value is ignore by nfs_fhget(),
BTW).
