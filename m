From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: Bug#579397: STAT_FAIL to debian for SM_MON of 192.168.120.254,
 No canonical hostname found for 192.168.120.254
Date: Sat, 05 Jun 2010 21:29:59 +0100
Message-ID: <1275769799.2870.107.camel@localhost>
References: <4BF71C27.7070309@nchc.org.tw>
	 <1274492328.11828.3.camel@localhost> <4BFA99CD.2040902@oracle.com>
	 <4C0819C2.2020203@oracle.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha1"; protocol="application/pgp-signature"; boundary="=-CoEYm119EEbUxDHKJKY7"
Cc: 579397@bugs.debian.org, linux-nfs@vger.kernel.org
To: Chuck Lever <chuck.lever@oracle.com>,
	Steven Shiau <steven@nchc.org.tw>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:40291 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755244Ab0FEUaO (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 5 Jun 2010 16:30:14 -0400
In-Reply-To: <4C0819C2.2020203@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


--=-CoEYm119EEbUxDHKJKY7
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Thu, 2010-06-03 at 17:08 -0400, Chuck Lever wrote:
> On 05/24/10 11:22 AM, Chuck Lever wrote:
[...]
> > We can probably remove the reverse mapping constraint for presentation
> > addresses. A simple fix might be to change statd_canonical_name() from:
> >
> > freeaddrinfo(ai);
> > if (!result)
> > return NULL;
> >
> > to
> >
> > freeaddrinfo(ai);
> > if (!result)
> > return strdup(hostname);
> >
> > Let me know if this works.
>=20
> Any update?  I have a patch ready for nfs-utils to fix this regression,=
=20
> but I need confirmation that it addresses your problem.

Steven originally had this problem, not me.  Steven, do you need me to
build a new package with this change?

Ben.

--=20
Ben Hutchings
Once a job is fouled up, anything done to improve it makes it worse.

--=-CoEYm119EEbUxDHKJKY7
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)

iQIVAwUATAqzxue/yOyVhhEJAQKD6hAAtT3I2egWDRSipPtRbHjIjg7Xv/8Oa0q9
QIsjuwtMScBTcaI6OmlzBiDsy3PTQFSXsWuLfz1vwqSZXKzTkYt3jHDT/M9znfXG
Q1hnOxUlOqliO938VsOxYaJ+1DTsIe997BLruJO59LN8LwwcVHe85Y/Nzh86COkC
+lidQ/GCYryESJW5HE5k+uPEE4AGTDplhHIJ+gIsD67QqnjVszU7XE6RCdr9fMJ/
eqcXJFhMspXGws60LwBR/ZnQy/mqCaDJmgyylS09BuiX/efuIiG8+XTLyfCfbqhY
U9mK2rwJJyWL8KTJeSKKvoxX9XSP9JuakKzunfj3pr5iZs2er3pOUJtvNSIA7wrP
FWiQBzKCx0xeH9LPeEgIJoxjVJ8zG8ZC6BpYqxxIBTVDXiPPBFksXwVbwEXG6Ud1
M/eomF91ODKsuTl7wYW2l971JkHfXSNh6kFu6baN4rMsujLXbyTlu81WhafBySST
dFFlW0UT2d6rC8gBrwhKtbxzNGk94XwCt6pfhbSJ0CSWqTnHgrPEFJTOT14Pr++r
LAMSO/9tfrU17DVArti1SfBWJzDQ9ViLeZCmkfbkMuvT3couXLTPBiqdcxHEly27
qN4K0CDhyFIaNbWEHE/mydqBAjmCQKiksXSKXoyGOUdn73EvsF8pPvsMGObJY/Va
opOsfosXX9c=
=sd+m
-----END PGP SIGNATURE-----

--=-CoEYm119EEbUxDHKJKY7--
