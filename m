Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:20965 "EHLO
        userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754167AbcH2UCg (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 29 Aug 2016 16:02:36 -0400
Content-Type: text/plain; charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 9.3 \(3124\))
Subject: Re: [PATCH v2 19/22] xprtrdma: Support larger inline thresholds
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <c922120b-35f3-65bf-e778-3cef645cee48@Netapp.com>
Date: Mon, 29 Aug 2016 16:02:28 -0400
Cc: List Linux RDMA Mailing <linux-rdma@vger.kernel.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <741D8723-D193-4F52-826F-807F89DC19C7@oracle.com>
References: <20160823174402.13038.84561.stgit@manet.1015granger.net> <20160823175438.13038.1624.stgit@manet.1015granger.net> <c922120b-35f3-65bf-e778-3cef645cee48@Netapp.com>
To: Anna Schumaker <Anna.Schumaker@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


> On Aug 29, 2016, at 3:52 PM, Anna Schumaker <Anna.Schumaker@netapp.com> wrote:
> 
> Hi Chuck,
> 
> On 08/23/2016 01:54 PM, Chuck Lever wrote:
>> RPC-over-RDMA Version Two will likely require at least a 4KB inline
>> threshold by default. The Version One inline threshold is still 1KB,
>> and it's automatically negotiated down to in
>> rpcrdma_update_connect_private.
> 
> I'm curious, what is the status of RPCoRDMA v2?

There is a personal draft published:

  https://datatracker.ietf.org/doc/draft-cel-nfsv4-rpcrdma-version-two/

And being discussed actively in the nfsv4 Working Group.

The features added in this series are usable with the Linux V1 implementation
too; the point being to experiment with these new facilities before we finish
RPC-over-RDMA Version Two.


> Thanks,
> Anna
> 
>> 
>> The maximum is somewhat arbitrary. There's no fundamental
>> architectural limit I'm aware of, but it's good to keep the size of
>> Receive buffers reasonable. Now that Send can use a s/g list, a
>> Send buffer is only as large as each RPC requires. Receive buffers
>> are always the size of the inline threshold, however.
>> 
>> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
>> ---
>> include/linux/sunrpc/xprtrdma.h |    4 ++--
>> net/sunrpc/xprtrdma/transport.c |    4 ++--
>> 2 files changed, 4 insertions(+), 4 deletions(-)
>> 
>> diff --git a/include/linux/sunrpc/xprtrdma.h b/include/linux/sunrpc/xprtrdma.h
>> index 39267dc..221b7a2 100644
>> --- a/include/linux/sunrpc/xprtrdma.h
>> +++ b/include/linux/sunrpc/xprtrdma.h
>> @@ -53,8 +53,8 @@
>> #define RPCRDMA_MAX_SLOT_TABLE	(256U)
>> 
>> #define RPCRDMA_MIN_INLINE  (1024)	/* min inline thresh */
>> -#define RPCRDMA_DEF_INLINE  (1024)	/* default inline thresh */
>> -#define RPCRDMA_MAX_INLINE  (3068)	/* max inline thresh */
>> +#define RPCRDMA_DEF_INLINE  (4096)	/* default inline thresh */
>> +#define RPCRDMA_MAX_INLINE  (65536)	/* max inline thresh */
>> 
>> /* Memory registration strategies, by number.
>>  * This is part of a kernel / user space API. Do not remove. */
>> diff --git a/net/sunrpc/xprtrdma/transport.c b/net/sunrpc/xprtrdma/transport.c
>> index 6a358ab..ed5e285 100644
>> --- a/net/sunrpc/xprtrdma/transport.c
>> +++ b/net/sunrpc/xprtrdma/transport.c
>> @@ -97,7 +97,7 @@ static struct ctl_table xr_tunables_table[] = {
>> 		.data		= &xprt_rdma_max_inline_read,
>> 		.maxlen		= sizeof(unsigned int),
>> 		.mode		= 0644,
>> -		.proc_handler	= proc_dointvec,
>> +		.proc_handler	= proc_dointvec_minmax,
>> 		.extra1		= &min_inline_size,
>> 		.extra2		= &max_inline_size,
>> 	},
>> @@ -106,7 +106,7 @@ static struct ctl_table xr_tunables_table[] = {
>> 		.data		= &xprt_rdma_max_inline_write,
>> 		.maxlen		= sizeof(unsigned int),
>> 		.mode		= 0644,
>> -		.proc_handler	= proc_dointvec,
>> +		.proc_handler	= proc_dointvec_minmax,
>> 		.extra1		= &min_inline_size,
>> 		.extra2		= &max_inline_size,
>> 	},
>> 
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>> 
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

--
Chuck Lever



