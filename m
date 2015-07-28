Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:59447 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754296AbbG1Opk (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 28 Jul 2015 10:45:40 -0400
Subject: Re: [PATCH RESEND 0/4] Use max_sge_rd device capability
To: Steve Wise <swise@opengridcomputing.com>
References: <20150727230906.10102.88491.stgit@build2.ogc.int>
Cc: infinipath@intel.com, sagig@mellanox.com, linux-rdma@vger.kernel.org,
        linux-nfs@vger.kernel.org, bfields@fieldses.org
From: Doug Ledford <dledford@redhat.com>
Message-ID: <55B79592.4060500@redhat.com>
Date: Tue, 28 Jul 2015 10:45:38 -0400
MIME-Version: 1.0
In-Reply-To: <20150727230906.10102.88491.stgit@build2.ogc.int>
Content-Type: multipart/signed; micalg=pgp-sha256;
 protocol="application/pgp-signature";
 boundary="1h2fcggdQ57rEnQrj8AREXTivX9LGG8Bc"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--1h2fcggdQ57rEnQrj8AREXTivX9LGG8Bc
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

On 07/27/2015 07:09 PM, Steve Wise wrote:
> Resending because I forgot to cc linux-rdma :(
>=20
> Some devices were not setting this capability, so fix those devices,
> and svcrdma to use max_sge_rd.  Also remove rdma_cap_read_multi_sge()
> since it isn't needed.
>=20
> These patches were originally part of:
>=20
> http://www.spinics.net/lists/linux-rdma/msg27436.html
>=20
> They really aren't part of iSER/iWARP at all, so I've split=20
> them out. =20
>=20
> Bruce: This hits svcrdma, but I suggest they get merged via Doug's tree=

> to avoid any merge problems.
>=20
> ---
>=20
> Sagi Grimberg (1):
>       mlx4, mlx5, mthca: Expose max_sge_rd correctly
>=20
> Steve Wise (3):
>       RDMA/Core: remove rdma_cap_read_multi_sge() helper
>       svcrdma: Use max_sge_rd for destination read depths
>       ipath,qib: Expose max_sge_rd correctly
>=20
>=20
>  drivers/infiniband/hw/ipath/ipath_verbs.c    |    1 +
>  drivers/infiniband/hw/mlx4/main.c            |    1 +
>  drivers/infiniband/hw/mlx5/main.c            |    1 +
>  drivers/infiniband/hw/mthca/mthca_provider.c |    1 +
>  drivers/infiniband/hw/qib/qib_verbs.c        |    1 +
>  include/linux/sunrpc/svc_rdma.h              |    1 +
>  include/rdma/ib_verbs.h                      |   28 ------------------=
--------
>  net/sunrpc/xprtrdma/svc_rdma_recvfrom.c      |   12 +----------
>  net/sunrpc/xprtrdma/svc_rdma_transport.c     |    4 ++++
>  9 files changed, 11 insertions(+), 39 deletions(-)
>=20

Thanks Steve, I'm picking this up for my for-next work today.

--=20
Doug Ledford <dledford@redhat.com>
              GPG KeyID: 0E572FDD



--1h2fcggdQ57rEnQrj8AREXTivX9LGG8Bc
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2
Comment: Using GnuPG with Thunderbird - http://www.enigmail.net/

iQIcBAEBCAAGBQJVt5WSAAoJELgmozMOVy/d3M4QAJlyKEgLcH75mPPdgS2/nUG+
eko3zcZBHFLKjtxiXa5TVj6dlbU/UbngOeCzWE3ajJ5vMkOFfu78QtX8pEvWVI5D
wFHnc9+NoZdri7FkKhRADeXTihoN02bff/8MA8YfdpgoxIB/C70Pokbv8YHewhWU
KZDDpiVt2vAcd29NX6HD1dOghwM9V+3RrmV8Q5pkPHVHEYAv8PkX4cTvBTPM9HQp
1hsVmn/QtmcSq9jmlG4xZQFWD95QUQ7na6SS8AAa4DRGBgT3EJ9MB2Vv9Y8PZ452
Tz0KOSDkaeL2vzjVatTvWZkfN89gDn/4dUlhG030tQkoW1Gb4ubKrm6+vh9subnZ
hM3QwlmprOTzRnzV4IAZOl1yR1p4J5qZQSp04GB7/3xvdB+LGHY0JFNblM2Hrtg2
c8NAG/bieSbNM0ykW919t4bHlYMPqC3B/GxJgwcbxihQ/KBR7/AMy7n8qTGFMQxe
yQkEkJzRgZkJTbBN64JVOeQ7CrSeYC4de3aMx1ntflvYPNB9F5XDk6jlfLQzeU+H
PcI6Mc6cCF/F1ko+RmudznlSby7tvWYmOK/Zi53T0VP9i0FUDQSGgXNI+BlR2V01
Xd7rWevf3HmGo/e3n5lg9LSoiDlT9KFmafmoQU967CPrJzHOPUyhB7X2dWRj+VsA
HekDGasdM5HGZQFuqRFD
=Om0i
-----END PGP SIGNATURE-----

--1h2fcggdQ57rEnQrj8AREXTivX9LGG8Bc--
