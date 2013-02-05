Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:43346 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756047Ab3BEP6K (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 5 Feb 2013 10:58:10 -0500
Date: Tue, 5 Feb 2013 10:58:04 -0500
From: Jeff Layton <jlayton@redhat.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH v2 0/8] nfsd: duplicate reply cache overhaul
Message-ID: <20130205105804.0c15bdaa@tlielax.poochiereds.net>
In-Reply-To: <20130205151505.GE9886@fieldses.org>
References: <1359983887-28535-1-git-send-email-jlayton@redhat.com>
	<20130205151505.GE9886@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 5 Feb 2013 10:15:05 -0500
"J. Bruce Fields" <bfields@fieldses.org> wrote:

> On Mon, Feb 04, 2013 at 08:17:59AM -0500, Jeff Layton wrote:
> > This patchset is a first pass at fixing this. Instead of simply keeping
> > a cache of the last 1024 entries, it allows nfsd to grow and shrink the
> > DRC dynamically.
> 
> One other thing I think we should try is to organize the cache per
> client address and evict cache entries from clients with more entries
> first, on the theory that:
> 
> 	- There are diminishing returns from keeping huge numbers of
> 	  entries from a single client: a client that has sent us lots
> 	  of new requests is likely to have processed replies to the
> 	  older ones.
> 

Ok, but you'd need to be careful here. You don't want to drop any entry
before the client has had a chance to retransmit the request, but we
don't have a way to know what timeo= value the client is using.

> 	- We should still try to hang on to a few of the most recent
> 	  entries from a client that hasn't made any requests recently,
> 	  because such a client may have just temporarily lost contact,
> 	  in which case it's particularly likely to need to retry a
> 	  request, and we don't want its entries pushed out by clients
> 	  that remain active.
> 

Sounds tricky to get the heuristics right, but interesting. Maybe we
can try to hash them out while we're at cthon?

-- 
Jeff Layton <jlayton@redhat.com>
