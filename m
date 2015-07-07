Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-am1on0058.outbound.protection.outlook.com ([157.56.112.58]:19366
	"EHLO emea01-am1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S932464AbbGGPHl (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 7 Jul 2015 11:07:41 -0400
Message-ID: <559BEB45.9020706@mellanox.com>
Date: Tue, 7 Jul 2015 18:07:49 +0300
From: Haggai Eran <haggaie@mellanox.com>
MIME-Version: 1.0
To: Steve Wise <swise@opengridcomputing.com>, <dledford@redhat.com>
CC: <sagig@mellanox.com>, <ogerlitz@mellanox.com>, <roid@mellanox.com>,
        <linux-rdma@vger.kernel.org>, <eli@mellanox.com>,
        <target-devel@vger.kernel.org>, <linux-nfs@vger.kernel.org>,
        <trond.myklebust@primarydata.com>, <bfields@fieldses.org>
Subject: Re: [PATCH V3 1/5] RDMA/core: Transport-independent access flags
References: <20150705231831.12029.80307.stgit@build2.ogc.int>
 <20150705232158.12029.25472.stgit@build2.ogc.int>
 <559A2991.3040304@mellanox.com>
 <001e01d0b8bf$9785ff70$c691fe50$@opengridcomputing.com>
 <559BE365.4070007@mellanox.com>
 <003201d0b8c3$b7e29e00$27a7da00$@opengridcomputing.com>
In-Reply-To: <003201d0b8c3$b7e29e00$27a7da00$@opengridcomputing.com>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 07/07/2015 17:46, Steve Wise wrote:
> 
> 
>> -----Original Message-----
>> From: Haggai Eran [mailto:haggaie@mellanox.com]
>> Sent: Tuesday, July 07, 2015 9:34 AM
>> To: Steve Wise; dledford@redhat.com
>> Cc: sagig@mellanox.com; ogerlitz@mellanox.com; roid@mellanox.com; linux-rdma@vger.kernel.org; eli@mellanox.com; target-
>> devel@vger.kernel.org; linux-nfs@vger.kernel.org; trond.myklebust@primarydata.com; bfields@fieldses.org
>> Subject: Re: [PATCH V3 1/5] RDMA/core: Transport-independent access flags
>>
>> On 07/07/2015 17:17, Steve Wise wrote:
>>>
>>>
>>>> -----Original Message-----
>>>> From: linux-nfs-owner@vger.kernel.org [mailto:linux-nfs-owner@vger.kernel.org] On Behalf Of Haggai Eran
>>>> Sent: Monday, July 06, 2015 2:09 AM
>>>> To: Steve Wise; dledford@redhat.com
>>>> Cc: sagig@mellanox.com; ogerlitz@mellanox.com; roid@mellanox.com; linux-rdma@vger.kernel.org; eli@mellanox.com; target-
>>>> devel@vger.kernel.org; linux-nfs@vger.kernel.org; trond.myklebust@primarydata.com; bfields@fieldses.org
>>>> Subject: Re: [PATCH V3 1/5] RDMA/core: Transport-independent access flags
>>>>
>>>> On 06/07/2015 02:22, Steve Wise wrote:
>>>>> +int rdma_device_access_flags(struct ib_pd *pd, int roles, int attrs)
>>>>> +{
>>>>> +	int access_flags = attrs;
>>>>> +
>>>>> +	if (roles & RDMA_MRR_RECV)
>>>>> +		access_flags |= IB_ACCESS_LOCAL_WRITE;
>>>>> +
>>>>> +	if (roles & RDMA_MRR_WRITE_DEST)
>>>>> +		access_flags |= IB_ACCESS_LOCAL_WRITE | IB_ACCESS_REMOTE_WRITE;
>>>>> +
>>>>> +	if (roles & RDMA_MRR_READ_DEST) {
>>>>> +		access_flags |= IB_ACCESS_LOCAL_WRITE;
>>>>> +		if (rdma_protocol_iwarp(pd->device,
>>>>> +					rdma_start_port(pd->device)))
>>>>> +			access_flags |= IB_ACCESS_REMOTE_WRITE;
>>>>> +	}
>>>>> +
>>>>> +	if (roles & RDMA_MRR_READ_SOURCE)
>>>>> +		access_flags |= IB_ACCESS_REMOTE_READ;
>>>>> +
>>>>> +	if (roles & RDMA_MRR_ATOMIC_DEST)
>>>>> +		access_flags |= IB_ACCESS_LOCAL_WRITE | IB_ACCESS_REMOTE_ATOMIC;
>>>>
>>>> I think you need LOCAL_WRITE for ATOMIC_SOURCE in order to receive the
>>>> results of the atomic operation.
>>>>
>>>
>>> Where/how are the results returned?  In a recv completion?  If so, then that MR would need RDMA_MRR_RECV, not
>> RDMA_MRR_ATOMIC_SOURCE.
>>
>> They are returned in the scatter list provided in ib_send_wr.sg_list,
>> similarly to how RDMA read results are returned.
> 
> Ah.  Hmm.  I was confused about how the atomic operations worked.  
> 
> Is this correct:
> 
> ib_send_wr.wr.atomic.remote_addr : the peer's address that will be the target of the atomic operation.
> ib_send_wr.wr.atomic.compare_add/compare_add_mask: the data to be used in the atomic compare-and-add on the target address
Yes, in compare and swap, this is the value to compare the original
remote data with. In fetch and add, this would be the value to add.

> ib_send_wr.wr.atomic.swap/swap_mask: the data to be used in an atomic swap on the target address.
This is used in compare and swap as the data to write if the comparison
succeeds.

> ib_send_wr.sg_list: results from the swap or compare/add.
> 
> Is the above correct? 
Pretty much. See above.

> 
> Maybe the two role names should be RDMA_MRR_ATOMIC_TARGET and RDMA_MRR_ATOMIC_RESULT?
Sounds good.

Haggai
