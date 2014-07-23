Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:58601 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755865AbaGWDyE (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 22 Jul 2014 23:54:04 -0400
Date: Wed, 23 Jul 2014 13:53:53 +1000
From: NeilBrown <neilb@suse.de>
To: =?UTF-8?B?QW7DrWJhbA==?= Monsalve Salazar <anibal@debian.org>
Cc: linux-nfs@vger.kernel.org, John Hughes <john@calva.com>,
        755703@bugs.debian.org
Subject: Re: libtirpc1 0.2.4-1 causes rpc.gssd to crash on nfs4 sec=krb5
 mount
Message-ID: <20140723135353.2ae2bd08@notabene.brown>
In-Reply-To: <20140723004721.GA10142@master.debian.org>
References: <20140722144831.2069.50552.reportbug@celtic.calvaedi.com>
	<20140723004721.GA10142@master.debian.org>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 boundary="Sig_/h_TkEjr/0/gZuLO.kyzsUFp"; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Sig_/h_TkEjr/0/gZuLO.kyzsUFp
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

On Wed, 23 Jul 2014 10:47:21 +1000 An=C3=ADbal Monsalve Salazar
<anibal@debian.org> wrote:

> On Tue, 2014-07-22 16:48:31 +0200, John Hughes wrote:
> > Package: libtirpc1
> > Version: 0.2.3-2
> > Severity: important
> >=20
> > Dear Maintainer,
> >=20
> >    * What led up to the situation?
> >=20
> > Upgraded to libtirpc1_0.2.4-1_amd64.deb
> >=20
> >    * What was the outcome of this action?
> >=20
> > nfs4 sec=3Dkrb5 mounts stopped working, rpc.gssd segfaults in libgssapi=
_krb5
> >=20
> > Jul 22 16:22:22 celtic kernel: [  285.086078] rpc.gssd[1611]: segfault =
at 6c ip 00007f24c8f9e72f sp 00007fff60b1df10 error 4 in libgssapi_krb5.so.=
2.2[7f24c8f8b000+45000
> >=20
> > Downgrading to 0.2.3-2 "fixes" the problem.
> >=20
> > Note that some non-Debian people seem to have the same problem, e.g.
> >=20
> > http://forums.opensuse.org/showthread.php/494292-segmentation-fault-Ope=
nSUSE-13-1-when-mounting-nfs4-with-kerberos
> >=20
> > or:
> >=20
> > https://bugs.archlinux.org/task/39217
> >=20
> > -- System Information:
> > Debian Release: jessie/sid
> >   APT prefers unstable
> >   APT policy: (500, 'unstable'), (1, 'experimental')
> > Architecture: amd64 (x86_64)
> > Foreign Architectures: i386
> >=20
> > Kernel: Linux 3.14-1-amd64 (SMP w/4 CPU cores)
> > Locale: LANG=3Den_US.UTF-8, LC_CTYPE=3Den_US.UTF-8 (charmap=3DUTF-8)
> > Shell: /bin/sh linked to /bin/dash
> >=20
> > Versions of packages libtirpc1 depends on:
> > ii  libc6              2.19-7
> > ii  libgssglue1        0.4-2
> > ii  multiarch-support  2.19-7
> >=20
> > libtirpc1 recommends no packages.
> >=20
> > libtirpc1 suggests no packages.
> >=20
> > -- no debconf information
>=20
> https://bugs.debian.org/cgi-bin/bugreport.cgi?bug=3D755703
>=20
> How can I fix this bug in Debian?

Build both nfs-utils and libtirpc *without*  --with-gssglue, get rid of
libgssglue1.
(this was a major headache for openSUSE, but some of that was internal issu=
es)

NeilBrown

--Sig_/h_TkEjr/0/gZuLO.kyzsUFp
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)

iQIVAwUBU88x0Tnsnt1WYoG5AQIhiw//QMJHMefbKh1nEoyptQQ7SU7smFFlp8QF
3sszcfaIiqs6JOdlQYfVuNC2OD12tOC5cWMuiPrjmmySvttavSW30gTTssGjfopy
htOgp1zRe1REVdYa5XitKu9Rtwsl0EZxXweDtlCl09lV2hMs9TTFmh8+xgFN8mHC
V3LaDUOYDXgDXNgZUwQ8+0rjg6BNZhl7K0l7gi2frc26p8zmg9MuQH5AG8fYaW0X
Py5Wmk9oKUh0gMKaqcKNFdIyG6GfHuoDk9XOBsOYlYGJQbCq5emkWLtCLKoJipJi
Avc5AOQt/zLgNm8LXidt3RmCjDD8pJq0C2YROVvQsYoeKJBA/FTPUH8gPdGDHMdd
HT2EgxbVbu6b1FOMrsH6dk2tegkLSdWlISKuQv7trfKcut/qqZR05z+Qf3EmF3/n
K2EPZLZFH98eUAX9r4MovxdKX5P6XN0XufU/iBLv1r59NjAyKqqZEQ4RLVs5gSuO
2SxyGEvnzjzLz3dNgJR2vzuYrdZTPQE7EHOWG5tAM8afO459f79n8YCtq7B3lRKZ
shotXx+3GPtYz0Fd0VWKHDXA7pgbOLbmdoVzNdtmurAeybsmY87mxliC2foiq3pj
L+Q68+XIUnXS02bRjW5ONKq3BwY3Mlw3A13xXdRwN2/oL7rV1juIALJnmz0LO57X
HbVtVHk79nQ=
=t87l
-----END PGP SIGNATURE-----

--Sig_/h_TkEjr/0/gZuLO.kyzsUFp--
