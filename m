Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:45247 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751082Ab0CYWF4 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 25 Mar 2010 18:05:56 -0400
Date: Thu, 25 Mar 2010 18:07:48 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Cc: Jeff Layton <jlayton@redhat.com>, linux-nfs@vger.kernel.org,
        nfsv4@linux-nfs.org, Trond Myklebust <trond@netapp.com>
Subject: Re: [PATCH] nfsd: don't break lease while servicing a COMMIT call
	(try #2)
Message-ID: <20100325220748.GF8611@fieldses.org>
References: <1269000388-5543-1-git-send-email-jlayton@redhat.com> <20100322194710.GO5359@fieldses.org> <20100322163340.4b3b285f@tlielax.poochiereds.net> <20100325174707.GA4033@fieldses.org> <1269540988.3648.46.camel@localhost.localdomain>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1269540988.3648.46.camel@localhost.localdomain>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Thu, Mar 25, 2010 at 02:16:28PM -0400, Trond Myklebust wrote:
> On Thu, 2010-03-25 at 13:47 -0400, J. Bruce Fields wrote: 
> > On Mon, Mar 22, 2010 at 04:33:40PM -0400, Jeff Layton wrote:
> > > It looks like nfs_inode_return_delegation always calls nfs_msync_inode
> > > on any valid delegation before returning it, regardless of the
> > > delegation type.
> > > 
> > > RFC 3530 says this:
> > > 
> > >    If the client is granted a read delegation, it is assured that no
> > >    other client has the ability to write to the file for the duration of
> > >    the delegation.  If the client is granted a write delegation, the
> > >    client is assured that no other client has read or write access to
> > >    the file.
> > > 
> > > That doesn't seem to imply that we must flush writes before returning
> > > either type of delegation. OTOH, maybe it makes sense to treat those as
> > > cache consistency points since a delegreturn sort of implies that
> > > another client wants to use the file.
> > > 
> > > I'm not quite sure how to interpret the spec here...
> > 
> > If there's that call could cause the client to wait for an actual write
> > to succeed before returning the delegation, then something's wrong.
> 
> We're certainly expected to write back data before returning a write
> delegation (see Section 9.4.4 of RFC 3530).
> 
> For the case of a read delegation, then the spec is silent because it
> contains no discussion of the case where a server grants both an open
> for write and a read delegation. If you want a normative statement on
> what clients should do for that case, then I suggest a discussion on the
> IETF list with a view to getting it into RFC3530-bis.

Yeah, that would be a good idea to get nailed down at some point.

(But the current server implementation doesn't allow write opens in this
situation.  So I wonder why we're seeing any commit from the client at
all?)

--b.
