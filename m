Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:47206 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752066AbaBSDVY (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 18 Feb 2014 22:21:24 -0500
Date: Wed, 19 Feb 2014 14:21:14 +1100
From: NeilBrown <neilb@suse.de>
To: Steve Dickson <steved@redhat.com>
Cc: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 2/2] systemd: Removed the "ordering cycle" from
 nfs-server.service
Message-ID: <20140219142114.7a237f73@notabene.brown>
In-Reply-To: <1392713329-17979-3-git-send-email-steved@redhat.com>
References: <1392713329-17979-1-git-send-email-steved@redhat.com>
	<1392713329-17979-3-git-send-email-steved@redhat.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=PGP-SHA1;
 boundary="Sig_/=oNO0dWYi7W69gpg3t7+Qil"; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Sig_/=oNO0dWYi7W69gpg3t7+Qil
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

On Tue, 18 Feb 2014 03:48:49 -0500 Steve Dickson <steved@redhat.com> wrote:

> Commit 88ff0417 introduce 'Wants=3D' statements that
> conditionally started other services. Those services
> need to be removed from the 'After=3D' statements
> otherwise a systemd ordering cycle is created.
>=20
> Signed-off-by: Steve Dickson <steved@redhat.com>
> ---
>  systemd/nfs-server.service | 2 --
>  1 file changed, 2 deletions(-)
>=20
> diff --git a/systemd/nfs-server.service b/systemd/nfs-server.service
> index 26df656..43be4aa 100644
> --- a/systemd/nfs-server.service
> +++ b/systemd/nfs-server.service
> @@ -7,8 +7,6 @@ Wants=3Drpc-statd.service nfs-idmapd.service rpc-gssd.ser=
vice rpc-svcgssd.service
>  Wants=3Drpc-statd-notify.service
> =20
>  After=3D network.target proc-fs-nfsd.mount rpcbind.target nfs-mountd.ser=
vice
> -After=3D nfs-idmapd.service rpc-statd.service
> -After=3D rpc-gssd.service rpc-svcgssd.service
>  Before=3D rpc-statd-notify.service
> =20
>  [Service]

"Wants" does not imply ordering.  If A Wants B, then A and B can be started
at the same time.
But we really want these various services to be running before nfsd is
started.  So the "After" are important.  Please leave them.

The lack of ordering is explicit in the documentation for Requires:


               If a unit foo.service requires a unit bar.service as
           configured with Requires=3D and no ordering is configured with A=
fter=3D
           or Before=3D, then both units will be started simultaneously and
           without any delay between them if foo.service is activated.

and implicit in the documentation for Wants:

       Wants=3D
           A weaker version of Requires=3D.=20

Thanks,
NeilBrown

--Sig_/=oNO0dWYi7W69gpg3t7+Qil
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)

iQIVAwUBUwQjKjnsnt1WYoG5AQLt6w//QhMuHdCOjoQMI5v8r5F48/i2zblm69bx
6iS+11ssoGlCpdXoy4/P9Yaqo+y1hzZM6/lXhmyqQd2mpIcmEOKkYhNZ9136cdT9
wwpTgrAuJ4vE15vXBrTDqKCRZF8l0uszbY0JtL0FuwL2xC0ZbV0/Bj0xnRwopQGR
5Mjs5sHyRrT4r4eyXR6Vniu9QZbMrKITtZmw7E8ppbGUedjJbunIGj6AnGrXCc4v
k3x+uBBUXCEEr48tnwDf0KREvz2sTaH3d+nifoWEsEWVEZqefnlQlDVmxNYUDBei
ZJK+kXT14cyVqU1+Jo3k7rnuQTnedu7wCZk41dmcua6B3+6ZpWZxGUv2M0A08e84
Fftto3BAiiaPrvlNFctnyjujB91J91/2jbkVsMd+kFwwyn59/dDnzhL6R3Uw1val
0z58Bwd1Ug7flkhCcmG/s60DrN+0Wsv0BayHQy6uTi5qgdth/hh3NxYKFNDx/4My
6iXcoUAsZtfiv6XSRwPEE5fjlhre88rsaGfEKQVqFjCNQLCg9WLCQnQuF1uA1c+E
VpVCsddQuucq8orBsf9gnZF5q6bmeXAJTOOTtg1L+ABQOLX7bYDE5y7BxLzQf5op
onmJfC7LKpHhgMN18BIwyotRPHGbckxuEYPOVppcp5tK+bOdofdcCobf9p3wFS8r
K8L8gDpBVdA=
=Uotv
-----END PGP SIGNATURE-----

--Sig_/=oNO0dWYi7W69gpg3t7+Qil--
