Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:51719 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751230Ab1KCUov (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 3 Nov 2011 16:44:51 -0400
Date: Thu, 3 Nov 2011 16:44:49 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Jeff Layton <jlayton@redhat.com>
Cc: "Myklebust, Trond" <Trond.Myklebust@netapp.com>,
        "J. Bruce Fields" <bfields@redhat.com>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH] nfs: open-associated setattr shouldn't invalidate own
 cache
Message-ID: <20111103204449.GA27393@fieldses.org>
References: <02f301cc45a8$1ad15db6$78be630a@hq.netapp.com>
 <20111101202715.GB1891@fieldses.org>
 <2E1EB2CF9ED1CB4AA966F0EB76EAB4430BDE7BC5@SACMVEXC2-PRD.hq.netapp.com>
 <20111101204325.522c35b3@corrin.poochiereds.net>
 <20111102012315.GA5532@fieldses.org>
 <20111102070742.5354d83c@tlielax.poochiereds.net>
 <20111102144657.GD7721@fieldses.org>
 <20111102115453.7e81168f@corrin.poochiereds.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20111102115453.7e81168f@corrin.poochiereds.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

I'm feeling dense.

On Wed, Nov 02, 2011 at 11:54:53AM -0400, Jeff Layton wrote:
> Yes, I think it is different. When we truncate the file to 0 then we
> don't care if another write races in.

	Client 1		Client 2
	--------		--------

	setattr size to 0
				write to file
	get change attribute

If we decide not to invalidate the cache here, then we miss Client 2's
write.  The same is true if we set the size to something other than 0.

There's a second possible race when Client 2's write comes before the
setattr, and it's true that that race doesn't matter in the size-0 case
and does in the other.

But if we were doing a write instead of a setattr, we'd ignore that
second race.

And I don't understand why something like ftruncate should be treated
differently from write.  In either case we're modifying a file while
holding a write open, and I'd expect us to assume in both cases that
nobody else is doing the same.

> We're invalidating all of the
> pages we have cached for the file at that point anyway. If we try to
> reread the file afterward we're going to have to fetch the data from
> the server regardless.
> 
> I guess my main point is that we won't have any cached data after a
> truncate to 0, so there's no need to worry about ensuring that the
> cache is eventually invalidated after that. The VFS-level truncate on
> the client is going to take care of that for us anyway. That allows us
> to optimize for this special (but common) case.
> 
> A truncate to a non-zero size is different however because we may still
> have lingering cached pages. We will need to invalidate those if the
> server sends pre-op attrs

There are no pre-op attrs: the Linux v4 client's write compound is
putfh, write, getattr, with no getattr before the write, and the
nfs_post_op_update_inode_force_wcc() call in nfs4_write_done_cb() makes
the client pretends there were pre-op attributes the same as whatever it
currently has cached in the inode--if I understand it right.

--b.

> that indicate that something else happened
> prior to the truncate, or if the server doesn't send pre-op attrs at
> all.
