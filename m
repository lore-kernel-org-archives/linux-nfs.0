Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:34430 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760065Ab1CDUkf convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 4 Mar 2011 15:40:35 -0500
Subject: Re: [Security] [PATCH] nfs4: Ensure that ACL pages sent over NFS
 were not allocated from the slab
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: Jeff Layton <jlayton@redhat.com>
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
        Linus Torvalds <torvalds@linux-foundation.org>,
        Neil Horman <nhorman@tuxdriver.com>, linux-nfs@vger.kernel.org,
        security@kernel.org
In-Reply-To: <20110304153059.79374df7@tlielax.poochiereds.net>
References: <1299257053-13175-1-git-send-email-nhorman@tuxdriver.com>
	 <20110304171320.GA19496@fieldses.org>
	 <20110304184505.GB10083@hmsreliant.think-freely.org>
	 <20110304193325.GB21260@fieldses.org>
	 <AANLkTimpX6JPWyPgB6vcZ8TuQ5gj9aPcJ9OCK186n5Nk@mail.gmail.com>
	 <20110304200703.GC21260@fieldses.org>
	 <20110304153059.79374df7@tlielax.poochiereds.net>
Content-Type: text/plain; charset="UTF-8"
Date: Fri, 04 Mar 2011 15:40:19 -0500
Message-ID: <1299271219.2901.42.camel@heimdal.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Fri, 2011-03-04 at 15:30 -0500, Jeff Layton wrote: 
> Right, I don't think we can know that since we (at the RPC layer) don't
> get any real notification of when we receive a TCP ACK.
> 
> > In this case, we're not kfree()'ing until we've gotten an rpc reply
> > back.  But in theory perhaps there could be cases where the server's
> > gotten the data and we've seen the reply but the tcp layer still thinks
> > it needs to retransmit something?  I don't think we'd care if the data
> > was still correct in that case, but it could be an information leak if
> > nothing else.
> 
> There's also timeouts + soft mounts to consider. We may send the data
> on the socket, which gets buffered up and then the caller goes to sleep
> waiting for a reply. If that never comes (server crashed or something),
> then we can return an error back up to the VFS layer if it's a soft
> mount. Meanwhile, the kernel is still trying to send the data on the
> socket...

O_DIRECT writes have a similar problem, BTW. Occasionally we do return
control to userland while the pages are still buffered in the socket
(either due to the above conditions, or due to the fact that we were
retransmitting an RPC request, and we suddenly get a reply to the
previous transmission). If the application then scribbles over the page
data, the socket may end up transmitting a quite different WRITE payload
than what it was supposed to...

For that reason, it would be nice to have some way to know when the
socket is done referencing the data.

Cheers
  Trond

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com

