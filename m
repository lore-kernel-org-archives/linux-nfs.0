Return-Path: linux-nfs-owner@vger.kernel.org
Received: from bombadil.infradead.org ([198.137.202.9]:54283 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932865AbaGQOzg (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 17 Jul 2014 10:55:36 -0400
Date: Thu, 17 Jul 2014 07:55:34 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Jeff Layton <jeff.layton@primarydata.com>
Cc: Christoph Hellwig <hch@infradead.org>, bfields@fieldses.org,
        linux-nfs@vger.kernel.org
Subject: Re: [PATCH v2 06/10] nfsd: Protect the nfs4_file delegation fields
 using the fi_lock
Message-ID: <20140717145534.GA21127@infradead.org>
References: <1405521125-2303-1-git-send-email-jlayton@primarydata.com>
 <1405521125-2303-7-git-send-email-jlayton@primarydata.com>
 <20140716180943.GA6920@infradead.org>
 <20140716150401.00757454@tlielax.poochiereds.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20140716150401.00757454@tlielax.poochiereds.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Jul 16, 2014 at 03:04:01PM -0400, Jeff Layton wrote:
> Hmm...maybe. It's a very unlikely race though, and I think the same
> sort of race exists today. In fact, it's worse today since we don't do
> any checking of the validity of the lease after acquiring it now.
> 
> The flag sounds like a good idea, but the code is structured completely
> wrong for it currently. The delegation is only hashed after we get a
> lease, so the lease break wouldn't find anything to set a flag on.
> 
> Quite frankly, I _really_ do not want to have to rework the locking in
> the delegation code yet again. I think this scheme is an improvement
> over what we have now, even if it's not 100% perfect.
> 
> Once we get the scalability set done, I'd like to go back and overhaul
> the delegation code. There are a lot of ugly warts here, but fixing
> them is really a separate project in its own right.

But in the old code we had the client lock over all of this, right?

Anyway, if Bruce and you are fine with this I'm not going to block it,
although it seems a little incomplete to me.
