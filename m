Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qg0-f48.google.com ([209.85.192.48]:32815 "EHLO
	mail-qg0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751923AbaI0U5I (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 27 Sep 2014 16:57:08 -0400
Received: by mail-qg0-f48.google.com with SMTP id i50so355957qgf.21
        for <linux-nfs@vger.kernel.org>; Sat, 27 Sep 2014 13:57:07 -0700 (PDT)
From: Jeff Layton <jeff.layton@primarydata.com>
Date: Sat, 27 Sep 2014 16:57:04 -0400
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: Jeff Layton <jeff.layton@primarydata.com>,
        "nfsv4@ietf.org" <nfsv4@ietf.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: [nfsv4] Could somebody please enlighten me as to what is
 supposed to happen in this situation?
Message-ID: <20140927165704.59be4981@synchrony.poochiereds.net>
In-Reply-To: <CAHQdGtSc8+5k-U=5NB7gYEhh5Qd4jq2BqpzQ_0wA_YH637q97g@mail.gmail.com>
References: <CAABAsM4zDuzjapXfLUrminwM1FV7iwN+oEzxgzaQ60m93gBBug@mail.gmail.com>
	<20140927144056.2d303755@synchrony.poochiereds.net>
	<CAHQdGtQBNpBO+xv_uk+bkue6zoSKMhU72xjKaeOb2gEHY012Ew@mail.gmail.com>
	<20140927155045.76ce1149@synchrony.poochiereds.net>
	<CAHQdGtSc8+5k-U=5NB7gYEhh5Qd4jq2BqpzQ_0wA_YH637q97g@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sat, 27 Sep 2014 16:27:15 -0400
Trond Myklebust <trond.myklebust@primarydata.com> wrote:

> On Sat, Sep 27, 2014 at 3:50 PM, Jeff Layton
> <jeff.layton@primarydata.com> wrote:
> > On Sat, 27 Sep 2014 15:25:12 -0400
> > Trond Myklebust <trond.myklebust@primarydata.com> wrote:
> >
> >> On Sat, Sep 27, 2014 at 2:40 PM, Jeff Layton
> >> <jeff.layton@primarydata.com> wrote:
> >> > On Sat, 27 Sep 2014 11:22:29 -0400
> >> > Trond Myklebust <trond.myklebust@primarydata.com> wrote:
> >> >
> >> >
> >> > My take (quite possibly wrong, but...)
> >> >
> >> >> The scenario is this:
> >> >>                                        Server
> >> >>                                        ======
> >> >>                                        boot (B1)
> >> >> Client
> >> >> ======
> >> >> EXCHANGE_ID
> >> >> CREATE_SESSION
> >> >> OPEN(reclaim)
> >> >> LOCK(reclaim)
> >> >> RECLAIM_COMPLETE
> >> >>                                        (lift GRACE period)
> >> >
> >> > At this point, we'd deny reclaim from any client that has not issued a
> >> > RECLAIM_COMPLETE. In the case of the Linux server with nfsdcltrack, we
> >> > clean out any client records that have not issued a RECLAIM_COMPLETE.
> >> >
> >> >>                                        reboot (B2)
> >> >> EXCHANGE_ID
> >> >> CREATE_SESSION
> >> >> OPEN(reclaim)
> >> >>                                         reboot (while GRACE period
> >> >> still being enforced) (B3)
> >> >> EXCHANGE_ID
> >> >> CREATE_SESSION
> >> >> OPEN(reclaim)
> >> >>
> >> >> What should be the server response to the above OPEN(reclaim) from the
> >> >> client after reboot (B3)?
> >> >>
> >> >
> >> > My expectation is that it would be granted. There was a
> >> > RECLAIM_COMPLETE issued during the boot where the grace period was last
> >> > lifted, and that should be enough to allow the client to issue reclaims
> >> > on any subsequent reboot, until the grace period is lifted again.
> >> >
> >> > Doing anything else would be a pretty unfriendly way for the server to
> >> > behave. In the face of rapid reboots (a not-uncommon occurrence when
> >> > patching, etc), you'd lose state unless the client just happened to get
> >> > in there quickly enough to issue a RECLAIM_COMPLETE between each reboot.
> 
> Where is the evidence that this is a problem for NFS and for NFS
> client recovery?
> 

I don't have any other than my own experience with it. That said,
reclaim problems tend to be "silent killers". It's often hard to notice
when things go wrong as it's not necessarily a problem.

> >> > That was the situation with the legacy client tracker in knfsd. When
> >> > testing, it was trivial to reboot the machine quickly twice and on the
> >> > second reboot nothing could be reclaimed.
> >>
> >> So now, what if the following scenario:
> >>
> >>                                        Server
> >>                                        ======
> >>                                        boot (B1')
> >> Client
> >> ======
> >> EXCHANGE_ID
> >> CREATE_SESSION
> >> OPEN(reclaim)
> >> LOCK(reclaim)
> >> RECLAIM_COMPLETE
> >>                                        (lift GRACE period (G1))
> >>                                        reboot (B2')
> >> EXCHANGE_ID
> >> CREATE_SESSION
> >> OPEN(reclaim)
> >>                                        (lift GRACE period (G2))
> >>                                        reboot (B3')
> >> EXCHANGE_ID
> >> CREATE_SESSION
> >> OPEN(reclaim)
> >>
> >> What should happen to the OPEN(reclaim) in (B3')?
> >>
> >
> > (Let's call the lifting of grace periods 'G1' and 'G2'...)
> >
> > Denied.
> >
> > There was no RECLAIM_COMPLETE issued between B2 and G2. It's possible
> > that client2 could creep in between G2 and B3 and acquire locks that
> > conflict with ones that were not reclaimed by client1 between B2 and
> > G2. So, we can't allow any reclaims for client1 after B3.
> 
> Why should the possibility that clients might steal locks that were
> not reclaimed, affect reboot recovery of locks that were successfully
> reclaimed? There is no way for client 2 to steal those unless the
> lease expires, in which case client 1 will be blocked from recovering
> state anyway.
> 

Well, the server could allow it, but relying on the client to limit
what it reclaims in that case seems a bit sketchy. The question is:

    Can the client could lose its lease while the grace period is still
    in effect?

If so, then the client might reclaim some, but not all locks, and then
lose its lease. It gets a new lease and the reclaims only the ones that
it reclaimed before, even though it could have reclaimed all of them
since the grace period is still in effect.

I'm not sure which is worse. :-/

> So you are saying that the client should be able to reclaim all locks
> or nothing? If this is really the case then, could we please fix the
> spec?
> 

I'm saying that if the client wants to to be able to reclaim anything
on the next reboot, then it should issue a RECLAIM_COMPLETE during the
current one.

The exception there is if the server never gets to lift the grace
period before the next reboot occurs. In that case, we'll still want to
allow the client to reclaim on the next reboot (since we know that no
new state can have been established).

> > I should add a clarification here too. I'm assuming that the server in
> > this case just tracks the minimum required to allow state to be
> > reclaimed. If it (for instance) tracked on stable storage all of the
> > locks that it ever granted such that it knows that there were no
> > conflicts, then it could be more lenient about allowing client1 to
> > reclaim after B3.
> 
> No. A server doesn't need to do all that in order to allow the client
> to recover some of the locks.
> 
> All it needs to do is to be able to tell the client that it shouldn't
> reclaim locks that were not reclaimed in (B2'). A simple SEQUENCE
> status flag would suffice to let the client know that it failed to
> reclaim all its locks in the last valid grace period.
> 

It is required with the current protocol. If you're talking about
extending the protocol to allow it, then that's a different matter
entirely.

-- 
Jeff Layton <jlayton@primarydata.com>
