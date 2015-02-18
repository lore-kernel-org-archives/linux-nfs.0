Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:56789 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751562AbbBRBlJ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 17 Feb 2015 20:41:09 -0500
Date: Wed, 18 Feb 2015 12:41:01 +1100
From: NeilBrown <neilb@suse.de>
To: bfields@fieldses.org (J. Bruce Fields)
Cc: Steve Dickson <SteveD@redhat.com>, NFS <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH/RFC nfs-utils] exports.man: improve documentation of
 'nohide' and 'crossmnt'
Message-ID: <20150218124101.0c1cebfe@notabene.brown>
In-Reply-To: <20150216201751.GB22154@fieldses.org>
References: <20150216122107.4bfd4225@notabene.brown>
	<20150216201751.GB22154@fieldses.org>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 boundary="Sig_/JvADwuJXucYlFE7/tldy5_S"; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Sig_/JvADwuJXucYlFE7/tldy5_S
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

On Mon, 16 Feb 2015 15:17:51 -0500 bfields@fieldses.org (J. Bruce Fields)
wrote:

> On Mon, Feb 16, 2015 at 12:21:07PM +1100, NeilBrown wrote:
> >=20
> >=20
> > - note that 'nohide' is irrelevant for NFSv4
> > - note that children on a 'crossmnt' filesystem cannot be unexported
> > - note that 'nocrossmnt' is a valid option, but probably not useful.
> >=20
> > Signed-off-by: NeilBrown <neilb@suse.de>
> >=20
> > ---
> >=20
> > I wonder if we should add a new option, e.g. "noaccess" so that children
> > of a "crossmnt" filesystem can be hidden.  The  kernel wouldn't need to
> > know about this.  It would just tell mountd to refuse to export that
> > filesystem even if the parent was "crossmnt".
> > ??
>=20
> Seems logical enough, but I can't recall seeing requests for it, and
> the options here already seem complicated enough.

I haven't seem requests myself.  Just rumours of 'nohide' not working with
NFSv4, which seems to suggest that someone wants something like that.
But I cannot find a clear source.

Maybe:

http://ubuntuforums.org/showthread.php?t=3D2152643
http://ubuntuforums.org/showthread.php?t=3D1603881


>=20
> In theory something like that could also be done with namespaces.  (So,
> run mountd in a separate mount namespace that lacks those children.)

Do any of the NFS man pages need to be updated to say something about
namespaces?

NeilBrown


--Sig_/JvADwuJXucYlFE7/tldy5_S
Content-Type: application/pgp-signature
Content-Description: OpenPGP digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIVAwUBVOPtrTnsnt1WYoG5AQKSVxAAoSg5vstnO3pnKgEvVOp+u0oMHc0IiUd6
AZI4haitq21OsDq7USiE0kon/4zhB7uuv5BtlK7BMYgGu170g+pN/EIjqbH5Msf3
GFloMu484FYRAoiodXwzyuVCGl91NO+rELaYsn3k9tZH0NyzkYEvJRoXwgzv2Rhm
5aDvQBCEh7pwWt2h1HrK/trbLdvU20KddU3bqhakFiUsLrs8YgrpCU/ABRgHPZsc
9SXbZQBXRZGFE2uSr9AciK1kc5jdYFFxendRSfzMnFqV83ABLNn1HCFKHp8vx9M6
jubGmJK/cLWLfAqm+oEj8+D20e3PxwzpAM8aSgjpJWTa+yNCsg/Y4FhE6T1W1El6
5RVZE4l0TuzI5jqWg/ZipkRy0OlV89NgWMpL5cEK5jeutIT0ARQRZGOdMyaNaFvV
j0crq/x6BXAIVV15ekglogZT+HSkKAoCSg+o8qwlOzizbOlC2KeXzZ6jXHv8c6PQ
G1iKWqO541A6OO2xV5kLYRjfTxFgF4xTqHwzIY9RbsNI5B5X5pYUV81boduJtRSL
iyTPX3D9ZNj3nHEOFVRyzyigueuLUvy2ITkELPbcQf8b7yngR8XHb0x9WA9VqLjF
xgjUmlznruk6W/dCvnQJWKQhWzjXt3deqGQbL/4KLo404TQYTrNl+GUJGRoJ5CIa
w8PG57xNiko=
=Q6v4
-----END PGP SIGNATURE-----

--Sig_/JvADwuJXucYlFE7/tldy5_S--
