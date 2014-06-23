Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:49198 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754611AbaFWOLS (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 23 Jun 2014 10:11:18 -0400
Date: Mon, 23 Jun 2014 10:11:14 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Jeff Layton <jeff.layton@primarydata.com>
Cc: Christoph Hellwig <hch@infradead.org>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH v1 000/104] nfsd: eliminate the client_mutex
Message-ID: <20140623141114.GB22025@fieldses.org>
References: <1403189450-18729-1-git-send-email-jlayton@primarydata.com>
 <20140623133926.GA32746@infradead.org>
 <20140623095645.1fc23e9c@tlielax.poochiereds.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20140623095645.1fc23e9c@tlielax.poochiereds.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Jun 23, 2014 at 09:56:45AM -0400, Jeff Layton wrote:
> On Mon, 23 Jun 2014 06:39:26 -0700
> Christoph Hellwig <hch@infradead.org> wrote:
> 
> > Hi Jeff,
> > 
> > thanks for bringing this forward.  I've started looking at the series,
> > but I'm a little overwhelmed as it's growing bigger and bigger with
> > each posting.  That also makes me a little worried about putting all
> > of it into 3.17.  I know you've started separating a few bits out and
> > some of those actually went into 3.16, but maybe we really should
> > start to some easier to split piece in first and make sure they get
> > into 3.17 and then see if we can get through the rest of it in time.
> > 
> 
> Thanks for taking a look. The big problem with breaking this set up is
> that it will likely result in at least some performance regression in
> the interim. We're adding more granular locking inside of the
> coarse-grained client_mutex, which is likely to mean at least some
> slowdown until the client_mutex is removed. Maybe that's worth it
> though.

I also don't know if the in-between state (when we have both new and old
locking) is very interesting to test.

> 
> > Besides the obvious fixes for bits that were racy before and don't
> > just need better scalability one thing that strikes to mind are some
> > of the higher level logic changes, like the changes fixes to various
> > stateowner / stateid relations.
> > 
> 
> I'll have to think about how to break those out. Unfortunately, there
> are strong dependencies between some of those changes, which makes it
> hard to do this in pieces.

But, yes, if there's anything here it would be possible to take first
that would help....

--b.
