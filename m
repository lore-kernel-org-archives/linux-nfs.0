From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH] mount.nfs: prefer IPv4 addresses over IPv6 (try #2)
Date: Thu, 21 Jan 2010 14:57:46 -0500
Message-ID: <20100121195746.GC22021@fieldses.org>
References: <1263907662-19107-1-git-send-email-jlayton@redhat.com> <1667647A-2BB1-478D-8881-CE8EA2191F97@oracle.com> <20100120082905.1825f806@tlielax.poochiereds.net> <8E556CE2-569B-4E6D-BD02-7EF5CA84900D@oracle.com> <20100121191515.GA22021@fieldses.org> <4B58AD16.8040309@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jeff Layton <jlayton@redhat.com>, linux-nfs@vger.kernel.org,
	steved@redhat.com, trond.myklebust@fys.uio.no
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:46601 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752819Ab0AUT4Z (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 21 Jan 2010 14:56:25 -0500
In-Reply-To: <4B58AD16.8040309@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Jan 21, 2010 at 02:37:58PM -0500, Chuck Lever wrote:
> On 01/21/2010 02:15 PM, J. Bruce Fields wrote:
>> On Wed, Jan 20, 2010 at 10:36:36AM -0500, Chuck Lever wrote:
>>> For the record, we looked at Solaris behavior yesterday.  With bi-family
>>> servers, its mount command tries IPv6 first, but appears smart enough to
>>> fall back to IPv4.  One thing we haven't tried is to see how difficult it
>>> would be to fix the real problem by adding proper protocol family
>>> negotiation to our own mount command.
>>
>> Sorry, I probably just haven't been following: what's "proper protocol
>> family negotiation"?  I thought the only ways to negotiate were either
>> rpcbind (v2, v3) or trial and error (v4)?
>
> In TI-RPC parlance, a "protocol" is the transport protocol (UDP, for  
> example), and a "protocol family" is the address family ("inet6", for  
> example).  A netid represents a particular combination of the two:  the  
> netid "udp6" represents UDP over "inet6".
>
> The "protocol family" is really the value that is passed to socket(2).  
> This call generally takes PF_INET or something like that as its first  
> argument.  All of the PF_FOO thingies have the same integer value as  
> their AF_FOO counterparts.  For TI-RPC, we have "inet" and "inet6",  
> which are strings that match up with the AF_FOO and PF_FOO names.
>
> rpcb_getaddr(3t) is designed to use the rpcbind protocol to determine  
> the address and transport to use when contacting a remote service.  Our
> mount command has its own negotiation mechanism that is a superset of  
> rpcbind calls, in addition to having a faster timeout than 
> rpcb_getaddr(3t).

What does "is a superset of rpcbind calls" mean?  I still don't
understand what the proper protocol family negotiation is: what actually
happens on the wire?

--b.

>
> Until now, mount.nfs hasn't needed to negotiate the protocol family in  
> addition to the NFS and mount versions and transports.  It always  
> assumed "inet" (or AF_INET, or PF_INET), and until recently, used only  
> rpcbind protocol version 2.
