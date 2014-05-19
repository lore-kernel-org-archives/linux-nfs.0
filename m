Return-Path: linux-nfs-owner@vger.kernel.org
Received: from bombadil.infradead.org ([198.137.202.9]:55189 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751074AbaESPcf (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 19 May 2014 11:32:35 -0400
Date: Mon, 19 May 2014 08:32:34 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Weston Andros Adamson <dros@primarydata.com>
Cc: trond.myklebust@primarydata.com, linux-nfs@vger.kernel.org
Subject: Re: [PATCH 6/8] pnfs: clean up *_resend_to_mds
Message-ID: <20140519153234.GA21345@infradead.org>
References: <1400512508-7530-1-git-send-email-dros@primarydata.com>
 <1400512508-7530-7-git-send-email-dros@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1400512508-7530-7-git-send-email-dros@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

> +	desc->pg_dreq = hdr->dreq;
> +	while (!list_empty(&hdr->pages)) {
> +		struct nfs_page *req = nfs_list_entry(hdr->pages.next);
> +
> +		nfs_list_remove_request(req);
> +		if (!nfs_pageio_add_request(desc, req))
> +			nfs_list_add_request(req, &failed);
> +	}
> +	nfs_pageio_complete(desc);

I think you can also drop the export for nfs_pageio_complete now.

