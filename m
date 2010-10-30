Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from server.klug.on.ca ([205.189.48.131]:1165 "EHLO
	server.klug.on.ca" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751525Ab0J3V31 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 30 Oct 2010 17:29:27 -0400
Received: from linux.interlinx.bc.ca (d67-193-197-208.home3.cgocable.net [67.193.197.208])
	(using TLSv1 with cipher DHE-RSA-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by server.klug.on.ca (Postfix) with ESMTP id A07A22803
	for <linux-nfs@vger.kernel.org>; Sat, 30 Oct 2010 17:29:26 -0400 (EDT)
Received: from [10.75.22.1] (pc.ilinx [10.75.22.1])
	by linux.interlinx.bc.ca (Postfix) with ESMTP id 6A02386B0
	for <linux-nfs@vger.kernel.org>; Sat, 30 Oct 2010 17:29:25 -0400 (EDT)
Subject: Re: Error: state manager failed on NFSv4 server linux with error
 127
From: "Brian J. Murrell" <brian@interlinx.bc.ca>
To: linux-nfs@vger.kernel.org
In-Reply-To: <1288462786.3238.16.camel@heimdal.trondhjem.org>
References: <1287334833.4871.6.camel@pc>
	 <1287340520.5266.70.camel@heimdal.trondhjem.org>
	 <1288460514.32627.105.camel@pc>
	 <1288461151.3238.9.camel@heimdal.trondhjem.org>
	 <1288461562.32627.151.camel@pc>
	 <1288462786.3238.16.camel@heimdal.trondhjem.org>
Content-Type: multipart/signed; micalg="pgp-sha1"; protocol="application/pgp-signature"; boundary="=-yBCX5hLqS5d53S+hsv+N"
Date: Sat, 30 Oct 2010 17:29:24 -0400
Message-ID: <1288474164.32627.383.camel@pc>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

--=-yBCX5hLqS5d53S+hsv+N
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Sat, 2010-10-30 at 14:19 -0400, Trond Myklebust wrote:=20
>=20
> BTW: Do you have the following patches applied?
>   http://git.kernel.org/?p=3Dlinux/kernel/git/torvalds/linux-2.6.git&a=3D=
commitdiff&h=3Db0ed9dbc24f1fd912b2dd08b995153cafc1d5b1c
> and
>   http://git.kernel.org/?p=3Dlinux/kernel/git/torvalds/linux-2.6.git&a=3D=
commitdiff&h=3Dae1007d37e00144b72906a4bdc47d517ae91bcc1

These patches both deal with recovery issues, which you mentioned seems
to be the state the previously posted stack traces where in also.

Since the server has not been rebooted or even had its export list
reread/reexported, I wonder why recovery would have been triggered, to
cause this client problem.

Does recovery actually get invoked on the client for events other than
an outright restart of NFS on the server?  NFS on the server here should
have been entirely stable over the period of time in which this client
went bad.

b.


--=-yBCX5hLqS5d53S+hsv+N
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)

iEYEABECAAYFAkzMjjQACgkQl3EQlGLyuXCGRwCgkgUggVhvRyq3C+DdjmPHy7aZ
UgcAmwe7fXSY5XTg6xH9CyGBIGyvq55/
=v8ja
-----END PGP SIGNATURE-----

--=-yBCX5hLqS5d53S+hsv+N--
