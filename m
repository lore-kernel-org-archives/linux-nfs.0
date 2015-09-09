Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:47281 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752709AbbIIUkg (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 9 Sep 2015 16:40:36 -0400
Date: Wed, 9 Sep 2015 16:40:36 -0400
From: Bruce James Fields <bfields@fieldses.org>
To: Jeff Layton <jeff.layton@primarydata.com>
Cc: Trond Myklebust <trond.myklebust@primarydata.com>,
        Andrew W Elble <aweits@rit.edu>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: upgrade/downgrade race
Message-ID: <20150909204036.GD25750@fieldses.org>
References: <m2h9n3btno.fsf@discipline.rit.edu>
 <CAHQdGtQ84tUFEXaUwSngAmQst3NbjZDCSwB2jtqRqR29R4wBWg@mail.gmail.com>
 <CAHQdGtTvPPXjSm8Aq6AefMec4UEUwL6+swwav8SSFMQJMDchCA@mail.gmail.com>
 <20150909144935.51e3653b@tlielax.poochiereds.net>
 <CAHQdGtS2BL+d9NvV5adG=Mts0Qx6_=5Fwo34+nbz-eMVepnnKg@mail.gmail.com>
 <20150909151801.3fd2243f@tlielax.poochiereds.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20150909151801.3fd2243f@tlielax.poochiereds.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Sep 09, 2015 at 03:18:01PM -0400, Jeff Layton wrote:
> On Wed, 9 Sep 2015 15:01:54 -0400
> Trond Myklebust <trond.myklebust@primarydata.com> wrote:
> 
> > On Wed, Sep 9, 2015 at 2:49 PM, Jeff Layton <jeff.layton@primarydata.com> wrote:
> > > On Wed, 9 Sep 2015 13:49:44 -0400
> > > Trond Myklebust <trond.myklebust@primarydata.com> wrote:
> > >
> > >> +Bruce, +Jeff...
> > >>
> > >> On Wed, Sep 9, 2015 at 1:12 PM, Trond Myklebust
> > >> <trond.myklebust@primarydata.com> wrote:
> > >> > On Wed, Sep 9, 2015 at 9:37 AM, Andrew W Elble <aweits@rit.edu> wrote:
> > >> >>
> > >> >> In attempting to troubleshoot other issues, we've run into this race
> > >> >> with 4.1.4 (both client and server) with a few cherry-picked patches
> > >> >> from upstream. This is my attempt at a redacted packet-capture.
> > >> >>
> > >> >> These all affect the same fh/stateid:
> > >> >>
> > >> >> 116 -> OPEN (will be an upgrade / for write)
> > >> >> 117 -> OPEN_DOWNGRADE (to read for the existing stateid / seqid = 0x6
> > >> >>
> > >> >> 121 -> OPEN_DOWNGRADE (completed last / seqid = 0x8)
> > >> >> 122 -> OPEN (completed first / seqid = 0x7)
> > >> >>
> > >> >> Attempts to write using that stateid fail because the stateid doesn't
> > >> >> have write access.
> > >> >>
> > >> >> Any thoughts? I can share more data from the capture if needed.
> > >> >
> > >> > Bruce & Jeff,
> > >> >
> > >> > Given that the client sent a non-zero seqid, why is the OPEN_DOWNGRADE
> > >> > being executed after the OPEN here? Surely, if that is the case, the
> > >> > server should be returning NFS4ERR_OLD_STATEID and failing the
> > >> > OPEN_DOWNGRADE operation?
> > >> >
> > >
> > > The problem there is that we do the seqid checks at the beginning of
> > > the operation. In this case it's likely that it was 0x6 when the
> > > OPEN_DOWNGRADE started. The OPEN completed first though and bumped the
> > > seqid, and then the downgrade finished and bumped it again. When we bump
> > > the seqid we don't verify it against what came in originally.
> > >
> > > The question is whether that's wrong from the POV of the spec. RFC5661
> > > doesn't seem to explicitly require that we serialize such operations on
> > > the server. The closest thing I can find is this in 3.3.12:
> > 
> > RFC5661, section 8.2.2
> >   Except for layout stateids (Section 12.5.3), when a client sends a
> >    stateid to the server, it has two choices with regard to the seqid
> >    sent.  It may set the seqid to zero to indicate to the server that it
> >    wishes the most up-to-date seqid for that stateid's "other" field to
> >    be used.  This would be the common choice in the case of a stateid
> >    sent with a READ or WRITE operation.  It also may set a non-zero
> >    value, in which case the server checks if that seqid is the correct
> >    one.  In that case, the server is required to return
> >    NFS4ERR_OLD_STATEID if the seqid is lower than the most current value
> >    and NFS4ERR_BAD_STATEID if the seqid is greater than the most current
> >    value.  This would be the common choice in the case of stateids sent
> >    with a CLOSE or OPEN_DOWNGRADE.  Because OPENs may be sent in
> >    parallel for the same owner, a client might close a file without
> >    knowing that an OPEN upgrade had been done by the server, changing
> >    the lock in question.  If CLOSE were sent with a zero seqid, the OPEN
> >    upgrade would be cancelled before the client even received an
> >    indication that an upgrade had happened.
> > 
> > The suggestion there is clearly that the client can rely on the server
> > not reordering those CLOSE/OPEN_DOWNGRADE operations w.r.t. a parallel
> > OPEN. Otherwise, what is the difference between sending a non-zero
> > seqid and zero?
> > 
> > > "The server is required to increment the "seqid" field by
> > >  one at each transition of the stateid.  This is important since the
> > >  client will inspect the seqid in OPEN stateids to determine the order
> > >  of OPEN processing done by the server."
> > >
> > > If we do need to fix this on the server, it's likely to be pretty ugly:
> > >
> > > We'd either need to serialize seqid morphing operations (ugh), or make
> > > update_stateid do an cmpxchg to swap it into place (or add some extra
> > > locking around it), and then have some way to unwind all of the changes
> > > if that fails. That may be impossible however -- we're likely closing
> > > struct files after all.
> > 
> > Updates to the state are already required to be atomic. You can't have
> > a stateid where an OPEN_DOWNGRADE or CLOSE only partially succeeded.
> > 
> > >
> > > Now, all of that said, I think the client has some bugs in its seqid
> > > handling as well. It should have realized that the stateid was a r/o
> > > one after the OPEN_DOWNGRADE came back with the higher seqid, but it
> > > still issued a WRITE just afterward. That seems wrong.
> > 
> > No. The client is relying on the server not reordering the
> > OPEN_DOWNGRADE. It expects either for the OPEN to happen first, and
> > the OPEN_DOWNGRADE to fail, or for the OPEN_DOWNGRADE to happen first,
> > and for both operations to succeed.
> > 
> > Trond
> 
> In that case, the "simple" fix would be to add a mutex to
> nfs4_ol_stateid. Lock that in nfs4_preprocess_seqid_op, and ensure that
> we unlock it after bumping the seqid (or on error).
> 
> Bruce, any thoughts?

Why isn't nfsd4_cstate_assign_replay()/nfsd4_cstate_clear_replay()
already doing this with the so_replay.rp_mutex lock?

Looking at it.... OK, sorry, that's 4.0 only.  I don't know if that
should be shared in the session case.

--b.
