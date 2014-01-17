Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:41282 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751354AbaAQPjr (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 17 Jan 2014 10:39:47 -0500
Date: Fri, 17 Jan 2014 10:39:17 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Christoph Hellwig <hch@infradead.org>
Cc: Al Viro <viro@zeniv.linux.org.uk>, linux-fsdevel@vger.kernel.org,
        linux-kernel@vger.kernel.org, linux-nfs@vger.kernel.org,
        Miklos Szeredi <mszeredi@suse.cz>
Subject: Re: [PATCH] dcache: fix d_splice_alias handling of aliases
Message-ID: <20140117153917.GA26636@fieldses.org>
References: <20140115151749.GF23999@fieldses.org>
 <20140117121723.GA18375@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20140117121723.GA18375@infradead.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Jan 17, 2014 at 04:17:23AM -0800, Christoph Hellwig wrote:
> On Wed, Jan 15, 2014 at 10:17:49AM -0500, J. Bruce Fields wrote:
> > From: "J. Bruce Fields" <bfields@redhat.com>
> > 
> > d_splice_alias can create duplicate directory aliases (in the !new
> > case), or (in the new case) d_move without holding appropriate locks.
> > 
> > d_materialise_unique deals with both of these problems.  (The latter
> > seems to be dealt by trylocks (see __d_unalias), which look like they
> > could cause spurious lookup failures--but that's at least better than
> > corrupting the dcache.)
> 
> I'm a bit worried about those spurious failures, maybe we should
> retry in that case?

Maybe so.  I'm not sure how.  d_materialise_unique is called from lookup
and we'd need to at least drop the parent i_mutex to give a concurrent
rename a chance to progress.

I think NFS or cluster filesystem clients could hit this case with:

	host A		host B
	---------	-------------------------
	process 1	process 1	process 2
	---------	---------	---------

			mkdir foo/X
	mv foo/X bar/
			stat bar/X	mv baz qux


When (B,1) looks up X in bar it finds that X still has an alias in foo,
tries to rename that alias to bar/X, but can't because the current
baz->qux rename is holding the rename mutex.  So __d_unalias and the
lookup return -EBUSY.

None of those operations are particularly fast, so I'm a bit surprised
we haven't already heard complaints.  I must be missing some reason this
doesn't happen.  I guess I should set up a test.

> Also looking over the changes I wonder if the explicit cecking for
> aliases for every non-directory might have a major performance impact,
> all the dcache growling already was a major issues in NFS workloads
> years ago and I dumb it's become any better.

This only happens on the first (uncached) lookup.  So we've already
acquired a bunch of locks and probably done a round trip to a disk or a
server--is walking a (typically short) list really something to worry
about?

> Also looking at this area I'd like to suggest that if you end up
> merging the two I'd continue using the d_splice_alias name and
> calling conventions.

OK, I guess I don't care which one we keep.

> Also the inode == NULL case really should be split out from
> d_materialise_unique into a separate helper.  It shares almost no
> code, is entirely undocumented to the point that I don't really
> understand what the purpose is, and the only caller that can get
> there (fuse) already branches around that case in the caller anyway.

I think I see what you mean, I can fix that.

--b.
