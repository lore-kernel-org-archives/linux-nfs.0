Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:41368 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752454Ab2DWNeS (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 23 Apr 2012 09:34:18 -0400
Date: Mon, 23 Apr 2012 09:34:12 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Jeff Layton <jlayton@redhat.com>
Cc: Miklos Szeredi <miklos@szeredi.hu>, Malahal Naineni <malahal@us.ibm.com>,
        Steve Dickson <SteveD@redhat.com>, linux-fsdevel@vger.kernel.org,
        linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org,
        viro@zeniv.linux.org.uk, hch@infradead.org,
        michael.brantley@deshaw.com, sven.breuner@itwm.fraunhofer.de,
        chuck.lever@oracle.com, pstaubach@exagrid.com,
        trond.myklebust@fys.uio.no, rees@umich.edu
Subject: Re: [PATCH RFC v3] vfs: make fstatat retry once on ESTALE errors
 from getattr call
Message-ID: <20120423133412.GB13681@fieldses.org>
References: <1334316311-22331-1-git-send-email-jlayton@redhat.com>
 <1334749927-26138-1-git-send-email-jlayton@redhat.com>
 <20120420104055.511e15bc@tlielax.poochiereds.net>
 <4F91C49D.8070908@RedHat.com>
 <20120420203725.GA3512@us.ibm.com>
 <20120420171314.73801874@corrin.poochiereds.net>
 <CAJfpegt40cgMJQQo3JuNaaS1w957Y2a_NxVoyvx3bmTMj1TGOA@mail.gmail.com>
 <20120423080012.7c23ef24@tlielax.poochiereds.net>
 <20120423130009.GA13681@fieldses.org>
 <20120423091255.00f926c4@tlielax.poochiereds.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20120423091255.00f926c4@tlielax.poochiereds.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Apr 23, 2012 at 09:12:55AM -0400, Jeff Layton wrote:
> On Mon, 23 Apr 2012 09:00:09 -0400
> "J. Bruce Fields" <bfields@fieldses.org> wrote:
> 
> > On Mon, Apr 23, 2012 at 08:00:12AM -0400, Jeff Layton wrote:
> > > On Sun, 22 Apr 2012 07:40:57 +0200
> > > Miklos Szeredi <miklos@szeredi.hu> wrote:
> > > 
> > > > On Fri, Apr 20, 2012 at 11:13 PM, Jeff Layton <jlayton@redhat.com> wrote:
> > > > > On Fri, 20 Apr 2012 15:37:26 -0500
> > > > > Malahal Naineni <malahal@us.ibm.com> wrote:
> > > > >
> > > > >> Steve Dickson [SteveD@redhat.com] wrote:
> > > > >> > > 2) if we assume that it is fairly representative of one, how can we
> > > > >> > > achieve retrying indefinitely with NFS, or at least some large finite
> > > > >> > > amount?
> > > > >> > The amount of looping would be peer speculation. If the problem can
> > > > >> > not be handled by one simple retry I would say we simply pass the
> > > > >> > error up to the app... Its an application issue...
> > > > >>
> > > > >> As someone said, ESTALE is an incorrect errno for a path based call.
> > > > >> How about turning ESTALE into ENOENT after a retry or few retries?
> > > > >>
> > > > >
> > > > > It's not really the same thing. One could envision an application
> > > > > that's repeatedly renaming a new file on top of another one. The file
> > > > > is never missing from the namespace of the server, but you could still
> > > > > end up getting an ESTALE.
> > > > >
> > > > > That would break other atomicity guarantees in an even worse way, IMO...
> > > > 
> > > > For directory operations ESTALE *is* equivalent to ENOENT if already
> > > > retrying with LOOKUP_REVAL.  Think about it.  Atomic replacement by
> > > > another directory with rename(2) is not an excuse here actually.
> > > > Local filesystems too can end up with IS_DEAD directory after lookup
> > > > in that case.
> > > > 
> > > 
> > > Doesn't that violate POSIX? rename(2) is supposed to be atomic, and I
> > > can't see where there's any exception for that for directories.
> > 
> > Hm, but that only allows atomic replacement of the last component of a
> > path.
> > 
> > Suppose you're looking up a path, you've so far reached intermediate
> > directory "D", and the next step of the lookup (of some entry in D)
> > returns ESTALE.  Then either:
> > 
> > 	- D has since been unlinked, and ENOENT is obviously right.
> > 	- D was unlinked and then replaced by something else, in which
> > 	  case there was still a moment when ENOENT was correct.
> > 	- D was replaced atomically by a rename.  But for the rename to
> > 	  work it must have been replacing an empty directory, so there
> > 	  was still a moment when ENOENT would have been correct.
> 
> I don't think so...D should always exist in the namespace, so ENOENT
> would not be correct.

The operation above is a lookup in D, not a lookup of D.

> Just because it was empty doesn't mean that it
> didn't exist...
> 
> > 	  (Exception: if D was actually a regular file or some other
> > 	  non-directory object, then ENOTDIR would be the right error:
> > 	  but if you're able to get at least object type atomically with
> > 	  a lookup, then you should have noticed this already on lookup
> > 	  of D.)
> > 
> > I think that's what Miklos meant?
> > 
> > --b.
> 
> Here's an example -- suppose we have two directories: /foo
> and /bar. /bar is empty. We call:
> 
>     rename("/foo","/bar");
> 
> ...and at the same time, someone is calling:
> 
>     stat("/bar");
> 
> ...the calls race and in this condition the stat() gets ESTALE back
> -- /bar got replaced after we did the lookup.
> 
> According to POSIX, the name "/bar" should never be absent from the
> namespace in this situation, so I'm not sure I understand why returning
> ENOENT here would be acceptable.

Yes, agreed, my assertion was just that an ESTALE on a lookup of a
non-final component is probably equivalent to ENOENT.

I'm not sure if that's what Miklos meant.

--b.
