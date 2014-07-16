Return-Path: linux-nfs-owner@vger.kernel.org
Received: from bombadil.infradead.org ([198.137.202.9]:53336 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934736AbaGPSLg (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 16 Jul 2014 14:11:36 -0400
Date: Wed, 16 Jul 2014 11:11:35 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Jeff Layton <jlayton@primarydata.com>
Cc: bfields@fieldses.org, hch@infradead.org, linux-nfs@vger.kernel.org
Subject: Re: [PATCH v2 10/10] nfsd: Convert delegation counter to an
 atomic_long_t type
Message-ID: <20140716181135.GC6920@infradead.org>
References: <1405521125-2303-1-git-send-email-jlayton@primarydata.com>
 <1405521125-2303-11-git-send-email-jlayton@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1405521125-2303-11-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Jul 16, 2014 at 10:32:05AM -0400, Jeff Layton wrote:
> From: Trond Myklebust <trond.myklebust@primarydata.com>
> 
> We want to convert to an atomic type so that we don't need to lock
> across the call to alloc_init_deleg(). Then convert to a long type so
> that we match the size of 'max_delegations'.
> 
> None of this is a problem today, but it will be once we remove
> client_mutex protection.
> 
> Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>

Looks good,

Reviewed-by: Christoph Hellwig <hch@lst.de>
