Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from verein.lst.de ([213.95.11.211]:35106 "EHLO newverein.lst.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751084AbbLJQbF (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 10 Dec 2015 11:31:05 -0500
Date: Thu, 10 Dec 2015 17:31:02 +0100
From: Christoph Hellwig <hch@lst.de>
To: Jeff Layton <jlayton@poochiereds.net>
Cc: Christoph Hellwig <hch@lst.de>, bfields@fieldses.org,
        linux-nfs@vger.kernel.org, Kinglong Mee <kinglongmee@gmail.com>
Subject: Re: [RFC PATCH 2/2] nfsd: give up on CB_LAYOUTRECALLs after two
	lease periods
Message-ID: <20151210163102.GA29300@lst.de>
References: <1449577428-13181-1-git-send-email-jeff.layton@primarydata.com> <1449577428-13181-3-git-send-email-jeff.layton@primarydata.com> <20151208152123.GB4035@lst.de> <20151208104610.6e3eae3f@tlielax.poochiereds.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20151208104610.6e3eae3f@tlielax.poochiereds.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Dec 08, 2015 at 10:46:10AM -0500, Jeff Layton wrote:
> > This looks reasonable to me, but I'll need to actually test it
> > before giving an ACK.
> > 
> 
> Please do, I don't have a good way to test this at the moment...

Looks like the baseline got broken once again, so I'll need some time
to track that down first.

> > Btw, it seems like the delegation and layoutrecall code would benefit
> > from some more code sharing for timeouts.  For example delegation
> > returns currently don't support NFS4ERR_DELAY at all.
> 
> Yes...
> 
> I also wonder -- are we handling revoked layouts correctly? Shouldn't
> we be handling revoked layouts like we would a revoked delegation? Stop
> allowing the stateid to be used and morph it appropriately so that a
> TEST_STATEID against it gives you an error?

Probably, but I'd need to take a deeper look at this.
