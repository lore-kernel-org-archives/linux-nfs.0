Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-out.m-online.net ([212.18.0.10]:43435 "EHLO
        mail-out.m-online.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752628AbeBVISh (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 22 Feb 2018 03:18:37 -0500
Date: Thu, 22 Feb 2018 09:18:34 +0100
From: Matthias Gerstner <matthias.gerstner@nefkom.net>
To: Justin Mitchell <jumitche@redhat.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: nfs-utils: rpc.svcgssd segmentation fault in
 nss_gss_princ_to_ids()
Message-ID: <20180222081834.GB883@q910.gerrit.home>
References: <20180220224858.GA14972@q910.gerrit.home>
 <1519231741.7497.18.camel@redhat.com>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
        protocol="application/pgp-signature"; boundary="7iMSBzlTiPOCCT2k"
In-Reply-To: <1519231741.7497.18.camel@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


--7iMSBzlTiPOCCT2k
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hello,

> I will run some tests to see if this is isolated to certain compiler
> versions, or if the pragma isnt working as I expected.
>=20
> However simply moving the #pragma hidden will change the ABI which is a
> problem for some, so if necessary I will instead reorganise the code to
> achieve the same functionality without using the pragma

yes I understand. I was not suggesting this patch to be an actual solution.

Thanks for looking into this.

Regards

Matthias

--7iMSBzlTiPOCCT2k
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEQMifAG+4oyi4OjfMFK1vZXkJcoQFAlqOfNoACgkQFK1vZXkJ
coQ7DA/9GSa0EmwNg9GhJVkI93bJysg4ASlanBeUJYfmiYJSSTAu+9tcOtX7U/xo
UNM/tSDqJfR9UeX3bA3uOUwhFNra8NVfkIJiguWUtl7qLiceiHLB3A43NSELbgUt
dAsvAE1Hcfu6YDyM5XHOFB+uxgRmK4nMuw+wsZ3RD4p/V4+kw7HczFbGc+GOQURb
X0S3jcLUeaAUn0ctf5c1z0fa+TRS3KRlsn4fNPfBTIN5C2fvZXH4clDCy3nIIZi6
jxqNYBKDG8Km3jtpLnP+lwtacCjZ8PsnAGCTYdmDYwrD/HuELib7k29yj2wg8EJb
duSNgpZ0oj2bbc1Rd+bh8fgrYo6+veCd7MMouwXjE78oZj5QxY2uvFY759eHlFzU
2wjqC5e/kar5WUt4EEMvrs5dmnFIwPrVoykwPt+mUxQP9oDwCim+HxqT3sfdG8M9
YCoikMBf0SPgVi2kHgG4Xp9PJMQrevd8+48swkxbaT4ZTD6wNbb1KmV8KNFx53v+
0BoFYN8hR6NPI/mK5aPKMMy4/2JRf85rIZPW/+N1t+RG7E3ffshlF+4F3fyeNTFD
lM/hKjeHxV0oKovccoXtTPup4MeB1ypeKPHzoyy7P9ow1uAQ/NARxWhdtJpFuGmk
KZUPyBKNPNX2ePDlLXeRoO/Jpt0zcdu/Ih50+bCiz27NAqH2LgM=
=Njwi
-----END PGP SIGNATURE-----

--7iMSBzlTiPOCCT2k--
