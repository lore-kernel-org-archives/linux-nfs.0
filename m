From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: Performance Diagnosis
Date: Tue, 15 Jul 2008 14:51:19 -0400
Message-ID: <1216147879.7981.44.camel@localhost>
References: <e80abd30807150834m47a1b86cle39885150f1d5bfd@mail.gmail.com>
	 <487CC928.8070908@redhat.com>
	 <76bd70e30807150923r31027edxb0394a220bbe879b@mail.gmail.com>
	 <487CE202.2000809@redhat.com>
	 <76bd70e30807151117g520f22cj1dfe26b971987d38@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Peter Staubach <staubach@redhat.com>,
	Andrew Bell <andrew.bell.ia@gmail.com>,
	linux-nfs@vger.kernel.org
To: chucklever@gmail.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-out1.uio.no ([129.240.10.57]:37618 "EHLO mail-out1.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754112AbYGOSvZ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 15 Jul 2008 14:51:25 -0400
In-Reply-To: <76bd70e30807151117g520f22cj1dfe26b971987d38-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 2008-07-15 at 14:17 -0400, Chuck Lever wrote:
> On Tue, Jul 15, 2008 at 1:44 PM, Peter Staubach <staubach@redhat.com> wrote:
> > Chuck Lever wrote:
> >>
> >> On Tue, Jul 15, 2008 at 11:58 AM, Peter Staubach <staubach@redhat.com>
> >> wrote:
> >>
> >>>
> >>> If it is the notion described above, sometimes called head
> >>> of line blocking, then we could think about ways to duplex
> >>> operations over multiple TCP connections, perhaps with one
> >>> connection for small, low latency operations, and another
> >>> connection for larger, higher latency operations.
> >>>
> >>
> >> I've dreamed about that for years.  I don't think it would be too
> >> difficult, but one thing that has held it back is the shortage of
> >> ephemeral ports on the client may reduce the number of concurrent
> >> mount points we can support.
> >>
> >> One way to avoid the port issue is to construct an SCTP transport for
> >> NFS.  SCTP allows multiple streams on the same connection, effectively
> >> eliminating head of line blocking.
> >
> > I like the idea of combining this work with implementing a proper
> > connection manager so that we don't need a connection per mount.
> > We really only need one connection per client and server, no matter
> > how many individual mounts there might be from that single server.
> > (Or two connections, if we want to do something like this...)
> >
> > We could also manage the connection space and thus, never run into
> > the shortage of ports ever again.  When the port space is full or
> > we've run into some other artificial limit, then we simply close
> > down some other connection to make space.
> 
> I think we should do this for text-based mounts; however this would
> mean the connection management would happen in the kernel, which (only
> slightly) complicates things.
> 
> I was thinking about this a little last week when Trond mentioned
> implementing a connected UDP socket transport...
> 
> It would be nice if all the kernel RPC services that needed to send a
> single RPC request (like mount, rpcbind, and so on) could share a
> small managed pool of sockets (a pool of TCP sockets, or a pool of
> connected UDP sockets).  Connected sockets have the ostensible
> advantage that they can quickly detect the absence of a remote
> listener.  But such a pool would be a good idea because multiple mount
> requests to the same server could all flow over the same set of
> connections.
> 
> But we might be able to get away with something nearly as efficient if
> the RPC client would always invoke a connect(AF_UNSPEC) before
> destroying the socket.  Wouldn't that free the ephemeral port
> immediately?  What are the risks of trying something like this?


Why is all the talk here only about RPC level solutions?

Newer kernels already have a good deal of extra throttling of writes at
the NFS superblock level, and there is even a sysctl to control the
amount of outstanding writes before the VM congestion control sets in.
Please see /proc/sys/fs/nfs/nfs_congestion_kb

Cheers
  Trond

