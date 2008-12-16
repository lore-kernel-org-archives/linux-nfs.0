From: Jeff Layton <jlayton@redhat.com>
Subject: Re: [PATCH] lockd: handle fl_grant callbacks with coalesced locks
 (RFC)
Date: Tue, 16 Dec 2008 16:11:58 -0500
Message-ID: <20081216161158.2d173667@tleilax.poochiereds.net>
References: <1227130623-31607-1-git-send-email-jlayton@redhat.com>
	<20081122011555.GA28485@fieldses.org>
	<20081124103313.0c779324@tleilax.poochiereds.net>
	<20081124170653.GF17862@fieldses.org>
	<20081213074042.2e8223c3@tleilax.poochiereds.net>
	<20081216193806.GC18928@fieldses.org>
	<20081216195635.GD18928@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: linux-nfs@vger.kernel.org, teigland@redhat.com
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:39771 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751633AbYLPVME (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 16 Dec 2008 16:12:04 -0500
In-Reply-To: <20081216195635.GD18928@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 16 Dec 2008 14:56:35 -0500
"J. Bruce Fields" <bfields@fieldses.org> wrote:

> > +	if (result == 0) {
> > +		if (nlmsvc_check_overlap(block))
> > +			requeue = false;  
> 
> So these check_overlap()'s are in attempt to ensure that grants for
> overlapping ranges get sent back to the client in some given order?
> What order is that exactly?  (Do we know that the existing order is
> right?)
> 

No, the idea was to have this code walk the entire list of blocks and
grant any block that the lock completely covers. But, I think we need to
check and make sure that block doesn't conflict with another grant,
correct? That's what that function is intended to do.

> After thinking a little more: the interface is a lot simpler if it's
> just a simple request and reply (with the reply for a lock identical to
> the request).  I believe that's more or less what gfs2 is already do
> internally, if we look at the posix lock upcalls it's making to
> userspace.  So it shouldn't be hard to fix gfs2 to hand us back a lock
> that doesn't take into account any coalescing.  If it needs to keep an
> extra (unmodified) copy of the lock around, that's OK.
> 
> Did you try that and find a reason that doesn't work?
> 
> --b.
> 

Agreed. That would be much simpler, I think...

I didn't try that, though I did consider it before wandering down the
rabbit hole. Dave, any thoughts?

-- 
Jeff Layton <jlayton@redhat.com>
