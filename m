Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([198.137.202.9]:39748 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933888AbbCPS2L (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 16 Mar 2015 14:28:11 -0400
Date: Mon, 16 Mar 2015 11:28:10 -0700
From: Christoph Hellwig <hch@infradead.org>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Christoph Hellwig <hch@infradead.org>,
        Jeff Layton <jeff.layton@primarydata.com>, linux-nfs@vger.kernel.org
Subject: Re: nfsd use after free in 4.0-rc
Message-ID: <20150316182810.GA4690@infradead.org>
References: <20150315125614.GA766@infradead.org>
 <20150315180811.02847842@tlielax.poochiereds.net>
 <20150316114648.GA7432@infradead.org>
 <20150316155845.GC12231@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20150316155845.GC12231@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Mar 16, 2015 at 11:58:45AM -0400, J. Bruce Fields wrote:
> > 3240		list_add(&stp->st_perstateowner, &oo->oo_owner.so_stateids);
> > 3241		spin_lock(&fp->fi_lock);
> > 3242		list_add(&stp->st_perfile, &fp->fi_stateids);
> 
> I assume you're testing only NFS v4.1?

Exactly. I'm testing with a version of this patch applied to force 4.1:

http://git.infradead.org/users/hch/pnfs.git/commitdiff/72ef9b95aaed593ac061bb380bc27ced4fd67b4b
