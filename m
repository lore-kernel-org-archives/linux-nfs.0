Return-Path: linux-nfs-owner@vger.kernel.org
Received: from bombadil.infradead.org ([198.137.202.9]:59855 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752707AbaFGOeG (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 7 Jun 2014 10:34:06 -0400
Date: Sat, 7 Jun 2014 07:34:06 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Weston Andros Adamson <dros@primarydata.com>
Cc: trond.myklebust@primarydata.com, linux-nfs@vger.kernel.org
Subject: Re: [PATCH v2 3/6] nfs: merge nfs_pgio_data into _header
Message-ID: <20140607143406.GC9469@infradead.org>
References: <1401995791-40213-1-git-send-email-dros@primarydata.com>
 <1401995791-40213-4-git-send-email-dros@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1401995791-40213-4-git-send-email-dros@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Jun 05, 2014 at 03:16:28PM -0400, Weston Andros Adamson wrote:
> struct nfs_pgio_data only exists as a member of nfs_pgio_header, but is
> passed around everywhere, because there used to be multiple _data structs
> per _header. Many of these functions then use the _data to find a pointer
> to the _header.  This patch cleans this up by merging the nfs_pgio_data
> structure into nfs_pgio_header and passing nfs_pgio_header around instead.
> 
> Signed-off-by: Weston Andros Adamson <dros@primarydata.com>

Looks good,

Reviewed-by: Christoph Hellwig <hch@lst.de>

But now that we only have a _header and no _data should we just
call this struct nfs_pgio?
