Return-Path: linux-nfs-owner@vger.kernel.org
Received: from verein.lst.de ([213.95.11.211]:52878 "EHLO newverein.lst.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756437AbaIKP1q (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 11 Sep 2014 11:27:46 -0400
Date: Thu, 11 Sep 2014 17:27:43 +0200
From: Christoph Hellwig <hch@lst.de>
To: Anna Schumaker <Anna.Schumaker@netapp.com>
Cc: Christoph Hellwig <hch@lst.de>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH 3/4] pnfs/blocklayout: allocate separate pages for the
	layoutcommit payload
Message-ID: <20140911152743.GE6690@lst.de>
References: <1410395791-2385-1-git-send-email-hch@lst.de> <1410395791-2385-4-git-send-email-hch@lst.de> <5411AED8.4020204@Netapp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
In-Reply-To: <5411AED8.4020204@Netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Sep 11, 2014 at 10:16:56AM -0400, Anna Schumaker wrote:
> > +		arg->layoutupdate_pages =
> > +			kcalloc(DIV_ROUND_UP(buffer_size, PAGE_SIZE),
> > +				sizeof(struct page *), GFP_NOFS);
> 
> I don't think I've seen kcalloc() before.  What does it do?

The same as calloc(3) in userspace - allocate an array of nent entries
of size, and zero the result that is returned.

> >  	dprintk("%s found %i ranges\n", __func__, count);
> 
> I'm getting this:
> 
> fs/nfs/blocklayout/extent_tree.c: In function ‘ext_tree_prepare_commit’:
> fs/nfs/blocklayout/extent_tree.c:565:2: warning: format ‘%i’ expects argument of type ‘int’, but argument 3 has type ‘size_t’ [-Wformat=]
>   dprintk("%s found %i ranges\n", __func__, count);

For some reason I haven't managed to trigger this warning even after
turning on CONFIG_SUNRPC_DEBUG, but it should be easy to fix up..

