Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-wg0-f45.google.com ([74.125.82.45]:33586 "EHLO
	mail-wg0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751989AbbGLObt (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 12 Jul 2015 10:31:49 -0400
Received: by wgmn9 with SMTP id n9so25753707wgm.0
        for <linux-nfs@vger.kernel.org>; Sun, 12 Jul 2015 07:31:48 -0700 (PDT)
Subject: Re: [PATCH v1 04/12] xprtrdma: Remove last ib_reg_phys_mr() call site
To: Chuck Lever <chuck.lever@oracle.com>, linux-rdma@vger.kernel.org,
        linux-nfs@vger.kernel.org
References: <20150709203242.26247.4848.stgit@manet.1015granger.net>
 <20150709204218.26247.67243.stgit@manet.1015granger.net>
From: Sagi Grimberg <sagig@dev.mellanox.co.il>
Message-ID: <55A27A51.9010203@dev.mellanox.co.il>
Date: Sun, 12 Jul 2015 17:31:45 +0300
MIME-Version: 1.0
In-Reply-To: <20150709204218.26247.67243.stgit@manet.1015granger.net>
Content-Type: text/plain; charset=utf-8; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 7/9/2015 11:42 PM, Chuck Lever wrote:
> All HCA providers have an ib_get_dma_mr() verb. Thus
> rpcrdma_ia_open() will either grab the device's local_dma_key if one
> is available, or it will call ib_get_dma_mr() which is a 100%
> guaranteed fallback. There is never any need to use the
> ib_reg_phys_mr() code path in rpcrdma_register_internal(), so it can
> be removed.
>
> The remaining logic in rpcrdma_{de}register_internal() is folded
> into rpcrdma_{alloc,free}_regbuf().
>
> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>

Like,

Reviewed-By: Sagi Grimberg <sagig@mellanox.com>
