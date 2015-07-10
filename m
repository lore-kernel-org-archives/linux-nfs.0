Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pa0-f47.google.com ([209.85.220.47]:36603 "EHLO
	mail-pa0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754893AbbGJOL0 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 10 Jul 2015 10:11:26 -0400
Received: by pacgz10 with SMTP id gz10so95775489pac.3
        for <linux-nfs@vger.kernel.org>; Fri, 10 Jul 2015 07:11:25 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <559FC17A.7060502@talpey.com>
References: <20150709203242.26247.4848.stgit@manet.1015granger.net>
	<20150709204305.26247.39173.stgit@manet.1015granger.net>
	<CANjDDBh38PrxGgWGuKYCYcbjqY9ELrpkGqaRZ_ueKfD7FEQP8g@mail.gmail.com>
	<559FC17A.7060502@talpey.com>
Date: Fri, 10 Jul 2015 19:41:25 +0530
Message-ID: <CANjDDBipaXMO7Z5wirG127E9kQ0aHdWJ1s6ZM21th5RWLNh-4Q@mail.gmail.com>
Subject: Re: [PATCH v1 09/12] xprtrdma: Prepare rpcrdma_ep_post() for
 RDMA_NOMSG calls
From: Devesh Sharma <devesh.sharma@avagotech.com>
To: Tom Talpey <tom@talpey.com>
Cc: Chuck Lever <chuck.lever@oracle.com>, linux-rdma@vger.kernel.org,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Jul 10, 2015 at 6:28 PM, Tom Talpey <tom@talpey.com> wrote:
> On 7/10/2015 7:29 AM, Devesh Sharma wrote:
>>
>> we need to honor the max limits of device by checking
>> dev_attr.max_sge? a vendor may not support 4 sges.
>
>
> iWARP requires a minimum of 4 send SGEs (draft-hilland-verbs 8.1.3.2)
>
>    An RI MUST support at least four Scatter/Gather Elements per
>    Scatter/Gather List when the Scatter/Gather List refers to the Data
>    Source of a Send Operation Type or the Data Sink of a Receive
>    Operation. An RI is NOT REQUIRED to support more than one
>    Scatter/Gather Element per Scatter/Gather List when the
>    Scatter/Gather List refers to the Data Source of an RDMA Write.
>
> I'm not certain if IB and RoCE state a similar minimum requirement,
> but it seems a very bad idea to have fewer.

To my knowledge IBTA Spec do not pose any such minimum requirement.
RoCE also do not puts any minimum requirement. I think its fine if
xprtrdma honors the device limits, thus covering iWARP devices because
all iWARP devices would support minimum 4.

Chuck would correct me if xprtrdma do have any minimum requirements

>
