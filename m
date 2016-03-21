Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp.gentoo.org ([140.211.166.183]:53748 "EHLO smtp.gentoo.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756223AbcCUSLe (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 21 Mar 2016 14:11:34 -0400
To: linux-nfs@vger.kernel.org
From: Richard Yao <ryao@gentoo.org>
Subject: Making an interface for alternative data streams
Cc: linux-fsdevel@vger.kernel.org
Message-ID: <56F03945.40208@gentoo.org>
Date: Mon, 21 Mar 2016 14:11:17 -0400
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
 protocol="application/pgp-signature";
 boundary="EJAOhjsFhWVIgGQr3R7NNbAsQXf7erNej"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--EJAOhjsFhWVIgGQr3R7NNbAsQXf7erNej
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

I am thinking of implementing Solaris-style alternative data streams in
the ZFSOnLinux driver via an ioctl and writing a compatibility shim so
that software written to use O_XATTR can be trivially adapted to use the
interface.

I sketched out the fine details on github:

https://github.com/zfsonlinux/zfs/issues/4437

I would be much happier if the VFS gave filesystem drivers the ability
to implement O_XATTR. That would avoid the need to (ab)use an ioctl for
this and eliminate the risk of using a bit that would be defined to mean
something else. The former risks permissions checks becoming stale while
the latter is a situation that I would be happy to avoid.

Since this sort of interface is applicable to NFS too, I wanted to ask
what various mainline developers think about it before I tried doing an
initial implementation.


--EJAOhjsFhWVIgGQr3R7NNbAsQXf7erNej
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCAAGBQJW8DlOAAoJECDuEZm+6ExkQjoP/AueikdOuvkMm+OZh6XNPAc6
DjVcUmPjHly8vJ8iDL4h7uVSjjUxueHrOSLSHN5eu4scs5+wcWimTzKJzheYuvoB
hvzV+PL3j+uQGZth4IAQkOyiAQHkCGQFe2XFDhhKpHIDfURspZ9LbIWgxHyEuQSG
PrXZiud76H83p6Pv9fKZd3uLkQ0j02po8yOf52ip528z4R/HQsBkZVpWJjqZkf91
UE8e8EcZCixgSIkeGGjTNFNuCE6tELOuNMsGtZx+KD74kAYBA71b56f08vknarcW
KndDbjXqkSMEw9Auyad02mJJlBEVfREJvxIO6uTII3XxSRRIBUFMALk4/p6GKRF1
6aqSsyx7kHgOn2XcSvh/iC//vK5idzNJx//kxn4zdBKfGyvwlq0e2AHp6q/zodqx
Zs83IhhPTAeBYFY/vHXe0+Z3lpzRud1SrYS5Vxbs4114S/AYhFkxLNvYWe7DvPkk
S6QSbEeb1AA7adaLO7Iu6OgVbD979NTOdyeM+eH7wRIA/EztW62zlg0ns0s0B6EH
RVmLEJVvH5SJV05PWHSiMeziDpfV+JjTifAYdgDLkPhrPKm4v0udu0p47oDO4nwY
kayH39ZdVuzNz0sw3CCHiH+7H0T2B/2ke6eyM4DoJO7KL+Nln2Id9NdGrMcDQNWf
64fe06Nomh61roWBb/sM
=Nhfz
-----END PGP SIGNATURE-----

--EJAOhjsFhWVIgGQr3R7NNbAsQXf7erNej--
