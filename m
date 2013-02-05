Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:39036 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754462Ab3BEPPG (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 5 Feb 2013 10:15:06 -0500
Date: Tue, 5 Feb 2013 10:15:05 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Jeff Layton <jlayton@redhat.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH v2 0/8] nfsd: duplicate reply cache overhaul
Message-ID: <20130205151505.GE9886@fieldses.org>
References: <1359983887-28535-1-git-send-email-jlayton@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1359983887-28535-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Feb 04, 2013 at 08:17:59AM -0500, Jeff Layton wrote:
> This patchset is a first pass at fixing this. Instead of simply keeping
> a cache of the last 1024 entries, it allows nfsd to grow and shrink the
> DRC dynamically.

One other thing I think we should try is to organize the cache per
client address and evict cache entries from clients with more entries
first, on the theory that:

	- There are diminishing returns from keeping huge numbers of
	  entries from a single client: a client that has sent us lots
	  of new requests is likely to have processed replies to the
	  older ones.

	- We should still try to hang on to a few of the most recent
	  entries from a client that hasn't made any requests recently,
	  because such a client may have just temporarily lost contact,
	  in which case it's particularly likely to need to retry a
	  request, and we don't want its entries pushed out by clients
	  that remain active.

--b.
