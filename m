Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([18.85.46.34]:48437 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752211Ab1BOJbU (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 15 Feb 2011 04:31:20 -0500
Date: Tue, 15 Feb 2011 04:31:13 -0500
From: Christoph Hellwig <hch@infradead.org>
To: andros@netapp.com
Cc: trond.myklebust@netapp.com, linux-nfs@vger.kernel.org,
        Fred Isaman <iisaman@netapp.com>, Andy Adamson <andros@citi.umich.edu>,
        Dean Hildebrand <dhildeb@us.ibm.com>,
        Marc Eshel <eshel@almaden.ibm.com>, Mike Sager <sager@netapp.com>,
        Oleg Drokin <green@linuxhacker.ru>, Tao Guo <guotao@nrchpc.ac.cn>,
        Tigran Mkrtchyan <tigran@anahit.desy.de>,
        Tigran Mkrtchyan <tigran.mkrtchyan@desy.de>,
        Benny Halevy <bhalevy@panasas.com>
Subject: Re: [PATCH 13/16] pnfs: wave 3: filelayout i/o helpers
Message-ID: <20110215093113.GC29871@infradead.org>
References: <1297711116-3139-1-git-send-email-andros@netapp.com>
 <1297711116-3139-14-git-send-email-andros@netapp.com>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1297711116-3139-14-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Mon, Feb 14, 2011 at 02:18:33PM -0500, andros@netapp.com wrote:
> +static loff_t
> +filelayout_get_dserver_offset(struct pnfs_layout_segment *lseg, loff_t offset)
> +{
> +	struct nfs4_filelayout_segment *flseg = FILELAYOUT_LSEG(lseg);
> +
> +	switch (flseg->stripe_type) {
> +	case STRIPE_SPARSE:
> +		return offset;
> +
> +	case STRIPE_DENSE:
> +	{
> +		u32 stripe_width;
> +		u64 tmp, off;
> +		u32 unit = flseg->stripe_unit;
> +
> +		stripe_width = unit * flseg->dsaddr->stripe_count;
> +		tmp = off = offset - flseg->pattern_offset;
> +		do_div(tmp, stripe_width);
> +		return tmp * unit + do_div(off, unit);

For readability's sake I'd split this out into a helper:

static loff_t
filelayout_get_dense_offset(struct nfs4_filelayout_segment *flseg,
			    loff_t offset)
{
	u32 stripe_width = flseg->stripe_unit * flseg->dsaddr->stripe_count;
	u64 tmp;

	offset -= flseg->pattern_offset

	tmp = off;
	do_div(tmp, stripe_width);

	return tmp * unit + do_div(offset, flseg->stripe_unit);
}

...


	case STRIPE_DENSE:
		return filelayout_get_dense_offset(flset, offset);

