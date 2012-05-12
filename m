Return-Path: linux-nfs-owner@vger.kernel.org
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:41950 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752475Ab2ELJUY (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 12 May 2012 05:20:24 -0400
Message-ID: <1336814414.8274.501.camel@deadeye>
Subject: Re: [PATCH 3.0.y, 3.2.y] NFSv4: Revalidate uid/gid after open
From: Ben Hutchings <ben@decadent.org.uk>
To: Jonathan Nieder <jrnieder@gmail.com>
Cc: stable@vger.kernel.org, Rik Theys <Rik.Theys@esat.kuleuven.be>,
        Trond Myklebust <Trond.Myklebust@netapp.com>,
        linux-nfs@vger.kernel.org, David Flyn <davidf@rd.bbc.co.uk>,
        Jeff Layton <jlayton@redhat.com>, 659111@bugs.debian.org
Date: Sat, 12 May 2012 10:20:14 +0100
In-Reply-To: <20120511092020.GD5733@burratino>
References: <alpine.LRH.2.00.1204242156380.28096@helium.esat.kuleuven.be>
	 <20120511092020.GD5733@burratino>
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-12L0xInX7TK7G5G5UgpN"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


--=-12L0xInX7TK7G5G5UgpN
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Fri, 2012-05-11 at 04:20 -0500, Jonathan Nieder wrote:
> This is a shorter (and more appropriate for stable kernels) analog to
> the following upstream commit:
>=20
> commit 6926afd1925a54a13684ebe05987868890665e2b
> Author: Trond Myklebust <Trond.Myklebust@netapp.com>
> Date:   Sat Jan 7 13:22:46 2012 -0500
>=20
>     NFSv4: Save the owner/group name string when doing open
[...]

Added to the queue for 3.2.y, thanks.

Ben.

--=20
Ben Hutchings
Experience is directly proportional to the value of equipment destroyed.
                                                         - Carolyn Scheppne=
r

--=-12L0xInX7TK7G5G5UgpN
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIVAwUAT64rTue/yOyVhhEJAQrj9g//fTbpODmG4hU8sZ3CfataqON/3sPUEZjx
eNkAYKBVrow+wGxjdr/Ug/KFe82/GT26lhGc8pR1c4gZNVMy9xCXbovM/5CMsDSi
w0Jo2x2MlP5jFNHpYlDH7VkT1oaVUyrIZ7f3fbrdbFwqNMsm/BNm0UJ1jZwJLQQn
Ri9WBV5OCSEFSNoCtFuWgZF4LTyvxCvWm5ZxKCXra2rF3Ck9wrW3VOKoPKsbm3ff
MhjmiMVAd1WXLU1AhVnYbIuT+i1h2TZJWuGHXBN0yTXjdY8FKDnQmfW1oW4dKywp
3eGaj7axE37ZGRRhh9djdCAsF9yF4s58jX+riY7lyrOgNH+o8N1mSlQeHjHfrGJE
kDhjKl4HHNM1d6GWpFexDAkHFF90fob2/DLxXNP40oHY5kzmp83FdgndoElw+I69
wOAtaG7NeepjSPq1yK/ZMn7Lo326rKGxFz1yu9iBciwG+XcCYHFGdz0a3xuH6/rY
JIY5IkOAuU972UnF+LwaQYGU5NXi5jE1OpEZuSxBXF4nAE+mg1Kp78I+8wEdvDof
qwYv7j/6dj5TxAETgzX2cv22xjeENvVH2S3lM2sK04rbus0klSPiRgA/BQGsLqdE
TKVAJZnoGa+q6ensNnyPQM5beyu5zVPaj3IvQt8Dq7qjri4vu8a6JnLos3hpnNvP
KTfJCvbHV1E=
=7/6d
-----END PGP SIGNATURE-----

--=-12L0xInX7TK7G5G5UgpN--
