Return-Path: linux-nfs-owner@vger.kernel.org
Received: from bombadil.infradead.org ([198.137.202.9]:53418 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751201AbaFCKz5 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 3 Jun 2014 06:55:57 -0400
Date: Tue, 3 Jun 2014 12:55:47 +0200
From: Peter Zijlstra <peterz@infradead.org>
To: John Stultz <john.stultz@linaro.org>
Cc: Trond Myklebust <trond.myklebust@primarydata.com>,
        Jeff Layton <jeff.layton@primarydata.com>,
        Linus Torvalds <torvalds@linux-foundation.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Linux Kernel mailing list <linux-kernel@vger.kernel.org>,
        Ingo Molnar <mingo@elte.hu>
Subject: Re: nfs4_do_reclaim lockdep pop in v3.15.0-rc1
Message-ID: <20140603105547.GV11096@twins.programming.kicks-ass.net>
References: <20140602104948.4faf0bc2@tlielax.poochiereds.net>
 <CAHQdGtRR6SvEhXiqWo24hoUh9AU9cL82Z8Z-d8-7u951F_d+5g@mail.gmail.com>
 <CALAqxLVmRdv3eVaf_ue-NutDmjxJA2NNAXnH-Tm4a6ud2U7Q4g@mail.gmail.com>
 <CAHQdGtSn9RwdgaFgEDQXjrxSA_Bg=rNWux+96-5f43dyUwXLRw@mail.gmail.com>
 <CALAqxLUwtMnE9eB_dfV=C5CLuXpEdB9+mK7pw2jgo5Yg2ACKPA@mail.gmail.com>
 <CAHQdGtQhurcOsAii7PYNZwEL4Xm-8a2CKBkS4OhrS0FhaAX3Aw@mail.gmail.com>
 <CALAqxLXeuiTffvgu0uBbn2fiYQ0-3PVdZ4V4AxqC-ZkTaFSfQQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="g4y/k9+5pukpRNAq"
In-Reply-To: <CALAqxLXeuiTffvgu0uBbn2fiYQ0-3PVdZ4V4AxqC-ZkTaFSfQQ@mail.gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


--g4y/k9+5pukpRNAq
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Mon, Jun 02, 2014 at 08:19:00PM -0700, John Stultz wrote:
> On Mon, Jun 2, 2014 at 5:59 PM, Trond Myklebust
> <trond.myklebust@primarydata.com> wrote:
> > On Mon, Jun 2, 2014 at 6:49 PM, John Stultz <john.stultz@linaro.org> wr=
ote:
> >> On Mon, Jun 2, 2014 at 3:42 PM, Trond Myklebust
> >> <trond.myklebust@primarydata.com> wrote:
> >>> The so_reclaim_seqcount only exists in order to tell the other threads
> >>> that they may need to replay file open or file lock requests that have
> >>> raced with state recovery (because those threads got scheduled out
> >>> after their RPC calls ran, but before they managed to set up the
> >>> tracking of the new state). It is basically an edge condition
> >>> killer...
> >>
> >> Would then swapping the acquisition order, so the seqcount is taken
> >> before the so_lock at the top of nfs4_reclaim_open_state() avoid this
> >> then, without having to disable lockdep?
> >>
> >
> > I can change the write seqcount to use raw_write_seqcount(), but that
>=20
> So this doesn't address my suggestion to change the locking order...
> is that solution not feasible?
>=20
> > doesn't answer the question of why raw_seqcount_begin() is the _only_
> > object out there with a "raw_" prefix, that doesn't explicitly disable
> > lockdep checking.
> >
> > What justifies the inconsistency?
>=20
> Here's the naming discussion...
> https://lkml.org/lkml/2014/1/2/404
>=20

Ah, I think I see what Trond means; so raw_write_seqcount_{begin,end}()
are without lockdep, _however_ raw_seqcount_begin() is with lockdep.

This is inconsistent within the same API (seqcount/seqlock).

Yes, we should fix that.

raw_seqcount_begin() is a variant of read_seqcount_begin() but without
the spin loop in. Maybe we should find a new name for this.

--g4y/k9+5pukpRNAq
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAEBAgAGBQJTjamzAAoJEHZH4aRLwOS69AUP/jEQuHc5R0qDHtIC4w0ddCBj
rWuoZpa/coiLxw632iyGo7HWgLfyvyi1uJOxvRf+l5aX8ZuYJAK3F5fnf06G0Hgo
q1ezg2KzGNO6li8HXOcHM7ezSOKQXEAr/rZNmeFuNiBDdQVsLWzRwEuck/E1M9bE
SsBNboXXaQ55U7PBNHqpYCVaMnz6lfYZ6I5Wd6KbaeIbw2bhOL/g/d6jHuGYpm9g
nRQQL1phBL8n7GtahtEe3DlOhVUk5C8B4Ct0Icbc1qGXFeiHMwE9EQ7aEzQgo7EQ
VD05q9w5KqF8eqXxgHfX2N5jk/jDak3pAoeWL/rFNmPC2OFEyJFEuxLR0N56+rnY
pH2agfeTtfcnRoSveyLn7JcVrx+kMgV/F/nnOXeJ+1Co/zFDumDbmikpkDnMviaQ
2RkO4DoczMMIeL/IdR3h5dQ5v2iL608Y9eCDXISWgiIDRIyo2N9cDmPCcBsVcgp1
IsAIZ5LWgA24cT54ZriHXmkgVsXFL6GN9xFd3Wn5JDLrzByPYMDS1YTj/apCAtWO
YV6RZDkwFMfvQWz6xJmqWv2RZ0xGceNtlKVOdEEqKwQ5PR5rAUIuVLxEXVZCBcuT
JEDF7r+4Fv9oM9i6YrOcDqlSnEQiHDjypVnaBAyY7Pgvy7tBn54jaxiOkwd29TgI
fAL6Vq5TUMZSW3XMQSIn
=no82
-----END PGP SIGNATURE-----

--g4y/k9+5pukpRNAq--
