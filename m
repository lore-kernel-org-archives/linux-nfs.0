Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-yh0-f47.google.com ([209.85.213.47]:63187 "EHLO
	mail-yh0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751322AbbALRyP (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 12 Jan 2015 12:54:15 -0500
Received: by mail-yh0-f47.google.com with SMTP id f73so10267529yha.6
        for <linux-nfs@vger.kernel.org>; Mon, 12 Jan 2015 09:54:15 -0800 (PST)
Date: Mon, 12 Jan 2015 09:54:11 -0800
From: Tom Haynes <thomas.haynes@primarydata.com>
To: Christoph Hellwig <hch@lst.de>
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
        Jeff Layton <jlayton@primarydata.com>, linux-nfs@vger.kernel.org,
        linux-fsdevel@vger.kernel.org, xfs@oss.sgi.com
Subject: Re: [PATCH 09/18] nfsd: implement pNFS operations
Message-ID: <20150112175411.GA10611@jhereg.localdomain>
References: <1420561721-9150-1-git-send-email-hch@lst.de>
 <1420561721-9150-10-git-send-email-hch@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1420561721-9150-10-git-send-email-hch@lst.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Jan 06, 2015 at 05:28:32PM +0100, Christoph Hellwig wrote:

> +#ifdef CONFIG_NFSD_PNFS
> +static __be32
> +nfsd4_encode_getdeviceinfo(struct nfsd4_compoundres *resp, __be32 nfserr,
> +		struct nfsd4_getdeviceinfo *gdev)
> +{
> +	struct xdr_stream *xdr = &resp->xdr;
> +	const struct nfsd4_layout_ops *ops =
> +		nfsd4_layout_ops[gdev->gd_layout_type];
> +	u32 starting_len = xdr->buf->len, needed_len;
> +	__be32 *p;
> +
> +	dprintk("%s: err %d\n", __func__, nfserr);
> +	if (nfserr)
> +		goto out;

In nfsd4_block_get_device_info_simple(), gdp->gd_device might have
been allocated, but sb->s_export_op->get_uuid() might have returned
an error, which would cause a leak here.

> +
> +	p = xdr_reserve_space(xdr, 4);
> +	if (!p)
> +		return nfserr_resource;

gdp->gd_device can be leaked here.

> +	*p++ = cpu_to_be32(gdev->gd_layout_type);
> +
> +	/* If maxcount is 0 then just update notifications */
> +	if (gdev->gd_maxcount != 0) {
> +		nfserr = ops->encode_getdeviceinfo(xdr, gdev);
> +		if (nfserr) {
> +			/*
> +			 * We don't bother to burden the layout drivers with
> +			 * enforcing gd_maxcount, just tell the client to
> +			 * come back with a bigger buffer if it's not enough.
> +			 */
> +			if (xdr->buf->len + 4 > gdev->gd_maxcount)
> +				goto toosmall;
> +			goto out;
> +		}
> +	}
> +
> +	if (gdev->gd_notify_types) {
> +		p = xdr_reserve_space(xdr, 4 + 4);
> +		if (!p)
> +			return nfserr_resource;

gdp->gd_device can be leaked here.

> +		*p++ = cpu_to_be32(1);			/* bitmap length */
> +		*p++ = cpu_to_be32(gdev->gd_notify_types);
> +	} else {
> +		p = xdr_reserve_space(xdr, 4);
> +		if (!p)
> +			return nfserr_resource;

gdp->gd_device can be leaked here.

> +		*p++ = 0;
> +	}
> +
> +out:
> +	kfree(gdev->gd_device);
> +	dprintk("%s: done: %d\n", __func__, be32_to_cpu(nfserr));
> +	return nfserr;
> +
> +toosmall:
> +	dprintk("%s: maxcount too small\n", __func__);
> +	needed_len = xdr->buf->len + 4 /* notifications */;
> +	xdr_truncate_encode(xdr, starting_len);
> +	p = xdr_reserve_space(xdr, 4);
> +	if (!p)
> +		return nfserr_resource;
> +	*p++ = cpu_to_be32(needed_len);
> +	nfserr = nfserr_toosmall;
> +	goto out;
> +}
> +
