From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: RPC service registration timeout
Date: Fri, 4 Apr 2008 15:28:13 -0400
Message-ID: <CA26795C-23B5-4E9B-806B-49CCF3AB1BC1@oracle.com>
References: <503B5614-4F04-470D-B7FF-9DAA6AE6E316@oracle.com> <EXNANE01XvpFVjCRGry00000233@exnane01.hq.netapp.com> <1207330103.11655.3.camel@heimdal.trondhjem.org> <0FE09339-FB7A-4E9E-B56F-61648EFD121A@oracle.com> <EXNANE017a0xtAEHLB800000238@exnane01.hq.netapp.com>
Mime-Version: 1.0 (Apple Message framework v753)
Content-Type: text/plain; charset=US-ASCII; delsp=yes; format=flowed
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>,
	"J. Bruce Fields" <bfields@fieldses.org>,
	Neil Brown <neilb@suse.de>, Steve Dickson <SteveD@redhat.com>,
	NFS list <linux-nfs@vger.kernel.org>
To: "Talpey, Thomas" <Thomas.Talpey@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from agminet01.oracle.com ([141.146.126.228]:10559 "EHLO
	agminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756568AbYDDTa4 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 4 Apr 2008 15:30:56 -0400
In-Reply-To: <EXNANE017a0xtAEHLB800000238-kboziUmgGqYSZCGxjG3uujkOHZLvdrmu@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Apr 4, 2008, at 2:54 PM, Talpey, Thomas wrote:
> At 02:41 PM 4/4/2008, Chuck Lever wrote:
>> Use TCP instead of UDP to contact the local rpcbind daemon.  If
>> rpcbind isn't listening, the connection is refused immediately, and
>> the RPC client can tell without waiting for a timeout.
>
> You can get a prompt error if you use UDP connected mode (call
> connect() on the UDP socket). Any ICMP port unreachable will
> flow back to an ECONNREFUSED error on the socket. This doesn't
> occur for unconnected UDP endpoints.

Yeah, RPC client uses unconnected UDP sockets.

>> We would have to create a new RPC_CLNT_CREATE_FOO flag that tells the
>> client to fail an RPC immediately if the connection is refused (kind
>> of like the old "one shot" flag).  This shouldn't be the default
>> behavior.
>
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

Because the RPC client does that for all RPCs.  It retries soft until  
a timeout; hard, forever.

It could be waiting for the remote to come up.  In which case, a few  
retries after ECONNREFUSED is useful, even preferred.

I'm going to try prototyping a new RPC_CLNT_ flag.

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com
