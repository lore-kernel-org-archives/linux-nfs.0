Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:52706 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754740AbaICB2x (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 2 Sep 2014 21:28:53 -0400
Date: Wed, 3 Sep 2014 11:28:43 +1000
From: NeilBrown <neilb@suse.de>
To: stable@vger.kernel.org, NFS <linux-nfs@vger.kernel.org>
Cc: Lars Behrens <lars.behrens@pi.uka.de>
Subject: Incorrect backport to 2.6.32-stable - NFSD regression.
Message-ID: <20140903112843.66bcd6dd@notabene.brown>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 boundary="Sig_/B9I4xI7tNNxoI_2C7SGsYvF"; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Sig_/B9I4xI7tNNxoI_2C7SGsYvF
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable


2.6.32.30 contains:

commit 63d059e73ff4574b79bd8aa252b5fc00b6326ddf
Author: NeilBrown <neilb@suse.de>
Date:   Wed Feb 16 13:08:35 2011 +1100

    nfsd: correctly handle return value from nfsd_map_name_to_*
   =20
    commit 47c85291d3dd1a51501555000b90f8e281a0458e upstream.
   =20
    These functions return an nfs status, not a host_err.  So don't
    try to convert  before returning.
   =20
    This is a regression introduced by
    3c726023402a2f3b28f49b9d90ebf9e71151157d; I fixed up two of the callers,
    but missed these two.
   =20
    Reported-by: Herbert Poetzl <herbert@13thfloor.at>
    Signed-off-by: NeilBrown <neilb@suse.de>
    Signed-off-by: J. Bruce Fields <bfields@redhat.com>
    Signed-off-by: Greg Kroah-Hartman <gregkh@suse.de>


But it does *not* contain a backport of
3c726023402a2f3b28f49b9d90ebf9e71151157d.

So rather an fixing a regression, it introduces one.

This patch should be reverted.

See also https://bugzilla.novell.com/show_bug.cgi?id=3D893787

NeilBrown

--Sig_/B9I4xI7tNNxoI_2C7SGsYvF
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)

iQIVAwUBVAZuyznsnt1WYoG5AQLQOg//SPFhcSdmea08aWFsTb0RrGFwZc7VTKIi
qzMEElKAAusLDH1WYYUkaPJR1AnD084SyfQP3IUA0srnSxtXwAPqNWoLW4bDbkIn
s6uDnrDFI+cObcrZ0IUCsEI2lAxKFLDDfKT3dffI2hBEv8Krpu1pw8MyiXNHJvS/
9B4WaYQcP/m7yTUpZ5qDjAOX1KhHqwainG4Otfg8B4fFN6o2zemI/ex6a9SfVs7j
dyFHzw8GmeCRAxLYQr6BFMRsJZh5dmfe7agHlXejpd6eVYbNBURcBOBAhSnTFOc1
qfI+IR3ppsd2k30TgavHHK5jzRefGshaBuft9OqVnGJMDW2qy//lGvmrcCmw9KV6
ek2kIBRR/YdrDHYtfr6/9Nw8XIg9wPUtsP8FU47CoIZfD/dunCREKxjeH2YiKrq6
36TM0Ufk6/1KWLfr8c2PwdagWGfMVxoVyYuhu2a6JE6IpH6J4kz15Fwctr3ryE0/
+EHw/1PoyElfbkFrjJylF5W4p+MKpIcQmqOyMVSA/WSJsixPGNMEGAAzz8R0h1mr
ZMdVkuXEdB4K/djyc/dlp1q+BAaTp+pOBvMyKH5EUlh0iswH7QUiRdUB1hJPWSsh
xio+4C51NJ9Fk05AJcUYRmt/MbdLZPAnUmVc8lorlVXkgKsW2CwY4YHPGdQ8m2mv
tBbLwTD3Xgg=
=0nht
-----END PGP SIGNATURE-----

--Sig_/B9I4xI7tNNxoI_2C7SGsYvF--
