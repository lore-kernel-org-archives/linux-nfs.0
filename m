Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp.opengridcomputing.com ([72.48.136.20]:37311 "EHLO
	smtp.opengridcomputing.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751904AbcADQ5z (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 4 Jan 2016 11:57:55 -0500
Subject: Re: [PATCH] svc_rdma: use local_dma_lkey
To: Christoph Hellwig <hch@lst.de>, bfields@redhat.com
References: <1450789915-22032-1-git-send-email-hch@lst.de>
Cc: linux-nfs@vger.kernel.org, linux-rdma@vger.kernel.org
From: Steve Wise <swise@opengridcomputing.com>
Message-ID: <568AA494.6000907@opengridcomputing.com>
Date: Mon, 4 Jan 2016 10:57:56 -0600
MIME-Version: 1.0
In-Reply-To: <1450789915-22032-1-git-send-email-hch@lst.de>
Content-Type: text/plain; charset=windows-1252; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On 12/22/2015 7:11 AM, Christoph Hellwig wrote:
> We now alwasy have a per-PD local_dma_lkey available.  Make use of that
> fact in svc_rdma and stop registering our own MR.
>
> Signed-off-by: Christoph Hellwig <hch@lst.de>
> Reviewed-by: Sagi Grimberg <sagig@mellanox.com>
> Reviewed-by: Jason Gunthorpe <jgunthorpe@obsidianresearch.com>
> Reviewed-by: Chuck Lever <chuck.lever@oracle.com>
> ---
>   include/linux/sunrpc/svc_rdma.h            |  2 --
>   net/sunrpc/xprtrdma/svc_rdma_backchannel.c |  2 +-
>   net/sunrpc/xprtrdma/svc_rdma_recvfrom.c    |  4 ++--
>   net/sunrpc/xprtrdma/svc_rdma_sendto.c      |  6 ++---
>   net/sunrpc/xprtrdma/svc_rdma_transport.c   | 36 ++++--------------------------
>   5 files changed, 10 insertions(+), 40 deletions(-)

Reviewed-by: Steve Wise <swise@opengridcomputing.com>

