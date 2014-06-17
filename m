Return-Path: linux-nfs-owner@vger.kernel.org
Received: from bombadil.infradead.org ([198.137.202.9]:38237 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932609AbaFQNwV (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 17 Jun 2014 09:52:21 -0400
Date: Tue, 17 Jun 2014 06:52:19 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Jeff Layton <jlayton@primarydata.com>
Cc: bfields@fieldses.org, linux-nfs@vger.kernel.org, hch@infradead.org
Subject: Re: [PATCH v2 1/4] nfsd: add __force to opaque verifier field casts
Message-ID: <20140617135219.GA13980@infradead.org>
References: <1403005454-7319-1-git-send-email-jlayton@primarydata.com>
 <1403005454-7319-2-git-send-email-jlayton@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1403005454-7319-2-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Jun 17, 2014 at 07:44:11AM -0400, Jeff Layton wrote:
> sparse complains that we're stuffing non-byte-swapped values into
> __be32's here. Since they're supposed to be opaque, it doesn't matter
> much. Just add __force to make sparse happy.
> 
> Signed-off-by: Jeff Layton <jlayton@primarydata.com>

Looks good,

Reviewed-by: Christoph Hellwig <hch@lst.de>
