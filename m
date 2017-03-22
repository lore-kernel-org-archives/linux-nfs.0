Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qt0-f194.google.com ([209.85.216.194]:35188 "EHLO
        mail-qt0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751211AbdCVTHm (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 22 Mar 2017 15:07:42 -0400
Subject: Re: [PATCH v1 03/14] svcrdma: Eliminate RPCRDMA_SQ_DEPTH_MULT
To: Chuck Lever <chuck.lever@oracle.com>
References: <20170316154132.4482.56769.stgit@klimt.1015granger.net>
 <20170316155250.4482.49638.stgit@klimt.1015granger.net>
 <46eb6195-a542-b35c-4902-a2bebb38feba@grimberg.me>
 <391F0D90-2A46-4B2F-BCF0-B3BE7D48A3EF@oracle.com>
 <ec82feb4-d6b9-7fb4-5b11-b8007e313845@grimberg.me>
 <C9D8A91C-DE08-4A41-A07D-1F4C42DD9B97@oracle.com>
Cc: List Linux RDMA Mailing <linux-rdma@vger.kernel.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
From: Sagi Grimberg <sagi@grimberg.me>
Message-ID: <68e3eda0-90f4-5bca-28be-b2cf494ed172@grimberg.me>
Date: Wed, 22 Mar 2017 21:06:49 +0200
MIME-Version: 1.0
In-Reply-To: <C9D8A91C-DE08-4A41-A07D-1F4C42DD9B97@oracle.com>
Content-Type: text/plain; charset=windows-1252; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


> Roughly speaking, I think there needs to be an rdma_rw API that
> assists the ULP with setting its CQ and SQ sizes, since rdma_rw
> hides the registration mode (one of which, at least, consumes
> more SQEs than the other).

Hiding the registration mode was the largely the motivation for
this... It buys us simplified implementation and inherently supports
both IB and iWARP (which was annoying and only existing in svc but
still suboptimal).

> I'd like to introduce one new function call that surfaces the
> factor used to compute how many additional SQEs that rdma_rw will
> need. The ULP will invoke it before allocating new Send CQs.

I see your point... We should probably get a sense on how to
size the completion queue. I think that this issue is solved with
the CQ pool API that Christoph sent a while ago but was never
pursued.

The basic idea is that the core would create a pool of long CQs
and then assigns queue-pairs depending on the sq+rq depth.
If we were to pick it up would you consider using it?

> I'll try to provide an RFC in the nfsd-rdma-rw-api topic branch.

Cool, lets see what you had in mind...
