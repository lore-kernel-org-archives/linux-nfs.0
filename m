Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([65.50.211.133]:60655 "EHLO
        bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750777AbdBASZU (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 1 Feb 2017 13:25:20 -0500
Date: Wed, 1 Feb 2017 10:25:18 -0800
From: Christoph Hellwig <hch@infradead.org>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: bfields@fieldses.org, linux-rdma@vger.kernel.org,
        linux-nfs@vger.kernel.org
Subject: Re: [PATCH v2 2/7] svcrdma: Clean up RPC-over-RDMA Reply header
 encoder
Message-ID: <20170201182518.GA32532@infradead.org>
References: <20170131184623.14185.35480.stgit@klimt.1015granger.net>
 <20170131185302.14185.10775.stgit@klimt.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20170131185302.14185.10775.stgit@klimt.1015granger.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

I'm always confused when a cleanup adds more line than it removes,
but it seems to be just comments in this case and some other
patches in the series.

> + * svc_rdma_xdr_encode_reply_header - Encode Reply's fixed header fields
> + * @rdma: controlling transport
> + * @rdma_argp: Call's transport header
> + * @rdma_resp: Reply's transport header
> + * @rdma_type: procedure number
> + *
> + */
> +void svc_rdma_xdr_encode_reply_header(struct svcxprt_rdma *rdma,
> +				      __be32 *rdma_argp, __be32 *rdma_resp,
> +				      __be32 rdma_type)

To me it would seem much cleaner to just take the few lines of encoding
into the only caller.
