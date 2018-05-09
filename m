Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx3-rdu2.redhat.com ([66.187.233.73]:43114 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S934328AbeEIMyQ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 9 May 2018 08:54:16 -0400
Message-ID: <1525870455.11756.367.camel@redhat.com>
Subject: Re: [PATCH] IB: remove redundant INFINIBAND kconfig dependencies
From: Doug Ledford <dledford@redhat.com>
To: Greg Thelen <gthelen@google.com>, Jason Gunthorpe <jgg@ziepe.ca>
Cc: linux-cifs@vger.kernel.org, linux-nfs@vger.kernel.org,
        linux-rdma@vger.kernel.org, linux-kernel@vger.kernel.org
Date: Wed, 09 May 2018 08:54:15 -0400
In-Reply-To: <20180504032919.90515-1-gthelen@google.com>
References: <20180504032919.90515-1-gthelen@google.com>
Content-Type: multipart/signed; micalg="pgp-sha256";
        protocol="application/pgp-signature"; boundary="=-OUWj7AIC2e6lj2ww1Maq"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


--=-OUWj7AIC2e6lj2ww1Maq
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Thu, 2018-05-03 at 20:29 -0700, Greg Thelen wrote:
> INFINIBAND_ADDR_TRANS depends on INFINIBAND.  So there's no need for
> options which depend INFINIBAND_ADDR_TRANS to also depend on INFINIBAND.
> Remove the unnecessary INFINIBAND depends.
>=20
> Signed-off-by: Greg Thelen <gthelen@google.com>
> ---
>  drivers/infiniband/ulp/srpt/Kconfig | 2 +-
>  drivers/nvme/host/Kconfig           | 2 +-
>  drivers/nvme/target/Kconfig         | 2 +-
>  drivers/staging/lustre/lnet/Kconfig | 2 +-
>  fs/cifs/Kconfig                     | 2 +-
>  net/9p/Kconfig                      | 2 +-
>  net/rds/Kconfig                     | 2 +-
>  net/sunrpc/Kconfig                  | 2 +-
>  8 files changed, 8 insertions(+), 8 deletions(-)

Thanks.  Since the original changes you submitted went through -rc, I'm
sending this cleanup there too.

--=20
Doug Ledford <dledford@redhat.com>
    GPG KeyID: B826A3330E572FDD
    Key fingerprint =3D AE6B 1BDA 122B 23B4 265B  1274 B826 A333 0E57 2FDD
--=-OUWj7AIC2e6lj2ww1Maq
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----

iQIzBAABCAAdFiEErmsb2hIrI7QmWxJ0uCajMw5XL90FAlry73cACgkQuCajMw5X
L90ifQ//WKtQIynf4c/6oOocd/TgRfyfPCFoH7DkhpOJySq2lCam0WQLv39NhlN8
XPrCCluiKI5zfNQRcmEpUjVA6CGlaqxZGmYXmdrwPjGYVwKXtx4o9Kk5rMpSrtpz
6/Ox3N9nPv1SZItRPayQvZ63orVAGgKQfTnXsmV9O2cGks2V3PVGf1mLlCESH+r9
qkw4bwJvT46hx0Uuqzss2+wLrJmOqpTEG4fenFws78OAvHZ4C9B43Jh9nQFRJpP0
aMf5V+SCzL/doK+4ccPHs1KeyqFeYkv8qhdZvw8FgTrk3VYf9TZEwOeEc6iaimUI
3R/sXI8LD3Pj33Z6Fq6UPofwPtPUR95TzgRrnIIduH3DSdr1KK20Of4afvAViAi6
hqwNEmTRtQ1DdnUjhVRJQivWH+x4TaIPeHwbkfJs6yIwptqF6aOAgiFjsoaIggRQ
WIyzGhLsGMHbvFu1/srzUDoVkkYyV6Uh17kuav0MffwPrrWXpMxK0ceYoS20VUBt
9Eu3YSVkPKMTn2OYtbtUmlBURjRXrc7y8m8ePGIYJGags0It4i30BEjvge7v7sDR
J7aG5iAJbqF9BKB/RdzzX5X8Q+yHNNvArt4+GklcZ3uR3f1ZYCfJ1wpGQymn/kGZ
TyO0/sMxqVIkBOuSdubyibb4C687CQKiDV05uaEiN/UALltkMTg=
=UJaf
-----END PGP SIGNATURE-----

--=-OUWj7AIC2e6lj2ww1Maq--

