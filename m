Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:25975 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753290AbbLPPGm convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 16 Dec 2015 10:06:42 -0500
Content-Type: text/plain; charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 8.2 \(2104\))
Subject: Re: [PATCH v3 04/11] xprtrdma: Move struct ib_send_wr off the stack
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <56716E6C.4020604@dev.mellanox.co.il>
Date: Wed, 16 Dec 2015 10:06:33 -0500
Cc: anna.schumaker@netapp.com, linux-rdma@vger.kernel.org,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <F2E992ED-2698-43DE-B7C5-4F02DA75AE42@oracle.com>
References: <20151214211317.16295.70115.stgit@manet.1015granger.net> <20151214211811.16295.47695.stgit@manet.1015granger.net> <56716E6C.4020604@dev.mellanox.co.il>
To: Sagi Grimberg <sagig@dev.mellanox.co.il>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


> On Dec 16, 2015, at 9:00 AM, Sagi Grimberg <sagig@dev.mellanox.co.il> wrote:
> 
> 
>> diff --git a/net/sunrpc/xprtrdma/xprt_rdma.h b/net/sunrpc/xprtrdma/xprt_rdma.h
>> index 4197191..e60d817 100644
>> --- a/net/sunrpc/xprtrdma/xprt_rdma.h
>> +++ b/net/sunrpc/xprtrdma/xprt_rdma.h
>> @@ -206,6 +206,8 @@ struct rpcrdma_frmr {
>>  	enum rpcrdma_frmr_state		fr_state;
>>  	struct work_struct		fr_work;
>>  	struct rpcrdma_xprt		*fr_xprt;
>> +	struct ib_reg_wr		fr_regwr;
>> +	struct ib_send_wr		fr_invwr;
> 
> Would it make sense to unionize these as they are guaranteed not to
> execute together? Some people don't like this sort of savings.

I dislike unions because they make the code that uses
them less readable. I can define macros to help that,
but sigh! OK.


--
Chuck Lever




