From: Linus Torvalds <torvalds@transmeta.com>
Subject: Re: [PATCH] direct-IO API change
Date: Fri, 4 Oct 2002 15:25:45 -0700 (PDT)
Sender: linux-kernel-owner@vger.kernel.org
Message-ID: <Pine.LNX.4.31.0210041525010.59482-100000@torvalds-p95.transmeta.com>
References: <Pine.LNX.4.44.0210041807340.8094-100000@dexter.citi.umich.edu>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Linux NFS List <nfs@lists.sourceforge.net>
Return-path: <linux-kernel-owner+linux-kernel=40quimby.gnus.org@vger.kernel.org>
To: Chuck Lever <cel@citi.umich.edu>
In-Reply-To: <Pine.LNX.4.44.0210041807340.8094-100000@dexter.citi.umich.edu>
List-ID: <nfs.lists.sourceforge.net>




On Fri, 4 Oct 2002, Chuck Lever wrote:
>
> this patch adds a "struct file *" argument to direct I/O.  this is needed
> by NFS direct I/O to make the file's credentials available to direct I/O
> subroutines.  we can't remove "struct inode *" yet because the raw driver
> still needs it.

Why isn't the raw driver changed to just use file->f_dentry->d_inode
instead?

		Linus
