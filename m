Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from ozlabs.org ([103.22.144.67]:60837 "EHLO ozlabs.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752126AbeDEVo1 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 5 Apr 2018 17:44:27 -0400
Date: Fri, 6 Apr 2018 07:43:14 +1000
From: Stephen Rothwell <sfr@canb.auug.org.au>
To: Anna Schumaker <Anna.Schumaker@Netapp.com>,
        Trond Myklebust <trondmy@gmail.com>,
        NFS Mailing List <linux-nfs@vger.kernel.org>
Cc: Linux-Next Mailing List <linux-next@vger.kernel.org>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
Subject: linux-next: bad commits in the nfs-anna tree
Message-ID: <20180406074314.7ae8652e@canb.auug.org.au>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
 boundary="Sig_/uDFnaOk4wPVxf/kgy+3jQP5"; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Sig_/uDFnaOk4wPVxf/kgy+3jQP5
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

Hi all,

It looks like part of Linus' tree has been rebased into the nfs-anna tree .=
.. commits

  4c8936622a01 ("btrfs: use kvzalloc to allocate btrfs_fs_info")
to
  8f1cd0ae48f5 ("Linux 4.16-rc4")

in the nfs-anna tree are the same as commits

  a8fd1f717493 ("btrfs: use kvzalloc to allocate btrfs_fs_info")
to
  661e50bc8532 ("Linux 4.16-rc4")

I can't use the nfs-anna tree as it is, please fis it up.

--=20
Cheers,
Stephen Rothwell

--Sig_/uDFnaOk4wPVxf/kgy+3jQP5
Content-Type: application/pgp-signature
Content-Description: OpenPGP digital signature

-----BEGIN PGP SIGNATURE-----

iQEzBAEBCAAdFiEENIC96giZ81tWdLgKAVBC80lX0GwFAlrGmHIACgkQAVBC80lX
0GwCVwf+Mt1XgGtCqTgcOK02dVHra2VC+3qNlTUWdZZXuQDyu8CkY4/J7FcgP2W4
h6VXup3qfN1iqTQexO/LAZtfgHZ+FympYwociJWa4jbkype8hPh82zj3F7nb6mqv
A4SiOdRy1/98ApY6LA0zN4URK+Q99pfiRB4kRbbMFflsN02jY+dfmMpVc/M8xke5
V3gNZuart5bRy/0AlqLZWI+Qf3+/hIiL+tKdfnFqsbFgiZKCnw3mxNU8Azy+2e42
riBueMBmDgUXtnOlpsMWD1BP54OmWzu7k9tfwEfvVwGgJ7phNwl+FNuLuIImzvWJ
rSTQ0+LhUf1FPQQp+/ZRQN12T4m98g==
=m25L
-----END PGP SIGNATURE-----

--Sig_/uDFnaOk4wPVxf/kgy+3jQP5--
