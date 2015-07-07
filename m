Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-db3on0084.outbound.protection.outlook.com ([157.55.234.84]:60448
	"EHLO emea01-db3-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1757737AbbGGOfG (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 7 Jul 2015 10:35:06 -0400
Message-ID: <559BE365.4070007@mellanox.com>
Date: Tue, 7 Jul 2015 17:34:13 +0300
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
In-Reply-To: <001e01d0b8bf$9785ff70$c691fe50$@opengridcomputing.com>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 07/07/2015 17:17, Steve Wise wrote:
> 
> 
>> -----Original Message-----
>> From: linux-nfs-owner@vger.kernel.org [mailto:linux-nfs-owner@vger.kernel.org] On Behalf Of Haggai Eran
>> Sent: Monday, July 06, 2015 2:09 AM
>> To: Steve Wise; dledford@redhat.com
>> Cc: sagig@mellanox.com; ogerlitz@mellanox.com; roid@mellanox.com; linux-rdma@vger.kernel.org; eli@mellanox.com; target-
>> devel@vger.kernel.org; linux-nfs@vger.kernel.org; trond.myklebust@primarydata.com; bfields@fieldses.org
>> Subject: Re: [PATCH V3 1/5] RDMA/core: Transport-independent access flags
>>
>> On 06/07/2015 02:22, Steve Wise wrote:
>>> +int rdma_device_access_flags(struct ib_pd *pd, int roles, int attrs)
>>> +{
>>> +	int access_flags = attrs;
>>> +
>>> +	if (roles & RDMA_MRR_RECV)
>>> +		access_flags |= IB_ACCESS_LOCAL_WRITE;
>>> +
>>> +	if (roles & RDMA_MRR_WRITE_DEST)
>>> +		access_flags |= IB_ACCESS_LOCAL_WRITE | IB_ACCESS_REMOTE_WRITE;
>>> +
>>> +	if (roles & RDMA_MRR_READ_DEST) {
>>> +		access_flags |= IB_ACCESS_LOCAL_WRITE;
>>> +		if (rdma_protocol_iwarp(pd->device,
>>> +					rdma_start_port(pd->device)))
>>> +			access_flags |= IB_ACCESS_REMOTE_WRITE;
>>> +	}
>>> +
>>> +	if (roles & RDMA_MRR_READ_SOURCE)
>>> +		access_flags |= IB_ACCESS_REMOTE_READ;
>>> +
>>> +	if (roles & RDMA_MRR_ATOMIC_DEST)
>>> +		access_flags |= IB_ACCESS_LOCAL_WRITE | IB_ACCESS_REMOTE_ATOMIC;
>>
>> I think you need LOCAL_WRITE for ATOMIC_SOURCE in order to receive the
>> results of the atomic operation.
>>
> 
> Where/how are the results returned?  In a recv completion?  If so, then that MR would need RDMA_MRR_RECV, not RDMA_MRR_ATOMIC_SOURCE.

They are returned in the scatter list provided in ib_send_wr.sg_list,
similarly to how RDMA read results are returned.
