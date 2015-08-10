Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:23143 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932726AbbHJV1W convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 10 Aug 2015 17:27:22 -0400
Content-Type: text/plain; charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 7.3 \(1878.6\))
Subject: Re: [PATCH] svcrdma: Change maximum server payload back to RPCSVC_MAXPAYLOAD
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <20150810210557.GC10455@fieldses.org>
Date: Mon, 10 Aug 2015 17:27:18 -0400
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <4E4E8EA4-AF06-4BB6-ABAB-5D9B5BF6FEB6@oracle.com>
References: <20150807205325.1887.53743.stgit@klimt.1015granger.net> <20150810210557.GC10455@fieldses.org>
To: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Aug 10, 2015, at 5:05 PM, J. Bruce Fields <bfields@fieldses.org> wrote:

> On Fri, Aug 07, 2015 at 04:55:46PM -0400, Chuck Lever wrote:
>> Both commit 0380a3f375 ("svcrdma: Add a separate "max data segs"
>> macro for svcrdma") and commit 7e5be28827bf ("svcrdma: advertise
>> the correct max payload") are incorrect. This commit reverts both
>> changes, restoring the server's maximum payload size to 1MB.
>> 
>> Commit 7e5be28827bf based the server's maximum payload on the
>> _client's_ RPCRDMA_MAX_DATA_SEGS value. That was wrong.
>> 
>> Commit 0380a3f375 tried to fix this so that the client maximum
>> payload size could be raised without affecting the server, but
>> managed to confuse matters more on the server side.
>> 
>> More importantly, limiting the advertised maximum payload size was
>> meant to be a workaround, not the actual fix. We need to revisit
>> 
>>  https://bugzilla.linux-nfs.org/show_bug.cgi?id=270
>> 
>> A Linux client on a platform with 64KB pages can overrun and crash
>> an x86_64 NFS/RDMA server when the r/wsize is 1MB. An x86/64 Linux
>> client seems to work fine using 1MB reads and writes when the Linux
>> server's maximum payload size is restored to 1MB.
>> 
>> BugLink: https://bugzilla.linux-nfs.org/show_bug.cgi?id=270
>> Fixes: 0380a3f375 ("svcrdma: Add a separate "max data segs" macro")
>> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
>> ---
>> 
>> Hi Bruce-
>> 
>> I notice you still have "svcrdma: Boost NFS READ/WRITE payload
>> size maximum" in both your nfsd-next and for-4.3 branches. Can
>> you please replace that patch with this one? This patch uses
>> the approach we agreed on several weeks ago.
>> 
>> Thanks!
> 
> Gah, I don't like rebasing those for-XXX branches, but OK, done.  In the
> future I'd prefer incremental patches against those branches if at all
> possible.

Thanks for taking the update!

I thought you were going to wait for v2 of that series.

http://marc.info/?l=linux-nfs&m=143680563000597&w=2

That's why I concluded a replacement rather than an incremental
was OK. I didn't realize those topic branches had a locked
history.


> --b.
> 
>> 
>> 
>> include/linux/sunrpc/svc_rdma.h          |    9 ++-------
>> net/sunrpc/xprtrdma/svc_rdma_transport.c |    2 +-
>> net/sunrpc/xprtrdma/xprt_rdma.h          |    1 -
>> 3 files changed, 3 insertions(+), 9 deletions(-)
>> 
>> diff --git a/include/linux/sunrpc/svc_rdma.h b/include/linux/sunrpc/svc_rdma.h
>> index 13af61b..d5ee6d8 100644
>> --- a/include/linux/sunrpc/svc_rdma.h
>> +++ b/include/linux/sunrpc/svc_rdma.h
>> @@ -172,13 +172,6 @@ struct svcxprt_rdma {
>> #define RDMAXPRT_SQ_PENDING	2
>> #define RDMAXPRT_CONN_PENDING	3
>> 
>> -#define RPCRDMA_MAX_SVC_SEGS	(64)	/* server max scatter/gather */
>> -#if RPCSVC_MAXPAYLOAD < (RPCRDMA_MAX_SVC_SEGS << PAGE_SHIFT)
>> -#define RPCRDMA_MAXPAYLOAD	RPCSVC_MAXPAYLOAD
>> -#else
>> -#define RPCRDMA_MAXPAYLOAD	(RPCRDMA_MAX_SVC_SEGS << PAGE_SHIFT)
>> -#endif
>> -
>> #define RPCRDMA_LISTEN_BACKLOG  10
>> /* The default ORD value is based on two outstanding full-size writes with a
>>  * page size of 4k, or 32k * 2 ops / 4k = 16 outstanding RDMA_READ.  */
>> @@ -187,6 +180,8 @@ struct svcxprt_rdma {
>> #define RPCRDMA_MAX_REQUESTS    32
>> #define RPCRDMA_MAX_REQ_SIZE    4096
>> 
>> +#define RPCSVC_MAXPAYLOAD_RDMA	RPCSVC_MAXPAYLOAD
>> +
>> /* svc_rdma_marshal.c */
>> extern int svc_rdma_xdr_decode_req(struct rpcrdma_msg **, struct svc_rqst *);
>> extern int svc_rdma_xdr_encode_error(struct svcxprt_rdma *,
>> diff --git a/net/sunrpc/xprtrdma/svc_rdma_transport.c b/net/sunrpc/xprtrdma/svc_rdma_transport.c
>> index 4054a9d..21e4036 100644
>> --- a/net/sunrpc/xprtrdma/svc_rdma_transport.c
>> +++ b/net/sunrpc/xprtrdma/svc_rdma_transport.c
>> @@ -91,7 +91,7 @@ struct svc_xprt_class svc_rdma_class = {
>> 	.xcl_name = "rdma",
>> 	.xcl_owner = THIS_MODULE,
>> 	.xcl_ops = &svc_rdma_ops,
>> -	.xcl_max_payload = RPCRDMA_MAXPAYLOAD,
>> +	.xcl_max_payload = RPCSVC_MAXPAYLOAD_RDMA,
>> 	.xcl_ident = XPRT_TRANSPORT_RDMA,
>> };
>> 
>> diff --git a/net/sunrpc/xprtrdma/xprt_rdma.h b/net/sunrpc/xprtrdma/xprt_rdma.h
>> index f49dd8b..e718d09 100644
>> --- a/net/sunrpc/xprtrdma/xprt_rdma.h
>> +++ b/net/sunrpc/xprtrdma/xprt_rdma.h
>> @@ -51,7 +51,6 @@
>> #include <linux/sunrpc/clnt.h> 		/* rpc_xprt */
>> #include <linux/sunrpc/rpc_rdma.h> 	/* RPC/RDMA protocol */
>> #include <linux/sunrpc/xprtrdma.h> 	/* xprt parameters */
>> -#include <linux/sunrpc/svc.h>		/* RPCSVC_MAXPAYLOAD */
>> 
>> #define RDMA_RESOLVE_TIMEOUT	(5000)	/* 5 seconds */
>> #define RDMA_CONNECT_RETRY_MAX	(2)	/* retries if no listener backlog */

--
Chuck Lever



