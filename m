Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.mailbox.org ([80.241.60.212]:36686 "EHLO mx1.mailbox.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752789AbdLUUZX (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 21 Dec 2017 15:25:23 -0500
Date: Thu, 21 Dec 2017 21:25:16 +0100
From: Andreas Radke <andreas.radke@mailbox.org>
To: Steve Dickson <SteveD@RedHat.com>
Cc: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: Re: ANNOUNCE: nfs-utils-2.3.1 released.
Message-ID: <20171221212516.031618d8@laptop64.home>
In-Reply-To: <1a56bb72-cc10-ba74-2b04-4df588804ef5@RedHat.com>
References: <1a56bb72-cc10-ba74-2b04-4df588804ef5@RedHat.com>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
 boundary="Sig_/H7XMR5Q7U7R2qX1RyboOYYT"; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Sig_/H7XMR5Q7U7R2qX1RyboOYYT
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

This new version fails make check here now:

nsm_client.c:147:12: warning: this statement may fall through [-Wimplicit-f=
allthrough=3D]
    my_prog =3D atoi(optarg);
    ~~~~~~~~^~~~~~~~~~~~~~
nsm_client.c:148:3: note: here
   case 'v':
   ^~~~
make[4]: *** No rule to make target '../../support/nfs/libnfs.a', needed by=
 'nsm_client'.
make[4]: Target 'nsm_client' not remade because of errors.
make[3]: *** [Makefile:565: check-am] Error 2
make[2]: *** [Makefile:567: check] Error 2
statdb_dump.c: In function =E2=80=98dump_host=E2=80=99:
statdb_dump.c:38:17: warning: unused parameter =E2=80=98timestamp=E2=80=99 =
[-Wunused-parameter]
    const time_t timestamp)
                 ^~~~~~~~~
statdb_dump.c: In function =E2=80=98main=E2=80=99:
statdb_dump.c:91:10: warning: unused parameter =E2=80=98argc=E2=80=99 [-Wun=
used-parameter]
 main(int argc, char **argv)
          ^~~~
make[3]: *** No rule to make target '../support/nfs/libnfs.a', needed by 's=
tatdb_dump'.
make[3]: Target 'statdb_dump' not remade because of errors.
make[2]: *** [Makefile:1028: check-am] Error 2
make[1]: *** [Makefile:717: check-recursive] Error 1
make[1]: Target 'check' not remade because of errors.


Any idea?

Andy
Arch Linux

--Sig_/H7XMR5Q7U7R2qX1RyboOYYT
Content-Type: application/pgp-signature
Content-Description: Digitale Signatur von OpenPGP

-----BEGIN PGP SIGNATURE-----

iQEzBAEBCAAdFiEErcih/MFeAdRTEEGelGV6sg8qCSsFAlo8GK0ACgkQlGV6sg8q
CSsMswf/T9Id+3fmqbY333JuRWiOWTeZiDj1kO7vG4hI0SDH/0+E7OCMWu7IFxSL
zOPxIt9wNtTVAKFGUjvwW8z5+xt4O4628ac5Wq0erhFnBsmQPovJ1nl9ORVltSLu
9JCSrM4lzr6zYlDTcO8H0ojJkNqKhZuHclwT4JzsZ/o6v0fL9y9y8GqO/wySbFNY
p0GnBiurcttlxWs9jM2v1lQq7ymojRwhZaHlig4Hlm+PlsBFxNDwBBWWO7TVFm1A
nJSTunIx5RtGTr9U8uPn/FL3RYpLrCPRLXGOCZAEEOdqNKk0Pjv+R7jagoEh9Pyo
j2xAcfJhXzpdKcsesI0VWnmx6dElbw==
=+mn5
-----END PGP SIGNATURE-----

--Sig_/H7XMR5Q7U7R2qX1RyboOYYT--
