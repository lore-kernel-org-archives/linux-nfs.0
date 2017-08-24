Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f195.google.com ([209.85.223.195]:33332 "EHLO
        mail-io0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752071AbdHXSS0 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 24 Aug 2017 14:18:26 -0400
Received: by mail-io0-f195.google.com with SMTP id s101so157778ioe.0
        for <linux-nfs@vger.kernel.org>; Thu, 24 Aug 2017 11:18:26 -0700 (PDT)
Subject: Re: [PATCH v1] xprtrdma: Use xprt_pin_rqst in rpcrdma_reply_handler
To: Trond Myklebust <trondmy@primarydata.com>,
        "anna.schumaker@netapp.com" <anna.schumaker@netapp.com>,
        "chuck.lever@oracle.com" <chuck.lever@oracle.com>
Cc: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
References: <20170823210344.7677.48608.stgit@manet.1015granger.net>
 <1503524423.84215.1.camel@primarydata.com>
From: Anna Schumaker <schumaker.anna@gmail.com>
Message-ID: <64ae2e4d-9fb5-25f7-a82e-32ec5006f903@gmail.com>
Date: Thu, 24 Aug 2017 14:18:22 -0400
MIME-Version: 1.0
In-Reply-To: <1503524423.84215.1.camel@primarydata.com>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 08/23/2017 05:40 PM, Trond Myklebust wrote:
> On Wed, 2017-08-23 at 17:05 -0400, Chuck Lever wrote:
>> Adopt the use of xprt_pin_rqst to eliminate contention between
>> Call-side users of rb_lock and the use of rb_lock in
>> rpcrdma_reply_handler.
>>
>> This replaces the mechanism introduced in 431af645cf66 ("xprtrdma:
>> Fix client lock-up after application signal fires").
>>
>> Use recv_lock to quickly find the completing rqst, pin it, then
>> drop the lock. At that point invalidation and pull-up of the Reply
>> XDR can be done. Both are often expensive operations.
>>
>> Finally, take recv_lock again to signal completion to the RPC
>> layer. It also protects adjustment of "cwnd".
>>
>> This greatly reduces the amount of time a lock is held by the
>> reply handler. Comparing lock_stat results shows a marked decrease
>> in contention on rb_lock and recv_lock.
>>
>> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
>> ---
>> Hi-
>>
>> If Trond's lock contention series is going into v4.14, I'd like you
>> to consider this one (applied at the end of that series) as well.
>> Without it, NFS/RDMA performance regresses a bit after the
>> first xprt_pin_rqst patch is applied. Thanks!
>>
> 
> If Anna is OK with it, then I can apply this patch once she's sent me
> the pull request for the other RDMA client patches.

Works for me.  Thanks!
> 
