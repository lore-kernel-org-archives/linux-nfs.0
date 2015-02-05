Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-wi0-f176.google.com ([209.85.212.176]:54587 "EHLO
	mail-wi0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756908AbbBEN35 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 5 Feb 2015 08:29:57 -0500
Received: by mail-wi0-f176.google.com with SMTP id bs8so39003526wib.3
        for <linux-nfs@vger.kernel.org>; Thu, 05 Feb 2015 05:29:55 -0800 (PST)
Received: from [10.89.64.70] (p4FDBAFEF.dip0.t-ipconnect.de. [79.219.175.239])
        by mx.google.com with ESMTPSA id x10sm7907747wif.15.2015.02.05.05.29.52
        for <linux-nfs@vger.kernel.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 05 Feb 2015 05:29:52 -0800 (PST)
Message-ID: <54D3704C.6010305@googlemail.com>
Date: Thu, 05 Feb 2015 14:29:48 +0100
From: Tobias Powalowski <tobias.powalowski@googlemail.com>
MIME-Version: 1.0
To: linux-nfs@vger.kernel.org
Subject: rpc-statd won't start for user NFS mounts
Content-Type: multipart/signed; micalg=pgp-sha256;
 protocol="application/pgp-signature";
 boundary="BqXd9fDkl1UMRr8vgPCJRCtnJQ7K9XBDu"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--BqXd9fDkl1UMRr8vgPCJRCtnJQ7K9XBDu
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

Hi,
https://bugs.archlinux.org/task/42491
This one I can reproduce, doing NFS3 user,noauto setting in fstab makes
it impossible to mount it as user.
- The systemd service nfs-client.target is loaded.
- rpcbind comes up by doing the mount
- rpc-statd is not coming up because of authentification error.
Failed to start rpc-statd.service: Interactive authentication required.
What is the correct way to solve this?

Thanks for your answer.
greetings
tpowa

--=20
Tobias Powalowski
Archlinux Developer & Package Maintainer (tpowa)
http://www.archlinux.org
tpowa@archlinux.org



--BqXd9fDkl1UMRr8vgPCJRCtnJQ7K9XBDu
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQEcBAEBCAAGBQJU03BMAAoJEHcd9mJ+32gfAlUIAKDa1xyshvrvLSR2dKlxGbPU
/Q+Z3XArNKdBydakTScT0wBoUwUzybXCQgY57ZKhGc1PymeBwvXOgmDNwbdSexAu
zKx66ex2GqwBn/TaXodTRzRDPZFvWOOPWwNPz5dZ0A49vWsZ1os/HfgzS9Kpar8F
Hab31JWyxsuo0pbitgj/4LNA8HUQIG85utlhkG3wrXtTYs3nKIQ3FUX7ivTJvvld
ZD/N4896OT6X9ga2jYXTyONolL+PinMJxpzkoJo2UsXiaKKe2H3yw06WgtZURQ1y
SbJWvY7SIniZN35/myjvMZN6g+jXe17CzvBqvZz0S+YzJtn0qBkZcwX0kp+DM80=
=+SiR
-----END PGP SIGNATURE-----

--BqXd9fDkl1UMRr8vgPCJRCtnJQ7K9XBDu--
