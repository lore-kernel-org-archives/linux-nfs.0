Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:11286 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753132AbaCaMLv (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 31 Mar 2014 08:11:51 -0400
Date: Mon, 31 Mar 2014 08:11:45 -0400
From: Jeff Layton <jlayton@redhat.com>
To: NeilBrown <neilb@suse.de>
Cc: "J. Bruce Fields" <bfields@fieldses.org>, NFS <linux-nfs@vger.kernel.org>
Subject: Re: nfsd needs "md5", but fips=1 disables it -> hang
Message-ID: <20140331081145.61efb4e7@tlielax.poochiereds.net>
In-Reply-To: <20140331175458.5f674ac5@notabene.brown>
References: <20140327205239.2ea29060@notabene.brown>
	<20140327143024.GA27633@fieldses.org>
	<20140327131132.5fe8ea33@ipyr.poochiereds.net>
	<20140331175458.5f674ac5@notabene.brown>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 boundary="Sig_/7K5GQ0zrtsu4uJ9YMrU794a"; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Sig_/7K5GQ0zrtsu4uJ9YMrU794a
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

On Mon, 31 Mar 2014 17:54:58 +1100
NeilBrown <neilb@suse.de> wrote:

> On Thu, 27 Mar 2014 13:11:32 -0700 Jeff Layton <jlayton@redhat.com> wrote:
>=20
> > On Thu, 27 Mar 2014 10:30:24 -0400
> > "J. Bruce Fields" <bfields@fieldses.org> wrote:
> >=20
> > > On Thu, Mar 27, 2014 at 08:52:39PM +1100, NeilBrown wrote:
> > > >=20
> > > > [I sent this 2 days ago but haven't seen it come back on the nfs
> > > >  list and don't see it in the archives.  Maybe someone we cannot
> > > > name filtered it because it contains the word 'crypto' ??]
> > >=20
> > > Huh.
>=20
> And my email still didn't get to the list, but at least it got to Bruce.
> And you replies only got to be directly, not through the list!
> Very weird ... I wonder if I care....
>=20

That is odd. Might be worth talking to DaveM and company and seeing why
they're getting dropped...

> > >=20
> > > > Apparently there is a thing called "FIPS" which lists some approved
> > > > crypto algorithms.  And some sites need to only use those.  So they
> > > > boot their kernel with
> > > >     fips=3D1
> > > > and anything non-fips-approved stops working.
> > > >=20
> >=20
> > Yes. As best I can tell, the primary purpose of FIPS is to render the
> > machine unusable for any non-trivial purpose. ;)
>=20
> I'd notice this wasn't the only thing that broke.  However it appear to b=
e a
> thing that we want to support :-(
>=20
> >=20
> > The story I have heard is that FIPS carves out an exemption for the use
> > of unapproved crypto as long as it stays "within the
> > implementation" (whatever that means).
>=20
> So it is probably ok to use md5 as long as we don't pretend that we are d=
oing
> crypto (which we aren't)
>=20

Probably, yes... The other problem with FIPS is that it's apparently
filled with a lot of weasel-words so getting definitive answers for
this sort of thing is pretty tough.

> >=20
> > > > "md5" is not fips-approved.
> > > >=20
> > > > So
> > > >=20
> > > > 	desc.tfm =3D crypto_alloc_hash("md5", 0, CRYPTO_ALG_ASYNC);
> > > >=20
> > > > in
> > > >=20
> > > > nfs4_make_rec_clidname(char *dname, const struct xdr_netobj *clname)
> > > >=20
> > > >=20
> > > > always fails when fips=3D1.  This interferes with efficient NFS
> > > > service (every 'open' hangs).
> > > >=20
> > > > s/md5/sha1/
> > > >=20
> > > > makes this problem go away, because sha1 is fips-approved.
> > > >=20
> > > > My question is: is this safe, or is the hash value used in some
> > > > external way (in /var/lib/nfs/v4recovery ??).
> > >=20
> >=20
> > The hashes aren't used outside the machine and they're not even
> > cryptographically significant. The kernel only uses it as a way to
> > squash the long-form clientid into something that it can use as a
> > directory name.
> >=20
> > In hindsight, the decision to use md5 for that purpose was
> > unfortunate...
>=20
> Isn't there a book about that .. "A series of unfortunate decisions" ...
>=20
>=20
> >=20
> > > Right, it's used in v4recovery, so you'd lose client state when you
> > > rebooted the server to the new (SHA1-using) server.
> > >=20
> > > Our intention was to migrate people that care about FIPS to the umh
> > > upcall.  But rhel6 has a hack (a private md5 implementation).
> > >=20
> > > Cc'ing jlayton (currently traveling) who did that work.
> > >=20
> >=20
> > Yep, exactly.
> >=20
> > For any newer kernels and nfs-utils, just use nfsdcltrack and don't
> > bother with the legacy code. Eventually I can forsee us getting rid of
> > the legacy client tracking.
>=20
> Where "newer" means .... Linux v3.8 and nfs-utils 1.2.7.
> I'll keep that in mind for future releases then, thanks.
>=20
>=20
> >=20
> > > >=20
> > > > If changing the hash to sha1 is safe, we should do that and
> > > > probably add select CRYPTO_SHA1
> > > > to Kconfig just to be safe.
> > > >=20
> > > > If we really need to keep it stable, I guess we need to find a way
> > > > to perform md5 computations that bypasses the fips checks.
> >=20
> > For RHEL6 I just made a private md5 implementation. I had considered
> > switching it to sha1 instead, but the problem is that you'll lose
> > persistent state if you upgrade the kernel and it switches the hashing
> > implementation.
> >=20
>=20
> Sounds like a plan ... thanks for the help.
>=20

No problem. What I basically did was copy crypto/md5.c to the nfsd
directory and scrape out all of the crypto API goop. md5_transform() is
still available even when fips=3D1 is enabled. ;)

--=20
Jeff Layton <jlayton@redhat.com>

--Sig_/7K5GQ0zrtsu4uJ9YMrU794a
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)

iQIcBAEBAgAGBQJTOVuCAAoJEAAOaEEZVoIVrQAP/i2kDLJxk9gZFMyWFVLd1ar9
j3zQ/F2mUbmNXuVAmNZ5yh5p2EHzJ3pxUTzalf1V5Yw3FULzJR7G4M0xIXfsvLZU
2ru2ZXf8cZ0QhwK+RhgJagM7cChK+de43iSA5uA84JuM006pqXmH5mA/tQwWDWP9
4dqhYH54/7IlfY0oAIY6UJbmdcGlI2gB82XSGocbyebgI2hOscseOHt/RLdChLaE
9Sc/5sjBlgtApOlCAPkjmErfQd3YMcfX8wgInTs8chZFvedBVd1eRwS02npeI+VW
3cdh4E3Q3WkBEP3T/lrxenZ1AkDKL9mbF5OBUM33JVtQ4Kd9UXVzsQW25QAYHcRT
GU5vx/KlGkDcolF7zoxHKgTJHgPVSIstjXVoVF2TJmcIpQgy8LfOb01L8oIiwPIa
51iI1gZjN1pFbAzZY+bUVqU45WIThR0nwFclkqLExJHzfKGFHfpoW3I8M7HdRf0I
6ADdA7/xgyFld6s3/c6KqVgNvSSo1a2D1yvZqNEIlf2WKEQQqJ0ZxSh3/z8JdVNg
HnB7WrleYcUXBYAXg7DHyKvidQ4OlGnnULbg1A4NjobiW/OIbu8ot9npXEpPDDgN
bPcaOdgrPgoT47D6qD4XBAoGHV+5tE8DmSSwUaG//t8UUdif94SypmgsnlzVH7F2
d3THi9RYSZjpNbMXqrFa
=CLY0
-----END PGP SIGNATURE-----

--Sig_/7K5GQ0zrtsu4uJ9YMrU794a--
