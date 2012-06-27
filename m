Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:51072 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932065Ab2F0UTP (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 27 Jun 2012 16:19:15 -0400
Date: Wed, 27 Jun 2012 16:19:13 -0400
From: Jeff Layton <jlayton@redhat.com>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
Cc: Harshula <harshula@redhat.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: rpciod process is blocked in nfs_release_page waiting for
 nfs_commit_inode to complete
Message-ID: <20120627161913.05229538@tlielax.poochiereds.net>
In-Reply-To: <1340826996.2398.15.camel@lade.trondhjem.org>
References: <1339764850.30233.11.camel@serendib>
	<20120615092103.15cc2b11@corrin.poochiereds.net>
	<1339795503.16363.9.camel@lade.trondhjem.org>
	<20120627115447.0fdf8c6e@corrin.poochiereds.net>
	<1340822635.2398.7.camel@lade.trondhjem.org>
	<20120627152814.4774048b@tlielax.poochiereds.net>
	<1340826996.2398.15.camel@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, 27 Jun 2012 19:56:38 +0000
"Myklebust, Trond" <Trond.Myklebust@netapp.com> wrote:

> On Wed, 2012-06-27 at 15:28 -0400, Jeff Layton wrote:
> > On Wed, 27 Jun 2012 18:43:56 +0000
> > "Myklebust, Trond" <Trond.Myklebust@netapp.com> wrote:
> > If there really is no alternative to freeing the socket, then the only
> > real fix I can see is to set PF_MEMALLOC when we go to create it and
> > then reset it afterward. That's a pretty ugly fix though...
> 
> I can think of 2 possible alternatives:
> 
>      1. Use the PF_FSTRANS flag to tell nfs_release_page that this is a
>         direct reclaim from rpciod.

Hmm...that's a bit indiscriminate, isn't it? Looks like only XFS uses
that flag now...

Suppose we're in some XFS allocation and then want to commit a NFS
page to satisfy it. There's no real reason we couldn't but that would
prevent it...

>      2. Add a 'congested' flag to the rpc client that could tell reclaim
>         type operations to give up if a socket allocation is in
>         progress.
> 

That's not a bad idea. That has the benefit of only skipping reclaim
when it's directly associated with the socket being reconnected. Seems
like that would have to hang off of the rpc_xprt, but we could do
something along those lines. Presumably Mel's swap-over-nfs patches
could be converted to do something similar instead of using PF_MEMALLOC
there too.

-- 
Jeff Layton <jlayton@redhat.com>
