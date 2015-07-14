Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:35725 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752132AbbGNTBu convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 14 Jul 2015 15:01:50 -0400
Content-Type: text/plain; charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 7.3 \(1878.6\))
Subject: Re: [PATCH v2 07/14] xprtrdma: Remove logic that constructs RDMA_MSGP type calls
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <55A55C63.50403@talpey.com>
Date: Tue, 14 Jul 2015 15:01:47 -0400
Cc: linux-rdma@vger.kernel.org,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <ED80C587-DFC7-4E4A-95E4-3ACBEC078D86@oracle.com>
References: <20150713160617.17630.97475.stgit@manet.1015granger.net> <20150713163048.17630.86326.stgit@manet.1015granger.net> <55A55C63.50403@talpey.com>
To: Tom Talpey <tom@talpey.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Jul 14, 2015, at 3:00 PM, Tom Talpey <tom@talpey.com> wrote:

> On 7/13/2015 12:30 PM, Chuck Lever wrote:
>> RDMA_MSGP type calls insert a zero pad in the middle of the RPC
>> message to align the RPC request's data payload to the server's
>> alignment preferences. A server can then "page flip" the payload
>> into place to avoid a data copy in certain circumstances. However:
>> ...
>> 
>> Clean up the marshaling code by removing the logic that constructs
>> RDMA_MSGP type calls. This also reduces the maximum send iovec size
>> from four to just two elements.
>> 
> 
>> diff --git a/net/sunrpc/xprtrdma/xprt_rdma.h b/net/sunrpc/xprtrdma/xprt_rdma.h
>> index 8219011..0b50103 100644
>> --- a/net/sunrpc/xprtrdma/xprt_rdma.h
>> +++ b/net/sunrpc/xprtrdma/xprt_rdma.h
> ...>
>> +#define RPCRDMA_MAX_IOVS	(4)
>> +
> 
> So, shouldn't this constant be "2"? The extra 2 iov's were used
> only for constructing the pad.

Yes, thanks. I folded a couple of patches together into this
one, and forgot to update the constant.


--
Chuck Lever



