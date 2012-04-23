Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:37360 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752454Ab2DWNzD (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 23 Apr 2012 09:55:03 -0400
Date: Mon, 23 Apr 2012 09:54:56 -0400
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
Message-ID: <20120423135456.GC13681@fieldses.org>
References: <20120420104055.511e15bc@tlielax.poochiereds.net>
 <4F91C49D.8070908@RedHat.com>
 <20120420203725.GA3512@us.ibm.com>
 <20120420171314.73801874@corrin.poochiereds.net>
 <CAJfpegt40cgMJQQo3JuNaaS1w957Y2a_NxVoyvx3bmTMj1TGOA@mail.gmail.com>
 <20120423080012.7c23ef24@tlielax.poochiereds.net>
 <20120423130009.GA13681@fieldses.org>
 <20120423091255.00f926c4@tlielax.poochiereds.net>
 <20120423133412.GB13681@fieldses.org>
 <20120423095021.1a91a23b@tlielax.poochiereds.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20120423095021.1a91a23b@tlielax.poochiereds.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Apr 23, 2012 at 09:50:21AM -0400, Jeff Layton wrote:
> On Mon, 23 Apr 2012 09:34:12 -0400
> "J. Bruce Fields" <bfields@fieldses.org> wrote:
> 
> > On Mon, Apr 23, 2012 at 09:12:55AM -0400, Jeff Layton wrote:
> > > Here's an example -- suppose we have two directories: /foo
> > > and /bar. /bar is empty. We call:
> > > 
> > >     rename("/foo","/bar");
> > > 
> > > ...and at the same time, someone is calling:
> > > 
> > >     stat("/bar");
> > > 
> > > ...the calls race and in this condition the stat() gets ESTALE back
> > > -- /bar got replaced after we did the lookup.
> > > 
> > > According to POSIX, the name "/bar" should never be absent from the
> > > namespace in this situation, so I'm not sure I understand why returning
> > > ENOENT here would be acceptable.
> > 
> > Yes, agreed, my assertion was just that an ESTALE on a lookup of a
> > non-final component is probably equivalent to ENOENT.
> > 
> > I'm not sure if that's what Miklos meant.
> > 
> 
> Ahh ok, sorry I misunderstood. Yeah in that case I suppose it would
> be ok to replace ESTALE with ENOENT. Ok, so to illustrate...
> 
> Suppose we're trying to stat("/bar/baz") instead in the above example.
> Then we could just return ENOENT instead on an ESTALE return for the
> reasons that Bruce outlined. If the dir was stale, then there was a
> at least one point in time where we *know* that "baz" didn't exist.
> 
> That doesn't seem like it'll work as a general solution though since it
> wouldn't apply to an ESTALE on the last component. For that we'd need
> to do something different -- retry the operation in some form, but it
> might be potential optimization in the path walking code to avoid
> retrying in some cases.

I also wonder whether it would be making too many assumptions about the
server or filesystem: just because ordinary posix interfaces don't allow
atomic replacement of a whole directory tree doesn't mean the server
might not have some way to do it.

--b.
