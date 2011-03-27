Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from lo.gmane.org ([80.91.229.12]:39288 "EHLO lo.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752061Ab1C0AH0 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 26 Mar 2011 20:07:26 -0400
Received: from list by lo.gmane.org with local (Exim 4.69)
	(envelope-from <glN-linux-nfs@m.gmane.org>)
	id 1Q3dVt-0005AQ-O3
	for linux-nfs@vger.kernel.org; Sun, 27 Mar 2011 01:07:25 +0100
Received: from d67-193-214-242.home3.cgocable.net ([67.193.214.242])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <linux-nfs@vger.kernel.org>; Sun, 27 Mar 2011 01:07:25 +0100
Received: from brian by d67-193-214-242.home3.cgocable.net with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <linux-nfs@vger.kernel.org>; Sun, 27 Mar 2011 01:07:25 +0100
To: linux-nfs@vger.kernel.org
From: "Brian J. Murrell" <brian@interlinx.bc.ca>
Subject: Re: different kernels mean NFS4/GSSAPI works or doesn't
Date: Sat, 26 Mar 2011 20:07:12 -0400
Message-ID: <4D8E7FB0.9060109@interlinx.bc.ca>
References: <imbb8m$uiv$1@dough.gmane.org>	 <AANLkTimFJ2fMn805jY91u8FQihib8GfJ=8S7Yy4y47R3@mail.gmail.com>	 <4D89D36D.3090207@interlinx.bc.ca>	 <AANLkTi=b1z0MrYYQmidbra0EHanegcLO5qoOScLq21rb@mail.gmail.com>	 <4D8A0C9F.8090300@interlinx.bc.ca> <1300900035.11677.12.camel@lade.trondhjem.org>
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enig51F3B30CECD4604F801EDDC6"
Cc: Kevin Coffman <public-kwc-vtMw8L3fJ9vSiEDVxGk4TQ@lo.gmane.org>
In-Reply-To: <1300900035.11677.12.camel@lade.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

--------------enig51F3B30CECD4604F801EDDC6
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




--------------enig51F3B30CECD4604F801EDDC6
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org/

iEYEARECAAYFAk2Of7AACgkQl3EQlGLyuXA6KACgndbSOAncrfUCQI2BEWlgkZlc
0IoAoMpQWD3/fGsY8Ql1aN1a7DSnFCXK
=juBK
-----END PGP SIGNATURE-----

--------------enig51F3B30CECD4604F801EDDC6--
