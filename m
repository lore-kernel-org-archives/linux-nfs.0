Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:43636 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1755851AbeBPSMj (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 16 Feb 2018 13:12:39 -0500
Date: Fri, 16 Feb 2018 13:12:38 -0500
From: "J. Bruce Fields" <bfields@redhat.com>
To: Olga Kornievskaia <aglo@umich.edu>
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
        Olga Kornievskaia <kolga@netapp.com>,
        linux-nfs <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH v6 07/10] NFSD create new stateid for async copy
Message-ID: <20180216181237.GB2623@parsley.fieldses.org>
References: <20171024174752.74910-1-kolga@netapp.com>
 <20171024174752.74910-8-kolga@netapp.com>
 <20180126215942.GC7770@fieldses.org>
 <CAN-5tyGBBfh0i9QmyHTHp-SWa6ncMCz4ZQdZcAuyWKhxtQ9xLA@mail.gmail.com>
 <20180202214545.GB7229@parsley.fieldses.org>
 <CAN-5tyHOa6SM1Gv+dv=pfQaQ--YTjfkyA6V57wgGic5qEK+jvg@mail.gmail.com>
 <20180216014337.GA3591@parsley.fieldses.org>
 <CAN-5tyFMSqC8GJEvCjxzTO7Nf3c69YBMjmRRc6EFrgXzKJ4+cg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <CAN-5tyFMSqC8GJEvCjxzTO7Nf3c69YBMjmRRc6EFrgXzKJ4+cg@mail.gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Feb 16, 2018 at 11:06:07AM -0500, Olga Kornievskaia wrote:
> On Thu, Feb 15, 2018 at 8:43 PM, J. Bruce Fields <bfields@redhat.com> wrote:
> > On Thu, Feb 15, 2018 at 05:18:55PM -0500, Olga Kornievskaia wrote:
> >> On Fri, Feb 2, 2018 at 4:45 PM, J. Bruce Fields <bfields@redhat.com> wrote:
> >> > Is it really OK to do a COPY with a delegation stateid?  That sounds
> >> > messy if the delegation is revoked partway through the copy.
> >>
> >> Yes, according to the spec, it is ok to use any of the stateids.
> >>
> >> RFC 7862 15.2.3
> >> The ca_dst_stateid MUST refer to a stateid that is valid for a WRITE
> >>    operation and follows the rules for stateids in Sections 8.2.5 and
> >>    18.32.3 of [RFC5661].... while for an intra-server copy
> >> ca_src_stateid MUST refer
> >>    to a stateid that is valid for a READ operation and follows the rules
> >>    for stateids in Sections 8.2.5 and 18.22.3 of [RFC5661].
> >>
> >> 8.2.5 is the section that says in the decreasing priority to choose
> >> delegation stateid, locking stateid, open stateid.
> >>
> >> Trying to deal with the delegation stateid seems to be rather complex.
> >> Here's what I could do (which I mentioned before already):
> >> 1. possibly change the client to never use a delegation stateid.
> >> 2. for CLOSE/UNLOCK send back ERR_DELAY if copy list is not empty.
> >> 3. for DELEGRETURN (or when the server initiates CB_RECALL?) kill any
> >> on-going copies. Change the nfsd copy to send a reply if it was killed
> >> with a signal. What I'm not sure if when it's killed I get any partial
> >> bytes from the VFS, I don't think so. I think in that case, the only
> >> thing that I might reply with is a 0bytes copy. And whatever client
> >> that did sent a copy with a delegation stateid would deal with
> >> restarting it with a different stateid.
> >>
> >> Having said all that, I'd like to ask why do you think handling
> >> CLOSE/LOCKU/DELEGRETURN should be any different for async copy vs what
> >> is currently there for the synchronous copy. Right now if the server
> >> receives those operations it does nothing to the on-going synchronous
> >> copy.
> >
> > Or for that matter, why should it be different from READ and
> > WRITE--looks like those can also continue executing after a close, too.
> > So, good point.
> >
> >> As you noted, the async copy takes a reference on the parent stateid
> >> so the state won't go away while the async copy is going on. Why not
> >> keep async copy same as the synchronous one?
> >
> > OK, so maybe it's not such a big deal.
> >
> > I'm still confused about the delegation case, though: a copy can take a
> > very long time, so we can't just wait for the copy to end before
> > revoking the delegation.  So do we allow the copy to continue
> > indefinitely even after the delegation stateid it was initiated with has
> > long ago been revoked?
> >
> > Maybe it's not a problem.  I guess I'm having trouble remembering why
> > copies (or IO in general) uses stateids in the first place....
> 
> Sigh. No you are right, we shouldn't let it run long past the
> revocation.

I'm worried by it running long past the revocation, but I'm also not
managing to come with a case where it causes an actual problem.

--b.

> With IO operations, once it starts an operation like
> CLOSE/UNLOCK/DELEGRETURN can arrive at the server and it's ok because
> IO isn't long, and once it's done the client will notice a change in
> stateid and will choose a different stateid to do the next IO
> operation. I guess that's why a synchronous copy is still bordering ok
> because it's relatively short and the next copy will choose a
> different stateid.
> 
> Unless there are any big objections, I'll make the following changes
> 1. CLOSE/UNLOCK will check for none-empty list and return ERR_DELAY.
> 2. change the copy code to once received a signal to return the
> partial copy back.
> 3. DELEGRETURN will stop/kill any on-going copies, which would trigger
> a partial copy reply and the next copy should choose a different
> stateid.
