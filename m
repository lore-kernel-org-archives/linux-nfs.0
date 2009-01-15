From: David Teigland <teigland@redhat.com>
Subject: Re: [PATCH] lockd: handle fl_grant callbacks with coalesced locks (RFC)
Date: Thu, 15 Jan 2009 10:30:14 -0600
Message-ID: <20090115163014.GA6602@redhat.com>
References: <1227130623-31607-1-git-send-email-jlayton@redhat.com> <20081122011555.GA28485@fieldses.org> <20081124103313.0c779324@tleilax.poochiereds.net> <20081124170653.GF17862@fieldses.org> <20081213074042.2e8223c3@tleilax.poochiereds.net> <20081216193806.GC18928@fieldses.org> <20081216195635.GD18928@fieldses.org> <20081216161158.2d173667@tleilax.poochiereds.net> <20081217191453.GA16777@redhat.com> <20081217200156.GO4614@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jeff Layton <jlayton@redhat.com>, linux-nfs@vger.kernel.org
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:59679 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754758AbZAOQcW (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 15 Jan 2009 11:32:22 -0500
In-Reply-To: <20081217200156.GO4614@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Dec 17, 2008 at 03:01:56PM -0500, J. Bruce Fields wrote:
> On Wed, Dec 17, 2008 at 01:14:53PM -0600, David Teigland wrote:
> > Jeff suggested the following patch, which I've tried and it fixes the
> > problem I was seeing.  It passes the original, unmodified file_lock to
> > notify(), instead of the copy which is passed to (and coalesced by)
> > posix_lock_file().  I'm guessing this was reason for having a copy of the
> > file_lock in the first place, but it was just not used correctly.
> 
> Yep, that looks much better.  Though actually I suspect what was really
> intended was to use "flc" for the notifies, and "fl" for the
> posix_lock_file().
> 
> Also, since flc is never actually handed to the posix lock system, I
> think it should be a "shallow" lock copy--so it should be created with
> __locks_copy_lock().  Something like the below?

I left this hanging over the holidays and I'd like to get it wrapped up.
In summary, I think the following is the correct fix:
  http://marc.info/?l=linux-nfs&m=122954145532438&w=2

(I'd like to do the s/locks_copy_lock/__locks_copy_lock/ in a separate
patch since it's not directly related to fixing the bug.)

Bruce suggested that perhaps my patch should swap "fl" and "flc", which
I don't think is correct (and doesn't fix the problem in a test).  Here's
my complicated explanation of that:
  http://marc.info/?l=linux-nfs&m=122954948914263&w=2

Without any further feedback, I'll plan to send my patch soon for 2.6.29.
Thanks,
Dave

