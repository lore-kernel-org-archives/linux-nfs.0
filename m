Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:42519 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932177AbbGJOz1 convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 10 Jul 2015 10:55:27 -0400
Content-Type: text/plain; charset=windows-1252
Mime-Version: 1.0 (Mac OS X Mail 7.3 \(1878.6\))
Subject: Re: [PATCH v1 09/12] xprtrdma: Prepare rpcrdma_ep_post() for RDMA_NOMSG calls
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <CANjDDBipaXMO7Z5wirG127E9kQ0aHdWJ1s6ZM21th5RWLNh-4Q@mail.gmail.com>
Date: Fri, 10 Jul 2015 10:53:40 -0400
Cc: Tom Talpey <tom@talpey.com>, linux-rdma@vger.kernel.org,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <F5F5CAC4-866E-4BCA-8094-908CE9ED3B4B@oracle.com>
References: <20150709203242.26247.4848.stgit@manet.1015granger.net> <20150709204305.26247.39173.stgit@manet.1015granger.net> <CANjDDBh38PrxGgWGuKYCYcbjqY9ELrpkGqaRZ_ueKfD7FEQP8g@mail.gmail.com> <559FC17A.7060502@talpey.com> <CANjDDBipaXMO7Z5wirG127E9kQ0aHdWJ1s6ZM21th5RWLNh-4Q@mail.gmail.com>
To: Devesh Sharma <devesh.sharma@avagotech.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Jul 10, 2015, at 10:11 AM, Devesh Sharma <devesh.sharma@avagotech.com> wrote:

> On Fri, Jul 10, 2015 at 6:28 PM, Tom Talpey <tom@talpey.com> wrote:
>> On 7/10/2015 7:29 AM, Devesh Sharma wrote:
>>> 
>>> we need to honor the max limits of device by checking
>>> dev_attr.max_sge? a vendor may not support 4 sges.
>> 
>> 
>> iWARP requires a minimum of 4 send SGEs (draft-hilland-verbs 8.1.3.2)
>> 
>>   An RI MUST support at least four Scatter/Gather Elements per
>>   Scatter/Gather List when the Scatter/Gather List refers to the Data
>>   Source of a Send Operation Type or the Data Sink of a Receive
>>   Operation. An RI is NOT REQUIRED to support more than one
>>   Scatter/Gather Element per Scatter/Gather List when the
>>   Scatter/Gather List refers to the Data Source of an RDMA Write.
>> 
>> I'm not certain if IB and RoCE state a similar minimum requirement,
>> but it seems a very bad idea to have fewer.
> 
> To my knowledge IBTA Spec do not pose any such minimum requirement.
> RoCE also do not puts any minimum requirement. I think its fine if
> xprtrdma honors the device limits, thus covering iWARP devices because
> all iWARP devices would support minimum 4.
> 
> Chuck would correct me if xprtrdma do have any minimum requirements

At least 2 SGEs are required for normal operation. The code in
rpcrdma_marshal_req() sets up an iovec for the RPC/RDMA header
and one for the RPC message itself. These are used in
rpcrdma_ep_post() to SEND each request.

Four SGEs are needed only for RDMA_MSGP type requests, but so far
I have never seen one of these used. I wonder if that logic can
be removed.

It is certainly possible to examine the device’s max_sge field
in rpcrdma_ep_create() and fail transport creation if the
device’s max_sge is less than RPC_MAX_IOVS.

--
Chuck Lever



