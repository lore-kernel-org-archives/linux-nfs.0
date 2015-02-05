Return-Path: linux-nfs-owner@vger.kernel.org
Received: from bombadil.infradead.org ([198.137.202.9]:50699 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753111AbbBEOKI (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 5 Feb 2015 09:10:08 -0500
Date: Thu, 5 Feb 2015 06:10:07 -0800
From: Christoph Hellwig <hch@infradead.org>
To: Anna Schumaker <Anna.Schumaker@netapp.com>
Cc: Trond.Myklebust@primarydata.com, linux-nfs@vger.kernel.org
Subject: Re: [PATCH v2 1/6] NFS: Add READ_PLUS support for data segments
Message-ID: <20150205141007.GA4522@infradead.org>
References: <1422477830-28090-1-git-send-email-Anna.Schumaker@Netapp.com>
 <1422477830-28090-2-git-send-email-Anna.Schumaker@Netapp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1422477830-28090-2-git-send-email-Anna.Schumaker@Netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Jan 28, 2015 at 03:43:45PM -0500, Anna Schumaker wrote:
> +	if (type == NFS4_CONTENT_DATA)
> +		status = decode_read_plus_data(xdr, res);
> +	else
> +		status = -ENOTSUPP;
> +
> +	if (segments > 1)
> +		res->eof = 0;

Given that the server can return any amount of data and hole
segments it doesn't make any sense to separate this patch from patches 4
and 6.
