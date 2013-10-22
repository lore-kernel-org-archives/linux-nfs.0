Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:43056 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753185Ab3JWAYZ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 22 Oct 2013 20:24:25 -0400
Date: Wed, 23 Oct 2013 08:30:19 +1100
From: NeilBrown <neilb@suse.de>
To: Anna Schumaker <bjschuma@netapp.com>
Cc: NFS <linux-nfs@vger.kernel.org>, David Howells <dhowells@redhat.com>
Subject: Re: What is the long term fix for the idmapper key-quota problem.
Message-ID: <20131023083019.7dfc39f9@notabene.brown>
In-Reply-To: <52669069.5050700@netapp.com>
References: <20131021160514.4dbcbf12@notabene.brown>
	<52669069.5050700@netapp.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=PGP-SHA1;
 boundary="Sig_/Q+8qe2g1T3T9g6823IKaUVd"; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Sig_/Q+8qe2g1T3T9g6823IKaUVd
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

On Tue, 22 Oct 2013 10:49:13 -0400 Anna Schumaker <bjschuma@netapp.com> wro=
te:

> On Mon 21 Oct 2013 01:05:14 AM EDT, NeilBrown wrote:
> >
> > Hi,
> >  as you probably know, request_key() imposes a quota on
> > the number of keys that can be requested, which by default is quite low=
 (200).
> > When idmap exceeds this quota, request_key() returns an error and
> > the result is userspace sees "nobody" as the owner.
> >
> > A short term fix is to fiddle some sysctl values, but I wonder if any l=
ong
> > term fix is being planned.
>=20
> I don't have anything planned.

Maybe it is time to start planning then.  This is a very real regression th=
at
needs to be fixed.


>=20
> >
> > Probably the sensible thing would be for nfs-idmap to bypass the quota.
> > As keys are not held active for very long at a time, they should be gar=
bage
> > collected in due course.
> > There is currently no interface to request this but I suspect one could=
 be
> > added.
>=20
> Adding a new keyring interface might be a better question for David=20
> Howells, since he's done a lot of keyring work.

Let's add David to Cc then.  Hi David!

>=20
> How many idmap keys do you have active at once?  I'm guessing the quota=20
> is there for a reason, and increasing it in-kernel would probably be=20
> much easier than adding a new interface for short-lived keys.

Only 1 or 2 active at once.  Lots active sequentially in a short period of
time.

The problem, as I see it, is that you are trying to use a keyring like a
cache, and it doesn't seem to be designed for that purpose.

It certainly has some of the attributes of a cache, like an LRU list and a
garbage collector.  However the garbage collector doesn't discard entries
simply because they are old (as you would expect for a cache).  It discards
them because they have expired or have been marked as dead.

To get the keyring to act like a cache you need some way to discard the
"oldest" when the keyring is full.

Though as the quotas are per-user rather than per-keyring I'm not sure that
is really a well defined concept.

I was imagining something like
  while (request_key(&key_type_id_resolver, ...) =3D=3D -EDQUOT)
        discard_oldest_key(&key_type_id_resolver);

but it is entirely possible that root's entire quota is used for some other
key_type so this could fail.

David: is there some way that keyrings can be used as a simple FIFO cache
with some minimum number of entries?  If not, this might require a major
redesign.


NeilBrown


--Sig_/Q+8qe2g1T3T9g6823IKaUVd
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.19 (GNU/Linux)

iQIVAwUBUmbuaznsnt1WYoG5AQJUGQ/5AdR2k1agSRUDbTsTLIihQ1udeU/utZ8M
fXr5zk6xLVp8/bsF/P70dOdw1pnh90B3ikGiadZv+2i0c1qVtJn/0LcJlUZrVvtw
xQVBsh13OHR1iL7ifFY0BQIlwHBxZ8YnEUaPnVuy9gNO0G8IDsm0HhTHBykppQ6X
ybLBQyN1fofb2AjWg5SqhDfk9qnFlUgbssjW6rrGFceNtBZXRsdd5R8dP1nOhF/X
tCYiKeybZ5iGDjyjJYIaAV+Xai4YIBRIja8N7c6YDTq7WAS5HsLNXVgzxZOOIFH6
JeY8zf1WQUmdFtgfOSXWxI5JO5MtDyoGzMjhvJibig/dyng/0Imq19Eb79aByRCI
TjUQ5ZGd8CAEZ1H4prc6oMgnDEaq601s+CwI3evIpcSJDPVnspH/2sL7TDAcbTEl
wneamb4C1ZGsohwib69QckoCQ2pTfEa+julDKqmoEUdMd25+v8Mg1gtkTzIyqx6P
23K+CgJwh60JBssNW/e1azK4saWmHyDt6/W8zDlgS7aSmx/w3EZa2aWXVhN4i130
zKP5Kqi7ma0Pfh/w+lET2FPxoIie+oV3PpPExvXoy3CIa56VK+sGd7R/q59u7xj3
gx1PleiQvSjZm6BSfPCUr8HCh27igqGPr8PY0lZ+Z1b3XN1REaS36xYYzlzwgusy
tyaawx95Qxo=
=Vvxc
-----END PGP SIGNATURE-----

--Sig_/Q+8qe2g1T3T9g6823IKaUVd--
