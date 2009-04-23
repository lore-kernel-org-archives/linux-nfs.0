From: Theodore Tso <tytso@mit.edu>
Subject: Re: Fw: 2.6.28.9: EXT3/NFS inodes corruption
Date: Wed, 22 Apr 2009 20:11:39 -0400
Message-ID: <20090423001139.GX15541@mit.edu>
References: <20090422142424.b4105f4c.akpm@linux-foundation.org> <20090422224455.GV15541@mit.edu> <20090422234823.GA24477@gradator.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andrew Morton <akpm@linux-foundation.org>,
	linux-ext4@vger.kernel.org, linux-nfs@vger.kernel.org
To: Sylvain Rochet <gradator-XWGZPxRNpGHk1uMJSBkQmQ@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from THUNK.ORG ([69.25.196.29]:49265 "EHLO thunker.thunk.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751281AbZDWALt (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 22 Apr 2009 20:11:49 -0400
In-Reply-To: <20090422234823.GA24477-XWGZPxRNpGHk1uMJSBkQmQ@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Apr 23, 2009 at 01:48:23AM +0200, Sylvain Rochet wrote:
> > 
> > This is on the client side; what happens when you look at the same
> > directory from the server side?
> 
> This is on the server side ;)
> 

On the server side, that means you also an inode table block look
corrupted.  I'm pretty sure that if you used debugfs to examine those
blocks you would have seen that the inodes were completely garbaged.
Depending on the inode size, and assuming a 4k block size, there are
typically 128 or 64 inodes in a 4k block, so if you were to look at
the inodes by inode number, you normally find that adjacent inodes are
corrupted within a 4k block.  Of course, this just tells us what had
gotten damaged; whether it was damanged by a kernel bug, a memory bug,
a hard drive or controller failure (and there are multiple types of
storage stack failures; complete garbage getting written into the
right place, and the right data getting written into the wrong place).

> Well, this is the inode numbers of directories with entries pointing on 
> inexisting inodes, of course we cannot delete these directories anymore 
> through a regular recursive deletion (well, without debugfs ;). 
> Considering the amount of inodes, this is quite a very low corruption 
> rate.

Well, sure, but any amount of corruption is extremely troubling....

> Yes, this is what we thought too, especially because we use ext3/nfs for 
> a very long time without problem like that. I moved all the data to the 
> backup array so we can now do read-write tests on the primary one 
> without impacting much the production.
> 
> So, let's check the raid6 array, well, this is going to take a few days.
> 
> # badblocks -w -s /dev/md10
> 
> If everything goes well I will check disk by disk.
> 
> By the way, if such corruptions doesn't happen on the backup storage 
> array we can conclude to a hardware problem around the primary one, but, 
> we are not going to be able to conclude before a few weeks.

Good luck!!

						- Ted
