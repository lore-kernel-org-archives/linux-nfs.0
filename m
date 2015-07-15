Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:47169 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753623AbbGOV3z convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 15 Jul 2015 17:29:55 -0400
Content-Type: text/plain; charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 7.3 \(1878.6\))
Subject: Re: [PATCH v2 07/14] xprtrdma: Remove logic that constructs RDMA_MSGP type calls
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <CANjDDBgLX9pBWv5Jt6YwMFhRULWgfjSJNOvwa8L6kwkykRbnRw@mail.gmail.com>
Date: Wed, 15 Jul 2015 17:29:50 -0400
Cc: Tom Talpey <tom@talpey.com>, linux-rdma@vger.kernel.org,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <38D7020A-EF93-4545-A0BF-DF1C9645CA64@oracle.com>
References: <20150713160617.17630.97475.stgit@manet.1015granger.net> <20150713163048.17630.86326.stgit@manet.1015granger.net> <55A55C63.50403@talpey.com> <ED80C587-DFC7-4E4A-95E4-3ACBEC078D86@oracle.com> <CANjDDBgLX9pBWv5Jt6YwMFhRULWgfjSJNOvwa8L6kwkykRbnRw@mail.gmail.com>
To: Devesh Sharma <devesh.sharma@avagotech.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Thanks Devesh, will note that in the next versions of these series.


On Jul 15, 2015, at 2:26 PM, Devesh Sharma <devesh.sharma@avagotech.com> wrote:

> with MAX_IOVS set to 2 iozone passes with ocrdma device. My testing
> includes both the series of svcrdma and xprtrdma.
> 
> On Wed, Jul 15, 2015 at 12:31 AM, Chuck Lever <chuck.lever@oracle.com> wrote:
>> 
>> On Jul 14, 2015, at 3:00 PM, Tom Talpey <tom@talpey.com> wrote:
>> 
>>> On 7/13/2015 12:30 PM, Chuck Lever wrote:
>>>> RDMA_MSGP type calls insert a zero pad in the middle of the RPC
>>>> message to align the RPC request's data payload to the server's
>>>> alignment preferences. A server can then "page flip" the payload
>>>> into place to avoid a data copy in certain circumstances. However:
>>>> ...
>>>> 
>>>> Clean up the marshaling code by removing the logic that constructs
>>>> RDMA_MSGP type calls. This also reduces the maximum send iovec size
>>>> from four to just two elements.
>>>> 
>>> 
>>>> diff --git a/net/sunrpc/xprtrdma/xprt_rdma.h b/net/sunrpc/xprtrdma/xprt_rdma.h
>>>> index 8219011..0b50103 100644
>>>> --- a/net/sunrpc/xprtrdma/xprt_rdma.h
>>>> +++ b/net/sunrpc/xprtrdma/xprt_rdma.h
>>> ...>
>>>> +#define RPCRDMA_MAX_IOVS    (4)
>>>> +
>>> 
>>> So, shouldn't this constant be "2"? The extra 2 iov's were used
>>> only for constructing the pad.
>> 
>> Yes, thanks. I folded a couple of patches together into this
>> one, and forgot to update the constant.
>> 
>> 
>> --
>> Chuck Lever
>> 
>> 
>> 
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html

--
Chuck Lever



