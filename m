From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: Performance Diagnosis
Date: Tue, 15 Jul 2008 16:27:31 -0400
Message-ID: <1216153651.7981.57.camel@localhost>
References: <e80abd30807150834m47a1b86cle39885150f1d5bfd@mail.gmail.com>
	 <487CC928.8070908@redhat.com>
	 <76bd70e30807150923r31027edxb0394a220bbe879b@mail.gmail.com>
	 <487CE202.2000809@redhat.com>
	 <76bd70e30807151117g520f22cj1dfe26b971987d38@mail.gmail.com>
	 <1216147879.7981.44.camel@localhost>  <487CF8D6.2090908@redhat.com>
	 <1216150552.7981.48.camel@localhost>  <487D00C9.1010305@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: chucklever@gmail.com, Andrew Bell <andrew.bell.ia@gmail.com>,
	linux-nfs@vger.kernel.org
To: Peter Staubach <staubach@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-out2.uio.no ([129.240.10.58]:51920 "EHLO mail-out2.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758254AbYGOU1h (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 15 Jul 2008 16:27:37 -0400
In-Reply-To: <487D00C9.1010305@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 2008-07-15 at 15:55 -0400, Peter Staubach wrote:
> It seems to me that as long as we don't shut down a connection
> which is actively being used for an outstanding request, then
> we shouldn't have any larger problems with the duplicate caches
> on servers than we do now.
> 
> We can do this easily enough by reference counting the connection
> state and then only closing connections which are not being
> referenced.

Agreed.

> A gain would be that we could reduce the numbers of connections on
> active clients if we could disassociate a connection with a
> particular mounted file system.  As long as we can achieve maximum
> network bandwidth through a single connection, then we don't need
> more than one connection per server.

Isn't that pretty much the norm today anyway? The only call to
rpc_create() that I can find is made when creating the nfs_client
structure. All other NFS-related rpc connections are created as clones
of the above shared structure, and thus share the same rpc_xprt.

I'm not sure that we want to share connections in the cases where we
can't share the same nfs_client, since that usually means that RPC level
parameters such as timeout values, NFS protocol versions differ.

> We could handle the case where the client was talking to more
> servers than it had connection space for by forcibly, but safely
> closing connections to servers and then using the space for a
> new connection to a server.  We could do this in the connection
> manager by checking to see if there was an available connection
> which was not marked as in the process of being closed.  If so,
> then it just enters the fray as needing a connection and am
> working like all of the others.
> 
> The algorithm could look something like:
> 
> top:
>     Look for a connection to the right server which is not marked
>         as being closed.
>     If one was found, then increment its reference count and
>        return it.
>     Attempt to create a new connect,
>     If this works, then increment its reference count and
>        return it.
>     Find a connection to be closed, either one not being currently
>        used or via some heuristic like round-robin.
>     If this connection is not actively being used, then close it
>        and go to top.
>     Mark the connection as being closed, wait until it is closed,
>        and then go to top.

Actually, what you really want to do is look at whether or not any of
the rpc slots are in use or not. If they aren't, then you are free to
close the connection, if not, go to the next.

Unfortunately, you still can't get rid of the 2 minute TIME_WAIT state
in the case of a TCP connection, so I'm not sure how useful this will
turn out to be...

Cheers
  Trond

