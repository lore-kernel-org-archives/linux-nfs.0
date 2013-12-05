Return-Path: linux-nfs-owner@vger.kernel.org
Received: from bombadil.infradead.org ([198.137.202.9]:48177 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932222Ab3LEN1T (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 5 Dec 2013 08:27:19 -0500
Date: Thu, 5 Dec 2013 05:27:17 -0800
From: Christoph Hellwig <hch@infradead.org>
To: Jeff Layton <jlayton@redhat.com>
Cc: linux-nfs@vger.kernel.org, Christoph Hellwig <hch@infradead.org>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        Dave Chinner <dchinner@redhat.com>
Subject: Re: [PATCH RFC 0/3] nfsd: convert nfsd DRC code to use list_lru
 infrastructure
Message-ID: <20131205132717.GB3381@infradead.org>
References: <1386241253-5781-1-git-send-email-jlayton@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1386241253-5781-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Dec 05, 2013 at 06:00:50AM -0500, Jeff Layton wrote:
> This patchset converts the LRU list in the nfsd duplicate reply cache to
> use the new list_lru infrastrucure. Note that this is based on top of
> the patch that I sent to Bruce earlier this week that fixes the
> svc_cacherep direct reclaim bug. I'm sending this as an RFC since I'm
> not 100% convinced it's an improvement.
> 
> The majorly unintuitive thing about list_lru that I've found is that
> you can't call call list_lru_del from list_lru_walk. So, you need
> different routines to free an object depending on how it's being freed.

That's because list_lru_walk already does all the accounting.  You can
simply do an list_del_init and then return LRU_MOVED and you're done.

