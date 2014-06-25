Return-Path: linux-nfs-owner@vger.kernel.org
Received: from aserp1040.oracle.com ([141.146.126.69]:39116 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756944AbaFYQOm (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 25 Jun 2014 12:14:42 -0400
Message-ID: <53AAF56E.7010800@oracle.com>
Date: Wed, 25 Jun 2014 09:14:38 -0700
From: Shirley Ma <shirley.ma@oracle.com>
MIME-Version: 1.0
To: Chuck Lever <chuck.lever@oracle.com>
CC: linux-rdma <linux-rdma@vger.kernel.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH v1 10/13] xprtrdma: Release FRMR segment buffers during
 LOCAL_INV completion
References: <20140623223201.1634.83888.stgit@manet.1015granger.net> <20140623224023.1634.67233.stgit@manet.1015granger.net> <53AA5B72.3010200@oracle.com> <89930B1D-AE3B-48AD-922C-6FCA754D2B01@oracle.com>
In-Reply-To: <89930B1D-AE3B-48AD-922C-6FCA754D2B01@oracle.com>
Content-Type: text/plain; charset=windows-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On 06/25/2014 07:32 AM, Chuck Lever wrote:
> Hi Shirley-
> 
> On Jun 25, 2014, at 1:17 AM, Shirley Ma <shirley.ma@oracle.com> wrote:
> 
>> Would it be possible to delay rpcrdma_buffer_put() until LOCAL_INV request send completion? remove rpcrdma_buffer_put() from xprt_rdma_free(), add a call back after LOCAL_INV completed?
> 
> That’s exactly what this patch does. The relevant part of
> rpcrdma_buffer_put() is:
> 
>   list_add(&mw->mw_list, &buf->rb_mws);
> 
> This is now wrapped with a reference count so that
> rpcrdma_buffer_put() and the LOCAL_INV completion can run in any
> order. The FRMR is added back to the list only after both of those
> two have finished.

What I was thinking is to run rpcrdma_buffer_put after LOCAL_INV completion without reference count.
 
> Nothing in xprt_rdma_free() is allowed to sleep, so we can’t wait for
> LOCAL_INV completion in there.
> 
> The only alternative I can think of is having rpcrdma_buffer_get() check
> fr_state as it removes FRMRs from the rb_mws list. Only if the FRMR is
> marked FRMR_IS_INVALID, rpcrdma_buffer_get() will add it to the
> rpcrdma_req.

I thought about it too, an atomic operation would be better than a lock.

> --
> Chuck Lever
> chuck[dot]lever[at]oracle[dot]com
> 
> 
> 
