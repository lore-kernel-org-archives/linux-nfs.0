Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail4.gandi.net ([217.70.183.210]:51997 "EHLO gandi.net"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S932122AbbGJMyr (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 10 Jul 2015 08:54:47 -0400
Date: Fri, 10 Jul 2015 14:54:44 +0200
From: William Dauchy <william@gandi.net>
To: Jeff Layton <jlayton@poochiereds.net>
Cc: William Dauchy <william@gandi.net>,
        Linux NFS mailing list <linux-nfs@vger.kernel.org>,
        Trond Myklebust <trond.myklebust@primarydata.com>, jloup@gandi.net
Subject: Re: extra reference to fl->fl_file, possible regression
Message-ID: <20150710125444.GL15144@gandi.net>
References: <20150710092910.GI15144@gandi.net>
 <20150710072438.08b3417a@tlielax.poochiereds.net>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="ai3I8gwHc37+ASRI"
In-Reply-To: <20150710072438.08b3417a@tlielax.poochiereds.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


--ai3I8gwHc37+ASRI
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Jul10 07:24, Jeff Layton wrote:
> Huh. I'm stumped...
>=20
> These patches are pretty straightforward. We're just taking an extra
> reference to the filp when running lock operations so that it doesn't
> disappear before the replies can be processed (typically in the event
> that a signal comes in while waiting on the reply). Given the odd stack
> trace above, I have to wonder if there's some sort of memory scribble
> going on.

I also forgot to mention that I also had the following messgae before
the trace:

VFS: Close: file count is 0

--=20
William

--ai3I8gwHc37+ASRI
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iEYEARECAAYFAlWfwJQACgkQ1I6eqOUidQEdTwCgn1vdFJJpYI8Ie7vkAYFwiXKQ
3WwAoIPMm3vciCl2MjJxrcsHcj06pJrE
=Fi0e
-----END PGP SIGNATURE-----

--ai3I8gwHc37+ASRI--
