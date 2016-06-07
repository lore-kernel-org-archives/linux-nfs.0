Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:31731 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751475AbcFGVvO convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 7 Jun 2016 17:51:14 -0400
Content-Type: text/plain; charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 9.3 \(3124\))
Subject: Re: [PATCH v1 09/20] xprtrdma: Limit the number of rpcrdma_mws
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <20160607212831.GA9192@obsidianresearch.com>
Date: Tue, 7 Jun 2016 17:51:04 -0400
Cc: linux-rdma <linux-rdma@vger.kernel.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <D90190F5-ACCB-45D8-B08D-B75023ED6240@oracle.com>
References: <20160607194001.18401.88592.stgit@manet.1015granger.net> <20160607194732.18401.71941.stgit@manet.1015granger.net> <20160607204941.GA7991@obsidianresearch.com> <F1820E16-A2BF-4529-A5C9-59C9AD57369A@oracle.com> <20160607212831.GA9192@obsidianresearch.com>
To: Jason Gunthorpe <jgunthorpe@obsidianresearch.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


> On Jun 7, 2016, at 5:28 PM, Jason Gunthorpe <jgunthorpe@obsidianresearch.com> wrote:
> 
> On Tue, Jun 07, 2016 at 05:09:47PM -0400, Chuck Lever wrote:
> 
>>> Either the number in queue is limited by the invalidation
>>> synchronization point to 2, or in the case of iwarp read, it doesn't
>>> matter since everything executes serially in order and the value can
>>> safely wrap.
>> 
>> I don't understand this. How does invalidation prevent
>> the ULP from registering more R_keys?
> 
> The ULP doesn't 'register' rkeys, it only changes the active RKey assigned
> to a MR. The number of active rkeys is strictly limited to the number
> of available MRs.

I'm sure I'm using the language poorly.


> Further changing the rkey can only be done as part of an invalidate
> cycle.

OK, I'm not remembering something very clearly, and
I've drawn an incorrect conclusion. Yes, there always
has to be an invalidation before an R_key can be
reused to register a new MR.


> Invaliding a MR/RKey can only happen after synchronization with the
> remote.
> 
> So the work queue looks broadly like this:
> 
> WR setup rkey 1
> WR send rkey 1 to remote
> <synchronize>
> WR invalidate rkey 1
> WR setup rkey 2
> WR send rkey 2 to remote
> <synchronize>
> 
> Thus the WR queue can never have more than 2 rkey's per MR in it at
> any time, and there is no need to care about the 24/8 bit split.

Agreed, I see that the split has nothing to do with it.
I will drop this patch.


>> And, I'd like to limit the number of pre-allocated MRs
>> to no more than each transport endpoint can use. For
>> xprtrdma, a transport is one QP and PD. What is that
>> number?
> 
> I'm not sure I understand this question. AFAIK there is no limit on
> MRs that can be used with a QP. As long as the MR is allocated you can
> use it.

There is a practical number of MRs that can be allocated
per device, I thought. And each MR consumes some amount
of host memory.

xprtrdma is happy to allocate thousands of MRs per QP/PD
pair, but that isn't practical as you start adding more
transports/connections.

The question has to do with scaling the number of xprt
connections over available device resources.


> Typically you'd allocate enough MRs to handle your typical case
> concurrancy level (pipeline depth).
> 
> The concurrancy level is limited by lots of things, for instance the
> max number of posted recv's typically places a hard upper limit.

xprtrdma already makes an estimate. I'm wondering if its
still a valid one. Fewer MRs means better scaling in number
of transports.


--
Chuck Lever



