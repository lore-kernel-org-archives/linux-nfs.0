Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:52760 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751308AbcADJDY (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 4 Jan 2016 04:03:24 -0500
Date: Mon, 4 Jan 2016 17:03:17 +0800
From: Stefan Hajnoczi <stefanha@redhat.com>
To: Kinglong Mee <kinglongmee@gmail.com>
Cc: linux-nfs@vger.kernel.org, "J. Bruce Fields" <bfields@fieldses.org>,
        skinsbursky@parallels.com,
        Trond Myklebust <trond.myklebust@primarydata.com>
Subject: Re: [PATCH] nfsd: Fix nfsd leaks sunrpc module references
Message-ID: <20160104090317.GA12684@stefanha-x1.localdomain>
References: <20150911104517.GA4947@stefanha-thinkpad.home>
 <5689E3C9.1010708@gmail.com>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="9amGYk9869ThD9tj"
In-Reply-To: <5689E3C9.1010708@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


--9amGYk9869ThD9tj
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Mon, Jan 04, 2016 at 11:15:21AM +0800, Kinglong Mee wrote:
> Stefan Hajnoczi reports,
> nfsd leaks 3 references to the sunrpc module here:
>=20
>   # echo -n "asdf 1234" >/proc/fs/nfsd/portlist
>   bash: echo: write error: Protocol not supported
>=20
> Now stop nfsd and try unloading the kernel modules:
>=20
>   # systemctl stop nfs-server
>   # systemctl stop nfs
>   # systemctl stop proc-fs-nfsd.mount
>   # systemctl stop var-lib-nfs-rpc_pipefs.mount
>   # rmmod nfsd
>   # rmmod nfs_acl
>   # rmmod lockd
>   # rmmod auth_rpcgss
>   # rmmod sunrpc
>   rmmod: ERROR: Module sunrpc is in use
>   # lsmod | grep rpc
>   sunrpc                315392  3
>=20
> It is caused by nfsd don't cleanup rpcb program for nfsd
> when destroying svc service after creating xprt fail.
>=20
> Reported-by: Stefan Hajnoczi <stefanha@redhat.com>
> Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>

Thanks for looking into this!

Tested-by: Stefan Hajnoczi <stefanha@redhat.com>

--9amGYk9869ThD9tj
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQEcBAEBAgAGBQJWijVVAAoJEJykq7OBq3PI/aUIAJ7qxZXKI6DPVlte+UbvnRjy
IT02fbcSF//9B2n0D+JcdafZZI6rGBKY0bytfYWExaIh1Wk8Hn4H2Aar59F/pWOg
9wBjNukJfP58i0cSUONKFxg/GwMkK6Mt858GOWUrsn0jqj7Nxb/QTQFxm8vnuvuz
/DwPfX5b8fYrnCt5SDs+9tr2VGNUDIZ62mcPUT91U3Jm1A9he+vLocqsG+U9cq1i
XYZ9FA/dIRqi1pW1eUAjbrKRE9p9MowFO3x72Nf3xiGatCabnWRwmncozJn2m5Zf
TU85yeJMXNJi2yRrFRUDLO+KOblzv4NggxREI2cKrOUW+Ktn63ZkGozt0t/ayZ8=
=VVvP
-----END PGP SIGNATURE-----

--9amGYk9869ThD9tj--
