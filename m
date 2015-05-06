Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-wg0-f47.google.com ([74.125.82.47]:34378 "EHLO
	mail-wg0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752215AbbEFOFk (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 6 May 2015 10:05:40 -0400
Received: by wgso17 with SMTP id o17so12930851wgs.1
        for <linux-nfs@vger.kernel.org>; Wed, 06 May 2015 07:05:39 -0700 (PDT)
Message-ID: <554A1FBF.2080504@dev.mellanox.co.il>
Date: Wed, 06 May 2015 17:05:51 +0300
From: Sagi Grimberg <sagig@dev.mellanox.co.il>
MIME-Version: 1.0
To: Chuck Lever <chuck.lever@oracle.com>,
        Devesh Sharma <devesh.sharma@avagotech.com>
CC: linux-rdma@vger.kernel.org,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH v1 02/14] xprtrdma: Warn when there are orphaned IB objects
References: <20150504174626.3483.97639.stgit@manet.1015granger.net> <20150504175700.3483.57728.stgit@manet.1015granger.net> <CANjDDBicLDb7K=RZB5Gqv+oACaAG8DANJX3ML971jnXd_5KEuQ@mail.gmail.com> <963F9850-38D0-4434-88E8-14BC42F74499@oracle.com>
In-Reply-To: <963F9850-38D0-4434-88E8-14BC42F74499@oracle.com>
Content-Type: text/plain; charset=windows-1252; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 5/6/2015 4:24 PM, Chuck Lever wrote:
> Hi Devesh-
>
> On May 6, 2015, at 7:37 AM, Devesh Sharma <devesh.sharma@avagotech.com> wrote:
>
>> On Mon, May 4, 2015 at 11:27 PM, Chuck Lever <chuck.lever@oracle.com> wrote:
>>>
>>> Print an error during transport destruction if ib_dealloc_pd()
>>> fails. This is a sign that xprtrdma orphaned one or more RDMA API
>>> objects at some point, which can pin lower layer kernel modules
>>> and cause shutdown to hang.
>>>
>>> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
>>> ---
>>> net/sunrpc/xprtrdma/verbs.c |    4 ++--
>>> 1 file changed, 2 insertions(+), 2 deletions(-)
>>>
>>> diff --git a/net/sunrpc/xprtrdma/verbs.c b/net/sunrpc/xprtrdma/verbs.c
>>> index 4870d27..0cc4617 100644
>>> --- a/net/sunrpc/xprtrdma/verbs.c
>>> +++ b/net/sunrpc/xprtrdma/verbs.c
>>> @@ -710,8 +710,8 @@ rpcrdma_ia_close(struct rpcrdma_ia *ia)
>>>         }
>>>         if (ia->ri_pd != NULL && !IS_ERR(ia->ri_pd)) {
>>>                 rc = ib_dealloc_pd(ia->ri_pd);
>>> -               dprintk("RPC:       %s: ib_dealloc_pd returned %i\n",
>>> -                       __func__, rc);
>>
>> Should we check for EBUSY explicitly? other then this is an error in
>> vendor specific ib_dealloc_pd()
>
> Any error return means ib_dealloc_pd() has failed, right? Doesn’t that
> mean the PD is still allocated, and could cause problems later?

AFAICT, the only non-zero rc that ib_dealloc_pd should return is EBUSY.
So I don't see value in verifying it at all.

So, Looks Good

Reviewed-by: Sagi Grimberg <sagig@mellanox.com>
