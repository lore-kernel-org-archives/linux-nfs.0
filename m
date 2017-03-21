Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qt0-f196.google.com ([209.85.216.196]:36481 "EHLO
        mail-qt0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1757727AbdCURys (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 21 Mar 2017 13:54:48 -0400
Subject: Re: [PATCH v1 02/14] svcrdma: Add svc_rdma_map_reply_hdr()
To: Chuck Lever <chuck.lever@oracle.com>, linux-rdma@vger.kernel.org,
        linux-nfs@vger.kernel.org
References: <20170316154132.4482.56769.stgit@klimt.1015granger.net>
 <20170316155242.4482.64809.stgit@klimt.1015granger.net>
From: Sagi Grimberg <sagi@grimberg.me>
Message-ID: <f5000e25-6ca1-fc24-35c0-6089cf50923c@grimberg.me>
Date: Tue, 21 Mar 2017 19:54:44 +0200
MIME-Version: 1.0
In-Reply-To: <20170316155242.4482.64809.stgit@klimt.1015granger.net>
Content-Type: text/plain; charset=utf-8; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


>  	svc_rdma_build_send_wr(ctxt, 1);
>  	ret = svc_rdma_send(rdma, &ctxt->send_wr);
>  	if (ret) {
> +		svc_rdma_unmap_dma(ctxt);
> +		svc_rdma_put_context(ctxt, 1);
>  		ret = -EIO;
> -		goto out_unmap;
>  	}

Any specific reason to not go with the goto scheme?
Can't this function grow more error paths in the future?

btw, I'm assuming svc_rdma_unmap_dma() is the opposite of
svc_rdma_map_reply_hdr() ?
