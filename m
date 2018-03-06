Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:39768 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754017AbeCFTdL (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 6 Mar 2018 14:33:11 -0500
Date: Tue, 6 Mar 2018 14:33:11 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Olga Kornievskaia <aglo@umich.edu>
Cc: "J. Bruce Fields" <bfields@redhat.com>,
        Olga Kornievskaia <kolga@netapp.com>,
        linux-nfs <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH v6 07/10] NFSD create new stateid for async copy
Message-ID: <20180306193311.GF7099@fieldses.org>
References: <20180126215942.GC7770@fieldses.org>
 <CAN-5tyGBBfh0i9QmyHTHp-SWa6ncMCz4ZQdZcAuyWKhxtQ9xLA@mail.gmail.com>
 <20180202214545.GB7229@parsley.fieldses.org>
 <CAN-5tyHOa6SM1Gv+dv=pfQaQ--YTjfkyA6V57wgGic5qEK+jvg@mail.gmail.com>
 <20180216014337.GA3591@parsley.fieldses.org>
 <CAN-5tyFMSqC8GJEvCjxzTO7Nf3c69YBMjmRRc6EFrgXzKJ4+cg@mail.gmail.com>
 <20180216181237.GB2623@parsley.fieldses.org>
 <CAN-5tyHmt1DWgPz9nzuK9V2bVBRhEGev3iOoMv7TNY_k8shgXA@mail.gmail.com>
 <20180220184829.GA528@fieldses.org>
 <CAN-5tyEJu0PZ8i+t5c6EGMSWuW=zpcH1+1z8W+mXNxt-rON9AQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <CAN-5tyEJu0PZ8i+t5c6EGMSWuW=zpcH1+1z8W+mXNxt-rON9AQ@mail.gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Mar 06, 2018 at 12:15:59PM -0500, Olga Kornievskaia wrote:
> On Tue, Feb 20, 2018 at 1:48 PM, J. Bruce Fields <bfields@fieldses.org> wrote:
> > Yeah, I kinda suspect there's a bug in the CLOSE and UNLOCK case too.
> >
> > I don't know if the client really causes trouble for anyone but itself
> > if it allows IO to go on past close, unlock, or delegreturn.
> >
> > If it's still going on after another client acquires a conflicting open,
> > lock, or delegation, that could be a problem: a client that holds a
> > mandatory lock, or an open with DENY_WRITE, or a delegation, has a right
> > not to expect the file to change underneath it.  We should already be
> > safe against that in the delegation case thanks to the vfs checks in
> > fs/locks.c:check_conflicting_open().
> >
> > In the DENY_WRITE case I bet there's still bug.  Maybe in the mandatory
> > lock case, too.  But those cases are rare and already have other
> > problems.
> >
> > So, I guess I don't care too much unless someone's seeing another
> > problem.
> >
> > Still, killing off a long-running copy is probably a good precaution?
> 
> Now that I got back into the code and remembered it again, copy
> stateid is never associated with a delegation stateid. Copy is
> associated with the destination file's stateid which is opened for
> write. Since linux server does not give out write delegations, then
> the stateid is either an open stateid or lock stateid (in my testing I
> varied not locking and locking the destination file so to get open
> stateid as well as lock stateid to be used in the copy). If you want
> me to keep the code for killing off copy in the delegreturn because in
> the future there might be write delegations, I can but I recall the
> rule of thumb is to keep it simple, thus I'm inclined to remove it.

I'm hoping to get to write delegations soon....  And you can actually
write while holding a read delegation.  (Currently knfsd breaks the
delegation in that case, but I'm fixing that.)

That said, I still haven't convinced myself there's any real issue here.
So, I'm fine with leaving that out.

--b.
