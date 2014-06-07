Return-Path: linux-nfs-owner@vger.kernel.org
Received: from bombadil.infradead.org ([198.137.202.9]:59839 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752778AbaFGOcs (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 7 Jun 2014 10:32:48 -0400
Date: Sat, 7 Jun 2014 07:32:48 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Weston Andros Adamson <dros@primarydata.com>
Cc: trond.myklebust@primarydata.com, linux-nfs@vger.kernel.org
Subject: Re: [PATCH v2 1/6] nfs: move nfs_pgio_data and remove nfs_rw_header
Message-ID: <20140607143248.GA9469@infradead.org>
References: <1401995791-40213-1-git-send-email-dros@primarydata.com>
 <1401995791-40213-2-git-send-email-dros@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1401995791-40213-2-git-send-email-dros@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Jun 05, 2014 at 03:16:26PM -0400, Weston Andros Adamson wrote:
> nfs_rw_header was used to allocate an nfs_pgio_header along with an
> nfs_pgio_data, because a _header would need at least one _data.
> 
> Now there is only ever one nfs_pgio_data for each nfs_pgio_header -- move
> it to nfs_pgio_header and get rid of nfs_rw_header.
> 
> Signed-off-by: Weston Andros Adamson <dros@primarydata.com>

Looks good,

Reviewed-by: Christoph Hellwig <hch@lst.de>
