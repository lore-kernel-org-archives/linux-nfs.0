Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from ozlabs.org ([103.22.144.67]:60903 "EHLO ozlabs.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751343AbeCUAMW (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 20 Mar 2018 20:12:22 -0400
Date: Wed, 21 Mar 2018 11:11:40 +1100
From: Stephen Rothwell <sfr@canb.auug.org.au>
To: Anna Schumaker <Anna.Schumaker@Netapp.com>,
        Trond Myklebust <trond.myklebust@fys.uio.no>,
        NFS Mailing List <linux-nfs@vger.kernel.org>
Cc: Linux-Next Mailing List <linux-next@vger.kernel.org>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
Subject: linux-next: please clean up the nfs-anna tree
Message-ID: <20180321111140.618e1e6c@canb.auug.org.au>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
 boundary="Sig_/WLFs3oQvoBhVVy2EDOm/H.0"; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Sig_/WLFs3oQvoBhVVy2EDOm/H.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

Hi all,

It only seems to contain commits that have been upsreamed as different
commits and is causing conflicts:

CONFLICT (content): Merge conflict in net/sunrpc/xprtrdma/transport.c
CONFLICT (content): Merge conflict in net/sunrpc/xprt.c

--=20
Cheers,
Stephen Rothwell

--Sig_/WLFs3oQvoBhVVy2EDOm/H.0
Content-Type: application/pgp-signature
Content-Description: OpenPGP digital signature

-----BEGIN PGP SIGNATURE-----

iQEzBAEBCAAdFiEENIC96giZ81tWdLgKAVBC80lX0GwFAlqxozwACgkQAVBC80lX
0GwrPAf/ebBneh78TQ4IIol/aYP56kfjR2m63E03h4qzJi1R4PFH4tZwP7MnfvlQ
U9lqke8kwBWFnzUM0lMOMZtF7VKodfWvrfGejqO0eg0qmf3DjXNhSjuW8OW4tTEt
t2kPgSSi2aOMyDfCR4qooDBFnB9HKdYGfaDqyMPyjKTObDjwStyhtNOCJcKYBaWz
T1QN24g03n0/7TGpYQaVwpDd0aV9Tlvg79kn87/6YNNtIb05ZVo32/pIA4lhNCWR
cleFoWfb3kSfCcvA0azAckIPzM4CcP32QB11qbQWtdSbRzcC5WU2Ogo33dX9+/Pl
TxDEtj0yZYx27lQZU/K/VLwfNCXumg==
=0kRP
-----END PGP SIGNATURE-----

--Sig_/WLFs3oQvoBhVVy2EDOm/H.0--
