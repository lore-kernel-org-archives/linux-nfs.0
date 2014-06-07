Return-Path: linux-nfs-owner@vger.kernel.org
Received: from bombadil.infradead.org ([198.137.202.9]:59844 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752778AbaFGOdG (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 7 Jun 2014 10:33:06 -0400
Date: Sat, 7 Jun 2014 07:33:06 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Weston Andros Adamson <dros@primarydata.com>
Cc: trond.myklebust@primarydata.com, linux-nfs@vger.kernel.org
Subject: Re: [PATCH v2 2/6] nfs: rename members of nfs_pgio_data
Message-ID: <20140607143306.GB9469@infradead.org>
References: <1401995791-40213-1-git-send-email-dros@primarydata.com>
 <1401995791-40213-3-git-send-email-dros@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1401995791-40213-3-git-send-email-dros@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Jun 05, 2014 at 03:16:27PM -0400, Weston Andros Adamson wrote:
> Rename "verf" to "writeverf" and "pages" to "page_array" to prepare for
> merge of nfs_pgio_data and nfs_pgio_header.
> 
> Signed-off-by: Weston Andros Adamson <dros@primarydata.com>
> ---
>  fs/nfs/blocklayout/blocklayout.c | 17 ++++++++++-------
>  fs/nfs/objlayout/objlayout.c     |  4 ++--
>  fs/nfs/pagelist.c                | 12 ++++++------
>  fs/nfs/write.c                   |  9 +++++----
>  include/linux/nfs_xdr.h          |  4 ++--
>  5 files changed, 25 insertions(+), 21 deletions(-)

Looks good,

Reviewed-by: Christoph Hellwig <hch@lst.de>
