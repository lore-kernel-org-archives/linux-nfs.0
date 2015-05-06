Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:23297 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751110AbbEFNYW convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 6 May 2015 09:24:22 -0400
Content-Type: text/plain; charset=windows-1252
Mime-Version: 1.0 (Mac OS X Mail 7.3 \(1878.6\))
Subject: Re: [PATCH v1 02/14] xprtrdma: Warn when there are orphaned IB objects
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <CANjDDBicLDb7K=RZB5Gqv+oACaAG8DANJX3ML971jnXd_5KEuQ@mail.gmail.com>
Date: Wed, 6 May 2015 09:24:19 -0400
Cc: linux-rdma@vger.kernel.org,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <963F9850-38D0-4434-88E8-14BC42F74499@oracle.com>
References: <20150504174626.3483.97639.stgit@manet.1015granger.net> <20150504175700.3483.57728.stgit@manet.1015granger.net> <CANjDDBicLDb7K=RZB5Gqv+oACaAG8DANJX3ML971jnXd_5KEuQ@mail.gmail.com>
To: Devesh Sharma <devesh.sharma@avagotech.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Devesh-

On May 6, 2015, at 7:37 AM, Devesh Sharma <devesh.sharma@avagotech.com> wrote:

> On Mon, May 4, 2015 at 11:27 PM, Chuck Lever <chuck.lever@oracle.com> wrote:
>> 
>> Print an error during transport destruction if ib_dealloc_pd()
>> fails. This is a sign that xprtrdma orphaned one or more RDMA API
>> objects at some point, which can pin lower layer kernel modules
>> and cause shutdown to hang.
>> 
>> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
>> ---
>> net/sunrpc/xprtrdma/verbs.c |    4 ++--
>> 1 file changed, 2 insertions(+), 2 deletions(-)
>> 
>> diff --git a/net/sunrpc/xprtrdma/verbs.c b/net/sunrpc/xprtrdma/verbs.c
>> index 4870d27..0cc4617 100644
>> --- a/net/sunrpc/xprtrdma/verbs.c
>> +++ b/net/sunrpc/xprtrdma/verbs.c
>> @@ -710,8 +710,8 @@ rpcrdma_ia_close(struct rpcrdma_ia *ia)
>>        }
>>        if (ia->ri_pd != NULL && !IS_ERR(ia->ri_pd)) {
>>                rc = ib_dealloc_pd(ia->ri_pd);
>> -               dprintk("RPC:       %s: ib_dealloc_pd returned %i\n",
>> -                       __func__, rc);
> 
> Should we check for EBUSY explicitly? other then this is an error in
> vendor specific ib_dealloc_pd()

Any error return means ib_dealloc_pd() has failed, right? Doesn’t that
mean the PD is still allocated, and could cause problems later?


>> +               if (rc)
>> +                       pr_warn("rpcrdma: ib_dealloc_pd status %i\n", rc);
>>        }
>> }

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com



