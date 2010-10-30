Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from server.klug.on.ca ([205.189.48.131]:3373 "EHLO
	server.klug.on.ca" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753434Ab0J3Vq6 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 30 Oct 2010 17:46:58 -0400
Received: from linux.interlinx.bc.ca (d67-193-197-208.home3.cgocable.net [67.193.197.208])
	(using TLSv1 with cipher DHE-RSA-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by server.klug.on.ca (Postfix) with ESMTP id 277C62803
	for <linux-nfs@vger.kernel.org>; Sat, 30 Oct 2010 17:46:57 -0400 (EDT)
Received: from [10.75.22.1] (pc.ilinx [10.75.22.1])
	by linux.interlinx.bc.ca (Postfix) with ESMTP id 52DF386B0
	for <linux-nfs@vger.kernel.org>; Sat, 30 Oct 2010 17:46:56 -0400 (EDT)
Subject: Re: Error: state manager failed on NFSv4 server linux with error
 127
From: "Brian J. Murrell" <brian@interlinx.bc.ca>
To: linux-nfs@vger.kernel.org
In-Reply-To: <1288474886.8621.3.camel@heimdal.trondhjem.org>
References: <1287334833.4871.6.camel@pc>
	 <1287340520.5266.70.camel@heimdal.trondhjem.org>
	 <1288460514.32627.105.camel@pc>
	 <1288461151.3238.9.camel@heimdal.trondhjem.org>
	 <1288461562.32627.151.camel@pc>
	 <1288462786.3238.16.camel@heimdal.trondhjem.org>
	 <1288474164.32627.383.camel@pc>
	 <1288474886.8621.3.camel@heimdal.trondhjem.org>
Content-Type: multipart/signed; micalg="pgp-sha1"; protocol="application/pgp-signature"; boundary="=-V7Gj+wg1A2k9qiT5UgAs"
Date: Sat, 30 Oct 2010 17:46:55 -0400
Message-ID: <1288475215.32627.406.camel@pc>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

--=-V7Gj+wg1A2k9qiT5UgAs
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Sat, 2010-10-30 at 17:41 -0400, Trond Myklebust wrote:=20
>=20
> There are 2 cases which can trigger recovery: server reboot, and network
> partition (i.e. a networking fault that causes the client to be unable
> to contact the server in time in order to renew its lease).

Yes, seems two cases which I would suspect also.

> If none of the above apply,

None should be applicable.  Of course I could never know if the network
"blipped" (but highly doubt even that happened) but there should not
have been an outtage long enough to prevent a lease renewal.

> then we need to look at whether it is the
> client or the server that is screwed up.

Yes, fair enough.  I suppose having more than 1 client using the same
server could be sufficient to determine fault at the client or server?
Or is there a more direct route?

b.


--=-V7Gj+wg1A2k9qiT5UgAs
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)

iEYEABECAAYFAkzMkk8ACgkQl3EQlGLyuXATagCeJCP+NsHmN4bl+2O+wxowg3V1
qigAn2CH9b/VFLnIvNBghXBdjLbaBXgT
=y9Mw
-----END PGP SIGNATURE-----

--=-V7Gj+wg1A2k9qiT5UgAs--
