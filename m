Return-Path: linux-nfs-owner@vger.kernel.org
Received: from aserp1040.oracle.com ([141.146.126.69]:36766 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756382AbaFYOcn convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 25 Jun 2014 10:32:43 -0400
Content-Type: text/plain; charset=windows-1252
Mime-Version: 1.0 (Mac OS X Mail 7.3 \(1878.2\))
Subject: Re: [PATCH v1 10/13] xprtrdma: Release FRMR segment buffers during LOCAL_INV completion
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <53AA5B72.3010200@oracle.com>
Date: Wed, 25 Jun 2014 10:32:38 -0400
Cc: linux-rdma <linux-rdma@vger.kernel.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <89930B1D-AE3B-48AD-922C-6FCA754D2B01@oracle.com>
References: <20140623223201.1634.83888.stgit@manet.1015granger.net> <20140623224023.1634.67233.stgit@manet.1015granger.net> <53AA5B72.3010200@oracle.com>
To: Shirley Ma <shirley.ma@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Shirley-

On Jun 25, 2014, at 1:17 AM, Shirley Ma <shirley.ma@oracle.com> wrote:

> Would it be possible to delay rpcrdma_buffer_put() until LOCAL_INV request send completion? remove rpcrdma_buffer_put() from xprt_rdma_free(), add a call back after LOCAL_INV completed?

That’s exactly what this patch does. The relevant part of
rpcrdma_buffer_put() is:

  list_add(&mw->mw_list, &buf->rb_mws);

This is now wrapped with a reference count so that
rpcrdma_buffer_put() and the LOCAL_INV completion can run in any
order. The FRMR is added back to the list only after both of those
two have finished.

Nothing in xprt_rdma_free() is allowed to sleep, so we can’t wait for
LOCAL_INV completion in there.

The only alternative I can think of is having rpcrdma_buffer_get() check
fr_state as it removes FRMRs from the rb_mws list. Only if the FRMR is
marked FRMR_IS_INVALID, rpcrdma_buffer_get() will add it to the
rpcrdma_req.

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com



