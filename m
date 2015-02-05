Return-Path: linux-nfs-owner@vger.kernel.org
Received: from bombadil.infradead.org ([198.137.202.9]:50797 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757409AbbBEON0 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 5 Feb 2015 09:13:26 -0500
Date: Thu, 5 Feb 2015 06:13:25 -0800
From: Christoph Hellwig <hch@infradead.org>
To: Anna.Schumaker@netapp.com
Cc: bfields@fieldses.org, linux-nfs@vger.kernel.org
Subject: Re: [PATCH v2 2/4] NFSD: Add READ_PLUS support for data segments
Message-ID: <20150205141325.GC4522@infradead.org>
References: <1422477777-27933-1-git-send-email-Anna.Schumaker@Netapp.com>
 <1422477777-27933-3-git-send-email-Anna.Schumaker@Netapp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1422477777-27933-3-git-send-email-Anna.Schumaker@Netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

> +	p = xdr_reserve_space(xdr, 4 + 8 + 4); /* content type, offset, maxcount */
> +	if (!p)
> +		return nfserr_resource;
> +	xdr_commit_encode(xdr);
> +
> +	maxcount = svc_max_payload(resp->rqstp);
> +	maxcount = min_t(unsigned long, maxcount, (xdr->buf->buflen - xdr->buf->len));
> +	maxcount = min_t(unsigned long, maxcount, read->rd_length);
> +
> +	err = nfsd4_encode_readv(resp, read, file, &maxcount);

If the READ_PLUS implementation can't use the splice read path it's
probably a loss for most workloads.
