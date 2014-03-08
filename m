Return-Path: linux-nfs-owner@vger.kernel.org
Received: from linode.aoot.com ([69.164.194.13]:37193 "EHLO linode.aoot.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751052AbaCHUNp (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 8 Mar 2014 15:13:45 -0500
Message-ID: <531B79F8.2020008@opengridcomputing.com>
Date: Sat, 08 Mar 2014 14:13:44 -0600
From: Steve Wise <swise@opengridcomputing.com>
MIME-Version: 1.0
To: "'J. Bruce Fields'" <bfields@fieldses.org>,
        Tom Tucker <tom@opengridcomputing.com>
CC: "'Yan Burman'" <yanb@mellanox.com>, linux-nfs@vger.kernel.org,
        linux-rdma@vger.kernel.org, "'Or Gerlitz'" <ogerlitz@mellanox.com>
Subject: Re: NFS over RDMA crashing
References: <51127B3F.2090200@mellanox.com> <20130206222435.GL16417@fieldses.org> <20130207164134.GK3222@fieldses.org> <003601cf3a26$94523ee0$bcf6bca0$@opengridcomputing.com> <005d01cf3a45$94ced0d0$be6c7270$@opengridcomputing.com> <531B47B3.1070503@opengridcomputing.com> <531B6D90.2090208@opengridcomputing.com>
In-Reply-To: <531B6D90.2090208@opengridcomputing.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 3/8/2014 1:20 PM, Steve Wise wrote:
>
>> I removed your change and started debugging original crash that 
>> happens on top-o-tree.   Seems like rq_next_pages is screwed up.  It 
>> should always be >= rq_respages, yes?  I added a BUG_ON() to assert 
>> this in rdma_read_xdr() we hit the BUG_ON(). Look
>>
>> crash> svc_rqst.rq_next_page 0xffff8800b84e6000
>>   rq_next_page = 0xffff8800b84e6228
>> crash> svc_rqst.rq_respages 0xffff8800b84e6000
>>   rq_respages = 0xffff8800b84e62a8
>>
>> Any ideas Bruce/Tom?
>>
>
> Guys, the patch below seems to fix the problem.  Dunno if it is 
> correct though.  What do you think?
>
> diff --git a/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c 
> b/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c
> index 0ce7552..6d62411 100644
> --- a/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c
> +++ b/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c
> @@ -90,6 +90,7 @@ static void rdma_build_arg_xdr(struct svc_rqst *rqstp,
>                 sge_no++;
>         }
>         rqstp->rq_respages = &rqstp->rq_pages[sge_no];
> +       rqstp->rq_next_page = rqstp->rq_respages;
>
>         /* We should never run out of SGE because the limit is defined to
>          * support the max allowed RPC data length
> @@ -276,6 +277,7 @@ static int fast_reg_read_chunks(struct 
> svcxprt_rdma *xprt,
>
>         /* rq_respages points one past arg pages */
>         rqstp->rq_respages = &rqstp->rq_arg.pages[page_no];
> +       rqstp->rq_next_page = rqstp->rq_respages;
>
>         /* Create the reply and chunk maps */
>         offset = 0;
>
>

While this patch avoids the crashing, it apparently isn't correct...I'm 
getting IO errors reading files over the mount. :)

