Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:48165 "EHLO
        aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751119AbdCVNh0 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 22 Mar 2017 09:37:26 -0400
Content-Type: text/plain; charset=windows-1252
Mime-Version: 1.0 (Mac OS X Mail 9.3 \(3124\))
Subject: Re: [PATCH v1 03/14] svcrdma: Eliminate RPCRDMA_SQ_DEPTH_MULT
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <ec82feb4-d6b9-7fb4-5b11-b8007e313845@grimberg.me>
Date: Wed, 22 Mar 2017 09:36:40 -0400
Cc: List Linux RDMA Mailing <linux-rdma@vger.kernel.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <C9D8A91C-DE08-4A41-A07D-1F4C42DD9B97@oracle.com>
References: <20170316154132.4482.56769.stgit@klimt.1015granger.net> <20170316155250.4482.49638.stgit@klimt.1015granger.net> <46eb6195-a542-b35c-4902-a2bebb38feba@grimberg.me> <391F0D90-2A46-4B2F-BCF0-B3BE7D48A3EF@oracle.com> <ec82feb4-d6b9-7fb4-5b11-b8007e313845@grimberg.me>
To: Sagi Grimberg <sagi@grimberg.me>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


> On Mar 22, 2017, at 9:09 AM, Sagi Grimberg <sagi@grimberg.me> wrote:
> 
> 
>>> I agree this needs to happen, but turns out you don't have any
>>> guarantees of the maximum size of the sq depending on your max_sge
>>> parameter.
>> 
>> That's true. However, this is meant to be temporary while I'm
>> working out details of the rdma_rw API conversion. More work
>> in this area comes in the next series:
>> 
>> http://git.linux-nfs.org/?p=cel/cel-2.6.git;a=log;h=refs/heads/nfsd-rdma-rw-api
> 
> Thanks for the pointer...
> 
>>> I'd recommend having a fall-back shrinked size sq allocation
>>> impllemented like srpt does.
>> 
>> Agree it should be done. Would it be OK to wait until the dust
>> settles here, or do you think it's a hard requirement for
>> accepting this series?
> 
> It isn't and can definitely be added incrementally...

Roughly speaking, I think there needs to be an rdma_rw API that
assists the ULP with setting its CQ and SQ sizes, since rdma_rw
hides the registration mode (one of which, at least, consumes
more SQEs than the other).

I'd like to introduce one new function call that surfaces the
factor used to compute how many additional SQEs that rdma_rw will
need. The ULP will invoke it before allocating new Send CQs.

I'll try to provide an RFC in the nfsd-rdma-rw-api topic branch.


--
Chuck Lever



