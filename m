Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qt0-f195.google.com ([209.85.216.195]:33167 "EHLO
        mail-qt0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932641AbdCUSGG (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 21 Mar 2017 14:06:06 -0400
Subject: Re: [PATCH v1 03/14] svcrdma: Eliminate RPCRDMA_SQ_DEPTH_MULT
To: Chuck Lever <chuck.lever@oracle.com>, linux-rdma@vger.kernel.org,
        linux-nfs@vger.kernel.org
References: <20170316154132.4482.56769.stgit@klimt.1015granger.net>
 <20170316155250.4482.49638.stgit@klimt.1015granger.net>
From: Sagi Grimberg <sagi@grimberg.me>
Message-ID: <46eb6195-a542-b35c-4902-a2bebb38feba@grimberg.me>
Date: Tue, 21 Mar 2017 19:58:22 +0200
MIME-Version: 1.0
In-Reply-To: <20170316155250.4482.49638.stgit@klimt.1015granger.net>
Content-Type: text/plain; charset=utf-8; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


> The Send Queue depth is temporarily reduced to 1 SQE per credit. The
> new rdma_rw API does an internal computation, during QP creation, to
> increase the depth of the Send Queue to handle RDMA Read and Write
> operations.
>
> This change has to come before the NFSD code paths are updated to
> use the rdma_rw API. Without this patch, rdma_rw_init_qp() increases
> the size of the SQ too much, resulting in memory allocation failures
> during QP creation.

I agree this needs to happen, but turns out you don't have any
guarantees of the maximum size of the sq depending on your max_sge
parameter. I'd recommend having a fall-back shrinked size sq allocation
impllemented like srpt does.

We don't have it in nvmet-rdma nor iser, but its a good thing to have...
