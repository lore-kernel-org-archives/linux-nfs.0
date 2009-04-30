From: Andrew Savchenko <bircoph@gmail.com>
Subject: Re: [Bug] NFSv4 fails to work without ipv6 kernel module
Date: Fri, 1 May 2009 03:04:45 +0400
Message-ID: <200905010304.45884.bircoph@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart4882592.W5xI3vgZTv";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ew0-f176.google.com ([209.85.219.176]:65485 "EHLO
	mail-ew0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1763855AbZD3XE7 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 30 Apr 2009 19:04:59 -0400
Received: by ewy24 with SMTP id 24so2210759ewy.37
        for <linux-nfs@vger.kernel.org>; Thu, 30 Apr 2009 16:04:57 -0700 (PDT)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--nextPart4882592.W5xI3vgZTv
Content-Type: text/plain;
  charset="windows-1251"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

Hello, Chuck!

[10l, forget to CC to list]

On Thursday 30 April 2009, Chuck Lever wrote:
[...]
> > With ipv6 module loaded all works fine.
> >
> >> You can also try building 2.6.28 with
> >> CONFIG_SUNRPC_REGISTER_V4 disabled.
> >
> > With this option disabled errno 5 (see above) disappeared from
> > logs, but mount fails with the same errors. Yet again, with
> > ipv6 module loaded it works ok.
>
> Reproduced here.  A patch is attached.  (I usually send patches
> inline, but to test 2.6.29-stable I'm working outside of git,
> using old-fashioned tools like "diff").

Patch works ok, thank you.

=2D-=20
Best regards,
Andrew

--nextPart4882592.W5xI3vgZTv
Content-Type: application/pgp-signature; name=signature.asc 
Content-Description: This is a digitally signed message part.

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.11 (GNU/Linux)

iEYEABECAAYFAkn6Lo0ACgkQ2anJBBcsZw38sACgvv9TTWEJclQFT4ShpP6Ed0Ub
bgYAoNa4WlBJGkdvAx9daY1GJ5jvVXlE
=U+mV
-----END PGP SIGNATURE-----

--nextPart4882592.W5xI3vgZTv--
