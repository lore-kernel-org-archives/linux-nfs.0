From: Jeff Layton <jlayton@redhat.com>
Subject: Re: [PATCH] lockd: handle fl_grant callbacks with coalesced locks
 (RFC)
Date: Mon, 24 Nov 2008 10:33:13 -0500
Message-ID: <20081124103313.0c779324@tleilax.poochiereds.net>
References: <1227130623-31607-1-git-send-email-jlayton@redhat.com>
	<20081122011555.GA28485@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: linux-nfs@vger.kernel.org, teigland@redhat.com
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:40879 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753157AbYKXPdW (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 24 Nov 2008 10:33:22 -0500
In-Reply-To: <20081122011555.GA28485@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 21 Nov 2008 20:15:55 -0500
"J. Bruce Fields" <bfields@fieldses.org> wrote:

> On Wed, Nov 19, 2008 at 04:37:03PM -0500, Jeff Layton wrote:
> > Dave Teigland opened a bug stating that he was having some problems with
> > DLM and lockd. Essentially, the problem boiled down to the fact that
> > when you do a posix lock of a region that touches another lock, the VFS
> > will coalesce the locks and return a lock that encompasses the whole
> > range.
> > 
> > The problem here is that DLM then does a fl_grant callback to lockd with
> > the new coalesced lock. The fl_grant callback then looks through all
> > of the blocks and eventually returns -ENOENT since none match the
> > coalesced lock.
> 
> Ugh.
> 

My sentiments exactly...

> > I'm having a very hard time tracking down info about how the fl_grant
> > callback is supposed to work. Is it OK to send an fl_grant callback
> > with a lock that's larger than the one requested? If so, then lockd
> > needs to account for that possibility. Also, what exactly is the
> > purpose of the second arg on fl_grant ("conf" in nlmsvc_grant_deferred)?
> 
> It's only used in the case the lock failed, and it can optionally be set
> to a copy of the conflicting lock.
> 

Ok, good to know. At some point, a file in Documentation on these interfaces
this might be a nice addition...

> > What follows is a patch that changes nlmsvc_grant_deferred to account
> > for the possibility that it may receive an fl_grant that has already
> > been coalesced. It changes nlmsvc_grant_deferred to walk the entire
> > list of blocks and grant any blocks that are covered by the range of
> > the lock in the grant callback, if doing so will not conflict with an
> > earlier grant.
> 
> Hm.  That might work.
> 

It seems to with very basic, cursory testing, but it could be
broken and I'm just not seeing it. This code looks like it's only used
in a NLM over DLM setup though, so it's hard to comprehensively test
it. This scheme is certainly more complex than the current code, though
and I'm not sure I have everything right with it.

> > The patch is still very rough and is probably broken in subtle (and
> > maybe overt) ways, but it fixes the reproducer that Dave provided. It's
> > just intended as a starting point for discussion. Can anyone clarify how
> > fl_grant is supposed to work? Who's wrong here? DLM or NLM?
> 
> I think this wasn't thought through, apologies.  (It was my
> responsibility to make sure it was!)
> 
> I also occasionally think that it would be better to keep any actual
> lock application the caller's responsibility, to the extent that's
> possible--so fl_grant would just be a notification, and it would be up
> to lockd to try the lock again and check the result.  That's more or
> less the way it always worked before, and it seems a simpler model.
> 
> Some work in the filesystem would be required to make sure it would be
> ready to return an answer on that second request.
> 
> I also think there's a problem with lock cancelling in the current code.
> 

No worries, I think we can come up with something workable now that we
understand the problem.

When I dug through the mailing list archives, the only thing I could
find on this was this post by you:

http://lkml.org/lkml/2008/4/15/246

...and in particular:

	- With fl_grant the filesystem says: I'm giving you the final
	  result of the lock operation.  In particular, if I'm telling
	  you it succeeded, that means I've already granted you the
	  lock; don't ask me about it again.

...that seems to contradict what you're suggesting above. I suppose we
could consider changing NLM to use the .fl_notify interface, which you
described as:

	- With fl_notify the filesystem says: something just happened to
	  this lock.  I'm not guaranteeing anything, I'm just telling
	  you this would be a good time to try the lock again.  Do it
	  and maybe you'll get lucky!

...is that what you were suggesting?

-- 
Jeff Layton <jlayton@redhat.com>
