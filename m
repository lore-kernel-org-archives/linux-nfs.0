Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:21711 "EHLO
        userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752064AbdIEVGL (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 5 Sep 2017 17:06:11 -0400
Content-Type: text/plain; charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 9.3 \(3124\))
Subject: Re: [PATCH v1] xprtrdma: Use xprt_pin_rqst in rpcrdma_reply_handler
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <1504643592.18516.3.camel@primarydata.com>
Date: Tue, 5 Sep 2017 17:06:04 -0400
Cc: Anna Schumaker <anna.schumaker@netapp.com>,
        Anna Schumaker <schumaker.anna@gmail.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <CEEC5F17-B01F-4751-A82D-16FAD3267125@oracle.com>
References: <20170823210344.7677.48608.stgit@manet.1015granger.net> <1503524423.84215.1.camel@primarydata.com> <64ae2e4d-9fb5-25f7-a82e-32ec5006f903@gmail.com> <1504643592.18516.3.camel@primarydata.com>
To: Trond Myklebust <trondmy@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


> On Sep 5, 2017, at 4:33 PM, Trond Myklebust <trondmy@primarydata.com> wrote:
> 
> On Thu, 2017-08-24 at 14:18 -0400, Anna Schumaker wrote:
>> 
>> On 08/23/2017 05:40 PM, Trond Myklebust wrote:
>>> On Wed, 2017-08-23 at 17:05 -0400, Chuck Lever wrote:
>>>> Adopt the use of xprt_pin_rqst to eliminate contention between
>>>> Call-side users of rb_lock and the use of rb_lock in
>>>> rpcrdma_reply_handler.
>>>> 
>>>> This replaces the mechanism introduced in 431af645cf66
>>>> ("xprtrdma:
>>>> Fix client lock-up after application signal fires").
>>>> 
>>>> Use recv_lock to quickly find the completing rqst, pin it, then
>>>> drop the lock. At that point invalidation and pull-up of the
>>>> Reply
>>>> XDR can be done. Both are often expensive operations.
>>>> 
>>>> Finally, take recv_lock again to signal completion to the RPC
>>>> layer. It also protects adjustment of "cwnd".
>>>> 
>>>> This greatly reduces the amount of time a lock is held by the
>>>> reply handler. Comparing lock_stat results shows a marked
>>>> decrease
>>>> in contention on rb_lock and recv_lock.
>>>> 
>>>> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
>>>> ---
>>>> Hi-
>>>> 
>>>> If Trond's lock contention series is going into v4.14, I'd like
>>>> you
>>>> to consider this one (applied at the end of that series) as well.
>>>> Without it, NFS/RDMA performance regresses a bit after the
>>>> first xprt_pin_rqst patch is applied. Thanks!
>>>> 
>>> 
>>> If Anna is OK with it, then I can apply this patch once she's sent
>>> me
>>> the pull request for the other RDMA client patches.
>> 
>> Works for me.  Thanks!
> 
> Please can you both check http://git.linux-nfs.org/?p=trondmy/linux-nfs
> .git;a=commit;h=b1da5d90857ee4b8f5acee1143705412b16fce56 and see if all
> is well?
> 
> Do note that I did remove the call to rpcrdma_buffer_put() which was
> being called with an uninitialised argument.

Looking at that again. rpcrdma_buffer_put() does look unnecessary,
since out_norqst is being called now before "req" is initialized.

On further inspection, "return;" should be replaced with
"goto repost;". This is similar to "out_nomatch" and
"out_duplicate", which are both being replaced in this patch.

So, out_norqst should look something like this:


out_norqst:
        spin_unlock(&xprt->recv_lock);
        dprintk("RPC:       %s: no match for incoming xid 0x%08x\n",
                __func__, be32_to_cpu(xid));
        goto repost;


Otherwise, I don't see any obvious problems.

--
Chuck Lever



