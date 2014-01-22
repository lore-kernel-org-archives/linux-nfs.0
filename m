Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:44194 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752310AbaAVVwq (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 22 Jan 2014 16:52:46 -0500
Date: Thu, 23 Jan 2014 08:52:26 +1100
From: NeilBrown <neilb@suse.de>
To: Steve Dickson <SteveD@redhat.com>
Cc: Chuck Lever <chuck.lever@oracle.com>, varekova@redhat.com,
        sysstat@orange.fr, Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: Too many programs called nfsiostat.
Message-ID: <20140123085226.72ebaf85@notabene.brown>
In-Reply-To: <52DFC3C3.7080506@RedHat.com>
References: <20130410094639.5debfc90@notabene.brown>
	<20140121144517.5f549347@notabene.brown>
	<A5BFEC5C-7AF2-4A7E-856F-D62F35BCEFC0@oracle.com>
	<20140122112436.574f0e29@notabene.brown>
	<52DFC3C3.7080506@RedHat.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=PGP-SHA1;
 boundary="Sig_/MqzkmrmwMnu5+Ysk5sYpUkl"; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Sig_/MqzkmrmwMnu5+Ysk5sYpUkl
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

On Wed, 22 Jan 2014 08:12:35 -0500 Steve Dickson <SteveD@redhat.com> wrote:

>=20
>=20
> On 21/01/14 19:24, NeilBrown wrote:
> > On Tue, 21 Jan 2014 10:40:01 -0500 Chuck Lever <chuck.lever@oracle.com>=
 wrote:
> >=20
> >>
> >> On Jan 20, 2014, at 10:45 PM, NeilBrown <neilb@suse.de> wrote:
> >>
> >>>
> >>> (This time without the typo in Chuck's address - sorry).
> >>>
> >>> Not quite a year ago I wrote:
> >>>
> >>> On Wed, 10 Apr 2013 09:46:39 +1000 NeilBrown <neilb@suse.de> wrote:
> >>>
> >>>>
> >>>> Hi all,
> >>>> it seems that in 2010, a program called nfsiostat was added to the s=
ysstat
> >>>> package (http://sebastien.godard.pagesperso-orange.fr/)
> >>>>
> >>>> This is unfortunate because in 2008 a program called nfsiostat was a=
dded to
> >>>> the nfs-utils package.
> >>>>    (https://www.kernel.org/pub/linux/utils/nfs-utils/1.2.7/)
> >>>>
> >>>> The default install locations seem to be different (/usr/bin vs /usr=
/sbin),
> >>>> so packagers would not immediately notice.
> >>>>
> >>>> This seems like something that should be "fixed".
> >>>>
> >>>> Any suggestions what a good "fix" should look like?
> >>>>
> >>>> NeilBrown
> >>>
> >>>
> >>> No suggestions were forthcoming.
> >>> So I have a suggestion.
> >>> I propose we rename the "nfsiostat" in the "sysstat" package to
> >>> "nfsio-sysstat" and the "nfsiostat" in "nfs-utils" to
> >>> "nfs-utils-iostat".
> >>>
> >>> Does anyone object?  If not I'll send off patches shortly :-)
> >>
> >> What does the sysstat version do?  do we need two programs, or can the=
y be merged?  Or can one be dropped?
> >>
> >=20
> > It reads /proc/self/mountstats and reports some numbers, not unlike the
> > nfs-utils version.
> >=20
> > $ /usr/sbin/nfsiostat=20
> >=20
> > eli:/home mounted on /mnt:
> >=20
> >    op/s		rpc bklog
> >    3.55	   0.00
> > read:            ops/s		   kB/s		  kB/op		retrans		avg RTT (ms)	avg exe=
 (ms)
> > 		  0.000	  0.000	  0.000       0 (0.0%)	  0.000	  0.000
> > write:           ops/s		   kB/s		  kB/op		retrans		avg RTT (ms)	avg exe=
 (ms)
> > 		  0.000	  0.000	  0.000       0 (0.0%)	  0.000	  0.000
> > $ /usr/bin/nfsiostat=20
> > Linux 3.11.6-4-desktop (notabene.brown) 	01/22/2014 	_x86_64_	(8 CPU)
> >=20
> > Filesystem:               rkB_nor/s    wkB_nor/s    rkB_dir/s    wkB_di=
r/s    rkB_svr/s    wkB_svr/s     ops/s    rops/s    wops/s
> > eli:/home                      0.00         0.00         0.00         0=
.00         0.00         0.00      0.00      0.00      0.00
> >=20
> >=20
> > The man page for the sysstat version is:
> >=20
> > http://www.makelinux.com/man/1/N/nfsiostat
> Is this version still actively being maintain?=20

Last change was 5 days ago.

https://github.com/sysstat/sysstat/commits/master/nfsiostat.c

NeilBrown


>=20
> steved.
>=20
> >=20
> > while man page for nfs-utils version is:
> >=20
> > http://linux.die.net/man/8/nfsiostat
> >=20
> > NeilBrown
> >=20


--Sig_/MqzkmrmwMnu5+Ysk5sYpUkl
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)

iQIVAwUBUuA9oTnsnt1WYoG5AQKiBg/+OneXgQWjJDCAYr47rmP5ihrcx2+AEs9z
HUTxbl2SEo2l4SHxsfkht3Ou+yJZFHfAwvcgkMPwtY4tGHkXpx+CiGrApg/MS3i1
uNiagdWe2EavRC2ByeW2FtfYKZH6hMJc6Z349uMoKj4/6GJ9Ts8nh0Cab12WgP39
Opdi29RCD4REh3DnjRlqDDex33Un6wpf/vBOMCHLO14cDnnN8dUbnsVYw9beXjwF
Fakk+BISDGbV8DzGETGP10d4th9FfzaSgBsasU2Nnkudu572WXNTi2X6hwYm1uyE
Z074rLpGIy4eLasUO/3h7PUcEdPLK9k3VLy2usyhIbN+HThiEYf19GsBN2hweDVC
MbFgiYZSJPGzVWBjbP6XApiORha1L4vb/IQcW3np3F4fiYqsfVCD4J9kyo6eBeZ7
EmP/J2UaSIf4y4SwJJ3p59/OAqB/+1/ccrf8bAE8CaYSKbUvXAyXbZemycte8wpd
8My0OmhS9fG8FK+PzdcMzcEMUnIJ5MNMAVSuB3cv2fsQfwwPr6YMTWbFZXVUsond
Y1HD9A8sqo6nEki+3eiTwjw6ViBOkthh2oLqWB103xtqK3XT7e4FlP31Iygkw8Rn
DCjDXb0LD4sB518SnYs0qIBmAoqlu1pLz0blTcJvXaX6XBzPhTjDcs2TDNz4fb8r
Mmuv6l+Gv3A=
=0VhZ
-----END PGP SIGNATURE-----

--Sig_/MqzkmrmwMnu5+Ysk5sYpUkl--
