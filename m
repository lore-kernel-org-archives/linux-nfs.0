Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id BA16A3D9548;
	Tue,  6 Oct 2026 13:55:45 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1791294947; cv=none; b=uskmKs6KUdQzCH+lNd0aa7WrrLoj2qOLw2bCIPC6rJa3EdNQg8zrR2Uoa6+ADDE+fSl7gcwMDimKXSGUUu3BQNpjDPT5jQqTB14t8neBtlQum1PA1nD+C09mnGQhja94i7urYDAbIpp+WiSUNpmlde0M3jedS5AdhbwtIimqu8g=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1791294947; c=relaxed/simple;
	bh=n/tR9zi6lntqz+oVs1Efkbwfhwd3FRLPFtZx6jgbnug=;
	h=MIME-Version:Date:From:To:Cc:Message-Id:In-Reply-To:References:
	 Subject:Content-Type; b=NcJ39Mb+Z8ChrGckGQ0t7cXSSdafqUVcIfhvgRdrCtbjcLFT2dQccq3jfw7xme/3mFo9xBc22gr9BvbDwB1qZ6qLi0+6ZBQcjtVMJ/hft1Lv9Xr7i4TlSXfPxQGHosTBfSZLdGDDWB2XCWK6tC8cHIfCQ0xwGaYMVZnZ8AcgIsM=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=jD6o7EG0; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="jD6o7EG0"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id B97E41F000FF;
	Tue,  6 Oct 2026 13:55:44 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1791294945;
	bh=Kl/k7bnTCKMZSbaFxBHBqM57uHyQ6u2KOYpmbP91kAU=;
	h=Date:From:To:Cc:In-Reply-To:References:Subject;
	b=jD6o7EG04xqxpv8mNBv9E2su67gDogg2xSVMOwk1fKUZ710qpYBgHrVs4GI4gPZUn
	 wTr/HH8IxB9pdPTtbvUWlXzO6XWzlcFVzRI8cX8urKCDw0Ev+Hvkxf+sxFfyIvw4JQ
	 +MW1ZO5m7ESOuZwyipEQOJbllr1Dkl+qUY5/HfJsBrrxiI3UmyBeZ3oTKmfwkQxpyz
	 Et2aa87LSIS01zno9txxyUzGWc0NJaeXkRCGbOS6HmC/i/Jt8tyLhIWOmlejVhUXR0
	 m7ROjQFrZYgYhJjU2zICd/yKQErWo3Eo/f9hRW2JZ3+T/8K29sgdUTH9ZpGCSPvHe4
	 qfv8C6ajRRG3w==
Received: from phl-compute-10.internal (phl-compute-10.internal [10.202.2.50])
	by mailfauth.phl.internal (Postfix) with ESMTP id 0E484F40068;
	Tue,  6 Oct 2026 09:55:44 -0400 (EDT)
Received: from phl-imap-15 ([10.202.2.104])
  by phl-compute-10.internal (MEProxy); Tue, 06 Oct 2026 09:55:44 -0400
X-ME-Sender: <xms:3_3Ean8S1CMZ36C4HDgTmv3-La6yhaETcl5efNZMfGhdhNcdG7Zwiw>
    <xme:3_3EaujNjNRGmtD4UESaqvZqe_VP15pntIiuzz9Tw4Uti7ghyvz4p7TmAIkLMCmni
    ELwj0nF4Ykbhx1cmd5HCDpzFAq93hdCi9rXVcImzLJV_-Qb_8s959E>
X-ME-Proxy-Cause: dmFkZTGPElFHAuIjVvx4Oqs3OUWZ7umJTitZfPGUrTIdhMl01zVxcrTU42ROcGy21q2LzX
    zdFmJabfFuN6I4hDB2Q5p2dyRoGStg66GCMljROvB0P04hpbwuhmMTeyiLUYoCMg3xOrsn
    7WG7/S8qsGJiNr76yxMeyVxhs2cLlj5mUff7arlRSjshJNTRd6c66q1a1QA1dYRQfBBAni
    OZ5ItBzQe1unmOFexteDOee9arhbjhqZcQhCi8u/Cls2tnu86lByCEfb2cGZahNf9osBd7
    sZjEcPIRZP8MSj4lDobxKCcpPzGHJKY3mas5BDQAZBlrBS+KlyHZYX5PVQvuTVRIHfmHII
    iE9FKnjHnzvlHvC8HPbTwXevRcLImjhqWspWUkKfzdoepV3OK/N9aRMuZJWxETa5m5RV0F
    FNvlNtwaE4Jz+gnWU8/eEeEEUR6rxUX5icb58BV0RWCrgC1vuLNpZzfWr14/rCMXf6xvLT
    a/D2cGuj74DyoYp9bvZIbNTgYYXHzFrA/uCaXglr06ssYyZW1bAxSOwjQ0HSR5FcF+G9Xt
    o3fJGUkAWmwjr3c5GckWgUNuYqDSqI/KKsg3JzFI1lRluTCtsPqgHmWoVveOOrpnstoUJ0
    CcxF6RRKcgzekEIvaF0RRG8kkdv7SIcflGGijujeL86258WBAk1GgWN04NNw
X-ME-Proxy: <xmx:4P3EakVjbepsZ7zYp0g4Z0rdJns2nms3Nz85OpsUG9KxKrwTrhY2LQ>
    <xmx:4P3EagsUXpz0JjBW12zhgaDmmFG-uEg3SjPFmXc7HRC-YUvpy2zQ1A>
    <xmx:4P3Ean54zedOKQllcHhA1qwOdfYPuXYoW_ccT1yoJBQtQSmmu3s3Zw>
    <xmx:4P3EajQAUPcVOJjaaqfObO-Ns152Q3T_CgdGLm4mpNbWqqzqpNl_iw>
    <xmx:4P3EaqvvHvJt6OzIOUTCvjMp06mYON5w8UNwk02DyZo5AOhYtdqnx3n6>
Feedback-ID: ifa6e4810:Fastmail
Received: by mailuser.phl.internal (Postfix, from userid 501)
	id E113E780070; Tue,  6 Oct 2026 09:55:43 -0400 (EDT)
X-Mailer: MessagingEngine.com Webmail Interface
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
X-ThreadId: AqskSCTaNkUk
Date: Tue, 06 Oct 2026 09:55:23 -0400
From: "Chuck Lever" <cel@kernel.org>
To: "J Louis Kaplan" <Louis.Kaplan@arm.com>, "Dai Ngo" <dai.ngo@oracle.com>,
 "Jeff Layton" <jlayton@kernel.org>, NeilBrown <neil@brown.name>,
 "Olga Kornievskaia" <okorniev@redhat.com>, "Tom Talpey" <tom@talpey.com>
Cc: linux-nfs@vger.kernel.org, linux-rdma@vger.kernel.org,
 "Anna Schumaker" <anna@kernel.org>, "Jason Gunthorpe" <jgg@ziepe.ca>,
 "Leon Romanovsky" <leon@kernel.org>, "Trond Myklebust" <trondmy@kernel.org>
Message-Id: <59261d53-53fc-4195-a7f4-d9f117bb0150@app.fastmail.com>
In-Reply-To: <20261006090028.3412544-4-Louis.Kaplan@arm.com>
References: <20261006090028.3412544-1-Louis.Kaplan@arm.com>
 <20261006090028.3412544-4-Louis.Kaplan@arm.com>
Subject: Re: [RFC PATCH 3/6] svcrdma: Coalesce contiguous pages when mapping replies
Content-Type: text/plain
Content-Transfer-Encoding: 7bit



On Tue, Oct 6, 2026, at 5:00 AM, J Louis Kaplan wrote:
> Mapping reply pagelists one page at a time uses a separate direct
> memory access (DMA) mapping and scatter/gather entry (SGE) for
> each base page, even when those pages are physically contiguous.
>
> Instead, map contiguous runs as multipage bvecs, capped by the device's
> mapping and segment length limits. Use the same coalescing rules
> when counting SGEs for the pull-up decision, avoiding unnecessary
> copying when the coalesced reply fits the Send SGE limit.
>
> Virtual-mapping devices bypass device-limit check.
>
> Signed-off-by: J Louis Kaplan <Louis.Kaplan@arm.com>
> Assisted-by: LLM
> ---
>  include/linux/sunrpc/svc_rdma.h       |  15 ++++
>  net/sunrpc/xprtrdma/svc_rdma_sendto.c | 112 +++++++++++++++-----------
>  2 files changed, 82 insertions(+), 45 deletions(-)
>
> diff --git a/include/linux/sunrpc/svc_rdma.h b/include/linux/sunrpc/svc_rdma.h
> index 71bd5bcc5ce2a..c296bf8b8b1e3 100644
> --- a/include/linux/sunrpc/svc_rdma.h
> +++ b/include/linux/sunrpc/svc_rdma.h
> @@ -42,6 +42,7 @@
> 
>  #ifndef SVC_RDMA_H
>  #define SVC_RDMA_H
> +#include <linux/dma-mapping.h>
>  #include <linux/llist.h>
>  #include <linux/sunrpc/xdr.h>
>  #include <linux/sunrpc/svcsock.h>
> @@ -134,6 +135,20 @@ static inline struct svcxprt_rdma 
> *svc_rdma_rqst_rdma(struct svc_rqst *rqstp)
>  	return container_of(xprt, struct svcxprt_rdma, sc_xprt);
>  }
> 
> +static inline unsigned int
> +svc_rdma_max_bvec_len(const struct svcxprt_rdma *rdma)

There are some interesting infrastructural changes in this series.
Using bvecs through the svcrdma code has been on my to-do list
for quite some time.


> +{
> +	struct ib_device *device = rdma->sc_cm_id->device;
> +
> +	if (ib_uses_virt_dma(device))
> +		return UINT_MAX;
> +
> +	/* Respect both DMA mapping and RDMA device segment limits. */
> +	return min_t(size_t,
> +		     dma_max_mapping_size(device->dma_device),
> +		     ib_dma_max_seg_size(device));
> +}
> +
>  /*
>   * Default connection parameters
>   */
> diff --git a/net/sunrpc/xprtrdma/svc_rdma_sendto.c 
> b/net/sunrpc/xprtrdma/svc_rdma_sendto.c
> index efa352ddf9d71..9f2e3ee3c2936 100644
> --- a/net/sunrpc/xprtrdma/svc_rdma_sendto.c
> +++ b/net/sunrpc/xprtrdma/svc_rdma_sendto.c
> @@ -260,10 +260,8 @@ static void svc_rdma_send_ctxt_unmap(struct 
> svcxprt_rdma *rdma,
>  		trace_svcrdma_dma_unmap_page(&ctxt->sc_cid,
>  					     ctxt->sc_sges[i].addr,
>  					     ctxt->sc_sges[i].length);
> -		ib_dma_unmap_page(device,
> -				  ctxt->sc_sges[i].addr,
> -				  ctxt->sc_sges[i].length,
> -				  DMA_TO_DEVICE);
> +		ib_dma_unmap_bvec(device, ctxt->sc_sges[i].addr,
> +				  ctxt->sc_sges[i].length, DMA_TO_DEVICE);
>  	}
>  }
> 
> @@ -730,44 +728,45 @@ svc_rdma_encode_reply_chunk(struct 
> svc_rdma_recv_ctxt *rctxt,
>  }
> 
>  struct svc_rdma_map_data {
> -	struct svcxprt_rdma		*md_rdma;
>  	struct svc_rdma_send_ctxt	*md_ctxt;
> +	unsigned int			md_max_bvec_len;
>  };
> 
>  /**
> - * svc_rdma_page_dma_map - DMA map one page
> + * svc_rdma_bvec_dma_map - DMA map one physically contiguous bvec
>   * @data: pointer to arguments
> - * @page: struct page to DMA map
> - * @offset: offset into the page
> - * @len: number of bytes to map
> + * @bv: contiguous range to DMA map
>   *
>   * Returns:
>   *   %0 if DMA mapping was successful
> - *   %-EIO if the page cannot be DMA mapped
> + *   %-EIO if the range cannot be DMA mapped
>   */
> -static int svc_rdma_page_dma_map(void *data, struct page *page,
> -				 unsigned long offset, unsigned int len)
> +static int svc_rdma_bvec_dma_map(void *data, struct bio_vec *bv)
>  {
>  	struct svc_rdma_map_data *args = data;
> -	struct svcxprt_rdma *rdma = args->md_rdma;
>  	struct svc_rdma_send_ctxt *ctxt = args->md_ctxt;
> +	struct svcxprt_rdma *rdma = ctxt->sc_rdma;
>  	struct ib_device *dev = rdma->sc_cm_id->device;
>  	dma_addr_t dma_addr;
> 
> +	if (bv->bv_len > args->md_max_bvec_len)
> +		return -EIO;
> +	if (WARN_ON_ONCE(ctxt->sc_send_wr.num_sge >= rdma->sc_max_send_sges))
> +		return -EIO;
>  	++ctxt->sc_cur_sge_no;
> 
> -	dma_addr = ib_dma_map_page(dev, page, offset, len, DMA_TO_DEVICE);
> +	dma_addr = ib_dma_map_bvec(dev, bv, DMA_TO_DEVICE);
>  	if (ib_dma_mapping_error(dev, dma_addr))
>  		goto out_maperr;
> 
> -	trace_svcrdma_dma_map_page(&ctxt->sc_cid, dma_addr, len);
> +	trace_svcrdma_dma_map_page(&ctxt->sc_cid, dma_addr, bv->bv_len);
>  	ctxt->sc_sges[ctxt->sc_cur_sge_no].addr = dma_addr;
> -	ctxt->sc_sges[ctxt->sc_cur_sge_no].length = len;
> +	ctxt->sc_sges[ctxt->sc_cur_sge_no].length = bv->bv_len;
>  	ctxt->sc_send_wr.num_sge++;
>  	return 0;
> 
>  out_maperr:
> -	trace_svcrdma_dma_map_err(&ctxt->sc_cid, dma_addr, len);
> +	trace_svcrdma_dma_map_err(&ctxt->sc_cid, dma_addr, bv->bv_len);
>  	return -EIO;
>  }
> 
> @@ -776,20 +775,18 @@ static int svc_rdma_page_dma_map(void *data, 
> struct page *page,
>   * @data: pointer to arguments
>   * @iov: kvec to DMA map
>   *
> - * ib_dma_map_page() is used here because svc_rdma_dma_unmap()
> - * handles DMA-unmap and it uses ib_dma_unmap_page() exclusively.
> - *
>   * Returns:
>   *   %0 if DMA mapping was successful
>   *   %-EIO if the iovec cannot be DMA mapped
>   */
>  static int svc_rdma_iov_dma_map(void *data, const struct kvec *iov)
>  {
> +	struct bio_vec bv;
> +
>  	if (!iov->iov_len)
>  		return 0;
> -	return svc_rdma_page_dma_map(data, virt_to_page(iov->iov_base),
> -				     offset_in_page(iov->iov_base),
> -				     iov->iov_len);
> +	bvec_set_virt(&bv, iov->iov_base, iov->iov_len);
> +	return svc_rdma_bvec_dma_map(data, &bv);
>  }
> 
>  /**
> @@ -798,7 +795,7 @@ static int svc_rdma_iov_dma_map(void *data, const 
> struct kvec *iov)
>   * @data: pointer to arguments
>   *
>   * Returns:
> - *   %0 if DMA mapping was successful
> + *   The number of mapped bytes if DMA mapping was successful
>   *   %-EIO if DMA mapping failed
>   *
>   * On failure, any DMA mappings that have been already done must be
> @@ -806,9 +803,11 @@ static int svc_rdma_iov_dma_map(void *data, const 
> struct kvec *iov)
>   */
>  static int svc_rdma_xb_dma_map(const struct xdr_buf *xdr, void *data)
>  {
> -	unsigned int len, remaining;
> +	struct svc_rdma_map_data *args = data;
> +	unsigned int remaining;
>  	unsigned long pageoff;
>  	struct page **ppages;
> +	unsigned int nr_pages;
>  	int ret;
> 
>  	ret = svc_rdma_iov_dma_map(data, &xdr->head[0]);
> @@ -818,15 +817,25 @@ static int svc_rdma_xb_dma_map(const struct 
> xdr_buf *xdr, void *data)
>  	ppages = xdr->pages + (xdr->page_base >> PAGE_SHIFT);
>  	pageoff = offset_in_page(xdr->page_base);
>  	remaining = xdr->page_len;
> +	nr_pages = DIV_ROUND_UP(pageoff + remaining, PAGE_SIZE);
>  	while (remaining) {
> -		len = min_t(u32, PAGE_SIZE - pageoff, remaining);
> -
> -		ret = svc_rdma_page_dma_map(data, *ppages++, pageoff, len);
> +		struct bio_vec bv;
> +		unsigned int bytes = svc_pages_to_bvec(&bv, ppages,
> +				nr_pages, pageoff, remaining,
> +				args->md_max_bvec_len);
> +		unsigned int advanced =
> +				(pageoff + bytes) >> PAGE_SHIFT;
> +
> +		if (!bytes)
> +			return -EIO;
> +		ret = svc_rdma_bvec_dma_map(data, &bv);
>  		if (ret < 0)
>  			return ret;
> 
> -		remaining -= len;
> -		pageoff = 0;
> +		pageoff = offset_in_page(pageoff + bytes);
> +		ppages += advanced;
> +		nr_pages -= advanced;
> +		remaining -= bytes;
>  	}
> 
>  	ret = svc_rdma_iov_dma_map(data, &xdr->tail[0]);
> @@ -836,10 +845,27 @@ static int svc_rdma_xb_dma_map(const struct 
> xdr_buf *xdr, void *data)
>  	return xdr->len;
>  }
> 
> +static unsigned int
> +svc_rdma_xb_page_sges(const struct xdr_buf *xdr,
> +		      unsigned int max_bvec_len)
> +{
> +	const unsigned long offset = offset_in_page(xdr->page_base);
> +	const unsigned int nr_pages =
> +		DIV_ROUND_UP(offset + xdr->page_len, PAGE_SIZE);
> +	struct page *const *ppages;
> +
> +	if (!xdr->page_len)
> +		return 0;
> +	ppages = xdr->pages + (xdr->page_base >> PAGE_SHIFT);
> +	return svc_pages_to_bvecs(NULL, ppages, nr_pages, offset,
> +				  xdr->page_len, max_bvec_len);
> +}
> +
>  struct svc_rdma_pullup_data {
>  	u8		*pd_dest;
>  	unsigned int	pd_length;
>  	unsigned int	pd_num_sges;
> +	unsigned int	pd_max_bvec_len;
>  };
> 
>  /**
> @@ -848,25 +874,22 @@ struct svc_rdma_pullup_data {
>   * @data: pointer to arguments
>   *
>   * Returns:
> - *   Number of SGEs needed to Send the contents of @xdr inline
> + *   %0 if the SGE count was updated
> + *   %-EIO if the page list cannot be described
>   */
>  static int svc_rdma_xb_count_sges(const struct xdr_buf *xdr,
>  				  void *data)
>  {
>  	struct svc_rdma_pullup_data *args = data;
> -	unsigned int remaining;
> -	unsigned long offset;
> +	unsigned int page_sges =
> +		svc_rdma_xb_page_sges(xdr, args->pd_max_bvec_len);
> 
>  	if (xdr->head[0].iov_len)
>  		++args->pd_num_sges;
> 
> -	offset = offset_in_page(xdr->page_base);
> -	remaining = xdr->page_len;
> -	while (remaining) {
> -		++args->pd_num_sges;
> -		remaining -= min_t(u32, PAGE_SIZE - offset, remaining);
> -		offset = 0;
> -	}
> +	if (xdr->page_len && !page_sges)
> +		return -EIO;
> +	args->pd_num_sges += page_sges;
> 
>  	if (xdr->tail[0].iov_len)
>  		++args->pd_num_sges;
> @@ -896,6 +919,7 @@ static int svc_rdma_check_pull_up(const struct 
> svcxprt_rdma *rdma,
>  	struct svc_rdma_pullup_data args = {
>  		.pd_length	= sctxt->sc_hdrbuf.len,
>  		.pd_num_sges	= 1,
> +		.pd_max_bvec_len = svc_rdma_max_bvec_len(rdma),
>  	};
>  	int ret;
> 
> @@ -964,7 +988,6 @@ static int svc_rdma_xb_linearize(const struct xdr_buf *xdr,
> 
>  /**
>   * svc_rdma_pull_up_reply_msg - Copy Reply into a single buffer
> - * @rdma: controlling transport
>   * @sctxt: send_ctxt for the Send WR; xprt hdr is already prepared
>   * @write_pcl: Write chunk list provided by client
>   * @xdr: prepared xdr_buf containing RPC message
> @@ -979,8 +1002,7 @@ static int svc_rdma_xb_linearize(const struct xdr_buf *xdr,
>   *   %0 if pull-up was successful
>   *   %-EMSGSIZE if a buffer manipulation problem occurred
>   */
> -static int svc_rdma_pull_up_reply_msg(const struct svcxprt_rdma *rdma,
> -				      struct svc_rdma_send_ctxt *sctxt,
> +static int svc_rdma_pull_up_reply_msg(struct svc_rdma_send_ctxt *sctxt,
>  				      const struct svc_rdma_pcl *write_pcl,
>  				      const struct xdr_buf *xdr)
>  {
> @@ -1021,8 +1043,8 @@ int svc_rdma_map_reply_msg(struct svcxprt_rdma *rdma,
>  			   const struct xdr_buf *xdr)
>  {
>  	struct svc_rdma_map_data args = {
> -		.md_rdma	= rdma,
>  		.md_ctxt	= sctxt,
> +		.md_max_bvec_len = svc_rdma_max_bvec_len(rdma),
>  	};
>  	int ret;
> 
> @@ -1043,7 +1065,7 @@ int svc_rdma_map_reply_msg(struct svcxprt_rdma *rdma,
>  	if (ret < 0)
>  		return ret;
>  	if (ret)
> -		return svc_rdma_pull_up_reply_msg(rdma, sctxt, write_pcl, xdr);
> +		return svc_rdma_pull_up_reply_msg(sctxt, write_pcl, xdr);
> 
>  	return pcl_process_nonpayloads(write_pcl, xdr,
>  				       svc_rdma_xb_dma_map, &args);
> -- 
> 2.43.0

-- 
Chuck Lever (Come to NFS bake-a-thon! https://nfsv4bat.org)
