From: "Brian J. Murrell" <brian-SquOHqY54CVWr29BmMi2cA@public.gmane.org>
Subject: Re: different kernels mean NFS4/GSSAPI works or doesn't
Date: Sun, 27 Mar 2011 08:42:41 -0400
Message-ID: <4D8F30C1.9030304@interlinx.bc.ca>
References: <imbb8m$uiv$1@dough.gmane.org>	 <AANLkTimFJ2fMn805jY91u8FQihib8GfJ=8S7Yy4y47R3@mail.gmail.com>	 <4D89D36D.3090207@interlinx.bc.ca>	 <AANLkTi=b1z0MrYYQmidbra0EHanegcLO5qoOScLq21rb@mail.gmail.com>	 <4D8A0C9F.8090300@interlinx.bc.ca> <1300900035.11677.12.camel@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enig46C03FE5D91718A815AF52A6"
Cc: kwc@citi.umich.edu, linux-nfs@vger.kernel.org
To: Trond.Myklebust@netapp.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from interlinx.bc.ca ([66.11.173.224]:54809 "EHLO
	linux.interlinx.bc.ca" rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org
	with ESMTP id S1753542Ab1C0MwS (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 27 Mar 2011 08:52:18 -0400
In-Reply-To: <1300900035.11677.12.camel-SyLVLa/KEI9HwK5hSS5vWB2eb7JE58TQ@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enig46C03FE5D91718A815AF52A6
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

On 11-03-23 01:07 PM, Trond Myklebust wrote:
> Please don't remove people from the Cc list.

Fair enough.  Personally, I dislike getting two copies, but I can
respect others' wishes.

> You said this happens only with RPCSEC_GSS?

Indeed.  Hrm.  Well, to be honest my two scenarios are NFS4 with
RPCSEC_GSS and NFSv3.  I've never really looked into NFS4 without
RPCSEC_GSS.  Is that even possible?  What's the point?  I guess there
are protocol improvements in NFS4 aside from RPCSEC_GSS?

> Have you tried bisecting, to see which changes caused it?

I just did, using Ubuntu's "mainline" kernels, which AFAIU are upstream
kernel source without any of their special sauce, but built with their
=2Econfigs.

It seems the problem was introduced in 2.6.32.12.  I don't really know
which commit between 2.6.32.11 and 2.6.32.12 though.  In fact I don't
even know where to find these so-called .11 and .12 4th order of
releases to see what all went into it.

I did find
http://www.kernel.org/pub/linux/kernel/v2.6/ChangeLog-2.6.32.11 but a
gitweb interface to the changes would be much more useful I think.
Although the number of changes that show up there for matches of /nfs/
or /gss/ are quite small (only one for the latter).

> You can
> probably restrict yourself to bisecting changes to include/linux/sunrpc=
,
> net/sunrpc and net/sunrpc/auth_gss.

If I could find a gitweb tree to grovel through.  :-)

b.






--------------enig46C03FE5D91718A815AF52A6
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org/

iEYEARECAAYFAk2PMMEACgkQl3EQlGLyuXCbWACg5SduTH9Qh0nQdXa07AYYLthH
m5sAn31KTdkAPGSeQkWSLdtGFdVp59rC
=Zapb
-----END PGP SIGNATURE-----

--------------enig46C03FE5D91718A815AF52A6--
