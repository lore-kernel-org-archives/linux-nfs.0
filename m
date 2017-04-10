Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:38351 "EHLO mx2.suse.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750705AbdDJBMR (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Sun, 9 Apr 2017 21:12:17 -0400
From: NeilBrown <neilb@suse.com>
To: Steve Dickson <steved@redhat.com>,
        Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Date: Mon, 10 Apr 2017 11:12:09 +1000
Subject: Re: [PATCH] systemd: nfs-server service should use network-online
In-Reply-To: <20170407150738.6200-1-steved@redhat.com>
References: <20170407150738.6200-1-steved@redhat.com>
Message-ID: <87shlhxdzq.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
        micalg=pgp-sha256; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--=-=-=
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Fri, Apr 07 2017, Steve Dickson wrote:

> There has been an number startup problems where parts of
> the NFS server fail to start due to DNS and other
> parts of the network not be up.
>
> Reading the systemd.special it seems network.target is
> a passive unit which does not wait and network-online.target
> is an active unit which does not wait so that
> should be used.

I assume that last "not" should not be there?

According to systemd.special, we should add
  Wants=3Dnetwork-online.target
though "Requires" is probably OK.

nfs-server.service already has
 Requires=3D network.target
which you didn't change.

Also nfs-mountd rpc-statd-notify and rpc.statd all have
 After =3D network.target

They should probably be changed too ??

Thanks,
NeilBrown


>
> Fixes: https://bugzilla.redhat.com/show_bug.cgi?id=3D1419351
>
> Signed-off-by: Steve Dickson <steved@redhat.com>
> ---
>  systemd/nfs-server.service | 4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)
>
> diff --git a/systemd/nfs-server.service b/systemd/nfs-server.service
> index 5be5de6..7cf4ae0 100644
> --- a/systemd/nfs-server.service
> +++ b/systemd/nfs-server.service
> @@ -7,8 +7,8 @@ Wants=3Drpcbind.socket
>  Wants=3Drpc-statd.service nfs-idmapd.service
>  Wants=3Drpc-statd-notify.service
>=20=20
> -After=3D local-fs.target
> -After=3D network.target proc-fs-nfsd.mount rpcbind.socket nfs-mountd.ser=
vice
> +After=3D local-fs.target network-online.target
> +After=3D proc-fs-nfsd.mount rpcbind.socket nfs-mountd.service
>  After=3D nfs-idmapd.service rpc-statd.service
>  Before=3D rpc-statd-notify.service
>=20=20
> --=20
> 2.9.3
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEG8Yp69OQ2HB7X0l6Oeye3VZigbkFAljq2+kACgkQOeye3VZi
gbmmJxAAuiMBmI+UNftVKuF+rsHNZKQkDUqilTEEy22kZcFj7uskRP+rQuckv76M
ENRI8l0dwaCEAr8nN+ppzMWd+DpZuNJFSUEHxs3roxVq+tV4FojkQafzkbmujluL
X511nmtA9j1yc4g+mYmYQFNO8Ua1Ye/GQ0FPuZd//uzeynUyKylEv3zeFETaptR7
6PQzOU87pfE6tUjMLVOLwaw1ZYmHPsL1OS/TO3mxlRVGUjO+4YkMaUj+YPq71UCp
ExFHc573O43pjo+JkbsTmiOjuYK4YRpJicVK70ZeYhg1AOGDaNWhgU/tI1Cb5dnu
ZrWS+Go5lxDkkZyB4LwtSHK1wb9JCqEn8+5pPfvhKgel+Vy546zisnDEMEssT+P7
HNy8DBslkieTH1FxHCG3nioqNmKHAuqS6bPWJWzW8hWiHmfDSP6hwyaqjP/gzzR7
incb5J4yVaIsAzeAWRO0sVLPHD4zeMCH6CDeIpTf0lofgyGnnZllugiNiUaLj4Nw
XwhTZHa4CpcFOLgsHoSk5E+mnEPHkFcg1NVfQUk4zikyRnAhwOgF/kGPj1SzoAp+
v1VaYeOrFYJBN+NRXiWR3ZEdH0b4vDb0AFZIdI3U6olCaQO4Vs65XKd2DLONdTsV
LwimL3YVLAx9B47Lmz55fdG8KqJP7SBuQGxSg7b5yw8aeY+IxmQ=
=mldq
-----END PGP SIGNATURE-----
--=-=-=--
