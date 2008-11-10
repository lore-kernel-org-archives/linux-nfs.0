From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: Re: [PATCH 5/9] rpc: call release_pipe only on last close
Date: Mon, 10 Nov 2008 15:21:55 -0500
Message-ID: <1226348515.7599.52.camel@heimdal.trondhjem.org>
References: <1226264683-28650-2-git-send-email-bfields@citi.umich.edu>
	 <1226264683-28650-3-git-send-email-bfields@citi.umich.edu>
	 <1226264683-28650-4-git-send-email-bfields@citi.umich.edu>
	 <1226264683-28650-5-git-send-email-bfields@citi.umich.edu>
	 <1226264683-28650-6-git-send-email-bfields@citi.umich.edu>
	 <1226344297.7599.41.camel@heimdal.trondhjem.org>
	 <20081110194900.GD19053@fieldses.org>
	 <1226347279.7599.47.camel@heimdal.trondhjem.org>
	 <20081110200727.GE19053@fieldses.org>
	 <1226347898.7599.49.camel@heimdal.trondhjem.org>
	 <20081110201708.GF19053@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain
Cc: aglo@citi.umich.edu, kwc@citi.umich.edu, linux-nfs@vger.kernel.org
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:59473 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751498AbYKJUWR (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 10 Nov 2008 15:22:17 -0500
In-Reply-To: <20081110201708.GF19053@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, 2008-11-10 at 15:17 -0500, J. Bruce Fields wrote:
> On Mon, Nov 10, 2008 at 03:11:38PM -0500, Trond Myklebust wrote:
> > On Mon, 2008-11-10 at 15:07 -0500, J. Bruce Fields wrote:
> > 
> > > Again, I'm dealing with that case by calling release_pipe() from
> > > rpc_close_pipes(), just as the current code does--the only change being
> > > to do that only when there are still opens:
> > > 
> > > 		last_close = rpci->nreaders != 0 || rpci->nwriters != 0;
> > >  		rpci->nreaders = 0;
> > > 		...
> > >  		rpci->nwriters = 0;
> > > 		if (last_close && ops->release_pipe)
> > >  			ops->release_pipe(inode);
> > 
> > Which means that if the kernel calls rpc_close_pipes() before gssd has
> > managed to close, then you _NEVER_ call ops->release_pipe()...
> 
> So, I take "before gssd has managed to close" to mean that gssd is still
> holding the file open.  Thus the statement
> 
> 	last_close = rpci->nreaders != 0 || rpci->nwriters != 0;
> 
> evaluates to true; either nreaders or nwriters must be nonzero.
> 
> (And note the open and close code that modifes nreaders and nwriters is
> all serialized with this code by the i_mutex.)
> 
> --b.

Exactly... That is a very common situation that happens pretty much
every time you unmount. The kernel closes the pipe on its side, and
removes the dentry; it doesn't wait for gssd to close the pipe.

Trond

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com
