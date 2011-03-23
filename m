From: "Brian J. Murrell" <brian-SquOHqY54CVWr29BmMi2cA@public.gmane.org>
Subject: Re: different kernels mean NFS4/GSSAPI works or doesn't
Date: Wed, 23 Mar 2011 11:07:11 -0400
Message-ID: <4D8A0C9F.8090300@interlinx.bc.ca>
References: <imbb8m$uiv$1@dough.gmane.org>	<AANLkTimFJ2fMn805jY91u8FQihib8GfJ=8S7Yy4y47R3@mail.gmail.com>	<4D89D36D.3090207@interlinx.bc.ca> <AANLkTi=b1z0MrYYQmidbra0EHanegcLO5qoOScLq21rb@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enigA271564123D175FF91B9B974"
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from lo.gmane.org ([80.91.229.12]:47681 "EHLO lo.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932945Ab1CWPH3 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 23 Mar 2011 11:07:29 -0400
Received: from list by lo.gmane.org with local (Exim 4.69)
	(envelope-from <glN-linux-nfs@m.gmane.org>)
	id 1Q2Peh-0003QE-I9
	for linux-nfs@vger.kernel.org; Wed, 23 Mar 2011 16:07:27 +0100
Received: from d67-193-214-242.home3.cgocable.net ([67.193.214.242])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <linux-nfs@vger.kernel.org>; Wed, 23 Mar 2011 16:07:27 +0100
Received: from brian by d67-193-214-242.home3.cgocable.net with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <linux-nfs@vger.kernel.org>; Wed, 23 Mar 2011 16:07:27 +0100
In-Reply-To: <AANLkTi=b1z0MrYYQmidbra0EHanegcLO5qoOScLq21rb-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enigA271564123D175FF91B9B974
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

On 11-03-23 10:29 AM, Kevin Coffman wrote:
>=20
> However, that doesn't appear to be the case from looking at the
> gssd/svcgssd output.  Have you checked the server's syslog for
> messages about rpc.gssd not running?

Yup.  Nothing there.

> OK.  Thanks.  There is enough info there, even with the redaction.

Ahhh.  Good.

> This shows that a des (enctype 4) session key is being negotiated and
> delivered to both kernels, so I don't think any of the Kerberos issues
> should be involved here.  (At least from the user-land perspective.)

Hrm.  So this gets even more interesting (for some values of "interesting=
").

> I'm not sure what kernel change would be causing your hang ...

Thanks for looking though.

I'm open to any more ideas, debugging info requests, etc. that anyone
might have.

b.


--------------enigA271564123D175FF91B9B974
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org/

iEYEARECAAYFAk2KDJ8ACgkQl3EQlGLyuXC0UACfWRcpiyr9lR5qe7ySJnUNqZi3
CskAn3HYn1Ru5euBvOve/4DAS39029Bx
=upHz
-----END PGP SIGNATURE-----

--------------enigA271564123D175FF91B9B974--

