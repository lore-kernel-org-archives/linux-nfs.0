Return-Path: linux-nfs-owner@vger.kernel.org
Received: from bombadil.infradead.org ([198.137.202.9]:45019 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758043AbaGOKAj (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 15 Jul 2014 06:00:39 -0400
Date: Tue, 15 Jul 2014 03:00:36 -0700
From: Christoph Hellwig <hch@infradead.org>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Jeff Layton <jeff.layton@primarydata.com>,
        Christoph Hellwig <hch@infradead.org>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH 00/11] nfsd: deny mode handling overhaul
Message-ID: <20140715100036.GA32138@infradead.org>
References: <1405015655-12469-1-git-send-email-jlayton@primarydata.com>
 <20140710201448.GF26561@fieldses.org>
 <20140711074656.GA17661@infradead.org>
 <20140711143128.GA7305@fieldses.org>
 <20140711114227.2902a15e@tlielax.poochiereds.net>
 <20140713114244.GA30809@infradead.org>
 <20140713075250.18677c29@tlielax.poochiereds.net>
 <20140714133810.GC17956@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20140714133810.GC17956@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Jul 14, 2014 at 09:38:10AM -0400, J. Bruce Fields wrote:
> > That should be doable as long as we're ok with adding in superfluous
> > spinlocking until the client_mutex is removed.
> 
> It means that an attempt to bisect any race introduced by the series
> will land on the one patch that drops the state lock.
> 
> But maybe that's the best we can do.

That's pretty much exactly how all the earlier series are structured as
well.

