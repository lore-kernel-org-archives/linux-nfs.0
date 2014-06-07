Return-Path: linux-nfs-owner@vger.kernel.org
Received: from bombadil.infradead.org ([198.137.202.9]:59888 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752886AbaFGOhB (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 7 Jun 2014 10:37:01 -0400
Date: Sat, 7 Jun 2014 07:37:01 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Weston Andros Adamson <dros@primarydata.com>
Cc: trond.myklebust@primarydata.com, linux-nfs@vger.kernel.org
Subject: Re: [PATCH v2 6/6] pnfs: clean up *_resend_to_mds
Message-ID: <20140607143701.GD9469@infradead.org>
References: <1401995791-40213-1-git-send-email-dros@primarydata.com>
 <1401995791-40213-7-git-send-email-dros@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1401995791-40213-7-git-send-email-dros@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Jun 05, 2014 at 03:16:31PM -0400, Weston Andros Adamson wrote:
> Clean up pnfs_read_done_resend_to_mds and pnfs_write_done_resend_to_mds:
>  - instead of passing all arguments from a nfs_pgio_header, just pass the header
>  - share the common code
> 
> Signed-off-by: Weston Andros Adamson <dros@primarydata.com>

Looks good,

Reviewed-by: Christoph Hellwig <hch@lst.de>

I think the exports for nfs_pageio_add_request and nfs_pageio_complete
can be dropped as well after this.

