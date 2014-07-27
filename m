Return-Path: linux-nfs-owner@vger.kernel.org
Received: from bombadil.infradead.org ([198.137.202.9]:58678 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751035AbaG0NmT (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 27 Jul 2014 09:42:19 -0400
Date: Sun, 27 Jul 2014 06:42:18 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Jeff Layton <jlayton@primarydata.com>
Cc: bfields@fieldses.org, linux-nfs@vger.kernel.org, hch@infradead.org
Subject: Re: [PATCH 08/40] nfsd: Add locking to protect the state owner lists
Message-ID: <20140727134218.GA26868@infradead.org>
References: <1405954972-28904-1-git-send-email-jlayton@primarydata.com>
 <1405954972-28904-9-git-send-email-jlayton@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1405954972-28904-9-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Jul 21, 2014 at 11:02:20AM -0400, Jeff Layton wrote:
> Change to using the clp->cl_lock for this. For now, there's a lot of
> cl_lock thrashing, but in later patches we'll eliminate that and close
> the potential races that can occur when releasing the cl_lock while
> walking the lists. For now, the client_mutex prevents those races.

I'll have to look at those later patches, but in general I'd prefer
not to have an intermediate stage like this.  Maybe just merge
the later cleanup in, maybe do some of the required cleanups before
even adding the new locking.

