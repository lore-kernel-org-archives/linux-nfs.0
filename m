Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:43875 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753254Ab2DWBE1 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 22 Apr 2012 21:04:27 -0400
Date: Mon, 23 Apr 2012 11:04:19 +1000
From: NeilBrown <neilb@suse.de>
To: "J. Bruce Fields" <bfields@redhat.com>
Cc: linux-nfs@vger.kernel.org, Jeff Layton <jlayton@redhat.com>
Subject: Re: [PATCH 0/3] Fix use_ipaddr race
Message-ID: <20120423110419.1311c364@notabene.brown>
In-Reply-To: <1334961978-2843-1-git-send-email-bfields@redhat.com>
References: <1334961978-2843-1-git-send-email-bfields@redhat.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=PGP-SHA1;
 boundary="Sig_/c97.V+X0YcIfzHc_gS7WWQ/"; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Sig_/c97.V+X0YcIfzHc_gS7WWQ/
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

On Fri, 20 Apr 2012 18:46:15 -0400 "J. Bruce Fields" <bfields@redhat.com>
wrote:

> From: "J. Bruce Fields" <bfields@redhat.com>
>=20
> We have a report of failed upcalls that occur when use_ipaddr is
> toggled.  The problem appears to be that for example after turning on
> use_ipaddr, the kernel may still see upcalls for clients such as "*".
>=20
> The following patches (untested except to check that they compile...)
> attempt to fix that by just letting nfsd_fh() accept either client type;
> does anyone see a problem with that?
>=20
>=20
> The current code actually attempts to avoid tihs problem by flushing
> caches on a use_ipaddr change (see the cache_flush() call in
> utils/mountd/auth.c:check_useipaddr().  But that doesn't work, because a
> write to a cache/flush file doesn't actually provide useful guarantees
> to the caller on return:
>=20
> 	- as far as I can tell, cache_clean leaves alone any entries
> 	  that were created in the current second.

We only do one thing each second - right?

Maybe a simple work around is:
  - update state in mountd
  - sleep(1)
  - flush cache.


?? Then anything dependant on the old behaviour will be gone.

> 	- cache_clean only removes entries from the cache, it doesn't
> 	  wait for them to actually be destroyed: so an in-progress nfsd
> 	  thread could still make an upcall using information from one
> 	  of the flushed entries.

Ideally we would like those threads to abort and re-start from the beginnin=
g.
That's not really very easy with all the NFSv4 state issues is it?

I think waiting for them to complete would be problematic.  As you say,
deadlocks and such.
So we need to continue to serve them faithfully.

Does that just mean changing nfsd_fh to *not* test use_ipaddr, but rather to
inspect the 'dom' and if it looks like an IP address, act as though use_ipa=
ddr
was set, else not?

>=20
> These seem like bugs in their own right to me: a cache-flush operation
> that actually guaranteed the entries were gone on return would be more
> useful.  And I wonder whether this doesn't also cause exportfs bugs....
>=20
> I'm not sure what to do about it, though.
>=20
> I don't think the existing interface is really fixable, since fixing the
> second problem above would (I think) require the cache/flush write to
> wait on in-progress rpc's, but those in-progress rpc's could be waiting
> on mountd, creating a deadlock.
>=20
> A new interface shouldn't need to accept a time--every actual user just
> wants to cache flushed now.

Having a time-stamp seems like a good idea at the time .... I don't remember
why though. :-(

>=20
> Maybe the first problem could be solved by replacing the time by a
> counter incremented on each insert of a cache entry.
>=20
> And the second could be fixed by waiting on in-progress rpc's.  That
> might not help mountd, but it would help exportfs at least.
>=20
> --b.
>=20
> J. Bruce Fields (3):
>   mountd: unconditionally resolve ip address

Not a good idea.  If /etc/exports only contains IP address and subnets, then
we don't ever want to do any address resolution.  The "resolve ip address"
must at least be conditional on "are there any domain-name, wild-cards,
netgroups in /etc/exports".


>   mountd: helper function for export upcall's client matching

This depends on the earlier patch?  and does the host-name lookup earlier.
That really can cause a delay sometimes so it should be as late as possible.


>   mountd: ignore use_ipaddr and just try both client types

Maybe ... though if we could syntactically distinguish "use_ipaddr" domains
from "!use_ipaddr" domain and still just choose one test to perform, I think
I'd prefer that.


NeilBrown

--Sig_/c97.V+X0YcIfzHc_gS7WWQ/
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.18 (GNU/Linux)

iQIVAwUBT5Sqkznsnt1WYoG5AQJvkg//Qy3Ayv0zl1Dl2JpKsKVUSDa21GZynr0Z
WcWNqAtHtjFRGv+2wA/GHtwd1dzUNnc1fDeij/qI0u0jz/305YfcVwFscbc3Pr6i
rGZqeCMX/jMJqEvWe3uhzZN74M329dPXNxaVIZEHBCx0j9I/rN4AncnX979tZepM
sOev0dGoNx93gISrmbUjR/pKZG5ucdScYtbHiueX7FAFuItvvacQUIQKi3a41OFN
hofRq3pURkrt9CBx796V8xnDJE4E5OYtOdDjUkWF0rFEJ0QImrG0MJDKjoOlOxDO
d0x0hkqLB+MP+0SAToSZ/DzVEO17FPg6MeveX3T7GliTUpz/LET/p4//auOPjF26
D0qnxOIivRO4gkziawaiqvtefdUNtKHfnwoGQTr1bMpxdZSMPgvJ/HoggP0Upv24
rITzbKlMfFIPxsjPesk6aqsEQw4EXEejrcpJP5FXOZh+VY3F8AF0bKicblO6vPdJ
zddaF2TOlc2RUIqRxWkQR1sigwXyyVw/+Jy5ZkpFAi18QO0HoNJuiBm263ha4uEW
s9PlmfXNhE76aLu+oHbelN/I89/2w/EnuY4AN5pDd1+syUB2dR/nEAWEHuuwNS2d
gM9QAUUxFWaJR6fgNiccRSdz/k53y97MAz6SQHCq0dbAiS6CnxZfbei2JC1+P4Hg
g9mAiB3cWQk=
=7w6P
-----END PGP SIGNATURE-----

--Sig_/c97.V+X0YcIfzHc_gS7WWQ/--
