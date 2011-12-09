Return-Path: linux-nfs-owner@vger.kernel.org
Received: from che.mayfirst.org ([209.234.253.108]:48190 "EHLO
	che.mayfirst.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752153Ab1LISbQ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 9 Dec 2011 13:31:16 -0500
Message-ID: <4EE253EC.2040609@fifthhorseman.net>
Date: Fri, 09 Dec 2011 13:31:08 -0500
From: Daniel Kahn Gillmor <dkg@fifthhorseman.net>
MIME-Version: 1.0
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: linux-nfs@vger.kernel.org
Subject: Re: linux-image: on nfs4 server: RPC: AUTH_GSS upcall timed out Please
 check user daemon is running
References: <8762hrozdl.fsf@fifthhorseman.net> <20111208174501.GA30088@fieldses.org>
In-Reply-To: <20111208174501.GA30088@fieldses.org>
Content-Type: multipart/signed; micalg=pgp-sha512;
 protocol="application/pgp-signature";
 boundary="------------enig19833F3FE96C87BA601B7529"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enig19833F3FE96C87BA601B7529
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

On 12/08/2011 12:45 PM, J. Bruce Fields wrote:
> Yes, if you're using NFSv4 then the client and server should each run
> both daemons.

ah, thanks.

>> If so, what functionality am i losing out on by not running it?
>=20
> You lose NFSv4.0 delegations, which depend on the ability for the serve=
r
> to contact the client to send delegation recalls.  Delegations are
> optional, so you won't lose correctness, but you may lose some
> performance.

Thanks, that's useful.  Do the clients need to run cachefilesd as well
to take advantage of delegation?  Is there a document where i could find
this sort of information without adding noise to the list?

> If you're using only v2, v3, or v4.1, that doesn't matter.  (v2 and v3
> lack delegations, and v4.1 sends callbacks over existing
> client-established connections).

OK, gotcha.  Is it possible to use 4.1 with linux kernel 3.1 and
nfs-utils 1.2.5, or would i need to pull a more recent version?

Thanks, and sorry for the basic questions,

	--dkg


--------------enig19833F3FE96C87BA601B7529
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org/

iQJ8BAEBCgBmBQJO4lPsXxSAAAAAAC4AKGlzc3Vlci1mcHJAbm90YXRpb25zLm9w
ZW5wZ3AuZmlmdGhob3JzZW1hbi5uZXQwRUU1QkU5NzkyODJEODBCOUY3NTQwRjFD
Q0QyRUQ5NEQyMTczOUU5AAoJEMzS7ZTSFznp5Z4P/RXfL5XYDSneFQGJhgPDlcsu
p77atan1OrMowYEB6yefQMtkZUbgMiljV7b4QvXX4d1yBemuhKahkO6xrlfApZ73
bKMWVW7NJDRgavWkxl0Ayvslhmshmru3nQNRMJKl/kkUrKwtMJMKvhT201oIf52j
bA6L11DGHhR7C+tIoWvBCwHSlULU62s015ZL0HcVVYxtievxVB5ARlxCn4mwJ7G0
tAt4zEtvvRYxI/oELbgHtiM4cUDgNNtSA0XM4/mzdu3WUWMVQutgGA1FkONEg9tY
bZFZQYqlTnDhFcEmRBpOERhevN9hRWmx9XR8zcQVd8OVyjzS1LcD2YONQ62PYBN0
INu7Ce+P3WCaImoMBrvnFdqzrgG3AJbuZ0oV56bXjJrqHfPlth1xFZ3bVUXbq3JI
Tj0Ddh4p5c+tcXuoRu6X/pjDe1RPp3jB3Mlp8T+ZmBy8X7YgIXXi+RxBpssIgvaU
9V0XFd64zkl1WFo+8+dKTuWxoalhnZnegz7tVNVb66S8+aM9JzrBeBChITsSzVTW
7U9QJciGBkKL6RWjlzRaC5vHbv68OsW/A66IscGU/Xj7d/jFIm/nC7AbaDI6ExKn
LpadJFhpw8+vTqY1qLHYS/7ODx8TWk789LimXo0O5dgX6Lds9Hm/o1tDAsrFSeXS
MAHpLVVgkCAycDdlGiHL
=ujh9
-----END PGP SIGNATURE-----

--------------enig19833F3FE96C87BA601B7529--
