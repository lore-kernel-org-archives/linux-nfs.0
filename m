Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet12.oracle.com ([148.87.113.124]:54258 "EHLO
	rcsinet12.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755861Ab0DBSFX (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 2 Apr 2010 14:05:23 -0400
Message-ID: <4BB63166.6050703@oracle.com>
Date: Fri, 02 Apr 2010 14:03:18 -0400
From: Chuck Lever <chuck.lever@oracle.com>
To: Roland Dreier <rdreier@cisco.com>
CC: Tom Tucker <tom@opengridcomputing.com>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        "linux-rdma@vger.kernel.org" <linux-rdma@vger.kernel.org>
Subject: Re: [PATCH,RFC] nfsd: Make INET6 transport creation failure an informational
 message
References: <4BB522CF.60503@opengridcomputing.com>	<4BB61F19.2000403@oracle.com> <adaljd57os6.fsf@roland-alpha.cisco.com>
In-Reply-To: <adaljd57os6.fsf@roland-alpha.cisco.com>
Content-Type: text/plain; charset=us-ascii; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Hi Roland-

On 04/02/2010 01:22 PM, Roland Dreier wrote:
>   >  >  The write_ports code will fail both the INET4 and INET6 transport
>   >  >  creation if
>   >  >  the transport returns an error when PF_INET6 is specified. Some transports
>   >  >  that do not support INET6 return an error other than EAFNOSUPPORT.
>   >
>   >  That's the real bug.  Any reason the RDMA RPC transport can't return
>   >  EAFNOSUPPORT in this case?
>
> I think Tom's changelog is misleading.  The problem is that the RDMA
> transport actually does support IPv6, but it doesn't support the
> IPV6ONLY option yet.  So if NFS/RDMA binds to a port for IPv4, then the
> IPv6 bind fails because of the port collision.

IPV6ONLY is a requirement for RPC over IPv6.  If the underlying 
transport does not support IPV6ONLY, then it cannot properly support RPC 
over IPv6.  It's easy enough to catch listener creation calls for IPv6 
on such transports, and simply return EAFNOSUPPORT until support for 
IPV6ONLY can be provided.

The __write_ports() interface is specifically designed to silently fall 
back to IPv4-only when IPv6 transport creation fails with ENOAFSUPPORT. 
  I don't see a good reason to change the generic logic in 
__write_ports() if there is a problem with implementing RPC over IPv6 in 
a specific transport capability.  __write_ports() will do the right 
thing if the transport returns the correct error code.

> Implementing the IPV6ONLY option for RDMA binding is probably not
> feasible for 2.6.34, so the best band-aid for now seems to be Tom's
> patch.

My recent experience with similar changes suggests the specific solution 
Tom proposed will trigger extra bug reports and e-mails, as the change 
appears to affect non-RDMA transports as well.  This printk might fire, 
for example, for INET transports on systems that are built without IPv6 
support, or where ipv6.ko is blacklisted in user space.

In other words, I agree that there's a bug that should be addressed in 
2.6.34, and I don't have any problem with setting up only an IPv4 
listener in this case.  But I think the addition of a printk that fires 
for all transports in this case is problematic.

It would be better to address this in the RPC/RDMA transport capability, 
and not in generic upper level logic.  We already have correct behavior 
in __write_ports, and the RPC/RDMA transport capability should be 
changed to use it.

-- 
chuck[dot]lever[at]oracle[dot]com
