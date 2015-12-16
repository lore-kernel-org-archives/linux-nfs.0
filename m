Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-lf0-f47.google.com ([209.85.215.47]:35460 "EHLO
	mail-lf0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753538AbbLPOAS (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 16 Dec 2015 09:00:18 -0500
Received: by mail-lf0-f47.google.com with SMTP id l133so29576228lfd.2
        for <linux-nfs@vger.kernel.org>; Wed, 16 Dec 2015 06:00:17 -0800 (PST)
Subject: Re: [PATCH v3 04/11] xprtrdma: Move struct ib_send_wr off the stack
To: Chuck Lever <chuck.lever@oracle.com>, anna.schumaker@netapp.com
References: <20151214211317.16295.70115.stgit@manet.1015granger.net>
 <20151214211811.16295.47695.stgit@manet.1015granger.net>
Cc: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
From: Sagi Grimberg <sagig@dev.mellanox.co.il>
Message-ID: <56716E6C.4020604@dev.mellanox.co.il>
Date: Wed, 16 Dec 2015 16:00:12 +0200
MIME-Version: 1.0
In-Reply-To: <20151214211811.16295.47695.stgit@manet.1015granger.net>
Content-Type: text/plain; charset=utf-8; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


> diff --git a/net/sunrpc/xprtrdma/xprt_rdma.h b/net/sunrpc/xprtrdma/xprt_rdma.h
> index 4197191..e60d817 100644
> --- a/net/sunrpc/xprtrdma/xprt_rdma.h
> +++ b/net/sunrpc/xprtrdma/xprt_rdma.h
> @@ -206,6 +206,8 @@ struct rpcrdma_frmr {
>   	enum rpcrdma_frmr_state		fr_state;
>   	struct work_struct		fr_work;
>   	struct rpcrdma_xprt		*fr_xprt;
> +	struct ib_reg_wr		fr_regwr;
> +	struct ib_send_wr		fr_invwr;

Would it make sense to unionize these as they are guaranteed not to
execute together? Some people don't like this sort of savings.
