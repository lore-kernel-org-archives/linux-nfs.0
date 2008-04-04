From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: Re: RPC service registration timeout
Date: Fri, 04 Apr 2008 15:25:53 -0400
Message-ID: <1207337153.13540.15.camel@heimdal.trondhjem.org>
References: <503B5614-4F04-470D-B7FF-9DAA6AE6E316@oracle.com>
	 <EXNANE01XvpFVjCRGry00000233@exnane01.hq.netapp.com>
	 <1207330103.11655.3.camel@heimdal.trondhjem.org>
	 <0FE09339-FB7A-4E9E-B56F-61648EFD121A@oracle.com>
	 <EXNANE017a0xtAEHLB800000238@exnane01.hq.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Chuck Lever <chuck.lever@oracle.com>,
	"J. Bruce Fields" <bfields@fieldses.org>,
	Neil Brown <neilb@suse.de>, Steve Dickson <SteveD@redhat.com>,
	NFS list <linux-nfs@vger.kernel.org>
To: "Talpey, Thomas" <Thomas.Talpey@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:8588 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751085AbYDDTZ4 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 4 Apr 2008 15:25:56 -0400
In-Reply-To: <EXNANE017a0xtAEHLB800000238-kboziUmgGqYSZCGxjG3uujkOHZLvdrmu@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Fri, 2008-04-04 at 14:54 -0400, Talpey, Thomas wrote:
> At 02:41 PM 4/4/2008, Chuck Lever wrote:
> >Use TCP instead of UDP to contact the local rpcbind daemon.  If  
> >rpcbind isn't listening, the connection is refused immediately, and  
> >the RPC client can tell without waiting for a timeout.
> 
> You can get a prompt error if you use UDP connected mode (call
> connect() on the UDP socket). Any ICMP port unreachable will
> flow back to an ECONNREFUSED error on the socket. This doesn't
> occur for unconnected UDP endpoints.

I hadn't realised that was a feature of connected UDP sockets, but
that's a good point.

> >We would have to create a new RPC_CLNT_CREATE_FOO flag that tells the  
> >client to fail an RPC immediately if the connection is refused (kind  
> >of like the old "one shot" flag).  This shouldn't be the default  
> >behavior.

> Sounds reasonable. But, a port unreachable error should generally
> be a "hard" indication, since it does come from the remote host,
> or a middlebox acting as its proxy. In other words, any reasonably
> small number of retries would all receive the same response. This is
> much like a TCP RST - not a transitory event. UDP errors such as
> host unreachable or network down (which come from the infrastructure
> not the server) should not of course be considered this way and
> retry is appropriate.
> 
> Bottom line, I think it might actually be a useful default. Why does
> the client currently retry ECONNREFUSED for port resolution?

The client currently doesn't retry in the case of a connection failing
for a soft RPC request. For hard RPC requests then it _must_ retry the
connection, but it does so using an exponential backoff rule.

Note that the NFSv4.1 channel bindings will probably force us to change
this...

Cheers
  Trond
-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com
