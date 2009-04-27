From: Andrew Savchenko <bircoph@gmail.com>
Subject: [Bug] NFSv4 fails to work without ipv6 kernel module
Date: Mon, 27 Apr 2009 19:03:07 +0400
Message-ID: <200904271903.36379.bircoph@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart1408610.grtFb74At8";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-fx0-f158.google.com ([209.85.220.158]:48158 "EHLO
	mail-fx0-f158.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752343AbZD0PDr (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 27 Apr 2009 11:03:47 -0400
Received: by fxm2 with SMTP id 2so2365843fxm.37
        for <linux-nfs@vger.kernel.org>; Mon, 27 Apr 2009 08:03:46 -0700 (PDT)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--nextPart1408610.grtFb74At8
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

Hello,

I have ipv6 support as a module (it may be needed in the recent=20
future), but currently I want ipv6 to be disabled on my system, so=20
I blacklisted this module. And here problems begin...

NFSv3 works flawlessly:
# mount 172.19.0.1:/home/ftp /mnt/nfs/

but NFSv4 fails:
# mount -t nfs4 172.19.0.1:/ /mnt/nfs/
mount.nfs4: Cannot allocate memory

After modprobe ipv6 it works:
# mount -t nfs4 172.19.0.1:/ /mnt/nfs/

I recompiled nfs-utils without ipv6 support, but this doesn't help.

Here is my /etc/exports:
/home/ftp 172.16.0.0/12
(ro,async,crossmnt,no_subtree_check,fsid=3D0,all_squash) \
        127.0.0.1/32
(ro,async,crossmnt,no_subtree_check,fsid=3D0,all_squash)

I use nfs-utils-1.1.5, I tested this on both vanilla linux kernels=20
2.6.28.7 and 2.6.28.9.

=2D-=20
Best regards,
Andrew

--nextPart1408610.grtFb74At8
Content-Type: application/pgp-signature; name=signature.asc 
Content-Description: This is a digitally signed message part.

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.11 (GNU/Linux)

iEYEABECAAYFAkn1yUgACgkQ2anJBBcsZw1xnACguw9gbp0W8kR3T8ObV57U0C+P
I+gAoIAJgT1udobsO+cqEMq9cGtBytlR
=y9Ah
-----END PGP SIGNATURE-----

--nextPart1408610.grtFb74At8--
