From: Andrew Morton <akpm@digeo.com>
Subject: Re: [PATCH] direct-IO API change
Date: Fri, 04 Oct 2002 15:37:59 -0700
Sender: linux-kernel-owner@vger.kernel.org
Message-ID: <3D9E1847.F6DDA3AE@digeo.com>
References: <Pine.LNX.4.44.0210041807340.8094-100000@dexter.citi.umich.edu> <Pine.LNX.4.31.0210041525010.59482-100000@torvalds-p95.transmeta.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Chuck Lever <cel@citi.umich.edu>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Linux NFS List <nfs@lists.sourceforge.net>
Return-path: <linux-kernel-owner+linux-kernel=40quimby.gnus.org@vger.kernel.org>
To: Linus Torvalds <torvalds@transmeta.com>
List-ID: <nfs.lists.sourceforge.net>

Linus Torvalds wrote:
> 
> On Fri, 4 Oct 2002, Chuck Lever wrote:
> >
> > this patch adds a "struct file *" argument to direct I/O.  this is needed
> > by NFS direct I/O to make the file's credentials available to direct I/O
> > subroutines.  we can't remove "struct inode *" yet because the raw driver
> > still needs it.
> 
> Why isn't the raw driver changed to just use file->f_dentry->d_inode
> instead?
> 

Because the file handle which we have is for /dev/raw/raw0,
not for /dev/hda1.

The raw driver binds to major/minor, not a file*.  I considered
changing that (change userspace to pass the open fd).  But didn't.

An alternative would be to rewrite i_mapping for /dev/raw/raw0
to be bdev->bd_inode->i_mapping.  I guess we should look at doing
that.
