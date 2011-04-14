Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pw0-f46.google.com ([209.85.160.46]:38216 "EHLO
	mail-pw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751281Ab1DNGjy (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 14 Apr 2011 02:39:54 -0400
Received: by pwi15 with SMTP id 15so497124pwi.19
        for <linux-nfs@vger.kernel.org>; Wed, 13 Apr 2011 23:39:53 -0700 (PDT)
Message-ID: <4DA696AE.3060002@gmail.com>
Date: Wed, 13 Apr 2011 23:39:42 -0700
From: Dean <seattleplus@gmail.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
CC: Andy Adamson <andros@netapp.com>, Jeff Layton <jlayton@redhat.com>,
        Badari Pulavarty <pbadari@us.ibm.com>,
        Chuck Lever <chuck.lever@oracle.com>, linux-nfs@vger.kernel.org,
        khoa@us.ibm.com
Subject: Re: [RFC][PATCH] Vector read/write support for NFS (DIO) client
References: <1302622335.3877.62.camel@badari-desktop>	 <0DC51758-AE6C-4DD2-A959-8C8E701FEA4E@oracle.com>	 <1302624935.3877.66.camel@badari-desktop>	 <FF1EE11E-62EB-42B9-A4C9-7A2FE4C60D2F@oracle.com>	 <1302630360.3877.72.camel@badari-desktop>	 <20110413083656.12e54a91@tlielax.poochiereds.net>	 <4DA5A899.3040202@us.ibm.com>	 <20110413100228.680ace66@tlielax.poochiereds.net>	 <1302704533.8571.12.camel@lade.trondhjem.org>	 <20110413132034.459c68bb@corrin.poochiereds.net>	 <7497FEC4-F173-4E10-B571-B856471CB9FD@netapp.com>	 <4DA63E08.2080505@gmail.com> <1302741769.4789.7.camel@lade.trondhjem.org>
In-Reply-To: <1302741769.4789.7.camel@lade.trondhjem.org>
Content-Type: text/plain; charset=UTF-8; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0



On 4/13/11 5:42 PM, Trond Myklebust wrote:
> On Wed, 2011-04-13 at 17:21 -0700, Dean wrote:
>>>>> This issue has come up several times recently. My preference would be to
>>>>> tie the availability of slots to the TCP window size, and basically say
>>>>> that if the SOCK_ASYNC_NOSPACE flag is set on the socket, then we hold
>>>>> off allocating more slots until we get a ->write_space() callback which
>>>>> clears that flag.
>>>>>
>>>>> For the RDMA case, we can continue to use the current system of a fixed
>>>>> number of preallocated slots.
>>>>>
>>>> I take it then that we'd want a similar scheme for UDP as well? I guess
>>>> I'm just not sure what the slot table is supposed to be for.
>>> [andros] I look at the rpc_slot table as a representation of the amount of data the connection to the server
>>> can handle - basically the #slots should = double the bandwidth-delay product divided by the max(rsize/wsize).
>>> For TCP, this is the window size. (ping of max MTU packet * interface bandwidth).
>>> There is no reason to allocate more rpc_rqsts that can fit on the wire.
>> I agree with checking for space on the link.
>>
>> The above formula is a good lower bound on the maximum number of slots,
>> but there are many times when a client could use more slots than the
>> above formula.  For example, we don't want to punish writes if rsize>
>> wsize.  Also, you have to account for the server memory, which can
>> sometimes hold several write requests while waiting for them to  be
>> sync'd to disk, leaving the TCP buffers less than full.
> Err... No... On the contrary, it is a good _upper_ bound on the number
> of slots. There is no point in allocating a slot for an RPC request
> which you know you have no ability to transmit. That has nothing to do
> with rsize or wsize values: if the socket is backed up, it won't take
> more data.

Absolutely, I'm just trying to point out that checking the 
SOCK_ASYNC_NOSPACE flag seems to be the only way to guarantee it won't 
take more data.
Dean
> Trond
>
