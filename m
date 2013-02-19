Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:12064 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932711Ab3BSMeE (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 19 Feb 2013 07:34:04 -0500
Date: Tue, 19 Feb 2013 07:33:18 -0500
From: Jeff Layton <jlayton@redhat.com>
To: NeilBrown <neilb@suse.de>
Cc: Al Viro <viro@ZenIV.linux.org.uk>,
        "Myklebust, Trond" <Trond.Myklebust@netapp.com>,
        NFS <linux-nfs@vger.kernel.org>,
        Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: More fun with unmounting ESTALE directories.
Message-ID: <20130219073318.2b822c56@tlielax.poochiereds.net>
In-Reply-To: <20130219101450.42c1752c@notabene.brown>
References: <20130212113813.427b8e05@notabene.brown>
	<20130214104230.013b7f71@tlielax.poochiereds.net>
	<20130218132509.0ce779de@notabene.brown>
	<20130218184609.GF4503@ZenIV.linux.org.uk>
	<20130218144655.42b3f3e3@tlielax.poochiereds.net>
	<20130218201502.GH4503@ZenIV.linux.org.uk>
	<20130219101450.42c1752c@notabene.brown>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=PGP-SHA1;
 boundary="Sig_/=thgERu36yQ8Z.minFw.pDW"; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Sig_/=thgERu36yQ8Z.minFw.pDW
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

On Tue, 19 Feb 2013 10:14:50 +1100
NeilBrown <neilb@suse.de> wrote:

> On Mon, 18 Feb 2013 20:15:02 +0000 Al Viro <viro@ZenIV.linux.org.uk> wrot=
e:
>=20
> > On Mon, Feb 18, 2013 at 02:46:55PM -0500, Jeff Layton wrote:
> >=20
> > > Ok, that helps. In that case, this patch might be a reasonable
> > > forward-port of the one Neil sent earlier today. Note that this doesn=
't
> > > really do anything for the umount problem, but it does seem to fix the
> > > testcase for the problem I've been looking at.
> > >=20
> > > Thoughts?
> >=20
> > If we really go for "in this case revalidate should be weaker", we might
> > as well introduce a separate method for it.
> >=20
> > As it is, we have several callers of ->d_revalidate(); this one (in
> > complete_walk(), only for FS_REVAL_DOT filesystems) and ones in
> > lookup_dcache() and lookup_fast() (in both cases we have and want the
> > name to match).  There are only two fs with FS_REVAL_DOT present - nfs
> > and 9p.  *IF* we want to make ->d_revalidate() on NFS behave differently
> > in complete_walk() case, it would argue for just splitting the method
> > in two, replacing FS_REVAL_DOT with "dentry has this method" and probab=
ly
> > taking a good look at what 9p needs in the same case.
>=20
> Sounds good to me.
>=20
> Reminds me that we used to have an i_op->revalidate() method for revalida=
ting
> just the inode (not the dentry).  It called nfs_revalidate_inode() for NF=
S.
>=20
> We lost it over a decade ago:
>=20
> commit cc41b90f8a9ad3cd85a39dd4fcc71f965a675b0e
> Author: Alexander Viro <viro@math.psu.edu>
> Date:   Tue May 21 21:12:46 2002 -0700
>=20
>     [PATCH] kill ->i_op->revalidate()
>    =20
>     kill ->i_op->revalidate()
>=20
>=20
>=20
> :-)
>=20
> (this doesn't help my umount problem though)
>=20

That would work for NFS, but unfortunately I think 9p needs a dentry
operation here if we're not going to break it. Anyone want to suggest a
new name for it? I'm using d_reval_dot for now, but a better name would
be welcome...

--=20
Jeff Layton <jlayton@redhat.com>

--Sig_/=thgERu36yQ8Z.minFw.pDW
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.19 (GNU/Linux)

iQIcBAEBAgAGBQJRI3EOAAoJEAAOaEEZVoIVYq8P/2sNQ8Ro5zY9Q7+mNuwLPVHF
OS9ZxI4tg7nzU1Y7vMo8qOSr6/ekU0ptZ0uxW2r/vRHOAOVqlt8gTgU+naJrlRED
P+Z4MKVp1nyw59vupGc7A0/HQVZf5JFBOZwZfvOX5ZUox1+RPcpvPOrTco5fhh5B
0CltmLHr9agqm3inuBQM9N85APnd2oJ4Sun1A9GnRG+XKml98TdBRYvNsCPCNwS0
Ixkw9Nh6XU9FSJuXkxZOdbwqPZU7YdhIeIgjXM8pbnfMQ1UUI9t6wTIIquR9Qngq
WmjulAhnXNIJBtaLFZmg1Pn2azjzXYBVBQDLTxHqwshmD4iAiECcDEaPA0v0tK4O
dSnmAud6+fycm+Xs2w6Vd5qFkBW7Y8D6cuR6JFf9O2iJ4KCf5eX2sC7hpGaJKH1O
h/jfgerDUDSIwvZr/vUCewnE98MIf+KAs6sXOCMhY9UNW6wDD08p2bzcktdb4VMn
c+CBbFIHPCTO2T9YoIi+1wVwyWz38jrZZa8RCt7ZkoWqeHcqB/Hcey+adA4xS8XA
DyKZESzyktjR1Tf3dGskvS4BIgsfTfS+piDHT2IJJE8GDir/zYctywoVwpMgSZI6
rz2lmelw6NZYGn4ww7S8s3SUyblM4kFX90INf5jIRZ9w7NTF8XAnXdq5d4Hvzk2r
UTk43IEtVoez2gALpUW+
=hKud
-----END PGP SIGNATURE-----

--Sig_/=thgERu36yQ8Z.minFw.pDW--
