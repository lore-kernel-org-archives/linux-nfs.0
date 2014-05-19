Return-Path: linux-nfs-owner@vger.kernel.org
Received: from bombadil.infradead.org ([198.137.202.9]:55668 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753543AbaESPeC (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 19 May 2014 11:34:02 -0400
Date: Mon, 19 May 2014 08:34:02 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Weston Andros Adamson <dros@primarydata.com>
Cc: trond.myklebust@primarydata.com, linux-nfs@vger.kernel.org
Subject: Re: [PATCH 8/8] pnfs: merge identical functions
Message-ID: <20140519153402.GB21345@infradead.org>
References: <1400512508-7530-1-git-send-email-dros@primarydata.com>
 <1400512508-7530-9-git-send-email-dros@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1400512508-7530-9-git-send-email-dros@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

> -static void pnfs_writehdr_free(struct nfs_pgio_header *hdr)
> +static void pnfs_pgio_header_free(struct nfs_pgio_header *hdr)
>  {
>  	pnfs_put_lseg(hdr->lseg);
>  	nfs_pgio_header_free(hdr);
>  }

I think it should also be mossible to simply call pnfs_put_lseg
from nfs_pgio_header_free.  pnfs_put_lseg handles a NULL argument fine,
is stubbed out for the non-pnfs case, and the other callers should never
have it set.

