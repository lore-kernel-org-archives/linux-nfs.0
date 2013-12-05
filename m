Return-Path: linux-nfs-owner@vger.kernel.org
Received: from bombadil.infradead.org ([198.137.202.9]:48192 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755863Ab3LENaI (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 5 Dec 2013 08:30:08 -0500
Date: Thu, 5 Dec 2013 05:30:08 -0800
From: Christoph Hellwig <hch@infradead.org>
To: Jeff Layton <jlayton@redhat.com>
Cc: linux-nfs@vger.kernel.org, Christoph Hellwig <hch@infradead.org>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        Dave Chinner <dchinner@redhat.com>
Subject: Re: [PATCH RFC 2/3] list_lru: add a new LRU_SKIP_REST lru_status
 value and handling
Message-ID: <20131205133008.GD3381@infradead.org>
References: <1386241253-5781-1-git-send-email-jlayton@redhat.com>
 <1386241253-5781-3-git-send-email-jlayton@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1386241253-5781-3-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Dec 05, 2013 at 06:00:52AM -0500, Jeff Layton wrote:
> The current list_lru_walk_node implementation always walks the entire
> list. In some cases, we can be sure that when an entry isn't freeable
> that none of the rest of the entries on the list will be either.
> 
> Create a new LRU_SKIP_REST return value that not only indicates that
> the current entry was skipped, but that caller should stop scanning
> the current node.
> 
> Signed-off-by: Jeff Layton <jlayton@redhat.com>

I'd call it LRU_DONE, but otherwise this looks fine to me.

