Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:58736 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751839AbcHQOY4 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 17 Aug 2016 10:24:56 -0400
Date: Wed, 17 Aug 2016 10:24:52 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Jeff Layton <jlayton@redhat.com>
Cc: linux-nfs@vger.kernel.org, hch@lst.de
Subject: Re: [RFC PATCH] nfsd: fix error handling for clients that fail to
 return the layout
Message-ID: <20160817142452.GA8492@fieldses.org>
References: <1471368867-29362-1-git-send-email-jlayton@redhat.com>
 <20160816211745.GA795@fieldses.org>
 <1471440494.3196.21.camel@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
In-Reply-To: <1471440494.3196.21.camel@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Aug 17, 2016 at 09:28:14AM -0400, Jeff Layton wrote:
> On Tue, 2016-08-16 at 17:17 -0400, J. Bruce Fields wrote:
> > On Tue, Aug 16, 2016 at 01:34:27PM -0400, Jeff Layton wrote:
> > > 
> > > Currently, when the client fails to return the layout we'll
> > > eventually
> > > give up trying but leave the layout in place.
> > 
> > Maybe I'm not reading the code right, but I think the layout is
> > eventually removed unconditionally in every case, by
> > nfsd4_cb_layout_release--were you seeing something else?
> > 
> 
> Yes, you're correct. Still, we'll be revoking the layout record in the
> server, but the client could still think it has it and it could
> continue writing to the storage. If we're revoking the layout without
> the client explicitly acknowledging that it's no longer using it, then
> we really do have to fence as well.

Got it.  Could just use some changelog clarification.

> > > What we really need to
> > > do here is fence the client in this case. Have it fall through to
> > > that
> > > code in that case instead of into the NFS4ERR_NOMATCHING_LAYOUT
> > > case.
> > 
> > So the only change here is to fence in the case a client keeps
> > responding with DELAY, right?
> > 
> 
> That, or if it is returning 0 and not following up with a LAYOUTRETURN.
> 
> > That does seem like an improvement.
> > 
> > I wonder if the result is completely correct.
> > 
> > In the list_empty(&ls->ls_layouts) case, shouldn't we also call
> > trace_layout_recall_done()?
> > 
> > Does it really make sense to retry the callback in the case the
> > callback
> > succeeds but the client hasn't returned yet?
> > 
> 
> No it doesn't, but fixing that is a little more difficult. Right now,
> we time out the recall in the ->done operation. If we don't retry the
> call then we don't have a mechanism to handle the timeout.
> 
> There are several ways to fix that, but they're all pretty ugly,
> AFAICT. Any thoughts on how you'd like to handle the timeout?

The delegation code keeps the delegation return or revocation mostly
separate from the callback.  Revocation is handled by the laundromat.

I'd prefer delegation and layout timeouts were handled in roughly the
same way.

As you know it's taken a long time to shake races out of the delegation
code.  So if the current layout recall approach is simpler, and if the
only drawback is redundant callbacks, then I guess there's no rush to
rewrite everything.

> > If the client returns the layout but returns a status other than 0,
> > DELAY, or NOMATCHING_LAYOUT, is it really correct to fence it?
> > 
> 
> Probably not. Some of the error cases (e.g. NFS4ERR_BADHANDLE) could
> probably be considered the same as NFS4ERR_NOMATCHING_LAYOUT. That
> said, fencing is generally the safer option when we're in doubt.
> 
> > If trunking's in effect and we have to change the callback connection
> > while waiting for the return, do we do the right thing?  (Looking at
> > it... Actually, I think nfsd4_cb_sequence_done should handle these
> > cases
> > for us, OK, maybe I'm less worried.)
> > 
> 
> Yeah, that should all be handled in the CB_SEQUENCE op.

That said, we need pynfs tests or similar to test those codepaths, there
are probably lurking bugs.  That'd be a prerequisite for any rewrite of
the layout revocation.

--b.
