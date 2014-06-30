Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx02.posteo.de ([89.146.194.165]:50455 "EHLO posteo.de"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751286AbaF3Lk4 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 30 Jun 2014 07:40:56 -0400
Message-ID: <53B14CC4.4000803@posteo.de>
Date: Mon, 30 Jun 2014 13:40:52 +0200
From: Karl-Philipp Richter <krichter@posteo.de>
MIME-Version: 1.0
To: Anna Schumaker <schumaker.anna@gmail.com>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: (Follow) sparse file support (development)
References: <53B03ED5.6040400@posteo.de> <CAFX2Jfne-eDPBChRmBqp2N08-+i6tYBpSosnudg_J6Yd2dNNcg@mail.gmail.com>
In-Reply-To: <CAFX2Jfne-eDPBChRmBqp2N08-+i6tYBpSosnudg_J6Yd2dNNcg@mail.gmail.com>
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="upheUEQNIX9RVrGp5S0ms30Uef6eM4B6c"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--upheUEQNIX9RVrGp5S0ms30Uef6eM4B6c
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

Hi Anna,
Yes you did, thank you! I'd like to recommend you to put this
information in the wiki, if you don't want to rely on $SEARCH_ENGINE
finding this thread in the mailing list archives only :)

Best regards,
Kalle

Am 30.06.2014 01:39, schrieb Anna Schumaker:
> Hi Kalle,
>=20
> Currently you can use SEEK_SET to create sparse files through seeking. =
 NFS
> v4.2 (currently in development) will add support for an fallocate
> interface, but that won't be merged into Linux until after the draft is=

> finished.
>=20
> I hope I answered your question!
>=20
> Anna
>=20
> On Sunday, June 29, 2014, Karl-Philipp Richter <krichter@posteo.de> wro=
te:
>=20
>> Hi together,
>> I had trouble finding a statement in the NFS wiki
>>
>>     http://wiki.linux-nfs.org/wiki/index.php/Main_Page
>>
>> about sparse file support or development plans for it outside of (very=

>> very) technical documents which I honestly didn't take the time to
>> understand. Maybe I can get you to give me short statement on this :).=

>>
>> Best regards,
>> Kalle Richter
>>
>>
>=20


--upheUEQNIX9RVrGp5S0ms30Uef6eM4B6c
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1
Comment: Using GnuPG with Thunderbird - http://www.enigmail.net/

iQEcBAEBAgAGBQJTsUzEAAoJEGadKJ8eJ7ZGBqgH/2ZE+CM8W1E+RofQwsW4/hrg
WR8EX8WQF/VbT7G4B1qg2JK8KatcuHTeThU94Df2aBs6zMJ8SjeOyCK63cKl8FoI
O3IXJNGdmwPAZzwukzwdAM0+bw6WOTevFpOlufN55uYGpeCQnkuAc86Js4uy80kZ
HxuP32BPpPbABJCYW7SGSvyJ7jbSvUNXISiiGT2ilVATdtpq+c/a35ZYtEcCBAL2
aNJgkSw9NbHxR1alP5vKUFkmYSmtI5nuW7jfE8DsYGRn5YMK/UWJRy5sGGLLAQTg
pyDWQE9cqKX66mitgJjFG9zIvRzI04iMP24sQOf/VgA80giulioShrJfyMZp250=
=7HBy
-----END PGP SIGNATURE-----

--upheUEQNIX9RVrGp5S0ms30Uef6eM4B6c--
