Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet10.oracle.com ([148.87.113.121]:55497 "EHLO
	rcsinet10.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756859Ab1DMSr1 convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 13 Apr 2011 14:47:27 -0400
Subject: Re: [RFC][PATCH] Vector read/write support for NFS (DIO) client
Content-Type: text/plain; charset=us-ascii
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <1302718471.8571.48.camel@lade.trondhjem.org>
Date: Wed, 13 Apr 2011 14:47:05 -0400
Cc: Andy Adamson <andros@netapp.com>, Jeff Layton <jlayton@redhat.com>,
        Badari Pulavarty <pbadari@us.ibm.com>, linux-nfs@vger.kernel.org,
        khoa@us.ibm.com
Message-Id: <D860A5B3-B6D5-4810-936B-ADC78E097997@oracle.com>
References: <1302622335.3877.62.camel@badari-desktop> <0DC51758-AE6C-4DD2-A959-8C8E701FEA4E@oracle.com> <1302624935.3877.66.camel@badari-desktop> <FF1EE11E-62EB-42B9-A4C9-7A2FE4C60D2F@oracle.com> <1302630360.3877.72.camel@badari-desktop> <20110413083656.12e54a91@tlielax.poochiereds.net> <4DA5A899.3040202@us.ibm.com> <20110413100228.680ace66@tlielax.poochiereds.net> <1302704533.8571.12.camel@lade.trondhjem.org> <20110413132034.459c68bb@corrin.poochiereds.net> <7497FEC4-F173-4E10-B571-B856471CB9FD@netapp.com> <1302718471.8571.48.camel@lade.trondhjem.org>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0


On Apr 13, 2011, at 2:14 PM, Trond Myklebust wrote:

> On Wed, 2011-04-13 at 13:56 -0400, Andy Adamson wrote:
>> On Apr 13, 2011, at 1:20 PM, Jeff Layton wrote:
>> 
>>> On Wed, 13 Apr 2011 10:22:13 -0400
>>> Trond Myklebust <Trond.Myklebust@netapp.com> wrote:
>>> 
>>>> On Wed, 2011-04-13 at 10:02 -0400, Jeff Layton wrote:
>>>>> We could put the rpc_rqst's into a slabcache, and give each rpc_xprt a
>>>>> mempool with a minimum number of slots. Have them all be allocated with
>>>>> GFP_NOWAIT. If it gets a NULL pointer back, then the task can sleep on
>>>>> the waitqueue like it does today. Then, the clients can allocate
>>>>> rpc_rqst's as they need as long as memory holds out for it.
>>>>> 
>>>>> We have the reserve_xprt stuff to handle congestion control anyway so I
>>>>> don't really see the value in the artificial limits that the slot table
>>>>> provides.
>>>>> 
>>>>> Maybe I should hack up a patchset for this...
>>>> 
>>>> This issue has come up several times recently. My preference would be to
>>>> tie the availability of slots to the TCP window size, and basically say
>>>> that if the SOCK_ASYNC_NOSPACE flag is set on the socket, then we hold
>>>> off allocating more slots until we get a ->write_space() callback which
>>>> clears that flag.
>>>> 
>>>> For the RDMA case, we can continue to use the current system of a fixed
>>>> number of preallocated slots.
>>>> 
>>> 
>>> I take it then that we'd want a similar scheme for UDP as well? I guess
>>> I'm just not sure what the slot table is supposed to be for.
>> 
>> [andros] I look at the rpc_slot table as a representation of the amount of data the connection to the server
>> can handle - basically the #slots should = double the bandwidth-delay product divided by the max(rsize/wsize).
>> For TCP, this is the window size. (ping of max MTU packet * interface bandwidth).
>> There is no reason to allocate more rpc_rqsts that can fit on the wire. 
> 
> Agreed, but as I said earlier, there is no reason to even try to use UDP
> on high bandwidth links, so I suggest we just leave it as-is.

I think Jeff is suggesting that all the transports should use the same logic, but UDP and RDMA should simply have fixed upper limits on their slot table size.  UDP would then behave the same as before, but would share code with the others.  That might be cleaner than maintaining separate slot allocation mechanisms for each transport.

In other words, share the code, but parametrize it so that UDP and RDMA have effectively fixed slot tables as before, but TCP is allowed to expand.

My two pfennig's worth.

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com



