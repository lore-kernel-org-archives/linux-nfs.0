Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ie0-f172.google.com ([209.85.223.172]:43943 "EHLO
	mail-ie0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754572AbaCLOFe (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 12 Mar 2014 10:05:34 -0400
Received: by mail-ie0-f172.google.com with SMTP id as1so10591331iec.17
        for <linux-nfs@vger.kernel.org>; Wed, 12 Mar 2014 07:05:34 -0700 (PDT)
Content-Type: text/plain; charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 7.2 \(1874\))
Subject: Re: NFS over RDMA crashing
From: Trond Myklebust <trond.myklebust@primarydata.com>
In-Reply-To: <20140312093300.7a434cbb@tlielax.poochiereds.net>
Date: Wed, 12 Mar 2014 10:05:24 -0400
Cc: Steve Wise <swise@opengridcomputing.com>,
        Dr Fields James Bruce <bfields@fieldses.org>,
        Tucker Tom <tom@opengridcomputing.com>, Yan Burman <yanb@mellanox.com>,
        linux-nfs@vger.kernel.org, linux-rdma@vger.kernel.org,
        Or Gerlitz <ogerlitz@mellanox.com>
Message-Id: <731A7629-7DBB-4FC3-8F21-70380705ED4E@primarydata.com>
References: <51127B3F.2090200@mellanox.com> <20130206222435.GL16417@fieldses.org> <20130207164134.GK3222@fieldses.org> <003601cf3a26$94523ee0$bcf6bca0$@opengridcomputing.com> <005d01cf3a45$94ced0d0$be6c7270$@opengridcomputing.com> <531B47B3.1070503@opengridcomputing.com> <531B6D90.2090208@opengridcomputing.com> <531B79F8.2020008@opengridcomputing.com> <20140312093300.7a434cbb@tlielax.poochiereds.net>
To: Layton Jeff <jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Mar 12, 2014, at 9:33, Jeff Layton <jlayton@redhat.com> wrote:

> On Sat, 08 Mar 2014 14:13:44 -0600
> Steve Wise <swise@opengridcomputing.com> wrote:
> 
>> On 3/8/2014 1:20 PM, Steve Wise wrote:
>>> 
>>>> I removed your change and started debugging original crash that 
>>>> happens on top-o-tree.   Seems like rq_next_pages is screwed up.  It 
>>>> should always be >= rq_respages, yes?  I added a BUG_ON() to assert 
>>>> this in rdma_read_xdr() we hit the BUG_ON(). Look
>>>> 
>>>> crash> svc_rqst.rq_next_page 0xffff8800b84e6000
>>>> rq_next_page = 0xffff8800b84e6228
>>>> crash> svc_rqst.rq_respages 0xffff8800b84e6000
>>>> rq_respages = 0xffff8800b84e62a8
>>>> 
>>>> Any ideas Bruce/Tom?
>>>> 
>>> 
>>> Guys, the patch below seems to fix the problem.  Dunno if it is 
>>> correct though.  What do you think?
>>> 
>>> diff --git a/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c 
>>> b/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c
>>> index 0ce7552..6d62411 100644
>>> --- a/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c
>>> +++ b/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c
>>> @@ -90,6 +90,7 @@ static void rdma_build_arg_xdr(struct svc_rqst *rqstp,
>>>               sge_no++;
>>>       }
>>>       rqstp->rq_respages = &rqstp->rq_pages[sge_no];
>>> +       rqstp->rq_next_page = rqstp->rq_respages;
>>> 
>>>       /* We should never run out of SGE because the limit is defined to
>>>        * support the max allowed RPC data length
>>> @@ -276,6 +277,7 @@ static int fast_reg_read_chunks(struct 
>>> svcxprt_rdma *xprt,
>>> 
>>>       /* rq_respages points one past arg pages */
>>>       rqstp->rq_respages = &rqstp->rq_arg.pages[page_no];
>>> +       rqstp->rq_next_page = rqstp->rq_respages;
>>> 
>>>       /* Create the reply and chunk maps */
>>>       offset = 0;
>>> 
>>> 
>> 
>> While this patch avoids the crashing, it apparently isn't correct...I'm 
>> getting IO errors reading files over the mount. :)
>> 
> 
> I hit the same oops and tested your patch and it seems to have fixed
> that particular panic, but I still see a bunch of other mem corruption
> oopses even with it. I'll look more closely at that when I get some
> time.
> 
> FWIW, I can easily reproduce that by simply doing something like:
> 
>   $ dd if=/dev/urandom of=/file/on/nfsordma/mount bs=4k count=1
> 
> I'm not sure why you're not seeing any panics with your patch in place.
> Perhaps it's due to hw differences between our test rigs.
> 
> The EIO problem that you're seeing is likely the same client bug that
> Chuck recently fixed in this patch:
> 
>   [PATCH 2/8] SUNRPC: Fix large reads on NFS/RDMA
> 
> AIUI, Trond is merging that set for 3.15, so I'd make sure your client
> has those patches when testing.
> 

Nothing is in my queue yet.

_________________________________
Trond Myklebust
Linux NFS client maintainer, PrimaryData
trond.myklebust@primarydata.com

