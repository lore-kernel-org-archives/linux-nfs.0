Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:53516 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755564Ab2DXQfC (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 24 Apr 2012 12:35:02 -0400
Date: Tue, 24 Apr 2012 12:34:13 -0400
From: Jeff Layton <jlayton@redhat.com>
To: Miklos Szeredi <miklos@szeredi.hu>
Cc: Peter Staubach <pstaubach@exagrid.com>, Steve Dickson <SteveD@redhat.com>,
        "linux-fsdevel\@vger.kernel.org" <linux-fsdevel@vger.kernel.org>,
        "linux-nfs\@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "linux-kernel\@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "viro\@ZenIV.linux.org.uk" <viro@ZenIV.linux.org.uk>,
        "hch\@infradead.org" <hch@infradead.org>,
        "michael.brantley\@deshaw.com" <michael.brantley@deshaw.com>,
        "sven.breuner\@itwm.fraunhofer.de" <sven.breuner@itwm.fraunhofer.de>,
        "chuck.lever\@oracle.com" <chuck.lever@oracle.com>,
        "malahal\@us.ibm.com" <malahal@us.ibm.com>,
        "bfields\@fieldses.org" <bfields@fieldses.org>,
        "trond.myklebust\@fys.uio.no" <trond.myklebust@fys.uio.no>,
        "rees\@umich.edu" <rees@umich.edu>
Subject: Re: [PATCH RFC v3] vfs: make fstatat retry once on ESTALE errors
 from getattr call
Message-ID: <20120424123413.17625d5d@tlielax.poochiereds.net>
In-Reply-To: <87lillktv3.fsf@tucsk.pomaz.szeredi.hu>
References: <1334316311-22331-1-git-send-email-jlayton@redhat.com>
	<1334749927-26138-1-git-send-email-jlayton@redhat.com>
	<20120420104055.511e15bc@tlielax.poochiereds.net>
	<4F91C49D.8070908@RedHat.com>
	<20120420171300.326d6e36@corrin.poochiereds.net>
	<4F956D5C.5050801@RedHat.com>
	<20120423113216.01992555@tlielax.poochiereds.net>
	<4F959A36.2080402@RedHat.com>
	<FA8A9A935BFD3A4D8F0CDA1C4F611BCC063CF8E64B@IT-1874.Isys.com>
	<20120424105049.5ed96b40@tlielax.poochiereds.net>
	<87lillktv3.fsf@tucsk.pomaz.szeredi.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 24 Apr 2012 17:54:56 +0200
Miklos Szeredi <miklos@szeredi.hu> wrote:

> Jeff Layton <jlayton@redhat.com> writes:
> 
> > On Mon, 23 Apr 2012 16:38:00 -0400
> > Peter Staubach <pstaubach@exagrid.com> wrote:
> >
> >> I don't really like the idea of introducing another errno as well.  It seems like too much complexity and represents complexity that no one has really justified needing.
> >> 
> >
> > I tend to agree here. Miklos, can you elaborate a bit on what fuse
> > filesystems you're particularly concerned about here? Which ones return
> > ESTALE and under what conditions. Maybe we can try to tailor this
> > solution to avoid the complexity without impacting them.
> 
> It is not just fuse I'm concerned about.  Grep for -ESTALE, there are
> about 120 hits about 20 of which come from NFS.  There's no guarantee
> that any of those ESTALE errors will go away on retry, which for an
> unlimited retry means a hung OS.  If you limit the number of retries
> then in the best case it's just lots of wasted CPU cycles.
> 

Yes, that's one of the first things I did when I went to look at this
problem. Almost all of those are in export_operations related code and
would never be returned on a path based syscall.

Others are not in fs-related code at all (another subsystem has
repurposed the error code), or are in fs-related code but are using it
internally for other purposes (JFS seems to have some of this).

While I don't like to waste CPU cycles, this is an error condition and
I don't think we're well served in optimizing for it.

> And an audit would still not ensure safety against future additions of
> ESTALE.
> 

Well, nothing is safe from the future. It's incumbent upon us to review
patches and such before such breakage goes in.

> And a simple audit won't find things like fuse, where the error comes
> from outside the kernel.  Fixing that is not trivial either.  Turning
> ESTALE into some other error prevents looping but breaks the return
> value.
> 

Then that fs is just plain returning the wrong error, IMO. We're not
breaking any kABI guarantees with this -- they're still able to return
ESTALE, it's just that the behavior on such a return is more resilient
if we reattempt.

But, let's say for the purposes of argument that we do have a fs (FUSE
or otherwise) that is persistently returning ESTALE on a lookup. Why
was Peter's check that we were making forward progress not enough to
guard against this problem?

In particular, I'm talking about the code he added to link_path_walk in
this patch to check that the value of nd->path.dentry was changing:

    https://lkml.org/lkml/2008/3/10/266

It seems like that ought to be enough to alleviate your fears on this.
We could also check for fatal signals on each pass and that would allow
users to break out of the loop even when the underlying fs doesn't
handle signals properly.

-- 
Jeff Layton <jlayton@redhat.com>
