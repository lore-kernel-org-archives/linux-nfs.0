Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:46646 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756638Ab1DMO1b (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 13 Apr 2011 10:27:31 -0400
Subject: Re: [RFC][PATCH] Vector read/write support for NFS (DIO) client
Content-Type: text/plain; charset=us-ascii
From: Andy Adamson <andros@netapp.com>
In-Reply-To: <1302704533.8571.12.camel@lade.trondhjem.org>
Date: Wed, 13 Apr 2011 10:27:23 -0400
Cc: Jeff Layton <jlayton@redhat.com>, Badari Pulavarty <pbadari@us.ibm.com>,
        Chuck Lever <chuck.lever@oracle.com>, linux-nfs@vger.kernel.org,
        khoa@us.ibm.com
Message-Id: <00D863C6-8B7E-4645-A53E-14D1E2507AEE@netapp.com>
References: <1302622335.3877.62.camel@badari-desktop> <0DC51758-AE6C-4DD2-A959-8C8E701FEA4E@oracle.com> <1302624935.3877.66.camel@badari-desktop> <FF1EE11E-62EB-42B9-A4C9-7A2FE4C60D2F@oracle.com> <1302630360.3877.72.camel@badari-desktop> <20110413083656.12e54a91@tlielax.poochiereds.net> <4DA5A899.3040202@us.ibm.com> <20110413100228.680ace66@tlielax.poochiereds.net> <1302704533.8571.12.camel@lade.trondhjem.org>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0


On Apr 13, 2011, at 10:22 AM, Trond Myklebust wrote:

> On Wed, 2011-04-13 at 10:02 -0400, Jeff Layton wrote:
>> We could put the rpc_rqst's into a slabcache, and give each rpc_xprt a
>> mempool with a minimum number of slots. Have them all be allocated with
>> GFP_NOWAIT. If it gets a NULL pointer back, then the task can sleep on
>> the waitqueue like it does today. Then, the clients can allocate
>> rpc_rqst's as they need as long as memory holds out for it.
>> 
>> We have the reserve_xprt stuff to handle congestion control anyway so I
>> don't really see the value in the artificial limits that the slot table
>> provides.
>> 
>> Maybe I should hack up a patchset for this...
> 
> This issue has come up several times recently. My preference would be to
> tie the availability of slots to the TCP window size, and basically say
> that if the SOCK_ASYNC_NOSPACE flag is set on the socket, then we hold
> off allocating more slots until we get a ->write_space() callback which
> clears that flag.

I am scoping the dynamic rpc_slot allocation work and plan to prototype.

-->Andy
 
> 
> For the RDMA case, we can continue to use the current system of a fixed
> number of preallocated slots.
> 
> Cheers
>  Trond
> -- 
> Trond Myklebust
> Linux NFS client maintainer
> 
> NetApp
> Trond.Myklebust@netapp.com
> www.netapp.com
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

