Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:47231 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751078Ab0JVW1k convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 22 Oct 2010 18:27:40 -0400
Subject: Re: [PATCH] xs_bind retry binding forever
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: Ben Myers <bpm@sgi.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
In-Reply-To: <BDE2E840-86B2-4E2F-B80D-93E6B020E765@oracle.com>
References: <20101021183203.12776.28469.stgit@lady3jane.americas.sgi.com>
	 <20101021183337.12776.18768.stgit@lady3jane.americas.sgi.com>
	 <1287689917.9144.84.camel@heimdal.trondhjem.org>
	 <48B51F5A-E060-4B0B-8AD6-1E4247C4289F@oracle.com>
	 <1287769536.6311.9.camel@heimdal.trondhjem.org>
	 <BDE2E840-86B2-4E2F-B80D-93E6B020E765@oracle.com>
Content-Type: text/plain; charset="UTF-8"
Date: Fri, 22 Oct 2010 18:27:36 -0400
Message-ID: <1287786456.24361.12.camel@heimdal.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Fri, 2010-10-22 at 14:15 -0400, Chuck Lever wrote:
> On Oct 22, 2010, at 1:45 PM, Trond Myklebust wrote:
> 
> > On Fri, 2010-10-22 at 11:56 -0400, Chuck Lever wrote:
> >> On Oct 21, 2010, at 3:38 PM, Trond Myklebust wrote:
> >> 
> >>> On Thu, 2010-10-21 at 13:33 -0500, Ben Myers wrote:
> >>>> Retry bind for reserved source ports forever.  Add an error message when we
> >>>> have a hard time binding one.
> >>> 
> >>> NACK. This approach leads to the process spinning forever in that loop,
> >>> which is exactly why we introduced the limit in the first place. See all
> >>> the old archived bug report emails about 'rpciod taking 100% cpu'.
> >> 
> >> The root problem seems to be the hard loop.  Thinking out loud, what if the client's FSM or some other higher up layer performed the retry, with a short delay inserted after each attempt?
> > 
> > The problem isn't only the hard loop. The reason why we return the
> > EADDRINUSE is in order to allow quick failure of mounts and/or
> > automounts when we can't bind the socket.
> > 
> > I suggest 2 changes:
> > 
> >     1. In case of error, pass the return value from xs_bind to the
> >        pending tasks
> >     2. Add a handler for EADDRINUSE in call_status(),
> >        xprt_connect_status() and call_connect_status(). Make sure that
> >        call_status() and call_connect_status() fail for SOFTCONN tasks,
> >        and that they print an error message, delay and retry in the
> >        case of ordinary hard tasks.
> 
> The thing is, though, we don't want mounts to fail in this case; that's the presenting problem Ben is trying to address.
> 
> This is not the same problem as SOFTCONN -- it's entirely one of how the local system allocates its own resources.  Thus, theoretically, it's one where it is possible for us to behave entirely predictably.  At its heart, our privileged port allocation mechanism is really an unfair way to allocate this resource, since there's no way to prevent starvation.

I beg to differ. It is quite possible for an external server to put us
in this position by closing connections too often. If we're running
against a too heavily loaded Linux NFS server, this is actually expected
to happen.

> I don't know if this is within the realm of possibilities, but it would be nice, for example, if the MNT client and the rpcbind client could each hold onto a privileged TCP port (to prevent others from using it) and just re-use that port whenever a new request needs to be sent to any remote host.

That would mean holding onto connections for longer than required.
Although it may fix some cases where a client mounts many partitions
from the same server, it will cause regressions for clients that mount
many partitions from different servers.

Quite frankly, if you are hitting bind issues due to the
portmapper/rpcbind and NFSv3 mount protocols, then the solution already
exists: switch to NFSv4.

> It would be fun to use net namespaces to allocate a separate port range that no-one else could touch, but I don't think that's possible without a separate IP address.

That is not something the kernel should engage in anyway.

> Ben, our client already has the ability to use unprivileged ports for MNT, as long as the server's mountd is configured to accept it.  That, plus stipulating mountproto=udp, may give you more relief.

Or see above...

Cheers
  Trond


