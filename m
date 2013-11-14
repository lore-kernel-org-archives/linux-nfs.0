Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:54435 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750797Ab3KNBKY (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 13 Nov 2013 20:10:24 -0500
Date: Thu, 14 Nov 2013 12:10:10 +1100
From: NeilBrown <neilb@suse.de>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
        Charles Edward Lever <chuck.lever@oracle.com>,
        Steve Dickson <SteveD@redhat.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] Adding the nfs4_secure_mounts bool
Message-ID: <20131114121010.74b4fe29@notabene.brown>
In-Reply-To: <1384316126.15992.33.camel@leira.trondhjem.org>
References: <1384037221-7224-1-git-send-email-steved@redhat.com>
	<E061C7A8-DC27-49BA-93C2-DC2E9C19EA7B@netapp.com>
	<52811CBB.3070204@RedHat.com>
	<E520DD5F-7E5A-4B6C-9FF6-6B74DA36FD1E@oracle.com>
	<5281290B.6000201@RedHat.com>
	<E0FBCF46-C70F-41E5-BA67-48406253CD7E@oracle.com>
	<20131112161135.25a487da@notabene.brown>
	<F58540AB-00BE-4AC5-B823-7260F30F8D58@netapp.com>
	<20131112161634.GC15060@fieldses.org>
	<20131113112346.3f5f3bd0@notabene.brown>
	<20131113034636.GA32628@fieldses.org>
	<1384316126.15992.33.camel@leira.trondhjem.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=PGP-SHA1;
 boundary="Sig_/Nqduv7vgGj/FgB/.654Hh7m"; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Sig_/Nqduv7vgGj/FgB/.654Hh7m
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

On Wed, 13 Nov 2013 04:15:26 +0000 "Myklebust, Trond"
<Trond.Myklebust@netapp.com> wrote:

> On Tue, 2013-11-12 at 22:46 -0500, J. Bruce Fields wrote:
>=20
> > OK, but it still seems dumb to even attempt the reverse lookup: the
> > lookup probably isn't secure, and the mount commandline should have a
> > name that we can match to a krb5 principal without needing any other
> > lookups.
> >=20
> > So I'd think reasonable behavior in this case would be to just try the
> > IP address on the chance there's actually an nfs/x.y.z.w@REALM
> > principal.  (Or just fail outright if kerberos doesn't allow principals
> > that look like that.)
>=20
> Looking through the krb5.conf manpage etc it looks as if a lot of this
> functionality should be covered by the krb protocol itself without us
> needing to do explicit reverse lookups in rpc.gssd. I'm thinking of the
> 'canonicalize' and 'rdns' options, for instance. Am I wrong?
>=20

I suspect there is a good chance that you are correct, though my man page
only mentions "rdns", not "canonicalize" so there may be some version
dependency to think about.

However I think fixing this is a separate (though related) issue to fixing =
my
current problem and would probably require more code examination and testing
than I feel inclined to at the moment.  So I'll leave this side of the
question alone and just fix the bit that is clearly broken.

Thanks,
NeilBrown

--Sig_/Nqduv7vgGj/FgB/.654Hh7m
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.19 (GNU/Linux)

iQIVAwUBUoQi8jnsnt1WYoG5AQIGlhAAlwsBS/u9Gi7fowD8Ubic0VmySahtADei
PzQhWhBmueC0mSvH+dvFcvfQ6IDmZ+MnDSPT2atNxQe17CMwMqznfJxb5FElHX1J
ZwNwKP/SdpLzwx1a+6oxCnDSiCfiDzCFFp55g2cStCpvBbDA4AcnNx5WLiNQh0pa
zKDjbZVghHLW5GkwGpgCa1k2zqa5aze/i57tLlnTujD7iZ/SYIVTvGLY02c45UaJ
n0v8nQwgF2WtZpQeTrFYCZyNkRlsnCpIfF4DD9BL4qmwya6/aupZ9Q4bGIi6ry3u
p/xTdvCgoLLjB39Gg7i055WPgAys2FLqFf9vKL3J6D64Bguw5mcHYux7wjuWJeCo
M0AVsBcH0zOn4KiVGf4HEpYTqubxCipu7g62x5Emn9znxR5iM0DT4JUwatUSodg8
DYX+5uaJmqD8nCA+ZXp6DuPN36FYVKolJQsnaL4qk0EdZm3KrFJ2Mzp7jsAGt55D
Ce4wU/NnTPYXuuMix3dBsW7YmdtUDebRB0xkJjzdY59q3yjRslrqgruUvbYppjP7
CnuD8T7kN4GuTj3JSNw1ffXvVn880mClpJrwp2vvvopD5V5KWAQ8h5YthFI+5t7y
4r8NaLgkBEHzavPkNxc1KqwLceC4FGhIFYYAQMhXTJC6Xt9YN6QRduqoLWWJu20q
xDcLpjxl85k=
=lO6x
-----END PGP SIGNATURE-----

--Sig_/Nqduv7vgGj/FgB/.654Hh7m--
