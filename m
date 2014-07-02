Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:44770 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751306AbaGBCUv (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 1 Jul 2014 22:20:51 -0400
Date: Wed, 2 Jul 2014 12:20:43 +1000
From: NeilBrown <neilb@suse.de>
To: Rik Theys <Rik.Theys@esat.kuleuven.be>
Cc: linux-nfs@vger.kernel.org
Subject: Re: NFS server caches client mount permissions?
Message-ID: <20140702122043.1c1c2c2d@notabene.brown>
In-Reply-To: <53B2B1AD.4080507@esat.kuleuven.be>
References: <53B2B1AD.4080507@esat.kuleuven.be>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=PGP-SHA1;
 boundary="Sig_/rwFrY0UpTsiap_w4.3jd6sm"; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Sig_/rwFrY0UpTsiap_w4.3jd6sm
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

On Tue, 01 Jul 2014 15:03:41 +0200 Rik Theys <Rik.Theys@esat.kuleuven.be>
wrote:

> Hi,
>=20
> We use NFS4 to export data to other clients. The exports file has the=20
> directories exported to netgroups, for example:
>=20
> /export		@nfs(rw,async,no_subtree_check,fsid=3D0)
> /export/data1	@nfs(rw,async,no_subtree_check)
> /export/data2	@nfs(rw,async,no_subtree_check)
>=20
> If we forget to add a new client to the netgroup, the server rejects the=
=20
> mount from the client (as it should). But when we then add the client to=
=20
> the netgroup it can take up to 15 minutes for the server to accept the=20
> new client.
>=20
> Using 'getent netgroup nfs' on the server immediately shows the new=20
> entry of the client.
>=20
> Running exportfs -rv to reload the exports also doesn't help.
>=20
> Does nfsd cache mount access (rejections) somewhere? How can I=20
> flush/tune this cache? Preferably without restarting the NFS server as=20
> that causes a 90s interruption due to the grace period.

Does
  exportfs -f

help?  It flushes the cache (which is normally updated ever 15 minutes).

NeilBrown

--Sig_/rwFrY0UpTsiap_w4.3jd6sm
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)

iQIVAwUBU7Nseznsnt1WYoG5AQJMVBAAvfoTUwFME6Lo2YYE6jyQFLUjWGzHFuEi
oe9HQy+ICxrE96VwQiZX/65piwjnOnKqqyMihrIq/CKQ2eMwhuy0toaZkqXQAUGH
QY8DcdeSG8Gae3Ldlm8p/1ZZ6l++7YLLsvZbSbU+i3G+nxR/6t327dA6rbXJbDqn
I9X1tHKORgPRH8M9yvDdm/lzWfTuuJIy/IBcw1TjM7DrnWb/GEY69lq3+bXg7vGE
mF3ZT3A+d+cu8EoCAjK5pJHRnsPIreSYXY6zmqxizDGHEjKePw+LDE04Chz2EXl5
OAsIrqWyFL0vDSAW9CGiJkevbX0gz0RslT/e1iYbuZGjE35YCfoKvZwcn72X6RmU
1cNldmbgXVpd1J0nAoNmZ0gBOd2zFxSOiiSNfaxxAei6oB26CnAjsznMgVHvZaet
uq2eP1NwmfE0hRESUeHcUIJViq+b1cM3t4/NNJbKve6J2+T/Eisb3YGS6LfZSidQ
YqsY5LXGNMhT9LPxJ2jeVCTE7xXUdHBfwvmEvTHFZfQ5SvCdhKN0c/9mt4kIhyS1
OOmERCtQacbIraU8TEQeiM2DQDjWGUp11VYpnTVut9T25idZxsV4MggIR+bK9g0n
OOW13H73nqt49vkwnoGLsE1CKv6j+RgNG0MIiAS3m+6E0OHEW/N/rjfEiKHoma99
vk90ywjcS+Y=
=SlOa
-----END PGP SIGNATURE-----

--Sig_/rwFrY0UpTsiap_w4.3jd6sm--
