From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH] mount.nfs: prefer IPv4 addresses over IPv6 (try #2)
Date: Thu, 21 Jan 2010 16:52:08 -0500
Message-ID: <20100121215208.GF23322@fieldses.org>
References: <1263907662-19107-1-git-send-email-jlayton@redhat.com> <1667647A-2BB1-478D-8881-CE8EA2191F97@oracle.com> <20100120082905.1825f806@tlielax.poochiereds.net> <8E556CE2-569B-4E6D-BD02-7EF5CA84900D@oracle.com> <20100121191515.GA22021@fieldses.org> <4B58AD16.8040309@oracle.com> <20100121195746.GC22021@fieldses.org> <4B58B8FE.80800@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jeff Layton <jlayton@redhat.com>, linux-nfs@vger.kernel.org,
	steved@redhat.com, trond.myklebust@fys.uio.no
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:42404 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753090Ab0AUVur (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 21 Jan 2010 16:50:47 -0500
In-Reply-To: <4B58B8FE.80800@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Jan 21, 2010 at 03:28:46PM -0500, Chuck Lever wrote:
> On 01/21/2010 02:57 PM, J. Bruce Fields wrote:
>> On Thu, Jan 21, 2010 at 02:37:58PM -0500, Chuck Lever wrote:
>>> rpcb_getaddr(3t) is designed to use the rpcbind protocol to determine
>>> the address and transport to use when contacting a remote service.  Our
>>> mount command has its own negotiation mechanism that is a superset of
>>> rpcbind calls, in addition to having a faster timeout than
>>> rpcb_getaddr(3t).
>>
>> What does "is a superset of rpcbind calls" mean?
>
> rpcb_getaddr(3t) performs a single specific rpcbind query with a long  
> fixed timeout.  mount.nfs uses several rpcbind queries, in a particular  
> order, to identify which NFS-related services are available.  mount.nfs  
> uses individual queries rather than a single DUMPALL in order to enable  
> firewalls to detect which ports should be opened.
>
>> I still don't
>> understand what the proper protocol family negotiation is: what actually
>> happens on the wire?
>
> If a particular RPC service (including rpcbind) cannot be contacted via  
> "inet6," and the server has an "inet" address listed in DNS, then  
> mount.nfs should be smart enough to try the mount request via the "inet"  
> address too.  This is in addition to support for rpcbind queries that  
> can return a netid, which would include information about which protocol  
> family to use).
>
> Currently our mount.nfs command fails if the target server has at least  
> one IPv6 address listed in DNS in addition to an IPv4 address, but does  
> not support NFS/IPv6.
>
> For NFSv4, a server that has an IPv6 address but does not support  
> NFS/IPv6 will refuse connection to port 2049 over IPv6.  In that case,  
> mount.nfs should tell the kernel to retry the mount with the server's  
> IPv4 address, if it has one.
>
> For NFSv3, a server that has an IPv6 address, but does not support  
> NFS/IPv6, will not register any inet6 netids in its rpcbind database.  
> Thus the mount.nfs command has to be smart enough to retry  
> PROGNOTREGISTERED results with the server's IPv4 address, if it has one.
>
> If the server has an IPv6 address, but is running portmap instead of  
> rpcbind, the initial rpcbind query connection will be refused (portmap  
> does not set up an IPv6 listener).  In that case, the mount request  
> should be retried with the server's IPv4 address, if it has one.
>
> Note that in any of these cases, if an NFS server does not have any IPv6  
> addresses listed in DNS, then behavior should be the same as before.

OK, got it.  (I think.)  Thanks!

--b.
