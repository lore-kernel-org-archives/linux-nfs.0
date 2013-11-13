Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:56295 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754327Ab3KMBNr (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 12 Nov 2013 20:13:47 -0500
Date: Wed, 13 Nov 2013 12:13:33 +1100
From: NeilBrown <neilb@suse.de>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
        Charles Edward Lever <chuck.lever@oracle.com>,
        Steve Dickson <SteveD@redhat.com>,
        "Linux NFS Mailing List" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] Adding the nfs4_secure_mounts bool
Message-ID: <20131113121333.2a16f646@notabene.brown>
In-Reply-To: <1384302651.15992.3.camel@leira.trondhjem.org>
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
	<1384302651.15992.3.camel@leira.trondhjem.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=PGP-SHA1;
 boundary="Sig_/HelAUhBpOvEE6ORq55AbHt/"; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Sig_/HelAUhBpOvEE6ORq55AbHt/
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

On Wed, 13 Nov 2013 00:30:53 +0000 "Myklebust, Trond"
<Trond.Myklebust@netapp.com> wrote:

> On Wed, 2013-11-13 at 11:23 +1100, NeilBrown wrote:
> > But back to my problem:  Following Trond's suggestion I've come up with=
 the
> > following patch.  Does it look right?
> >=20
> > The "fd =3D -1" is just to stop us trying to close a non-open fd in an =
error
> > path.
> >=20
> > The change from testing ->servicename to ->prog stops us from repeating=
 the
> > failed DNS lookup on every request, not that the failure isn't fatal.
> >=20
> > The last stanza makes sure we always reply to an upcall, with EINVAL if
> > nothing else seems appropriate.
>=20
> Wouldn't EACCES be more appropriate as a default?
>=20

Maybe.  And that is what you suggested before and I mis-remembered - sorry.

However EACCES is "Permission denied" which doesn't quite seem right to me.
It isn't really "you aren't allowed to do that", but "your question doesn't
make sense".

However I'm not fussed.  If you prefer EACCES, then I'll make it EACCES.

Thanks,
NeilBrown

--Sig_/HelAUhBpOvEE6ORq55AbHt/
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.19 (GNU/Linux)

iQIVAwUBUoLSPTnsnt1WYoG5AQIbKA/+KxEAyU70Q0iRG/tDavopBpRD09XFv0u1
unDFZjSoZIzwFiVvhsQFebNECqb8M+R/jf8ZR7is3Ny2wp7cwKgjwAXBHY+RcrB9
s/S1Kc8CWLyk6aMI/ePplD8s5B6LhrkMOlR3LFsap4rox9IpwhrHwYcWZTHDQZmy
ij8CU12TJZPd82qOLGOX56v4hGfZWAr0jzeW7lvsDt5LDROIsjatrqx7hklnPEwU
9bJ74vWy/zJptKLMRBD+SvP5CHzfHBsHqDGE/zF/k8ML9S6x7ebeADGVh8es6zJA
M78qP082bDpv5nJGKV4iFZfCy9VLUTXDhM/AESWDwdBpdwvBhQYFa/qSND/ZvPcI
eHYulXX15k9zVMfDc7tmEAR9HgJHm+DlY5ISppOVEh9JKXWdeG6odUn9MLaOu3Pj
+ENmjpT/GLuMag/lqz5MlynA8h8e8vX8xnvbNOQ+gnR5dQaKDRxcv7ZqyOuR1/GG
ZUaG+9+aqKZd24QUzmhQ8poHVxFLkSucoFuMPeMbK5cTTIyDiWWdF4sNWVoClW/h
NTqJfy9aWVXmkvjMV+rSKrCIZahpirQFVNtoQJLVhGHtV0hGUXjlOvbDDsGevnQ+
VVZflSja2Xi2CvD48TLz4HciFbhabhtNUuxF7fJGRBxolDerqCOCjuvZmhUVkcoL
7a4yKiWoyuw=
=NC/m
-----END PGP SIGNATURE-----

--Sig_/HelAUhBpOvEE6ORq55AbHt/--
