Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:37499 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756390AbaFRG1x (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 18 Jun 2014 02:27:53 -0400
Date: Wed, 18 Jun 2014 16:27:35 +1000
From: NeilBrown <neilb@suse.de>
To: Alex Bligh <alex@alex.org.uk>
Cc: linux-nfs@vger.kernel.org
Subject: Re: Peculiarity in handling NFSv4 mount paths with fsid=0
Message-ID: <20140618162735.34b3ae50@notabene.brown>
In-Reply-To: <EB04E1C061D36F087D431E74@nimrod.local>
References: <EB04E1C061D36F087D431E74@nimrod.local>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=PGP-SHA1;
 boundary="Sig_/YBHXf2UfaYVq094jd8DmV/I"; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Sig_/YBHXf2UfaYVq094jd8DmV/I
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

On Sat, 14 Jun 2014 10:37:14 +0100 Alex Bligh <alex@alex.org.uk> wrote:

> I've discovered I think a peculiarity with handling mount paths with fsid=
=3D0.

It looks to me like this has nothing to do with "fsid=3D0" and everything t=
o do
with using the expected number of '/' characters.


> This is on Ubuntu Precise (old) but I've used 3.13 too with the same
> problem.
>=20
> I have an exports line like this:
> /storage/local=20
> *(rw,sync,wdelay,nohide,crossmnt,insecure,no_root_squash,no_all_squash,no=
_subtree_check,secure_locks,acl,fsid=3D0,anonuid=3D65534,anongid=3D65534)
>=20
>=20
> And mounted a directory like this (which succeeded)
>=20
> # mount -t nfs4 10.157.208.1:nfs-01 /mnt
>=20
> And unmount did this:
>=20
> # umount 10.157.208.1:nfs-01
> /mnt was not found in /proc/mounts
> /mnt was not found in /proc/mounts
>=20
> Examination showed /proc/mounts contained the line:
>=20
> 10.157.208.1:/nfs-01 /mnt nfs4=20
> rw,relatime,vers=3D4.0,rsize=3D262144,wsize=3D262144,namlen=3D255,hard,pr=
oto=3Dtcp,port=3D0,timeo=3D600,retrans=3D2,sec=3Dsys,clientaddr=3D10.157.20=
8.1,local_lock=3Dnone,addr=3D10.157.208.1=20
> 0 0
>=20
> Whereas the outptut of 'mount' contained the line:
>=20
> 10.157.208.1:nfs-01 on /mnt type nfs4=20
> (rw,addr=3D10.157.208.1,clientaddr=3D10.157.208.1)
>=20
> There is a difference here between "/nfs-01" and "nfs-01".
>=20
> This might merely be an annoying bug, where it not for the fact that as
> far as I can tell the mount is now cannot be unmounted with userspace
> tools. No amount of --fake and -n appears to help. System reset required.

Doesn't
   umount /mnt
work?


>=20
> Of course had I typed:
>=20
> # mount -t nfs4 10.157.208.1:/nfs-01 /mnt
>=20
> all would have been well.
>=20
> I suspect something should be canonicalising the path consistently.
>=20

I agree there.

NeilBrown


--Sig_/YBHXf2UfaYVq094jd8DmV/I
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)

iQIVAwUBU6ExVznsnt1WYoG5AQLNQg/+P7af2gPa5qxs1qQVjfclAJc88A956RqY
hlAQ02HWoe/4ZFgvLVpSnh7KzNO0/m0tqt0QwF0qNX3XD5r8Jh3Y4JOvZbqli1j+
9ISLRp3AzUYSc+psovzBAHwHBsqW8N08LS94n0J+AuKf6Sevu/iilxO52Gg8IYf4
10o8rsl9pHFyjRYbaQyOkw4hwgech30BXrr1b0cL/um2u2DaYwkxoQZrlUAw2sSa
HkpJEGlycUFKyfhM8QvxFy11bePrrIsU6jbPk16UjEXiIXaRZbt9l76zTFI0xQt8
h8IA5GJjdWpVc1nqaI3Ezv8t55EO9QVKpRt/L9wQjiP4OfuZn7K8EWMn4gTfccT4
qD7BXlMjyjm/nGFEiPovJO25ycamrEjgKLxETLMyYv4Z0UqjJMn9CQ284d+2vmWF
pS6tytjslvCdddkcg1bDvtjGt1+bwwsy8osgbA6wNH62q0xkvrYhpPcg2T9TsCrE
PrTEf5EQhGORX2WQ1WlYT9ahOI6EBcJWbiDMDGSHrvKUxtpLDHeAqq3uMEtH9VkA
GwDHy5MYsw9u5T8qKGE287AaoeLDp03HS3ZihpMv8vfclFOH+fKV2ymzWacXS630
CAA4CGWyeWxrgKUWpk48Wz0c6H3AhBps6wP3DKYoKZTwFNrnQ9WpSrLb25rDvmTe
MBMeKAkwMWk=
=GCpw
-----END PGP SIGNATURE-----

--Sig_/YBHXf2UfaYVq094jd8DmV/I--
