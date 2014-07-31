Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:41028 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751008AbaGaUm1 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 31 Jul 2014 16:42:27 -0400
Date: Fri, 1 Aug 2014 06:42:17 +1000
From: NeilBrown <neilb@suse.de>
To: Ben Greear <greearb@candelatech.com>
Cc: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: Killing process in D state on mount to dead NFS server.
Message-ID: <20140801064217.01852788@notabene.brown>
In-Reply-To: <53DA8443.407@candelatech.com>
References: <53DA8443.407@candelatech.com>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 boundary="Sig_/5ZEnTI=HI8P.6.Btt=z54k6"; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Sig_/5ZEnTI=HI8P.6.Btt=z54k6
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

On Thu, 31 Jul 2014 11:00:35 -0700 Ben Greear <greearb@candelatech.com> wro=
te:

> So, this has been asked all over the interweb for years and years, but
> the best answer I can find is to reboot the system or create a fake NFS
> server somewhere with the same IP as the gone-away NFS server.
>=20
> The problem is:
>=20
> I have some mounts to an NFS server that no longer exists (crashed/powere=
d down).
>=20
> I have some processes stuck trying to write to files open on these mounts.
>=20
> I want to kill the process and unmount.
>=20
> umount -l will make the mount go a way, sort of.  But process is still hu=
ng.
> umount -f complains:
>   umount2:  Device or resource busy
>   umount.nfs: /mnt/foo: device is busy
>=20
> kill -9 does not work on process.

Kill -1 should work (since about 2.6.25 or so).
If it doesn't please report the kernel version and=20
 cat /proc/$PID/stack

for some processes that cannot be killed.

NeilBrown

>=20
>=20
> Aside from bringing a fake NFS server back up on the same IP, is there any
> other way to get these mounts unmounted and the processes killed without
> rebooting?
>=20
> Thanks,
> Ben
>=20


--Sig_/5ZEnTI=HI8P.6.Btt=z54k6
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)

iQIVAwUBU9qqKTnsnt1WYoG5AQKpEA//SMnoxhVBbIWNzmiGJJ0ahroUNw5em0pk
t7no66SkFmkciTxxjwm+1+rUAgxVmYt33ONQN9BuMTbo+EueRzYSamrBbIbriVE5
xXbiwqZIvzVfbYlGm43rRoknql/bh2/QlXxDsu9pjrVBWjco5qi/qCC2EsAde8/B
gaujYBbxzZOzhUR2+65rrmi7DfVG4gc+uVcysIXsmn5bT252+C4Cq+B7A3c7Qg/M
8u/XU4U1+1wEQ613IBPsTXZ+1rKvZlZ36QSjxSRscLkI3+TPFrSSz7XK6pI7LNDY
nqr87dt5w1HoffjzRRzcQenZJDRL01zVb1akkU/4kVzm6nEkoQx4DgKRjDM6KI3m
fTsqUJHp8gaOtY/W7j5A52qcbOkGdhzob9bc94zFdjfJSHuOt+55qByPEAhKW7RI
68Z5Fp1yonNCB29n3/AIrfzk/RQ8tmlhOpibBIqR/JCCzA28zhZjrZZn/d/31kVR
TLCF/GmsZmeSMzDLg7AshC5gVUaDKPBQ2bcvOAh7ItrohAeMGa6RoQnMyCooTMyQ
qlQGkvBimN2PH2PKtXHcS8DPjUxTkkR8O4hAiYm/p5Q0MZruDgRENvzaSnKIkTSX
h5YoUSKU69G8p0fCeLJwlqOdVS48CCCiHrCy+GJGqk+otJDwq1EnNf7wQvEGH4JM
cEL7CxbUGKw=
=cEUG
-----END PGP SIGNATURE-----

--Sig_/5ZEnTI=HI8P.6.Btt=z54k6--
