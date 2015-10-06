Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:47747 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751370AbbJFBri convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 5 Oct 2015 21:47:38 -0400
References: <20151005025022.5074.89318.stgit@klimt.1015granger.net> <001801d0ffa5$ebd3aff0$c37b0fd0$@opengridcomputing.com>
Mime-Version: 1.0 (1.0)
In-Reply-To: <001801d0ffa5$ebd3aff0$c37b0fd0$@opengridcomputing.com>
Content-Type: text/plain;
	charset=us-ascii
Message-Id: <6998D6F7-ECD3-4CF6-9DF1-C47551ABA9F2@oracle.com>
Cc: linux-nfs@vger.kernel.org, linux-rdma@vger.kernel.org
From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH] svcrdma: Fix NFS server crash triggered by 1MB NFS WRITE
Date: Mon, 5 Oct 2015 21:47:29 -0400
To: Steve Wise <swise@opengridcomputing.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


> On Oct 5, 2015, at 3:42 PM, Steve Wise <swise@opengridcomputing.com> wrote:
> 
> 
> 
>> -----Original Message-----
>> From: linux-nfs-owner@vger.kernel.org [mailto:linux-nfs-owner@vger.kernel.org] On Behalf Of Chuck Lever
>> Sent: Sunday, October 04, 2015 10:03 PM
>> To: linux-nfs@vger.kernel.org; linux-rdma@vger.kernel.org
>> Subject: [PATCH] svcrdma: Fix NFS server crash triggered by 1MB NFS WRITE
>> 
>> Now that the NFS server advertises a maximum payload size of 1MB
>> for RPC/RDMA again, it crashes in svc_process_common() when NFS
>> client sends a 1MB NFS WRITE on an NFS/RDMA mount.
>> 
>> The server has set up a 259 element array of struct page pointers
>> in rq_pages[] for each incoming request. The last element of the
>> array is NULL.
>> 
>> When an incoming request has been completely received,
>> rdma_read_complete() attempts to set the starting page of the
>> incoming page vector:
>> 
>>  rqstp->rq_arg.pages = &rqstp->rq_pages[head->hdr_count];
>> 
>> and the page to use for the reply:
>> 
>>  rqstp->rq_respages = &rqstp->rq_arg.pages[page_no];
>> 
>> But the value of page_no has already accounted for head->hdr_count.
>> Thus rq_respages now points past the end of the incoming pages. For
>> NFS WRITE operations smaller than the maximum, this is harmless.
>> 
>> But when the NFS WRITE operation is as large as the server's max
>> payload size, rq_respages now points at the last entry in rq_pages,
>> which is NULL.
>> 
>> Fixes: cc9a903d915c ('svcrdma: Change maximum server payload . . .')
>> BugLink: https://bugzilla.linux-nfs.org/show_bug.cgi?id=270
>> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
>> ---
>> 
>> This fixes a 4.3-rc regression. Please apply to 4.3-rc when this
>> patch passes review.
>> 
>> It could also be appropriate for stable kernels which do not have
>> commit 7e5be28827bf ("svcrdma: advertise the correct max payload"),
>> though I have not tested them with this patch.
>> 
>> net/sunrpc/xprtrdma/svc_rdma_recvfrom.c |    2 +-
>> 1 files changed, 1 insertions(+), 1 deletions(-)
>> 
>> diff --git a/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c b/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c
>> index cb51742..37b4341 100644
>> --- a/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c
>> +++ b/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c
>> @@ -531,7 +531,7 @@ static int rdma_read_complete(struct svc_rqst *rqstp,
>>    rqstp->rq_arg.page_base = head->arg.page_base;
>> 
>>    /* rq_respages starts after the last arg page */
>> -    rqstp->rq_respages = &rqstp->rq_arg.pages[page_no];
>> +    rqstp->rq_respages = &rqstp->rq_pages[page_no];
>>    rqstp->rq_next_page = rqstp->rq_respages + 1;
>> 
>>    /* Rebuild rq_arg head and tail. */
>> 
> 
> Reviewed-by: Steve Wise <swise@opengridcomputing.com>

Thanks!
