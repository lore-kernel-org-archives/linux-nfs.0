From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH 1/1] sunrpc: potential memory leak in function
	rdma_read_xdr
Date: Mon, 15 Jun 2009 19:34:46 -0400
Message-ID: <20090615233446.GD18504@fieldses.org>
References: <20090614000526.56036335@frequentis.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: neilb@suse.de, linux-nfs@vger.kernel.org
To: Christian Engelmayer <christian.engelmayer-USXAA5bZaHGDvotElmWtJA@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([141.211.133.115]:60566 "EHLO
	pickle.fieldses.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752010AbZFOXer (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 15 Jun 2009 19:34:47 -0400
In-Reply-To: <20090614000526.56036335-USXAA5bZaHGDvotElmWtJA@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sun, Jun 14, 2009 at 12:05:26AM +0200, Christian Engelmayer wrote:
> From: Christian Engelmayer <christian.engelmayer-USXAA5bZaHGDvotElmWtJA@public.gmane.org>
> 
> In case the check on ch_count fails the cleanup path is skipped and the
> previously allocated memory 'rpl_map', 'chl_map' is not freed.
> 
> Signed-off-by: Christian Engelmayer <christian.engelmayer-USXAA5bZaHGDvotElmWtJA@public.gmane.org>
> --
> Reported by Coverity.

Thanks, applied (after fixing up a minor whitespace error--extra space
added before tab on comment line).

rdma_read_xdr() is long.  If there were a logical way to move some of
that into a helper function or two, that might make it easier to read
(and/or might simplify cleanup on failure).

--b.

> 
> --- linux-2.6.29.4/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c.orig	2009-06-13 23:41:16.000000000 +0200
> +++ linux-2.6.29.4/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c	2009-06-13 23:40:21.000000000 +0200
> @@ -397,14 +397,14 @@ static int rdma_read_xdr(struct svcxprt_
>  	if (!ch)
>  		return 0;
>  
> -	/* Allocate temporary reply and chunk maps */
> -	rpl_map = svc_rdma_get_req_map();
> -	chl_map = svc_rdma_get_req_map();
> -
>  	svc_rdma_rcl_chunk_counts(ch, &ch_count, &byte_count);
>  	if (ch_count > RPCSVC_MAXPAGES)
>  		return -EINVAL;
>  
> + 	/* Allocate temporary reply and chunk maps */
> +	rpl_map = svc_rdma_get_req_map();
> +	chl_map = svc_rdma_get_req_map();
> +
>  	if (!xprt->sc_frmr_pg_list_len)
>  		sge_count = map_read_chunks(xprt, rqstp, hdr_ctxt, rmsgp,
>  					    rpl_map, chl_map, ch_count,
