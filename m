Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:62148 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932383Ab1KBPyU (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 2 Nov 2011 11:54:20 -0400
Date: Wed, 2 Nov 2011 11:54:53 -0400
From: Jeff Layton <jlayton@redhat.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: "Myklebust, Trond" <Trond.Myklebust@netapp.com>,
        "J. Bruce Fields" <bfields@redhat.com>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH] nfs: open-associated setattr shouldn't invalidate own
 cache
Message-ID: <20111102115453.7e81168f@corrin.poochiereds.net>
In-Reply-To: <20111102144657.GD7721@fieldses.org>
References: <02f301cc45a8$1ad15db6$78be630a@hq.netapp.com>
	<20111101202715.GB1891@fieldses.org>
	<2E1EB2CF9ED1CB4AA966F0EB76EAB4430BDE7BC5@SACMVEXC2-PRD.hq.netapp.com>
	<20111101204325.522c35b3@corrin.poochiereds.net>
	<20111102012315.GA5532@fieldses.org>
	<20111102070742.5354d83c@tlielax.poochiereds.net>
	<20111102144657.GD7721@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, 2 Nov 2011 10:46:57 -0400
"J. Bruce Fields" <bfields@fieldses.org> wrote:

> On Wed, Nov 02, 2011 at 07:07:42AM -0400, Jeff Layton wrote:
> > On Tue, 1 Nov 2011 21:23:15 -0400
> > "J. Bruce Fields" <bfields@fieldses.org> wrote:
> > 
> > > On Tue, Nov 01, 2011 at 08:43:25PM -0400, Jeff Layton wrote:
> > > > On Tue, 1 Nov 2011 16:07:27 -0700
> > > > "Myklebust, Trond" <Trond.Myklebust@netapp.com> wrote:
> > > > > Is the problem perhaps that we should be clearing the
> > > > > NFS_INO_INVALID_DATA flag in nfs_vmtruncate() when the size gets set to
> > > > > zero?
> > > > > 
> > > > 
> > > > That was my thinking too. Whenever we truncate the i_size to 0, we
> > > > can safely assume that the pagecache is now valid, and should be able
> > > > to clear NFS_INO_INVALID_DATA no matter when it was set, right?
> > > 
> > > I don't understand why 0 is a special case: why should my setting the
> > > size ever mean that I have to go reread data from the server?
> > > 
> > 
> > If the server doesn't send pre-op attrs (and linux servers don't) then
> > you have no way to know whether someone raced in and did writes to the
> > remaining pages just prior to your truncate.
> > 
> > Size 0 is a special case because there are no remaining pages.
> 
> Those 3rd-party writes could also arrive between the truncate and the
> read of the post-op attrs.  Is this setattr/write conflict really any
> different than write/write conflicts?  In both cases you've got a file
> open for write on two different clients.
> 
> And we live with the same sort of race in the write/write case.  (Hence
> the nfs_post_op_update_inode_force_wcc in nfs4_write_done_cb.)
> 


Yes, I think it is different. When we truncate the file to 0 then we
don't care if another write races in. We're invalidating all of the
pages we have cached for the file at that point anyway. If we try to
reread the file afterward we're going to have to fetch the data from
the server regardless.

I guess my main point is that we won't have any cached data after a
truncate to 0, so there's no need to worry about ensuring that the
cache is eventually invalidated after that. The VFS-level truncate on
the client is going to take care of that for us anyway. That allows us
to optimize for this special (but common) case.

A truncate to a non-zero size is different however because we may still
have lingering cached pages. We will need to invalidate those if the
server sends pre-op attrs that indicate that something else happened
prior to the truncate, or if the server doesn't send pre-op attrs at
all.

-- 
Jeff Layton <jlayton@redhat.com>
