Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pv0-f174.google.com ([74.125.83.174]:46516 "EHLO
	mail-pv0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751132Ab1DNAVk (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 13 Apr 2011 20:21:40 -0400
Received: by pvg12 with SMTP id 12so405577pvg.19
        for <linux-nfs@vger.kernel.org>; Wed, 13 Apr 2011 17:21:40 -0700 (PDT)
Message-ID: <4DA63E08.2080505@gmail.com>
Date: Wed, 13 Apr 2011 17:21:28 -0700
From: Dean <seattleplus@gmail.com>
To: Andy Adamson <andros@netapp.com>
CC: Jeff Layton <jlayton@redhat.com>,
        Trond Myklebust <Trond.Myklebust@netapp.com>,
        Badari Pulavarty <pbadari@us.ibm.com>,
        Chuck Lever <chuck.lever@oracle.com>, linux-nfs@vger.kernel.org,
        khoa@us.ibm.com
Subject: Re: [RFC][PATCH] Vector read/write support for NFS (DIO) client
References: <1302622335.3877.62.camel@badari-desktop> <0DC51758-AE6C-4DD2-A959-8C8E701FEA4E@oracle.com> <1302624935.3877.66.camel@badari-desktop> <FF1EE11E-62EB-42B9-A4C9-7A2FE4C60D2F@oracle.com> <1302630360.3877.72.camel@badari-desktop> <20110413083656.12e54a91@tlielax.poochiereds.net> <4DA5A899.3040202@us.ibm.com> <20110413100228.680ace66@tlielax.poochiereds.net> <1302704533.8571.12.camel@lade.trondhjem.org> <20110413132034.459c68bb@corrin.poochiereds.net> <7497FEC4-F173-4E10-B571-B856471CB9FD@netapp.com>
In-Reply-To: <7497FEC4-F173-4E10-B571-B856471CB9FD@netapp.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

>>> This issue has come up several times recently. My preference would be to
>>> tie the availability of slots to the TCP window size, and basically say
>>> that if the SOCK_ASYNC_NOSPACE flag is set on the socket, then we hold
>>> off allocating more slots until we get a ->write_space() callback which
>>> clears that flag.
>>>
>>> For the RDMA case, we can continue to use the current system of a fixed
>>> number of preallocated slots.
>>>
>> I take it then that we'd want a similar scheme for UDP as well? I guess
>> I'm just not sure what the slot table is supposed to be for.
> [andros] I look at the rpc_slot table as a representation of the amount of data the connection to the server
> can handle - basically the #slots should = double the bandwidth-delay product divided by the max(rsize/wsize).
> For TCP, this is the window size. (ping of max MTU packet * interface bandwidth).
> There is no reason to allocate more rpc_rqsts that can fit on the wire.
I agree with checking for space on the link.

The above formula is a good lower bound on the maximum number of slots, 
but there are many times when a client could use more slots than the 
above formula.  For example, we don't want to punish writes if rsize > 
wsize.  Also, you have to account for the server memory, which can 
sometimes hold several write requests while waiting for them to  be 
sync'd to disk, leaving the TCP buffers less than full.

Also, I think any solution should allow admins to limit the maximum 
number of slots.  Too many slots can increase request randomness at the 
server, and sometimes severely reduce performance.

Dean

>> Possibly naive question, and maybe you or Andy have scoped this out
>> already...
>>
>> Wouldn't it make more sense to allow the code to allocate rpc_rqst's as
>> needed, and manage congestion control in reserve_xprt ?
> [andros] Congestion control is not what the rpc_slot table is managing. It does need to have
> a minimum which experience has set at 16. It's the maximum that needs to be dynamic.
> Congestion control by the lower layers should work unfettered within the # of rpc_slots. Today that
> is not always the case when 16 slots is not enough to fill the wire, and the administrator has
> not changed the # of rpc_slots.
>
>> It appears that
>> that at least is what xprt_reserve_xprt_cong is supposed to do. The TCP
>> variant (xprt_reserve_xprt) doesn't do that currently, but we could do
>> it there and that would seem to make for more parity between the TCP
>> and UDP in this sense.
>>
>> We could do that similarly for RDMA too. Simply keep track of how many
>> RPCs are in flight and only allow reserving the xprt when that number
>> hasn't crossed the max number of slots...
>
>> -- 
>> Jeff Layton<jlayton@redhat.com>
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
