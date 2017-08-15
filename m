Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:19614 "EHLO
        aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753680AbdHORyk (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 15 Aug 2017 13:54:40 -0400
Content-Type: text/plain; charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 9.3 \(3124\))
Subject: Re: [PATCH 1/3] SUNRPC: Don't hold the transport lock across socket copy operations
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <1502813598.9053.3.camel@primarydata.com>
Date: Tue, 15 Aug 2017 13:54:35 -0400
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <F56144D8-92B6-4909-AF56-EA2E246D9A36@oracle.com>
References: <20170814191652.18263-1-trond.myklebust@primarydata.com> <20170814191652.18263-2-trond.myklebust@primarydata.com> <003E7C40-57BD-4F02-9157-97919FA206D5@oracle.com> <1502741277.19246.7.camel@primarydata.com> <55994DBE-0CE4-450A-8B19-B8C8F4CA0B69@oracle.com> <1502743109.19246.19.camel@primarydata.com> <7C0D016C-FBC3-4103-BA81-37AE0D6BAF5B@oracle.com> <1502759921.22283.23.camel@primarydata.com> <DE137089-1D71-47C3-BDC4-3BCE73DF235A@oracle.com> <1502809254.7593.19.camel@primarydata.com> <AB962563-977C-4903-A188-3AD32B9F0086@oracle.com> <1502813598.9053.3.camel@primarydata.com>
To: Trond Myklebust <trondmy@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


> On Aug 15, 2017, at 12:13 PM, Trond Myklebust <trondmy@primarydata.com> wrote:
> 
> On Tue, 2017-08-15 at 11:05 -0400, Chuck Lever wrote:
>> Reviewed-by: Chuck Lever <chuck.lever@oracle.com>
> 
> Thanks! I agree with your proposal for how to apply this to the RDMA
> code. I'm hoping you will be able to look into that and check that the
> removal of transport lock protection won't end up causing corruption of
> the RDMA statistics counters, etc.

The client-side RDMA statistics counters are currently not protected,
in general (although yes, some of them happen to be manipulated
only behind locks). I'm more worried about how to guarantee that
MR invalidation occurs exactly once as an RPC completes.

My plan is to wait until xprt_pin_rqst lands in mainline, then add
xprtrdma usage of that API in the following kernel release. Let me
know if you'd like something to go in _with_ xprt_pin_rqst instead,
and we can try to co-ordinate.


--
Chuck Lever



