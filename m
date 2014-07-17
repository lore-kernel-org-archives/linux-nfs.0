Return-Path: linux-nfs-owner@vger.kernel.org
Received: from bombadil.infradead.org ([198.137.202.9]:37009 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755420AbaGQJWX (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 17 Jul 2014 05:22:23 -0400
Date: Thu, 17 Jul 2014 02:22:22 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Jeff Layton <jeff.layton@primarydata.com>
Cc: Christoph Hellwig <hch@infradead.org>, bfields@fieldses.org,
        linux-nfs@vger.kernel.org
Subject: Re: [PATCH v2 09/10] nfsd: Fix delegation revocation
Message-ID: <20140717092222.GA904@infradead.org>
References: <1405521125-2303-1-git-send-email-jlayton@primarydata.com>
 <1405521125-2303-10-git-send-email-jlayton@primarydata.com>
 <20140716183047.GA19002@infradead.org>
 <20140716151640.6bb42713@tlielax.poochiereds.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20140716151640.6bb42713@tlielax.poochiereds.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Jul 16, 2014 at 03:16:40PM -0400, Jeff Layton wrote:
> > 
> > Seems a little confusing as we didn't turn the code into a REVOKED_DELEG
> > stateid type yet, but given that destroy_revoked_delegation doesn't
> > care this is probably fine.
> > 
> 
> True, but since we're destroying it anyway we don't need to revoke it.
> Still it is less confusing and since I'm respinning for other reasons,
> I can change that too...

It might make sense to just rename it to destroy_delegation and use it
for both types.  There's another opencoded instance later on as well.

> > Reviewed-by: Christoph Hellwig <hch@lst.de>
> > 
> > (would have been a little nicer to read if you had kept
> > destroy_revoked_delegation, otherwise diff obsfucates the fact that it
> > didn't change at all..
> 
> Thanks. Do you mean destroy_delegation? destroy_revoked_delegation
> still exists -- destroy_delegation is removed, but it's just a wrapper
> around nfs4_put_delegation at this point...

I meant keept in the same place.  You added a function above it, and
removed one below it, so diff makes a mess of it despite the function not
changing at all.

