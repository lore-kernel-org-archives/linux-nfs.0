Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-yh0-f41.google.com ([209.85.213.41]:43302 "EHLO
	mail-yh0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751316AbaI1LMW (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 28 Sep 2014 07:12:22 -0400
Received: by mail-yh0-f41.google.com with SMTP id i57so87556yha.0
        for <linux-nfs@vger.kernel.org>; Sun, 28 Sep 2014 04:12:21 -0700 (PDT)
From: Jeff Layton <jeff.layton@primarydata.com>
Date: Sun, 28 Sep 2014 07:12:17 -0400
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: Jeff Layton <jeff.layton@primarydata.com>,
        "nfsv4@ietf.org" <nfsv4@ietf.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: [nfsv4] Could somebody please enlighten me as to what is
 supposed to happen in this situation?
Message-ID: <20140928071219.242e1071@synchrony.poochiereds.net>
In-Reply-To: <CAHQdGtSjHVveG_Y4jzSDwLypSL1kGt4j2JUEzZXy2PWbpT6=aQ@mail.gmail.com>
References: <CAABAsM4zDuzjapXfLUrminwM1FV7iwN+oEzxgzaQ60m93gBBug@mail.gmail.com>
	<20140927144056.2d303755@synchrony.poochiereds.net>
	<CAHQdGtQBNpBO+xv_uk+bkue6zoSKMhU72xjKaeOb2gEHY012Ew@mail.gmail.com>
	<20140927155045.76ce1149@synchrony.poochiereds.net>
	<CAHQdGtSc8+5k-U=5NB7gYEhh5Qd4jq2BqpzQ_0wA_YH637q97g@mail.gmail.com>
	<20140927165704.59be4981@synchrony.poochiereds.net>
	<CAHQdGtRNMULR_dPkEwpqYWDRGRfi1o_z6+OuiN9ZM_z6ppTHUQ@mail.gmail.com>
	<20140927203723.7c84f050@synchrony.poochiereds.net>
	<CAHQdGtSjHVveG_Y4jzSDwLypSL1kGt4j2JUEzZXy2PWbpT6=aQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sat, 27 Sep 2014 21:17:23 -0400
Trond Myklebust <trond.myklebust@primarydata.com> wrote:

> On Sat, Sep 27, 2014 at 8:37 PM, Jeff Layton
> <jeff.layton@primarydata.com> wrote:
> > On Sat, 27 Sep 2014 19:12:02 -0400
> > Trond Myklebust <trond.myklebust@primarydata.com> wrote:
> >
> >> On Sat, Sep 27, 2014 at 4:57 PM, Jeff Layton
> >> <jeff.layton@primarydata.com> wrote:
> >> > On Sat, 27 Sep 2014 16:27:15 -0400
> >> > Trond Myklebust <trond.myklebust@primarydata.com> wrote:
> >> >
> >> >> On Sat, Sep 27, 2014 at 3:50 PM, Jeff Layton
> >> >> <jeff.layton@primarydata.com> wrote:
> >> >> > On Sat, 27 Sep 2014 15:25:12 -0400
> >> >> > Trond Myklebust <trond.myklebust@primarydata.com> wrote:
> >> >> >
> >> >> >> On Sat, Sep 27, 2014 at 2:40 PM, Jeff Layton
> >> >> >> <jeff.layton@primarydata.com> wrote:
> >> >> >> > On Sat, 27 Sep 2014 11:22:29 -0400
> >> >> >> > Trond Myklebust <trond.myklebust@primarydata.com> wrote:
> >> >> >> >
> >> >> >> >
> >> >> >> > My take (quite possibly wrong, but...)
> >> >> >> >
> >> >> >> >> The scenario is this:
> >> >> >> >>                                        Server
> >> >> >> >>                                        ======
> >> >> >> >>                                        boot (B1)
> >> >> >> >> Client
> >> >> >> >> ======
> >> >> >> >> EXCHANGE_ID
> >> >> >> >> CREATE_SESSION
> >> >> >> >> OPEN(reclaim)
> >> >> >> >> LOCK(reclaim)
> >> >> >> >> RECLAIM_COMPLETE
> >> >> >> >>                                        (lift GRACE period)
> >> >> >> >
> >> >> >> > At this point, we'd deny reclaim from any client that has not issued a
> >> >> >> > RECLAIM_COMPLETE. In the case of the Linux server with nfsdcltrack, we
> >> >> >> > clean out any client records that have not issued a RECLAIM_COMPLETE.
> >> >> >> >
> >> >> >> >>                                        reboot (B2)
> >> >> >> >> EXCHANGE_ID
> >> >> >> >> CREATE_SESSION
> >> >> >> >> OPEN(reclaim)
> >> >> >> >>                                         reboot (while GRACE period
> >> >> >> >> still being enforced) (B3)
> >> >> >> >> EXCHANGE_ID
> >> >> >> >> CREATE_SESSION
> >> >> >> >> OPEN(reclaim)
> >> >> >> >>
> >> >> >> >> What should be the server response to the above OPEN(reclaim) from the
> >> >> >> >> client after reboot (B3)?
> >> >> >> >>
> >> >> >> >
> >> >> >> > My expectation is that it would be granted. There was a
> >> >> >> > RECLAIM_COMPLETE issued during the boot where the grace period was last
> >> >> >> > lifted, and that should be enough to allow the client to issue reclaims
> >> >> >> > on any subsequent reboot, until the grace period is lifted again.
> >> >> >> >
> >> >> >> > Doing anything else would be a pretty unfriendly way for the server to
> >> >> >> > behave. In the face of rapid reboots (a not-uncommon occurrence when
> >> >> >> > patching, etc), you'd lose state unless the client just happened to get
> >> >> >> > in there quickly enough to issue a RECLAIM_COMPLETE between each reboot.
> >> >>
> >> >> Where is the evidence that this is a problem for NFS and for NFS
> >> >> client recovery?
> >> >>
> >> >
> >> > I don't have any other than my own experience with it. That said,
> >> > reclaim problems tend to be "silent killers". It's often hard to notice
> >> > when things go wrong as it's not necessarily a problem.
> >> >
> >> >> >> > That was the situation with the legacy client tracker in knfsd. When
> >> >> >> > testing, it was trivial to reboot the machine quickly twice and on the
> >> >> >> > second reboot nothing could be reclaimed.
> >> >> >>
> >> >> >> So now, what if the following scenario:
> >> >> >>
> >> >> >>                                        Server
> >> >> >>                                        ======
> >> >> >>                                        boot (B1')
> >> >> >> Client
> >> >> >> ======
> >> >> >> EXCHANGE_ID
> >> >> >> CREATE_SESSION
> >> >> >> OPEN(reclaim)
> >> >> >> LOCK(reclaim)
> >> >> >> RECLAIM_COMPLETE
> >> >> >>                                        (lift GRACE period (G1))
> >> >> >>                                        reboot (B2')
> >> >> >> EXCHANGE_ID
> >> >> >> CREATE_SESSION
> >> >> >> OPEN(reclaim)
> >> >> >>                                        (lift GRACE period (G2))
> >> >> >>                                        reboot (B3')
> >> >> >> EXCHANGE_ID
> >> >> >> CREATE_SESSION
> >> >> >> OPEN(reclaim)
> >> >> >>
> >> >> >> What should happen to the OPEN(reclaim) in (B3')?
> >> >> >>
> >> >> >
> >> >> > (Let's call the lifting of grace periods 'G1' and 'G2'...)
> >> >> >
> >> >> > Denied.
> >> >> >
> >> >> > There was no RECLAIM_COMPLETE issued between B2 and G2. It's possible
> >> >> > that client2 could creep in between G2 and B3 and acquire locks that
> >> >> > conflict with ones that were not reclaimed by client1 between B2 and
> >> >> > G2. So, we can't allow any reclaims for client1 after B3.
> >> >>
> >> >> Why should the possibility that clients might steal locks that were
> >> >> not reclaimed, affect reboot recovery of locks that were successfully
> >> >> reclaimed? There is no way for client 2 to steal those unless the
> >> >> lease expires, in which case client 1 will be blocked from recovering
> >> >> state anyway.
> >> >>
> >> >
> >> > Well, the server could allow it, but relying on the client to limit
> >> > what it reclaims in that case seems a bit sketchy. The question is:
> >> >
> >> >     Can the client could lose its lease while the grace period is still
> >> >     in effect?
> >> >
> >> > If so, then the client might reclaim some, but not all locks, and then
> >> > lose its lease. It gets a new lease and the reclaims only the ones that
> >> > it reclaimed before, even though it could have reclaimed all of them
> >> > since the grace period is still in effect.
> >> >
> >> > I'm not sure which is worse. :-/
> >>
> >> If the client loses its lease, then that will be recorded by the
> >> server in stable storage using the 1st boolean described in RFC5661,
> >> Section 8.4.3 (RFC3530, Section 8.6.3) . The server then knows not to
> >> allow recovery of any locks after a reboot.
> >>
> >
> > That's the case if there's a reboot in between the lease being lost.
> >
> > Consider this:
> >
> > client                          server
> > --------------------------      ----------------------------
> > (client holds an open and
> >  lock on server)
> >                                 Server reboots (B1)
> > EXCHANGE_ID
> > CREATE_SESSION
> > OPEN(reclaim)
> >
> >                 ....network partition....
> >
> >                                 Server expires lease
> >
> >                 ...partition heals....
> > LOCK(reclaim)
> >                                 return NFS4ERR_CLID_EXPIRED (or whatever)
> > EXCHANGE_ID
> > CREATE_SESSION
> > OPEN(reclaim)
> >
> > (skip LOCK since it couldn't
> >  be reclaimed on prev attempt)
> >
> > RECLAIM_COMPLETE
> >                                 Grace period is lifted
> >
> > ...am I correct that that's what you're suggesting that the client
> > should do?
> >
> > If so, then that leaves the client not even attempting to do the
> > LOCK(reclaim), even though the server would have granted it.
> 
> Why would the server expire a client lease _during_ the grace period?
> I grant you that the spec does allow that, but what would be the
> point? AFAICT doing so brings no benefits to either the server, the
> client or to other clients. The latter cannot obtain new locks since
> the grace period is in effect, so the only effect is to delay lock
> recovery by forcing the client to start from scratch.
> 
> IOW: the above looks like a situation where the server is shooting
> everyone, including itself, in the foot.
> 

True -- and Linux' knfsd won't expire the lease until it's going to
lift its grace period, so I guess the above situation is quite
theoretical.

> >> >> So you are saying that the client should be able to reclaim all locks
> >> >> or nothing? If this is really the case then, could we please fix the
> >> >> spec?
> >> >>
> >> >
> >> > I'm saying that if the client wants to to be able to reclaim anything
> >> > on the next reboot, then it should issue a RECLAIM_COMPLETE during the
> >> > current one.
> >> >
> >> > The exception there is if the server never gets to lift the grace
> >> > period before the next reboot occurs. In that case, we'll still want to
> >> > allow the client to reclaim on the next reboot (since we know that no
> >> > new state can have been established).
> >>
> >> Where is this exception documented? The only discussion I see about
> >> multiple reboots is in the context of edge conditions 1 and 2. There
> >> is nothing there about multiple reboots in other contexts.
> >>
> >
> > I'm not sure that it is. It's just the only behavior that made sense to
> > me when I was doing the work on nfsdcltrack. If the rules for handling
> > reclaims can't survive multiple reboots, then they aren't worth much,
> > IMO...
> 
> The rules don't handle multiple reboots unless the client manages to
> reclaim all its locks.
> 

Right.

> >> BTW: if this is indeed the correct interpretation of the spec, then
> >> does RFC3530 really intend that the client should be unable to recover
> >> any locks if the application doesn't perform a non-delegated open() or
> >> lock between the end of the grace period and the server reboot?
> >>
> >
> > This is the part that I argue is a v4.0 protocol bug. You can't count
> > on the client ever sending another OPEN/OPEN_CONFIRM. So, for v4.0
> > clients you can't purge a client record from stable storage when the
> > grace period is lifted if it happened to reclaim anything since the
> > last reboot.
> 
> However that is precisely why the v4.1 behaviour is problematic.
> 
> In the case of v4.0, the client needs to follow one set of rules: I
> can only reclaim those locks that I recovered on the last boot, but at
> least I know that I can recover them.
> In the case of v4.1, we follow a completely different set of rules: I
> can reclaim only if I successfully sent a RECLAIM_COMPLETE in the last
> boot.
> 
> It means that in v4.1, you can no longer recover locks in cases where
> v4.0 allowed you to do so.
> 

Yeah, the v4.0 vs. v4.1 differences are a pain, but the protocol is
just plain different so different logic has to apply.

> > I think that's really the best you can do given the limitations of v4.0.
> >
> >> >> > I should add a clarification here too. I'm assuming that the server in
> >> >> > this case just tracks the minimum required to allow state to be
> >> >> > reclaimed. If it (for instance) tracked on stable storage all of the
> >> >> > locks that it ever granted such that it knows that there were no
> >> >> > conflicts, then it could be more lenient about allowing client1 to
> >> >> > reclaim after B3.
> >> >>
> >> >> No. A server doesn't need to do all that in order to allow the client
> >> >> to recover some of the locks.
> >> >>
> >> >> All it needs to do is to be able to tell the client that it shouldn't
> >> >> reclaim locks that were not reclaimed in (B2'). A simple SEQUENCE
> >> >> status flag would suffice to let the client know that it failed to
> >> >> reclaim all its locks in the last valid grace period.
> >> >>
> >> >
> >> > It is required with the current protocol. If you're talking about
> >> > extending the protocol to allow it, then that's a different matter
> >> > entirely.
> >>
> >> Right now, I'm just trying to figure out the ramifications of all
> >> this: the RFC3530 requirements in particular...
> >>
> >
> > Yeah, the rules for v4.0 vs. v4.1+ clients really have to be quite
> > different since the protocols are so different. I'm not sure that v4.0
> > is fully fixable given its flaws.
> 
> The rule should be that if the lock could be recovered in NFSv4, then
> it should also be recoverable in NFSv4.1. Anything else should be
> considered to be a protocol regression.
> 

Po-tay-to, po-tah-to ;)

You say "protocol regression", I say "unavoidable change to protocol to
fix ambiguity".

IOW: I don't think it's quite that simple. The v4.0 reclaim logic was
just broken, period. The server had no way to know whether the client
had ever finished reclaiming and that's something that it needs to know
before it can hand out potentially conflicting locks.

v4.1 closes that hole but it does mean that the v4.1 server has to be
less forgiving to clients that didn't issue a RECLAIM_COMPLETE on the
last reboot. I don't see how we can reasonably avoid that.

-- 
Jeff Layton <jlayton@primarydata.com>
