Return-Path: linux-nfs-owner@vger.kernel.org
Received: from aserp1040.oracle.com ([141.146.126.69]:23627 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752021AbaGVV1d convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 22 Jul 2014 17:27:33 -0400
Content-Type: text/plain; charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 7.3 \(1878.6\))
Subject: Re: [PATCH 1/2] svcrdma: Increase credit limit to 32
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <20140722203520.GS8438@fieldses.org>
Date: Tue, 22 Jul 2014 17:27:25 -0400
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <39340C1C-072D-4F78-88BE-51C70EC43EA9@oracle.com>
References: <20140722195840.6011.87861.stgit@klimt.1015granger.net> <20140722200031.6011.28421.stgit@klimt.1015granger.net> <20140722203520.GS8438@fieldses.org>
To: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Jul 22, 2014, at 4:35 PM, J. Bruce Fields <bfields@fieldses.org> wrote:

> Could I just get a little more of a changelog?  Why (in one sentence)
> are we doing this?

Apologies, yes, I will resend with an adequate patch description.

> 
> --b.
> 
> On Tue, Jul 22, 2014 at 04:00:31PM -0400, Chuck Lever wrote:
>> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
>> ---
>> 
>> include/linux/sunrpc/svc_rdma.h |    3 +--
>> 1 files changed, 1 insertions(+), 2 deletions(-)
>> 
>> diff --git a/include/linux/sunrpc/svc_rdma.h b/include/linux/sunrpc/svc_rdma.h
>> index 5cf99a0..975da75 100644
>> --- a/include/linux/sunrpc/svc_rdma.h
>> +++ b/include/linux/sunrpc/svc_rdma.h
>> @@ -174,8 +174,7 @@ struct svcxprt_rdma {
>>  * page size of 4k, or 32k * 2 ops / 4k = 16 outstanding RDMA_READ.  */
>> #define RPCRDMA_ORD             (64/4)
>> #define RPCRDMA_SQ_DEPTH_MULT   8
>> -#define RPCRDMA_MAX_THREADS     16
>> -#define RPCRDMA_MAX_REQUESTS    16
>> +#define RPCRDMA_MAX_REQUESTS    32
>> #define RPCRDMA_MAX_REQ_SIZE    4096
>> 
>> /* svc_rdma_marshal.c */
>> 

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com



