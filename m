Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-wi0-f178.google.com ([209.85.212.178]:36639 "EHLO
	mail-wi0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752599AbbJFQ1x (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 6 Oct 2015 12:27:53 -0400
Received: by wicgb1 with SMTP id gb1so173417482wic.1
        for <linux-nfs@vger.kernel.org>; Tue, 06 Oct 2015 09:27:52 -0700 (PDT)
Subject: Re: [PATCH rdma-rc] xprtrdma: Don't require LOCAL_DMA_LKEY support
 for fasterg
To: Chuck Lever <chuck.lever@oracle.com>, Sagi Grimberg <sagig@mellanox.com>
References: <1444124889-8957-1-git-send-email-sagig@mellanox.com>
 <56C57483-17AA-47FF-8743-E1522BD8C351@oracle.com>
Cc: linux-rdma@vger.kernel.org,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
From: Sagi Grimberg <sagig@dev.mellanox.co.il>
Message-ID: <5613F684.3020904@dev.mellanox.co.il>
Date: Tue, 6 Oct 2015 19:27:48 +0300
MIME-Version: 1.0
In-Reply-To: <56C57483-17AA-47FF-8743-E1522BD8C351@oracle.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 10/6/2015 6:05 PM, Chuck Lever wrote:
> Hi Sagi-
>
>
>> On Oct 6, 2015, at 5:48 AM, Sagi Grimberg <sagig@mellanox.com> wrote:
>>
>> There is no need to require LOCAL_DMA_LKEY support in order to
>> use fast registration as the PD allocation makes sure that there
>> is a local_dma_lkey.
>
> In other words, all devices now have a local DMA lkey, so the
> check is unnecessary.

Right.

>
>
>> This caused a NULL pointer dereference in mlx5 which removed
>> the support for LOCAL_DMA_LKEY.
>
> Where was the bad dereference? in mlx5, or in xprtrdma?

xprtrdma, ia->ri_ops wasn't assigned correctly.

Now that I look at it, one error path in rpcrdma_ia_open misses
an rc assignment. That needs to be fixed too, should it be in the same
patch?

diff --git a/net/sunrpc/xprtrdma/verbs.c b/net/sunrpc/xprtrdma/verbs.c
index 7efd9ef..81e8d31 100644
--- a/net/sunrpc/xprtrdma/verbs.c
+++ b/net/sunrpc/xprtrdma/verbs.c
@@ -554,6 +554,7 @@ rpcrdma_ia_open(struct rpcrdma_xprt *xprt, struct 
sockaddr *addr, int memreg)
                 if (!ia->ri_device->alloc_fmr) {
                         dprintk("RPC:       %s: MTHCAFMR registration "
                                 "not supported by HCA\n", __func__);
+                       rc = -EINVAL;
                         goto out3;
                 }
         }
--

the incorrect requirement + missing rc caused the NULL deref of
ia->ri_ops.
