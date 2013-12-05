Return-Path: linux-nfs-owner@vger.kernel.org
Received: from bombadil.infradead.org ([198.137.202.9]:48185 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755863Ab3LEN3U (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 5 Dec 2013 08:29:20 -0500
Date: Thu, 5 Dec 2013 05:29:19 -0800
From: Christoph Hellwig <hch@infradead.org>
To: Jeff Layton <jlayton@redhat.com>
Cc: linux-nfs@vger.kernel.org, Christoph Hellwig <hch@infradead.org>,
        "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH RFC 1/3] nfsd: don't try to reuse an expired DRC entry
 off the list
Message-ID: <20131205132919.GC3381@infradead.org>
References: <1386241253-5781-1-git-send-email-jlayton@redhat.com>
 <1386241253-5781-2-git-send-email-jlayton@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1386241253-5781-2-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Dec 05, 2013 at 06:00:51AM -0500, Jeff Layton wrote:
> Currently when we are processing a request, we try to scrape an expired
> or over-limit entry off the list in preference to allocating a new one
> from the slab.
> 
> This is unnecessarily complicated. Just use the slab layer.

I really don't think pruning caches from lookup functions is a good
idea. To many chances for locking inversions, unbounded runtime and
other issues.  So I'd prefer my earlier version of the patch to
remove it entirely if we want to change anything beyond your minimal
fix.

