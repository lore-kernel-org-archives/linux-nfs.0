Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from server.klug.on.ca ([205.189.48.131]:1448 "EHLO
	server.klug.on.ca" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751245Ab0J3R7Z (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 30 Oct 2010 13:59:25 -0400
Received: from linux.interlinx.bc.ca (d67-193-197-208.home3.cgocable.net [67.193.197.208])
	(using TLSv1 with cipher DHE-RSA-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by server.klug.on.ca (Postfix) with ESMTP id 6AA422803
	for <linux-nfs@vger.kernel.org>; Sat, 30 Oct 2010 13:59:24 -0400 (EDT)
Received: from [10.75.22.1] (pc.ilinx [10.75.22.1])
	by linux.interlinx.bc.ca (Postfix) with ESMTP id 6FE7D86B0
	for <linux-nfs@vger.kernel.org>; Sat, 30 Oct 2010 13:59:23 -0400 (EDT)
Subject: Re: Error: state manager failed on NFSv4 server linux with error
 127
From: "Brian J. Murrell" <brian@interlinx.bc.ca>
To: linux-nfs@vger.kernel.org
In-Reply-To: <1288461151.3238.9.camel@heimdal.trondhjem.org>
References: <1287334833.4871.6.camel@pc>
	 <1287340520.5266.70.camel@heimdal.trondhjem.org>
	 <1288460514.32627.105.camel@pc>
	 <1288461151.3238.9.camel@heimdal.trondhjem.org>
Content-Type: multipart/signed; micalg="pgp-sha1"; protocol="application/pgp-signature"; boundary="=-JtAvGNXbLdfUQQPBLrwT"
Date: Sat, 30 Oct 2010 13:59:22 -0400
Message-ID: <1288461562.32627.151.camel@pc>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

--=-JtAvGNXbLdfUQQPBLrwT
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Sat, 2010-10-30 at 13:52 -0400, Trond Myklebust wrote:=20
>=20
> The processes appeared to be waiting for state recovery to complete, but
> your trace didn't contain any evidence that a state recovery thread was
> running.

To be clear, the trace was only that of blocked processes (echo w
> /proc/sysrq-trigger).  I'm not sure if we should have expected the
state recovery thread to have been included (i.e. it was blocked too).

> Did you over-edit the trace output, or was this really all?

Other than the usual post-show-blocked-state output, yes, this really
was all there was.

What does the state recovery thread look like in the process table so
that I can look for it next time?

b.




--=-JtAvGNXbLdfUQQPBLrwT
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)

iEYEABECAAYFAkzMXPoACgkQl3EQlGLyuXD9ZwCgylpdp6QUsFMbI4Y6cJO/6GS0
bJEAoMXnwqrALWj61T98dgta3PGppe2N
=83Q+
-----END PGP SIGNATURE-----

--=-JtAvGNXbLdfUQQPBLrwT--
