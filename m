From: Jeff Layton <jlayton@redhat.com>
Subject: Re: nfsd: Use vfs_fsync_range() in nfsd_commit
Date: Wed, 17 Mar 2010 15:08:13 -0400
Message-ID: <20100317150813.43815b5a@tlielax.poochiereds.net>
References: <1264796353.3644.4.camel@localhost>
	<20100129205022.GA14449@infradead.org>
	<1264798623.3644.18.camel@localhost>
	<1264799906.3644.21.camel@localhost>
	<20100129212706.GA28361@infradead.org>
	<1264801151.3644.27.camel@localhost>
	<20100129235852.GC30852@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>,
	Christoph Hellwig <hch@infradead.org>,
	linux-nfs@vger.kernel.org
To: "Dr. J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:48667 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753026Ab0CQTIg (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 17 Mar 2010 15:08:36 -0400
In-Reply-To: <20100129235852.GC30852@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 29 Jan 2010 18:58:52 -0500
"Dr. J. Bruce Fields" <bfields@fieldses.org> wrote:

> On Fri, Jan 29, 2010 at 04:39:11PM -0500, Trond Myklebust wrote:
> > On Fri, 2010-01-29 at 16:27 -0500, Christoph Hellwig wrote: 
> > > And not actually touched by your patch, but that is the reason to
> > > open/close the file if we don't actually do anything with it for an
> > > async export?
> > 
> > I must admit that I was wondering about that too. I'm assuming that the
> > reason is to provide consistent behaviour w.r.t. access checks and
> > possibly also to ensure that NFSv4 delegations are revoked. Perhaps
> > Bruce could comment?
> 
> Do delegations need to be revoked on commit?  (And do we care about
> access checks?)
> 
> We could do both without the need for an actual open, but I don't know
> that it matters much either way.
> 

Is there any reason that we need to revoke the delegation on a commit?

The only real effect is that writes would be flushed to stable storage.
The VM on the server could just decide the flush the data to stable
storage whenever it feels like it without revoking the lease. I don't
see why we'd need to revoke the lease just because a client asked for
the flush.

Bruce has already chimed in on it, but a deadlock of sorts has popped
up relating to this:

    https://bugzilla.redhat.com/show_bug.cgi?id=551028#c10

...and it seems like not recalling the delegation on a COMMIT might
help resolve it.

-- 
Jeff Layton <jlayton@redhat.com>
