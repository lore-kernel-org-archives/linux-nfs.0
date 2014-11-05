Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:56474 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750860AbaKETyV (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 5 Nov 2014 14:54:21 -0500
Date: Wed, 5 Nov 2014 14:54:20 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Jeff Layton <jeff.layton@primarydata.com>
Cc: Trond Myklebust <trond.myklebust@primarydata.com>,
        Olga Kornievskaia <aglo@umich.edu>,
        linux-nfs <linux-nfs@vger.kernel.org>,
        Thomas Haynes <thomas.haynes@primarydata.com>
Subject: Re: how to properly handle failures during delegation recall process
Message-ID: <20141105195420.GD6513@fieldses.org>
References: <CAHQdGtRuWdHBPfBzCTmDwsYXtpqNSwpGUdtoUqs3jWAd2unxEQ@mail.gmail.com>
 <CAN-5tyGUxgjpcb2=jnQQOD60ernNzf1YSnTG8B-NXUP5OidEFw@mail.gmail.com>
 <CAHQdGtQ=RBoO1u_7501-G2rbDEGim5Hh2G6zuWyyLVVy8QAQWw@mail.gmail.com>
 <CAHQdGtRo2uw5U1-w9O2U=4C8BwxCECAjjeC9SCdkyEP8FQ94Gw@mail.gmail.com>
 <CAN-5tyGsopFNFjo=LBwYE9n6b7Emv73Rkw0H2wyq2vCjMUOftA@mail.gmail.com>
 <CAHQdGtSQJLe60ja+-ChkHXOu8_UjmOpd4X7QHyhNOj1mPQGWPg@mail.gmail.com>
 <20141105065719.23e912b1@tlielax.poochiereds.net>
 <CAABAsM4YWr2fuQYXVa7jCDKexYPML8C1B6y13XVBKO-psXUmOA@mail.gmail.com>
 <20141105183152.GB6513@fieldses.org>
 <20141105144251.725816f6@tlielax.poochiereds.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20141105144251.725816f6@tlielax.poochiereds.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Nov 05, 2014 at 02:42:51PM -0500, Jeff Layton wrote:
> On Wed, 5 Nov 2014 13:31:52 -0500
> "J. Bruce Fields" <bfields@fieldses.org> wrote:
> 
> > On Wed, Nov 05, 2014 at 07:41:58AM -0500, Trond Myklebust wrote:
> > > On Wed, Nov 5, 2014 at 6:57 AM, Jeff Layton <jeff.layton@primarydata.com> wrote:
> > > > (cc'ing Tom here since we may want to consider providing guidance in
> > > >  the spec for this situation)
> > > >
> > > > Ok, I think both of you are right here :). Here's my interpretation:
> > > >
> > > > Olga is correct that the LOCK operation itself is safe since LOCK
> > > > doesn't actually modify the contents of the file. What it's not safe to
> > > > do is to trust that LOCK unless and until the DELEGRETURN is also
> > > > successful.
> > > >
> > > > First, let's clarify the potential race that Trond pointed out:
> > > >
> > > > Suppose we have a delegation and delegated locks. That delegation is
> > > > recalled and we do something like this:
> > > >
> > > > OPEN with DELEGATE_CUR: NFS4_OK
> > > > LOCK:                   NFS4_OK
> > > > LOCK:                   NFS4_OK
> > > > ...(maybe more successful locks here)...
> > > > DELEGRETURN:            NFS4ERR_ADMIN_REVOKED
> > > >
> > > > ...at that point, we're screwed.
> > > >
> > > > The delegation was obviously revoked after we did the OPEN but before
> > > > the DELEGRETURN. None of those LOCK requests can be trusted since
> > > > another client may have opened the file at any point in there, acquired
> > > > any one of those locks and then released it.
> > > >
> > > > For v4.1+ the client can do what Trond suggests. Check for
> > > > SEQ4_STATUS_RECALLABLE_STATE_REVOKED in each LOCK response. If it's set
> > > > then we can do the TEST_STATEID/FREE_STATEID dance. If the TEST_STATEID
> > > > fails, then we must consider the most recently acquired lock lost.
> > > > LOCKU it and give up trying to reclaim the rest of them.
> > > >
> > > > For v4.0, I'm not sure what the client can do other than wait until the
> > > > DELEGRETURN. If that fails with NFS4ERR_ADMIN_REVOKED, then we'll just
> > > > have to try to unwind the whole mess. Send LOCKUs for all of them and
> > > > consider them all to be lost.
> > > >
> > > > Actually, it may be reasonable to just do the same thing for v4.1. The
> > > > client tracks NFS_LOCK_LOST on a per-lockstateid basis, so once you have
> > > > any unreclaimable lock, any I/O done with that stateid is going to fail
> > > > anyway. You might as well just release any locks you do hold at that
> > > > point.
> > > >
> > > > The other question is whether the server ought to have any role to play
> > > > here. In principle it could track whether an open/lock stateid is
> > > > descended from a still outstanding delegation, and revoke those
> > > > stateids if the delegation is revoked. That would probably not be
> > > > trivial to do with the current Linux server implementation, however.
> > 
> > That sounds like a problem for whoever wants to implement support for
> > administrative revocation of state.  We don't really support it
> > currently.
> > 
> > Oops, right, except for the case where the delegation's revoked just
> > because the client ran out of time doing the recall.  In which case I
> > think the final error's going to be either EXPIRED (4.0) or
> > DELEG_REVOKED (4.1)?  (Except I think the Linux server's returning
> > BAD_STATEID in the 4.0 case, which looks wrong.)
> > 
> 
> I'm not sure that that's right... RFC3530 says:
> 
>    NFS4ERR_EXPIRED       A lease has expired that is being used in the
>                          current operation.
> 
> ...implicit in the scenario I layed out above is that the lease is
> being maintained. It's just that the client failed to return the
> delegation in time. So, BAD_STATEID may be correct, actually?

Yes, I misread that EXPIRED text.

That's a bit of a digression--in any case we agree that it's this late
DELEGRETURN case that's the only real bug right now?

On the client side I guess I can't think of anything better than your
suggestion of waiting for the error on DELEGRETURN as you describe.

And on the server side:

> > > What the server could (and probably should) do is revoke all
> > > open/lock/layout state for the clientid+file combination for which it
> > > is also revoking the delegation. That means that all applications that
> > > were using that file on that client would be screwed, but they
> > > probably will be anyway if the file gets corrupted due to non-atomic
> > > locking.

That sounds harsh at first, but I guess it makes sense.

--b.
