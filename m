Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:59112 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753155Ab2DIXSv (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 9 Apr 2012 19:18:51 -0400
Date: Mon, 9 Apr 2012 19:18:49 -0400
To: Jeff Layton <jlayton@redhat.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH][RFC] nfsd/lockd: have locks_in_grace take a sb arg
Message-ID: <20120409231849.GH10508@fieldses.org>
References: <1333455279-11200-1-git-send-email-jlayton@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1333455279-11200-1-git-send-email-jlayton@redhat.com>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Apr 03, 2012 at 08:14:39AM -0400, Jeff Layton wrote:
> The main reason for the grace period is to prevent the server from
> allowing an operation that might otherwise be denied once the client has
> reclaimed all of its stateful objects.
> 
> Currently, the grace period handling in the nfsd/lockd server code is
> very simple. When the lock managers start, they stick an entry on a list
> and set a timer. When the timers pop, then they remove the entry from
> the list. The locks_in_grace check just looks to see if the list is
> empty. If it is, then the grace period is considered to be over.
> 
> This is insufficient for a clustered filesystem that is being served
> from multiple nodes at the same time. In such a configuration, the grace
> period must be coordinated in some fashion, or else one node might hand
> out stateful objects that conflict with those that have not yet been
> reclaimed.
> 
> This patch paves the way for fixing this by adding a new export
> operation called locks_in_grace that takes a superblock argument. The
> existing locks_in_grace function is renamed to generic_locks_in_grace,
> and a new locks_in_grace function that takes a superblock arg is added.
> If a filesystem does not have a locks_in_grace export operation then the
> generic version will be used.

Looks more or less OK to me....

> Care has also been taken to reorder calls such that locks_in_grace is
> called last in compound conditional statements. Handling this for
> clustered filesystems may involve upcalls, so we don't want to call it
> unnecessarily.

Even if we're careful to do the check last, we potentially still have to
do it on every otherwise-succesful open and lock operation.

And really I don't think it's too much to ask that this be fast.

> @@ -3183,7 +3183,7 @@ nfs4_laundromat(void)
>  	nfs4_lock_state();
>  
>  	dprintk("NFSD: laundromat service - starting\n");
> -	if (locks_in_grace())
> +	if (generic_locks_in_grace())
>  		nfsd4_end_grace();

Looking at the code.... This is really just checking whether we've ended
our own grace period.  The laundromat's scheduled to run a grace period
after startup.  So I think we should just make this:

	static bool grace_ended = false;

	if (!grace_ended) {
		grace_ended = true;
		nfsd4_end_grace();
	}

or something.  No reason not to do that now.

(Hm, and maybe there's a reason to: locks_in_grace() could in theory
still return true on a second run of nfs4_laundromat(), but
nfsd4_end_grace() probably shouldn't really be run twice?)

--b.
