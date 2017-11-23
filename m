Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail1.g1.pair.com ([66.39.3.162]:59410 "EHLO mail1.g1.pair.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751497AbdKWMWg (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 23 Nov 2017 07:22:36 -0500
Date: Thu, 23 Nov 2017 13:13:27 +0100
From: Emmanuel Florac <eflorac@intellique.com>
To: =?UTF-8?B?w5Z6a2FuIEfDtmtzdQ==?= <ozkan.goksu@usishi.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: How to get NFS user list
Message-ID: <20171123131327.1aa66e49@harpe.intellique.com>
In-Reply-To: <296856FF-A18F-47EB-96AF-5C0E6C9BB5E1@usishi.com>
References: <296856FF-A18F-47EB-96AF-5C0E6C9BB5E1@usishi.com>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 boundary="Sig_//nzx/udQb1PoSgKWgeafSQK"; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Sig_//nzx/udQb1PoSgKWgeafSQK
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

Le Wed, 22 Nov 2017 16:31:43 +0200
=C3=96zkan G=C3=B6ksu <ozkan.goksu@usishi.com> =C3=A9crivait:

> I want to get NFS user list (client list) like "smbstatus"
> I want to see which user & ip is using which share and when connected.
> I want to kill a nfs user.
> I want to log what an user is doing like "Create, modify, delete".
>=20
> In the end; I want to manage nfs users. There is not enough
> information and tools about this problem.
>=20
> How you manage your nfs server?

Traditional tools for NFS monitoring are showmount, nfsstat and
nfswatch. Common other tools are nfsiostats and mountstats (on the
client). Unfortunately, AFAIK there is no single tools providing all
needed information, and nothing that compares to "smbstatus", i.e.
connected clients and opened files.

--=20
------------------------------------------------------------------------
Emmanuel Florac     |   Direction technique
                    |   Intellique
                    |	<eflorac@intellique.com>
                    |   +33 1 78 94 84 02
------------------------------------------------------------------------

--Sig_//nzx/udQb1PoSgKWgeafSQK
Content-Type: application/pgp-signature
Content-Description: Signature digitale OpenPGP

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iEYEARECAAYFAloWu2gACgkQX3jQXNUicVbX0gCgpsBYLPOn046jucTdvLLz/GE6
w/gAoJ17J8H2sniwdZppIEQf89Y+XCWI
=KUAU
-----END PGP SIGNATURE-----

--Sig_//nzx/udQb1PoSgKWgeafSQK--
