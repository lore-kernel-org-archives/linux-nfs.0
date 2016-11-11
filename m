Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp.gentoo.org ([140.211.166.183]:59964 "EHLO smtp.gentoo.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S965049AbcKKVAf (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 11 Nov 2016 16:00:35 -0500
Date: Fri, 11 Nov 2016 13:00:34 -0800
From: Mike Frysinger <vapier@gentoo.org>
To: NeilBrown <neilb@suse.com>
Cc: Steve Dickson <SteveD@redhat.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        libtirpc-devel@lists.sourceforge.net
Subject: Re: [Libtirpc-devel] [PATCH rpcbind] Move default state-dir to
 /run/rpcbind
Message-ID: <20161111210034.GM21655@vapier.lan>
References: <877f8almcf.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
        protocol="application/pgp-signature"; boundary="vJnATpogyuudK3Na"
In-Reply-To: <877f8almcf.fsf@notabene.neil.brown.name>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


--vJnATpogyuudK3Na
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On 11 Nov 2016 14:36, NeilBrown wrote:
> rpcbind can save state in a file to allow restart without forgetting
> about running services.
>=20
> The default location is currently "/tmp" which is an over-used
> directory that isn't really suitable for system files.
> The modern preferences would be a subdirectory of "/run", which can
> be selected with a ./configure option.  That subdirectory would still need
> to be created by something.

the portable path is /var/cache instead of /run.  i don't think libtirpc
should be configuring itself to assume Linux by default.
-mike

--vJnATpogyuudK3Na
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCAAGBQJYJjFyAAoJEEFjO5/oN/WBjXMP/2wujFQri5J+Q57f+wmmMGDh
Tj+QY67jzWIoepsnkAHiO0+zW20CtIS6mnIyhbpcOSrx0tBgHA/lb8KPa+ox04Cu
LF8fX2T5/8C7hiePSgqUcQ1Gqkf9C95ADVfrjmB5Fbk3IjxcZfcRxT+zN/VzlbWC
meG8kW/RtUk6154jAiGoRJmeTjAeHnuMYwCPZuP6DImpj+m0L6WN8JtLLnGpUebn
K0cY7n/wq3/evbN2q7ksNJmo5E/jegj7cAnsvOl+1f7DtRxDRxsT3y4X7osII0Y2
gTt0TXfJl5Oyt5dRPvUUsgyh53CdI+vRjMohXpLj8yQiHGMKIrwAknyP+tgIJ8I0
wq1IvoImTkvMELvoiA5xlmf5w9VkHox81b09tA+Kcg0znoXYqmdoxa+SFf6h8lV7
5azwWMyLBnNRgWLwuVlwAGQTnYNiJRskFufBE3F3/Add9BmoY7okvmdUguNSwmE6
UvV11KlON+3p3gRYFttN7TL86GaSHDVHNRQV5GinOZso7kslLZ/VqcaIrIlpKA0n
jd1zgwR8JFi28ChhEYmasV7ICOkUpMxT9F3+MicvfIH2hgdF6lZev7EmeCODAP7w
kBluydqxl5sEDnwfvWXsjpU+nA50mf/heFuKsSCqN+S2iUHh6vX/Thp1bhtzVAAZ
heM6dKDSFypQPUgqUjPr
=4psh
-----END PGP SIGNATURE-----

--vJnATpogyuudK3Na--
