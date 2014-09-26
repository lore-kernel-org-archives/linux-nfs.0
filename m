Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:36574 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755983AbaIZVro (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 26 Sep 2014 17:47:44 -0400
Date: Fri, 26 Sep 2014 17:47:43 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: Jeff Layton <jeff.layton@primarydata.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH v2 0/5] nfsd: support for lifting grace period early
Message-ID: <20140926214743.GH27412@fieldses.org>
References: <1408473509-14010-1-git-send-email-jlayton@primarydata.com>
 <20140926183949.GC27412@fieldses.org>
 <20140926145446.21a99698@tlielax.poochiereds.net>
 <20140926194616.GE27412@fieldses.org>
 <CAABAsM664Ce0JhBa=uK9+srsNB4_Ww4LLTymfOvcr1aM3g2X=g@mail.gmail.com>
 <20140926204549.GF27412@fieldses.org>
 <CAHQdGtR7uWW7s=ug=1_7n6uf_vU885d9Vc8W7kzaw4ncmdPi6w@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <CAHQdGtR7uWW7s=ug=1_7n6uf_vU885d9Vc8W7kzaw4ncmdPi6w@mail.gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Sep 26, 2014 at 04:58:47PM -0400, Trond Myklebust wrote:
> On Fri, Sep 26, 2014 at 4:45 PM, J. Bruce Fields <bfields@fieldses.org> wrote:
> > On Fri, Sep 26, 2014 at 04:37:23PM -0400, Trond Myklebust wrote:
> >> On Fri, Sep 26, 2014 at 3:46 PM, J. Bruce Fields <bfields@fieldses.org> wrote:
> >> >
> >> > As I understand it, the rule for the client is: you're allowed to
> >> > reclaim only the set locks that you held previously, where "the set of
> >> > locks you held previously" is "the set of locks held by the clientid
> >> > which last managed to send a reclaim OPEN or OPEN_CONFIRM".  So for
> >> > example once client1 sends that unrelated OPEN reclaim it's giving up on
> >> > anything else it doesn't manage to reclaim this time around.
> >>
> >> The rule for the client is very simple: "You may attempt to reclaim
> >> any locks that were held immediately prior to the reboot of the
> >> server."
> >> It doesn't matter how those locks were established (ordinary OPEN,
> >> delegated open, reclaim open, LOCK, reclaim lock...).
> >>
> >> However if the server reboots and the client did not manage to
> >> re-establish a lease (SETCLIENTID+SETCLIENTID_CONFIRM and/or
> >> EXCHANGE_ID+CREATE_SESSION) before the second reboot, then it is the
> >> server's responsibility to block that client from reclaiming any
> >> locks, since the client has no way to know how many times the server
> >> has rebooted.
> >> Ditto, of course, if the client tries to reclaim any locks outside the
> >> grace period and the server isn't tracking whether or not those locks
> >> have been handed out to another client.
> >
> > Agreed with everything except:
> >
> >         (SETCLIENTID+SETCLIENTID_CONFIRM and/or
> >         EXCHANGE_ID+CREATE_SESSION)
> >
> > If I remember correctly: RFC 5661 says the point where this happens is
> > actually RECLAIM_COMPLETE.  RFC 3530 was more vague but suggested first
> > OPEN reclaim or OPEN_CONFIRM, and 3530bis makes that explicit.
> >
> > But the client can choose an earlier point without violating the
> > protocol--it means it will decline reclaiming some things it could have,
> > but that's safer than the reverse mistake.
> >
> 
> Where is this documented? I'm not seeing it.

It's more vague than I remembered:

http://tools.ietf.org/html/rfc5661#section-8.4.3

	The server will set this for any client record in stable
	storage where the client has not done a suitable
	RECLAIM_COMPLETE (global or file system-specific depending on
	the target of the lock request) before it grants any new (i.e.,
	not reclaimed) lock to any client.

And the corresponding langue in 8.6.3 of rfc 3530 is:

	a timestamp that is updated the first time after a server boot
	or reboot the client acquires record locking, share reservation,
	or delegation state on the server.  The timestamp need not be
	updated on subsequent lock requests until the server reboots.

I thought there was something referring specifically to OPEN reclaim or
OPEN_CONFIRM as the point where "the client acquires record locking" but
can't find it on a quick skim.

I also say this is "vague" because, unfortunately, in both cases, this
language is part of a description of an example server implementation,
no actual protocol requirement is made explicit.

Which is weird given that noticing the partial-reclaim case was actually
Dave Noveck's original motivation for introducing RECLAIM_COMPLETE (then
RECOVERY_COMPLETE), with the grace-period shortening an extra benefit:

	http://osdir.com/ml/ietf.nfsv4/2006-01/msg00020.html

	Adding the RECOVERY_COMPLETE op allows this situation to be
	dealt with fairly simply. If a client has not recovered all of
	its locks and we have the possiblity of having given out a lock
	inconsistent with one of those (the normal realization of this
	would be that once we declare grace over with some client's
	reclaims not complete) we mark that client as essentially having
	had a lock effectively revoked and thus it would not allowed to
	reclaim locks after a subsequent reboot since it could no longer
	vouch for all the locks it thinks it had.

In the 3530 case we decided that the only safe point to choose was the
one described in the sample server implementation, so 3530bis says:

	A server may consider a client's lease "successfully
	established" once it has received an open operation from that
	client.

(And "open operation" probably is still too vague.)

Sorry for the length.

Anyway, if the client's currently doing this at SETCLIENTID_CONFIRM and
CREATE_SESSION then I think that's correct but more conservative than
necessary.  Which may be a good idea given that I think the chance of a
random server implementor making there way through all this is small.

--b.
