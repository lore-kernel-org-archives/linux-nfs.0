Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:36660 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751873Ab1KVTgi (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 22 Nov 2011 14:36:38 -0500
Date: Tue, 22 Nov 2011 14:36:38 -0500
To: Chuck Lever <chuck.lever@oracle.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [RFC] NFS: Cache state owners after files are closed
Message-ID: <20111122193638.GB21451@fieldses.org>
References: <20111122174225.1866.25410.stgit@degas.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20111122174225.1866.25410.stgit@degas.1015granger.net>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Nov 22, 2011 at 12:52:53PM -0500, Chuck Lever wrote:
> Servers have a finite amount of memory to store NFSv4 open and lock
> owners.  Moreover, servers may have a difficult time determining when
> they can reap their state owner table, thanks to gray areas in the
> NFSv4 protocol specification.

What's the gray area?

Reminding myself: OK, I guess it's the NFSv4.0 close-replay problem.
You have to keep around enough information about a closed stateid to
handle a replay.  If a client reuses the stateowner than you can purge
that as soon as you bump the sequence number, otherwise you have to keep
it around a while (how long is unclear).

(Is that what you're referring to?)

> Thus clients should be careful to reuse
> state owners when possible.
> 
> Currently Linux is not too careful.  When a user has closed all her
> files on one mount point, the state owner's reference count goes to
> zero, and it is released.  The next OPEN allocates a new one.  A
> workload that serially opens and closes files can run through a large
> number of open owners this way.
> 
> When a state owner's reference count goes to zero, slap it onto a free
> list for that nfs_server, with an expiry time.  Garbage collect before
> looking for a state owner.  This makes state owners for active users
> available for re-use.

Makes sense to me.

> @@ -1739,6 +1745,7 @@ struct nfs_server *nfs4_create_server(const struct nfs_parsed_mount_data *data,
>  		goto error;
>  
>  	dprintk("<-- nfs4_create_server() = %p\n", server);
> +	server->destroy = nfs4_destroy_server;
>  	return server;
>  
>  error:
> @@ -1792,6 +1799,7 @@ struct nfs_server *nfs4_create_referral_server(struct nfs_clone_mount *data,
>  		goto error;
>  
>  	dprintk("<-- nfs_create_referral_server() = %p\n", server);
> +	server->destroy = nfs4_destroy_server;

Couldn't you avoid adding that line in two different places, if you put
it in nfs4_server_common_setup()?

--b.
