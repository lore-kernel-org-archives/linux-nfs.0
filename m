Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:60181 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755630Ab1KBOrB (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 2 Nov 2011 10:47:01 -0400
Date: Wed, 2 Nov 2011 10:46:57 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Jeff Layton <jlayton@redhat.com>
Cc: "Myklebust, Trond" <Trond.Myklebust@netapp.com>,
        "J. Bruce Fields" <bfields@redhat.com>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH] nfs: open-associated setattr shouldn't invalidate own
 cache
Message-ID: <20111102144657.GD7721@fieldses.org>
References: <02f301cc45a8$1ad15db6$78be630a@hq.netapp.com>
 <20111101202715.GB1891@fieldses.org>
 <2E1EB2CF9ED1CB4AA966F0EB76EAB4430BDE7BC5@SACMVEXC2-PRD.hq.netapp.com>
 <20111101204325.522c35b3@corrin.poochiereds.net>
 <20111102012315.GA5532@fieldses.org>
 <20111102070742.5354d83c@tlielax.poochiereds.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20111102070742.5354d83c@tlielax.poochiereds.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Nov 02, 2011 at 07:07:42AM -0400, Jeff Layton wrote:
> On Tue, 1 Nov 2011 21:23:15 -0400
> "J. Bruce Fields" <bfields@fieldses.org> wrote:
> 
> > On Tue, Nov 01, 2011 at 08:43:25PM -0400, Jeff Layton wrote:
> > > On Tue, 1 Nov 2011 16:07:27 -0700
> > > "Myklebust, Trond" <Trond.Myklebust@netapp.com> wrote:
> > > > Is the problem perhaps that we should be clearing the
> > > > NFS_INO_INVALID_DATA flag in nfs_vmtruncate() when the size gets set to
> > > > zero?
> > > > 
> > > 
> > > That was my thinking too. Whenever we truncate the i_size to 0, we
> > > can safely assume that the pagecache is now valid, and should be able
> > > to clear NFS_INO_INVALID_DATA no matter when it was set, right?
> > 
> > I don't understand why 0 is a special case: why should my setting the
> > size ever mean that I have to go reread data from the server?
> > 
> 
> If the server doesn't send pre-op attrs (and linux servers don't) then
> you have no way to know whether someone raced in and did writes to the
> remaining pages just prior to your truncate.
> 
> Size 0 is a special case because there are no remaining pages.

Those 3rd-party writes could also arrive between the truncate and the
read of the post-op attrs.  Is this setattr/write conflict really any
different than write/write conflicts?  In both cases you've got a file
open for write on two different clients.

And we live with the same sort of race in the write/write case.  (Hence
the nfs_post_op_update_inode_force_wcc in nfs4_write_done_cb.)

--b.
