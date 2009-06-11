From: Neil Brown <neilb@suse.de>
Subject: Re: [PATCH 3/3] sunrpc: reduce timeout when unregistering rpcbind registrations.
Date: Thu, 11 Jun 2009 14:48:28 +1000
Message-ID: <18992.35996.986951.556723@notabene.brown>
References: <20090528062730.15937.70579.stgit@notabene.brown>
	<20090528063303.15937.62423.stgit@notabene.brown>
	<A85051CB-18EB-4003-8DD6-26D3E9968543@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:38278 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751426AbZFKEr6 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 11 Jun 2009 00:47:58 -0400
In-Reply-To: message from Chuck Lever on Thursday May 28
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thursday May 28, chuck.lever@oracle.com wrote:
> On May 28, 2009, at 2:33 AM, NeilBrown wrote:
> >
> > [An alternate might be to make the sunrpc code always "connect"
> > udp sockets so that "port not reachable" errors would get reported
> > back.  This requires a more intrusive change though and might have
> > other consequences]
> 
> We had discussed this about a year ago when I started adding IPv6  
> support.  I had suggested switching the local rpc client to use TCP  
> instead of UDP to solve exactly this time-out problem during start- 
> up.  There was some resistance to the idea because TCP would leave  
> privileged ports in TIMEWAIT (at shutdown, this is probably not a  
> significant concern).
> 
> Trond had intended to introduce connected UDP socket support to the  
> RPC client, although we were also interested in someday having a  
> single UDP socket for all RPC traffic... the design never moved on  
> from there.
> 
> My feeling at this point is that having a connected UDP socket  
> transport would be simpler and have broader benefits than waiting for  
> an eventual design that can accommodate multiple transport instances  
> sharing a single socket.

The use of connected UDP would have to be limited to known-safe cases
such as contacting the local portmap.  I believe there are still NFS
servers out there that - if multihomed - can reply from a different
address to the one the request was sent to.

And we would need to check that rpcbind does the right thing.  I
recently discovered that rpcbind is buggy and will sometimes respond
from the wrong interface - I suspect localhost addresses are safe, but
we would need to check, or fix it (I fixed that bug in portmap (glibc
actually) 6 years ago and now it appears again in rpcbind - groan!).

How hard would it be to add (optional) connected UDP support?  Would
we just make the code more like the TCP version, or are there any
gotchas that you know of that we would need to be careful of?

Thanks,
NeilBrown

