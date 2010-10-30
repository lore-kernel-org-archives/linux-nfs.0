Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from server.klug.on.ca ([205.189.48.131]:2811 "EHLO
	server.klug.on.ca" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751493Ab0J3TyA (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 30 Oct 2010 15:54:00 -0400
Received: from linux.interlinx.bc.ca (d67-193-197-208.home3.cgocable.net [67.193.197.208])
	(using TLSv1 with cipher DHE-RSA-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by server.klug.on.ca (Postfix) with ESMTP id 451A92803
	for <linux-nfs@vger.kernel.org>; Sat, 30 Oct 2010 15:53:57 -0400 (EDT)
Received: from [10.75.22.1] (pc.ilinx [10.75.22.1])
	by linux.interlinx.bc.ca (Postfix) with ESMTP id B26DF86B0
	for <linux-nfs@vger.kernel.org>; Sat, 30 Oct 2010 15:53:55 -0400 (EDT)
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
Content-Type: multipart/signed; micalg="pgp-sha1"; protocol="application/pgp-signature"; boundary="=-f2SmxKmv1qV9CpVtuisy"
Date: Sat, 30 Oct 2010 15:53:55 -0400
Message-ID: <1288468435.32627.279.camel@pc>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

--=-f2SmxKmv1qV9CpVtuisy
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Sat, 2010-10-30 at 14:19 -0400, Trond Myklebust wrote:=20
>=20
> It will be running a process with a name of the form "<server IP
> address>-manager", and will be running the function
> nfs4_run_state_manager().

I will keep an eye out for that the next time I see this problem.

> BTW: Do you have the following patches applied?
>   http://git.kernel.org/?p=3Dlinux/kernel/git/torvalds/linux-2.6.git&a=3D=
commitdiff&h=3Db0ed9dbc24f1fd912b2dd08b995153cafc1d5b1c
> and
>   http://git.kernel.org/?p=3Dlinux/kernel/git/torvalds/linux-2.6.git&a=3D=
commitdiff&h=3Dae1007d37e00144b72906a4bdc47d517ae91bcc1

Nope.

> They are not yet in the stable kernel series,

Which would be why I don't have them.  I am working with a 2.6.35
kernel.

> AFAIK, but are slated to
> be merged soon.

I take that mentioning them in this context means they would be good to
have?  Safe to apply to 2.6.35.4ish kernel?

b.


--=-f2SmxKmv1qV9CpVtuisy
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)

iEYEABECAAYFAkzMd9MACgkQl3EQlGLyuXCmowCgsYiZQyVvHcWR0Sf8t3BmUTsn
5koAnjmwYEPpzSTa++Ne1vu51pH4LNgv
=0es7
-----END PGP SIGNATURE-----

--=-f2SmxKmv1qV9CpVtuisy--
