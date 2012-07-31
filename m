Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:59648 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751870Ab2GaG65 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 31 Jul 2012 02:58:57 -0400
Date: Tue, 31 Jul 2012 16:58:42 +1000
From: NeilBrown <neilb@suse.de>
To: Steve Dickson <SteveD@redhat.com>, Karel Zak <kzak@redhat.com>
Cc: NFS <linux-nfs@vger.kernel.org>
Subject: nfs-utils: Something is wrong in is_vers4()
Message-ID: <20120731165842.08017d60@notabene.brown>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=PGP-SHA1;
 boundary="Sig_/Lx.YKwpJ.hdz6cM.hzaA=qo"; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Sig_/Lx.YKwpJ.hdz6cM.hzaA=qo
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable


in nfs-utils, in utils/mount/mount_libmount.c there is a function

 is_vers4()

which
 /* returns: error =3D -1, success =3D 0 , unknown =3D 1 */

which seems odd to me... I would have chosen '1' for success (it is vers 4),
0 for failure (not vers 4), and maybe -1 for error (something went wrong).

This is used as follows:
			switch (is_vers4(cxt)) {
			case 0:
				/* We ignore the error from nfs_umount23.
				 * If the actual umount succeeds (in del_mtab),
				 * we don't want to signal an error, as that
				 * could cause /sbin/mount to retry!
				 */
				nfs_umount23(mnt_context_get_source(cxt), opts);
				break;
			case 1:			/* unknown */
				break;
			default:		/* error */
				goto err;
			}

so in the '0' (success, it is vers4) case we do nfs_umount23.  Odd.
In the '1' (unknown, so presumably vers2 or 3) we don't.  Ever.  Very odd.

So we don't currently send MOUNT_UMNT requests for v2 or v3.
We don't for v4 either because nfs_umount_do_umnt contains:

	/* Skip UMNT call for vers=3D4 mounts */
	if (nfs_pmap.pm_vers =3D=3D 4)
		return EX_SUCCESS;

so maybe is_vers4 isn't needed?

Looks like something needs to be fixed here but I'm not entirely sure what.
Karel??

BTW Steve, Karel's "[PATCH] umount.nfs: ignore non-nfs filesystems"
which appears in email:

From: Karel Zak <kzak@redhat.com>
To: NeilBrown <neilb@suse.de>
Cc: Steve Dickson <SteveD@redhat.com>, NFS <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] umount.nfs: restore correct error status when umount f=
ails.
Date: Thu, 12 Jul 2012 18:44:20 +0200

hasn't been applied, but probably should be.

Thanks,
NeilBrown


--Sig_/Lx.YKwpJ.hdz6cM.hzaA=qo
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.18 (GNU/Linux)

iQIVAwUBUBeCIjnsnt1WYoG5AQIjyxAAobfVndusBtIKzofnfzcRYBTf65Dxn6Lt
8UEIp23QlFwzx7EF1dbJgrrT2u7aTVnKjNQnJGzl1iXyBGzg/EKPMUzCRLvoZL7Z
Rsf1M3YRzh/RS39ooa2r8C11jPYXMDDcdDE9aH1YOcYRPu1tvjCVW1wvx9CKEgBy
akfKBb7ehMf5fRS13v0HpmUMBSYo/aYSgvVX/BjgycfjIpDwft9V5E8ad9oaF4Uv
yZ/hasZ0ENATO4bdTRCPJEjGL27TbY6fXOQJsgpI1IWDptN777jz9G1njBumk40l
3/qyjYwTRMgcaBZhH+2/J3fgdO3LsQcsIukLm/UXFAsXgJAKPEhhfxJB70H1Vm5+
pbxwff2MBgYLT0Bc9t1sGUiaXBoL+kwZTtJlKNfxJ+eaMrayzJPMaZqucYgL94gV
WchNsmAFrC3n+wUN7A8CiHDvqlB1jDmnYC6txl/Q/vGxpGGvyn/g7AhYSf9vxlQl
655SbA4bWWOFKr/dK2YPP9vFfCh9SfAhViYf9UU3u5hRfWjgPP7D2evMRAis1Lvi
CqGX8YMfYu4kGSaawxjdSjIKo94t5XC/plB42XrSlT7RI6V950GVy9PlXifvhNDe
VafCBfjEqzkMKVz5cGAhVI3rRPHsJQRqQUkl08oJ/OYzHKaaIPJIAn0LWdp6ZHOf
NE5fThh5xSA=
=vtj4
-----END PGP SIGNATURE-----

--Sig_/Lx.YKwpJ.hdz6cM.hzaA=qo--
