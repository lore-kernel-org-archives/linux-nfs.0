Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:24621 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932822AbbELSTg convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 12 May 2015 14:19:36 -0400
Content-Type: text/plain; charset=windows-1252
Mime-Version: 1.0 (Mac OS X Mail 7.3 \(1878.6\))
Subject: Re: [PATCH v2 02/16] xprtrdma: Warn when there are orphaned IB objects
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <5552428D.7010907@Netapp.com>
Date: Tue, 12 May 2015 14:20:00 -0400
Cc: linux-rdma@vger.kernel.org,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <D9E151CC-AC68-42BF-9025-AEB77201611D@oracle.com>
References: <20150511174401.31263.79596.stgit@manet.1015granger.net> <20150511180235.31263.71754.stgit@manet.1015granger.net> <5552428D.7010907@Netapp.com>
To: Anna Schumaker <Anna.Schumaker@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On May 12, 2015, at 2:12 PM, Anna Schumaker <Anna.Schumaker@netapp.com> wrote:

> Hi Chuck,
> 
> On 05/11/2015 02:02 PM, Chuck Lever wrote:
>> WARN during transport destruction if ib_dealloc_pd() fails. This is
>> a sign that xprtrdma orphaned one or more RDMA API objects at some
>> point, which can pin lower layer kernel modules and cause shutdown
>> to hang.
> 
> I'm curious, what would cause an RDMA object to get orphaned in the first place?

A leaked object means there’s a software bug in the API consumer, which
is xprtrdma in this case. xprtrdma is supposed to track and clean up
every object it creates.

> Is there any way to prevent that?

The usual thing to do is find and fix the bug that allowed the leak.

> Anna
> 
>> 
>> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
>> Reviewed-by: Steve Wise <swise@opengridcomputing.com>
>> Reviewed-by: Sagi Grimberg <sagig@mellanox.com>
>> Reviewed-by: Devesh Sharma <devesh.sharma@avagotech.com>
>> ---
>> net/sunrpc/xprtrdma/verbs.c |   10 +++++-----
>> 1 file changed, 5 insertions(+), 5 deletions(-)
>> 
>> diff --git a/net/sunrpc/xprtrdma/verbs.c b/net/sunrpc/xprtrdma/verbs.c
>> index 4870d27..51900e6 100644
>> --- a/net/sunrpc/xprtrdma/verbs.c
>> +++ b/net/sunrpc/xprtrdma/verbs.c
>> @@ -702,17 +702,17 @@ rpcrdma_ia_close(struct rpcrdma_ia *ia)
>> 		dprintk("RPC:       %s: ib_dereg_mr returned %i\n",
>> 			__func__, rc);
>> 	}
>> +
>> 	if (ia->ri_id != NULL && !IS_ERR(ia->ri_id)) {
>> 		if (ia->ri_id->qp)
>> 			rdma_destroy_qp(ia->ri_id);
>> 		rdma_destroy_id(ia->ri_id);
>> 		ia->ri_id = NULL;
>> 	}
>> -	if (ia->ri_pd != NULL && !IS_ERR(ia->ri_pd)) {
>> -		rc = ib_dealloc_pd(ia->ri_pd);
>> -		dprintk("RPC:       %s: ib_dealloc_pd returned %i\n",
>> -			__func__, rc);
>> -	}
>> +
>> +	/* If the pd is still busy, xprtrdma missed freeing a resource */
>> +	if (ia->ri_pd && !IS_ERR(ia->ri_pd))
>> +		WARN_ON(ib_dealloc_pd(ia->ri_pd));
>> }
>> 
>> /*
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
chuck[dot]lever[at]oracle[dot]com



