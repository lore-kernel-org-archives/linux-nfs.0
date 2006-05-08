From: Neil Brown <neilb@suse.de>
Subject: Re: [NFS] Re: [PATCH][RFC] NFS: Improving the access cache
Date: Mon, 8 May 2006 12:44:14 +1000
Message-ID: <17502.45182.130630.119304@cse.unsw.edu.au>
References: <444EC96B.80400@RedHat.com>
	<17486.64825.942642.594218@cse.unsw.edu.au>
	<444F88EF.5090105@RedHat.com>
	<17487.62730.16297.979429@cse.unsw.edu.au>
	<44572B33.4070100@RedHat.com>
	<445834CB.4050408@citi.umich.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Steve Dickson <SteveD@redhat.com>, nfs@lists.sourceforge.net,
	linux-fsdevel@vger.kernel.org
Return-path: <linux-fsdevel-owner@vger.kernel.org>
To: cel@citi.umich.edu
In-Reply-To: message from Chuck Lever on Wednesday May 3
Sender: linux-fsdevel-owner@vger.kernel.org
List-ID: <nfs.lists.sourceforge.net>

On Wednesday May 3, cel@citi.umich.edu wrote:
> 
> For the sake of discussion, let me propose some design alternatives.
> 
> 1.  We already have cache shrinkage built in: when an inode is purged 
> due to cache shrinkage, the access cache for that inode is purged as 
> well.  In other words, there is already a mechanism for external memory 
> pressure to shrink this cache.  I don't see a strong need to complicate 
> matters by adding more cache shrinkage than already exists with normal 
> inode and dentry cache shrinkage.
> 

If you have one particular file that is use regularly - and so never
falls out of cache - and is uses occasionally by every single user in
you system, then that one inode could contribute to thousands of
access cache items that will never be purged.

This is why I thought that some sort of cleaning of the access cache
was important.

NeilBrown
