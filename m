Return-Path: linux-nfs-owner@vger.kernel.org
Received: from karif.server-speed.net ([188.40.51.140]:59601 "EHLO
	karif.server-speed.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755117Ab2KIRZy (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 9 Nov 2012 12:25:54 -0500
Message-ID: <509D3C9A.6040209@xinu.at>
Date: Fri, 09 Nov 2012 18:25:46 +0100
From: Florian Pritz <bluewind@xinu.at>
MIME-Version: 1.0
To: Ben Myers <bpm@sgi.com>
CC: "J. Bruce Fields" <bfields@fieldses.org>, linux-nfs@vger.kernel.org,
        Alex Elder <elder@kernel.org>, xfs@oss.sgi.com
Subject: Re: NFS stalls when writing - linux 3.6.x
References: <50957087.6050008@xinu.at> <20121107190724.GD7421@fieldses.org> <509D2993.4050604@xinu.at> <20121109163658.GE6171@fieldses.org> <20121109172014.GT9783@sgi.com>
In-Reply-To: <20121109172014.GT9783@sgi.com>
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enigA73601D2338BA9D2DB3A35AD"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enigA73601D2338BA9D2DB3A35AD
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

On 09.11.2012 18:20, Ben Myers wrote:
> I took a brief look but there were no slam dunks.  This seems like it m=
ight be
> a candidate:
>=20
> 8375f922 - xfs: re-enable xfsaild idle mode and fix associated races
>=20
> The sysrq-trigger information would definately be helpful.  Meanwhile I=
'll see
> if I can reproduce the issue.

No idea why it doesn't show up on gmane yet (the excerpt is from my mail
to the list), but I've uploaded it here[1]. The link will be valid for
10 days.

[1]: https://paste.xinu.at/koXRw/

--=20
Florian Pritz


--------------enigA73601D2338BA9D2DB3A35AD
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.19 (GNU/Linux)

iQIcBAEBAgAGBQJQnTyaAAoJEG0WVcFM4cE+MSAQANIRtLp/ZgBy5PGUv2jCi9j1
bOPFmidafzVaMX5fM0YcxI94ToAg4tkk6biGCj0C0kYfKbTaods9TsUOJO3MvLaM
yw3rZpUFAVDuyeA0Q5j9mqEZeCofVSURLHMvJx618giyfhEPMND4RBYAk8MH7eYV
5WGEsuB3x0Cog7zXz+kZ1UBrExhaHmEWfV3WK8zw9EBAkB4XhxE3SV9AT4uq6K4Q
LkSEm6SVKewnsS8GuULejPTgdo9GFi2lJCVUFJiVuOZyygxSuiSLZRoglsP4R5QO
Z2suctOJxpIEt8vVU3JORFowSlXG7lu4Z75GBmVHb65/Jhvk6G3fYEts/uInoO6d
rRmCA/kfLiTqPqpaA87lsfi72kQ5GwWnE1tVHBCZ3Q0gX8u0WpDY6twvcczmsxjZ
dSwx6ndD5FiN3rsvoYzdBYTZunPSVzPOwRsVHCofaHJfpaPf/zSipfN8+oQcUvKq
pfU0939mt87asnm7bnPKJ6PjZ/dxHkWJp40bZse7WfeyHFiRIj9OTuDt6DhjtpgV
60RJ2VpkvXFVmGulbrc7uHmd74NO2bNXXzbcaYGst81vq3Ojfzu1qgEPdPzDelBm
I9WBtzYP8CbE3D5KBlI80M2TSQLu1XzvQuPm2wTB9x/B213PR9LAmIcmVGHzaYKw
i5abQQoolhtPEnXxama+
=DpmF
-----END PGP SIGNATURE-----

--------------enigA73601D2338BA9D2DB3A35AD--
