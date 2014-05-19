Return-Path: linux-nfs-owner@vger.kernel.org
Received: from bombadil.infradead.org ([198.137.202.9]:49869 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932310AbaESQ5e (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 19 May 2014 12:57:34 -0400
Date: Mon, 19 May 2014 09:57:32 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Anna Schumaker <schumaker.anna@gmail.com>
Cc: Christoph Hellwig <hch@infradead.org>,
        Weston Andros Adamson <dros@primarydata.com>,
        trond.myklebust@primarydata.com, linux-nfs@vger.kernel.org
Subject: Re: [PATCH 8/8] pnfs: merge identical functions
Message-ID: <20140519165732.GB663@infradead.org>
References: <1400512508-7530-1-git-send-email-dros@primarydata.com>
 <1400512508-7530-9-git-send-email-dros@primarydata.com>
 <20140519153402.GB21345@infradead.org>
 <537A2D32.1020701@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <537A2D32.1020701@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, May 19, 2014 at 12:11:30PM -0400, Anna Schumaker wrote:
> > I think it should also be mossible to simply call pnfs_put_lseg
> > from nfs_pgio_header_free.  pnfs_put_lseg handles a NULL argument fine,
> > is stubbed out for the non-pnfs case, and the other callers should never
> > have it set.
> 
> Every function in this area is identical to each other :).  I'm already working on a patch series that combines these functions (and more!).  It also needs more testing before I can submit, but I can update against these patches first to see if this unlocks other cleanups.

Yes, pnfs.c has lots of duplication of the classic I/O path.  I don't
think we need to rush out your patches, but it would be good to get them
out in the not too far future.

