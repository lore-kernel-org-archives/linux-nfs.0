Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-lb0-f179.google.com ([209.85.217.179]:36841 "EHLO
	mail-lb0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751013AbbEFOWE convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 6 May 2015 10:22:04 -0400
Received: by lbbqq2 with SMTP id qq2so8736560lbb.3
        for <linux-nfs@vger.kernel.org>; Wed, 06 May 2015 07:22:03 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <963F9850-38D0-4434-88E8-14BC42F74499@oracle.com>
References: <20150504174626.3483.97639.stgit@manet.1015granger.net>
	<20150504175700.3483.57728.stgit@manet.1015granger.net>
	<CANjDDBicLDb7K=RZB5Gqv+oACaAG8DANJX3ML971jnXd_5KEuQ@mail.gmail.com>
	<963F9850-38D0-4434-88E8-14BC42F74499@oracle.com>
Date: Wed, 6 May 2015 19:52:03 +0530
Message-ID: <CANjDDBg3Ey0DEM3n9PY9VLW+chF0=AJPghYOopo1a9vL3CKzKg@mail.gmail.com>
Subject: Re: [PATCH v1 02/14] xprtrdma: Warn when there are orphaned IB objects
From: Devesh Sharma <devesh.sharma@avagotech.com>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: linux-rdma@vger.kernel.org,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, May 6, 2015 at 6:54 PM, Chuck Lever <chuck.lever@oracle.com> wrote:
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
>>>        }
>>>        if (ia->ri_pd != NULL && !IS_ERR(ia->ri_pd)) {
>>>                rc = ib_dealloc_pd(ia->ri_pd);
>>> -               dprintk("RPC:       %s: ib_dealloc_pd returned %i\n",
>>> -                       __func__, rc);
>>
>> Should we check for EBUSY explicitly? other then this is an error in
>> vendor specific ib_dealloc_pd()
>
> Any error return means ib_dealloc_pd() has failed, right? Doesn’t that
> mean the PD is still allocated, and could cause problems later?

Yes, you are correct, I was thinking ib_dealloc_pd() has a refcount
implemented in the core layer, thus if the PD is used by any resource,
it will always fail with -EBUSY.
.With emulex adapter it is possible to fail dealloc_pd with ENOMEM or
EIO in cases where device f/w is not responding etc. this situation do
not represent PD is actually in use.

>
>
>>> +               if (rc)
>>> +                       pr_warn("rpcrdma: ib_dealloc_pd status %i\n", rc);
>>>        }
>>> }
>
> --
> Chuck Lever
> chuck[dot]lever[at]oracle[dot]com
>
>
>



-- 
-Regards
Devesh
