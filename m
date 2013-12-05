Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:32845 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932075Ab3LENg7 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 5 Dec 2013 08:36:59 -0500
Date: Thu, 5 Dec 2013 08:36:27 -0500
From: Jeff Layton <jlayton@redhat.com>
To: Christoph Hellwig <hch@infradead.org>
Cc: linux-nfs@vger.kernel.org, "J. Bruce Fields" <bfields@fieldses.org>,
        Dave Chinner <dchinner@redhat.com>
Subject: Re: [PATCH RFC 2/3] list_lru: add a new LRU_SKIP_REST lru_status
 value and handling
Message-ID: <20131205083627.07a76b6b@tlielax.poochiereds.net>
In-Reply-To: <20131205133008.GD3381@infradead.org>
References: <1386241253-5781-1-git-send-email-jlayton@redhat.com>
	<1386241253-5781-3-git-send-email-jlayton@redhat.com>
	<20131205133008.GD3381@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 5 Dec 2013 05:30:08 -0800
Christoph Hellwig <hch@infradead.org> wrote:

> On Thu, Dec 05, 2013 at 06:00:52AM -0500, Jeff Layton wrote:
> > The current list_lru_walk_node implementation always walks the entire
> > list. In some cases, we can be sure that when an entry isn't freeable
> > that none of the rest of the entries on the list will be either.
> > 
> > Create a new LRU_SKIP_REST return value that not only indicates that
> > the current entry was skipped, but that caller should stop scanning
> > the current node.
> > 
> > Signed-off-by: Jeff Layton <jlayton@redhat.com>
> 
> I'd call it LRU_DONE, but otherwise this looks fine to me.
> 

Ok, if we end up taking this in I'll change the name...

Thanks,
-- 
Jeff Layton <jlayton@redhat.com>
