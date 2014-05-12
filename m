Return-Path: linux-nfs-owner@vger.kernel.org
Received: from bombadil.infradead.org ([198.137.202.9]:47481 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751942AbaELFfy (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 12 May 2014 01:35:54 -0400
Date: Sun, 11 May 2014 22:35:54 -0700
From: Christoph Hellwig <hch@infradead.org>
To: "J. Bruce Fields" <bfields@redhat.com>
Cc: linux-nfs@vger.kernel.org, Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH 02/43] nfsd4: tweak nfsd4_encode_getattr to take
 xdr_stream
Message-ID: <20140512053554.GC29134@infradead.org>
References: <1399841568-19716-1-git-send-email-bfields@redhat.com>
 <1399841568-19716-3-git-send-email-bfields@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1399841568-19716-3-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

>   * Note: @fhp can be NULL; in this case, we might have to compose the filehandle
>   * ourselves.
> - *
> - * countp is the buffer size in _words_
>   */
>  __be32
> -nfsd4_encode_fattr(struct svc_fh *fhp, struct svc_export *exp,
> -		struct dentry *dentry, __be32 **buffer, int count, u32 *bmval,
> +nfsd4_encode_fattr(struct xdr_stream *xdr, struct svc_fh *fhp, struct svc_export *exp,

Can you make sure that line that the patches touch don't exceed 80
lines?  There's quite a few more through the series, including new code.


Otherwise looks good,

Signed-off-by: Christoph Hellwig <hch@lst.de>
