Return-Path: linux-nfs-owner@vger.kernel.org
Received: from bombadil.infradead.org ([198.137.202.9]:38868 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751496Ab3LCKZT (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 3 Dec 2013 05:25:19 -0500
Date: Tue, 3 Dec 2013 02:25:17 -0800
From: Christoph Hellwig <hch@infradead.org>
To: Jeff Layton <jlayton@redhat.com>
Cc: bfields@fieldses.org, hch@infradead.org, gartim@gmail.com,
        linux-nfs@vger.kernel.org
Subject: Re: [PATCH] nfsd: when reusing an existing repcache entry, unhash it
 first
Message-ID: <20131203102517.GA12576@infradead.org>
References: <1386015979-27511-1-git-send-email-jlayton@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1386015979-27511-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Dec 02, 2013 at 03:26:19PM -0500, Jeff Layton wrote:
> The DRC code will attempt to reuse an existing, expired cache entry in
> preference to allocating a new one. It'll then search the cache, and if
> it gets a hit it'll then free the cache entry that it was going to
> reuse.
> 
> The cache code doesn't unhash the entry that it's going to reuse
> however, so it's possible for it end up designating an entry for reuse
> and then subsequently freeing the same entry after it finds it.  This
> leads it to a later use-after-free situation and usually some list
> corruption warnings or an oops.
> 
> Fix this by simply unhashing the entry that we intend to reuse. That
> will mean that it's not findable via a search and should prevent this
> situation from occurring.

The fix looks reasonable to me,

Reviewed-by: Christoph Hellwig <hch@lst.de>

Btw, it seems like this code would benefit from being converted to
the list_lru structure.
