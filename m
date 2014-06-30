Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:52991 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756501AbaF3Tck (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 30 Jun 2014 15:32:40 -0400
Date: Mon, 30 Jun 2014 15:32:37 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Jeff Layton <jeff.layton@primarydata.com>
Cc: Christoph Hellwig <hch@infradead.org>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH v2 000/117] nfsd: eliminate the client_mutex
Message-ID: <20140630193237.GA11935@fieldses.org>
References: <1403810017-16062-1-git-send-email-jlayton@primarydata.com>
 <20140630125142.GA32089@infradead.org>
 <20140630085934.2bf86ba0@tlielax.poochiereds.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20140630085934.2bf86ba0@tlielax.poochiereds.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Jun 30, 2014 at 08:59:34AM -0400, Jeff Layton wrote:
> On Mon, 30 Jun 2014 05:51:42 -0700
> Christoph Hellwig <hch@infradead.org> wrote:
> 
> > I'm pretty happy with what's the first 25 patches in this version
> > with all the review comments addressed, so as far as I'm concerned
> > these are ready for for-next.  Does anyone else plan to do a review
> > as well?
> > 
> 
> Thanks very much for the review so far.
> 
> > I'll try to get to the locking changes as well soon, but I've got some
> > work keeping me fairly busy at the moment.  I guess it wasn't easily
> > feasible to move the various stateid refcounting to before the major
> > locking changes?
> > 
> 
> Not really. If I had done the set from scratch I would have probably
> done that instead, but Trond's original had those changes interleaved.
> Separating them would be a lot of work that I'd prefer to avoid.
> 
> > Btw, do you have any benchrmarks showing the improvements of the new
> > locking scheme?
> 
> No, I'm hoping to get those numbers soon from our QA folks. Most of the
> testing I've done has been for correctness and stability. I'm pretty
> happy with things at that end now, but I don't have any numbers that
> show whether and how much this helps scalability.

The open-create problem at least shouldn't be hard to confirm.

It's also the only problem I've actually seen a complaint about--I do
wish it were possible to do just the minimum required to fix that before
doing all the rest.

--b.
