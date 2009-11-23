From: Michael Monnerie <michael.monnerie@is.it-management.at>
Subject: XFS, NFS and inode64 on 2.6.27
Date: Mon, 23 Nov 2009 14:19:50 +0100
Message-ID: <200911231419.50678@zmi.at>
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart1707051.dkEPfotEAB";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mailsrv1.zmi.at ([212.69.164.54]:48129 "EHLO mailsrv1.zmi.at"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751128AbZKWNpv (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 23 Nov 2009 08:45:51 -0500
Received: from mailsrv.i.zmi.at (h081217106033.dyn.cm.kabsi.at [81.217.106.33])
	(using TLSv1 with cipher DHE-RSA-CAMELLIA256-SHA (256/256 bits))
	(Client CN "mailsrv2.i.zmi.at", Issuer "power4u.zmi.at" (not verified))
	by mailsrv1.zmi.at (Postfix) with ESMTP id 36943C00AC0
	for <linux-nfs@vger.kernel.org>; Mon, 23 Nov 2009 14:20:20 +0100 (CET)
Received: from saturn.localnet (saturn.i.zmi.at [10.72.27.2])
	(using TLSv1 with cipher DHE-RSA-AES256-SHA (256/256 bits))
	(Client did not present a certificate)
	by mailsrv.i.zmi.at (Postfix) with ESMTPSA id 4147083C824
	for <linux-nfs@vger.kernel.org>; Mon, 23 Nov 2009 14:22:36 +0100 (CET)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--nextPart1707051.dkEPfotEAB
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: quoted-printable

(After sending this to the XFS list, I was suggested by =20
Christoph Hellwig to ask on this list. I'm not subscribed here, so=20
please CC me)

Dear all,

after searching for a long time I guess I found that inode64 on XFS with=20
kernel 2.6.27 (shipped with openSUSE 11.1) is incompatible with NFS.=20
Sorry if this was already know, it wasn't for me and finding the problem=20
was complicated.

This is my nfs4 root (fsid=3D0):

# ls -li
insgesamt 0
4666 drwxr-xr-x 2 root root 48 15. Nov 19:54 daten
4668 drwxr-xr-x 2 root root 48 15. Nov 19:54 download2
4667 drwxr-xr-x 2 root root 48 15. Nov 19:54 dvd-images
4661 drwxr-xr-x 2 root root 48 19. Nov 06:51 mailsrv-backup
4669 drwxr-xr-x 2 root root 48 15. Nov 19:54 q
4670 drwxr-xr-x 2 root root 48 15. Nov 19:54 z

Then I mount those subdirs (mount --bind ....) to fill it with the dirs=20
I want to share:

# ls -li
insgesamt 20
        256 drwxr-xr-x 14 root root  4096 19. Nov 03:01 daten
 6454034730 drwxrwx---  3 zmi  users   61 26. M=C3=A4r 2009  download2
    4070671 drwxr-xr-x  2 root root    76 13. Nov 12:17 dvd-images
 6500330752 drwxr-xr-x  5 root root  4096  8. Nov 04:31 mailsrv-backup
 8591091465 drwxr-xr-x 17 root root  4096 12. Nov 02:01 q
 2147483904 drwxrwx--- 31 zmi  bh    4096  7. Nov 09:58 z

The shares "daten" and "dvd-images" can be mounted from other servers. I=20
simply went to the original dirs of this mount-bind, and created several=20
new dirs:
mkdir 1 2 3 4 5 6 7 8 9
and one of them had an inode < 2G, so I moved the contents there and=20
renamed the dirs, remounted the --bind mounts and now have this:

# ls -li
insgesamt 20
      256 drwxr-xr-x 14 root root 4096 19. Nov 07:22 daten
184637244 drwxr-xr-x  3 root root   61 19. Nov 07:30 download2
  4070671 drwxr-xr-x  2 root root   76 13. Nov 12:17 dvd-images
960533297 drwxr-xr-x  5 root root 4096 19. Nov 07:27 mailsrv-backup
184190222 drwxr-xr-x 16 root root 4096 19. Nov 07:41 q
184637237 drwxr-xr-x 30 root root 4096 19. Nov 07:42 z

And everything mounts fine now.

(I still have one server that can mount, but not write, to such a share,=20
but that may be another problem)

Just to let others know that can be a problem.

mfg zmi
=2D-=20
// Michael Monnerie, Ing.BSc    -----      http://it-management.at
// Tel: 0660 / 415 65 31                      .network.your.ideas.
// PGP Key:         "curl -s http://zmi.at/zmi.asc | gpg --import"
// Fingerprint: AC19 F9D5 36ED CD8A EF38  500E CE14 91F7 1C12 09B4
// Keyserver: wwwkeys.eu.pgp.net                  Key-ID: 1C1209B4

--nextPart1707051.dkEPfotEAB
Content-Type: application/pgp-signature; name=signature.asc 
Content-Description: This is a digitally signed message part.

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.12 (GNU/Linux)

iEYEABECAAYFAksKi/YACgkQzhSR9xwSCbRu4ACcCEFztMrNp8qICaYl3/7dOkrw
YxEAn0hYtqVAjLLdM95yKSiBCzzfxlKd
=vjc0
-----END PGP SIGNATURE-----

--nextPart1707051.dkEPfotEAB--
