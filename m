Return-Path: linux-nfs-owner@vger.kernel.org
Received: from userp1040.oracle.com ([156.151.31.81]:49868 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752014AbaKJOyg convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 10 Nov 2014 09:54:36 -0500
Content-Type: text/plain; charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 7.3 \(1878.6\))
Subject: Re: [PATCH v2 06/10] xprtrdma: Enable pad optimization
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <5460CD53.1080301@Netapp.com>
Date: Mon, 10 Nov 2014 08:54:27 -0600
Cc: linux-rdma@vger.kernel.org,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <89410A6C-693C-4FB2-A0AB-5698803F3AFC@oracle.com>
References: <20141109010328.8806.5861.stgit@manet.1015granger.net> <20141109011453.8806.31817.stgit@manet.1015granger.net> <5460CD53.1080301@Netapp.com>
To: Anna Schumaker <Anna.Schumaker@netapp.com>,
        "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Nov 10, 2014, at 8:36 AM, Anna Schumaker <Anna.Schumaker@netapp.com> wrote:

> Hey Chuck,
> 
> 
> On 11/08/2014 08:14 PM, Chuck Lever wrote:
>> The Linux NFS/RDMA server used to reject NFSv3 WRITE requests when
>> pad optimization was enabled. That bug was fixed by commit
>> e560e3b510d2 ("svcrdma: Add zero padding if the client doesn't send
>> it").
> 
> Do we need to worry about backwards compatibility with servers that don't have this patch?

My impression is that we have a window where the server is assumed not
to work and thus is not enabled in distributions, and that therefore
changes like this are allowed. I could be wrong. Bruce, any guidance
on this?

In any event, if things break, they break immediately, and the fix is
simply to set this feature flag via /proc.




> Anna
> 
>> 
>> We can now enable pad optimization on the client, which helps
>> performance and is supported now by both Linux and Solaris servers.
>> 
>> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
>> ---
>> net/sunrpc/xprtrdma/transport.c |    2 +-
>> 1 file changed, 1 insertion(+), 1 deletion(-)
>> 
>> diff --git a/net/sunrpc/xprtrdma/transport.c b/net/sunrpc/xprtrdma/transport.c
>> index cfe9a81..8ed2576 100644
>> --- a/net/sunrpc/xprtrdma/transport.c
>> +++ b/net/sunrpc/xprtrdma/transport.c
>> @@ -73,7 +73,7 @@ static unsigned int xprt_rdma_max_inline_read = RPCRDMA_DEF_INLINE;
>> static unsigned int xprt_rdma_max_inline_write = RPCRDMA_DEF_INLINE;
>> static unsigned int xprt_rdma_inline_write_padding;
>> static unsigned int xprt_rdma_memreg_strategy = RPCRDMA_FRMR;
>> -                int xprt_rdma_pad_optimize = 0;
>> +		int xprt_rdma_pad_optimize = 1;
>> 
>> #ifdef RPC_DEBUG
>> 
>> 
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com



