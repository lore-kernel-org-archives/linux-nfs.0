Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp.opengridcomputing.com ([209.198.142.2]:55255 "EHLO
	smtp.opengridcomputing.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752333Ab0DBSwl (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 2 Apr 2010 14:52:41 -0400
Message-ID: <4BB63CF7.7020905@opengridcomputing.com>
Date: Fri, 02 Apr 2010 13:52:39 -0500
From: Tom Tucker <tom@opengridcomputing.com>
To: Roland Dreier <rdreier@cisco.com>
CC: Chuck Lever <chuck.lever@oracle.com>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        "linux-rdma@vger.kernel.org" <linux-rdma@vger.kernel.org>
Subject: Re: [PATCH,RFC] nfsd: Make INET6 transport creation failure an informational
 message
References: <4BB522CF.60503@opengridcomputing.com>	<4BB61F19.2000403@oracle.com> <adaljd57os6.fsf@roland-alpha.cisco.com>
In-Reply-To: <adaljd57os6.fsf@roland-alpha.cisco.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Roland Dreier wrote:
>  > > The write_ports code will fail both the INET4 and INET6 transport
>  > > creation if
>  > > the transport returns an error when PF_INET6 is specified. Some transports
>  > > that do not support INET6 return an error other than EAFNOSUPPORT.
>  > 
>  > That's the real bug.  Any reason the RDMA RPC transport can't return
>  > EAFNOSUPPORT in this case?
>
> I think Tom's changelog is misleading.
Yes, it should read "A transport may fail for some reason other than 
EAFNOSUPPORT."

>   The problem is that the RDMA
> transport actually does support IPv6, but it doesn't support the
> IPV6ONLY option yet.  So if NFS/RDMA binds to a port for IPv4, then the
> IPv6 bind fails because of the port collision.
>
>   

Should we fail INET4 if INET6 fails under any circumstances?

> Implementing the IPV6ONLY option for RDMA binding is probably not
> feasible for 2.6.34, so the best band-aid for now seems to be Tom's
> patch.
>
>  - R.
>   

