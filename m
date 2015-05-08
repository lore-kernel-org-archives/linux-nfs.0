Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-lb0-f180.google.com ([209.85.217.180]:35688 "EHLO
	mail-lb0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752932AbbEHPer (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 8 May 2015 11:34:47 -0400
Received: by lbbuc2 with SMTP id uc2so55706324lbb.2
        for <linux-nfs@vger.kernel.org>; Fri, 08 May 2015 08:34:46 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <554B404B.9090301@dev.mellanox.co.il>
References: <20150504174626.3483.97639.stgit@manet.1015granger.net>
	<20150504175827.3483.62904.stgit@manet.1015granger.net>
	<554B404B.9090301@dev.mellanox.co.il>
Date: Fri, 8 May 2015 21:04:46 +0530
Message-ID: <CANjDDBijCVfYRTPdnY6CaJR+8dvrCVje7t9cBm8a7+MuhQ_N6g@mail.gmail.com>
Subject: Re: [PATCH v1 11/14] xprtrdma: Remove rpcrdma_ia::ri_memreg_strategy
From: Devesh Sharma <devesh.sharma@avagotech.com>
To: Sagi Grimberg <sagig@dev.mellanox.co.il>
Cc: Chuck Lever <chuck.lever@oracle.com>, linux-rdma@vger.kernel.org,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Reviewed-bt: Devesh Sharma <devesh.sharma@avagotech.com>

On Thu, May 7, 2015 at 4:06 PM, Sagi Grimberg <sagig@dev.mellanox.co.il> wrote:
> On 5/4/2015 8:58 PM, Chuck Lever wrote:
>>
>> Clean up: This field is no longer used.
>>
>> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
>> ---
>>   include/linux/sunrpc/xprtrdma.h |    3 ++-
>>   net/sunrpc/xprtrdma/verbs.c     |    3 ---
>>   net/sunrpc/xprtrdma/xprt_rdma.h |    1 -
>>   3 files changed, 2 insertions(+), 5 deletions(-)
>>
>> diff --git a/include/linux/sunrpc/xprtrdma.h
>> b/include/linux/sunrpc/xprtrdma.h
>> index c984c85..b176130 100644
>> --- a/include/linux/sunrpc/xprtrdma.h
>> +++ b/include/linux/sunrpc/xprtrdma.h
>> @@ -56,7 +56,8 @@
>>
>>   #define RPCRDMA_INLINE_PAD_THRESH  (512)/* payload threshold to pad
>> (bytes) */
>>
>> -/* memory registration strategies */
>> +/* Memory registration strategies, by number.
>> + * This is part of a kernel / user space API. Do not remove. */
>>   enum rpcrdma_memreg {
>>         RPCRDMA_BOUNCEBUFFERS = 0,
>>         RPCRDMA_REGISTER,
>> diff --git a/net/sunrpc/xprtrdma/verbs.c b/net/sunrpc/xprtrdma/verbs.c
>> index eaf0b9d..1f51547 100644
>> --- a/net/sunrpc/xprtrdma/verbs.c
>> +++ b/net/sunrpc/xprtrdma/verbs.c
>> @@ -671,9 +671,6 @@ rpcrdma_ia_open(struct rpcrdma_xprt *xprt, struct
>> sockaddr *addr, int memreg)
>>         dprintk("RPC:       %s: memory registration strategy is '%s'\n",
>>                 __func__, ia->ri_ops->ro_displayname);
>>
>> -       /* Else will do memory reg/dereg for each chunk */
>> -       ia->ri_memreg_strategy = memreg;
>> -
>>         rwlock_init(&ia->ri_qplock);
>>         return 0;
>>
>> diff --git a/net/sunrpc/xprtrdma/xprt_rdma.h
>> b/net/sunrpc/xprtrdma/xprt_rdma.h
>> index 6a1e565..5650c23 100644
>> --- a/net/sunrpc/xprtrdma/xprt_rdma.h
>> +++ b/net/sunrpc/xprtrdma/xprt_rdma.h
>> @@ -70,7 +70,6 @@ struct rpcrdma_ia {
>>         int                     ri_have_dma_lkey;
>>         struct completion       ri_done;
>>         int                     ri_async_rc;
>> -       enum rpcrdma_memreg     ri_memreg_strategy;
>>         unsigned int            ri_max_frmr_depth;
>>         struct ib_device_attr   ri_devattr;
>>         struct ib_qp_attr       ri_qp_attr;
>>
>
> Looks good,
>
> Reviewed-by: Sagi Grimberg <sagig@mellanox.com>
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html



-- 
-Regards
Devesh
