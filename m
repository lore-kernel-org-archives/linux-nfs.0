Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp.gentoo.org ([140.211.166.183]:36640 "EHLO smtp.gentoo.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751158AbbEGIXp (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 7 May 2015 04:23:45 -0400
Date: Thu, 7 May 2015 04:23:44 -0400
From: Mike Frysinger <vapier@gentoo.org>
To: Thorsten Kukuk <kukuk@suse.de>
Cc: libtirpc-devel@lists.sourceforge.net, linux-nfs@vger.kernel.org
Subject: Re: [Libtirpc-devel] [PATCH libtirpc] fix build w/gssapi disabled
Message-ID: <20150507082344.GD30924@vapier>
References: <1430983149-22199-1-git-send-email-vapier@gentoo.org>
 <20150507074046.GA13973@suse.de>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
	protocol="application/pgp-signature"; boundary="tauoZ0QFNrdllat7"
In-Reply-To: <20150507074046.GA13973@suse.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


--tauoZ0QFNrdllat7
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On 07 May 2015 09:40, Thorsten Kukuk wrote:
> On Thu, May 07, Mike Frysinger wrote:
> > Starting with commit d5259e751111cb108c784b044296185f543fc0be (Add head=
er
> > definitions for rpc_gss_*() APIs), the gss headers were pulled in all t=
he
> > time leading to build failures like so:
> >   CC       libtirpc_la-bindresvport.lo
> > In file included from ../tirpc/rpc/svc_auth.h:44:0,
> >                  from ../tirpc/rpc/rpc.h:68,
> >                  from bindresvport.c:46:
> > ../tirpc/rpc/rpcsec_gss.h:38:27: fatal error: gssapi/gssapi.h: No such =
file or directory
>=20
> This will not work since this headers will be installed in
> /usr/include and other appliations compiled against libtirpc
> will never define HAVE_RPCSEC_GSS, thus never see this interfaces.
>=20
> We need something like the glibc features.h file, which will always
> be included and defines, how tirpc was configured.

this is what tirpc/rpc/rpc.h is already doing ...
-mike

--tauoZ0QFNrdllat7
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCAAGBQJVSyEQAAoJEEFjO5/oN/WBEm8QAJI91FkDg6ZrhgYOnSBOFdfm
uBLysTW76DjaJQZqSguQDZd7USC5reyJGYrOBNY6XQmzMSeV2v2rlgjO0/Sn+goB
F+I0GxLHodlwYDGM8tXwFK0My5ver35GNPcShAHa+BCCAhoIP08tDTH8mRXSbnv6
JiEsWecHXoUxSgUMCyV3H817YfIijGtzwMXAeAHq392qoUfB/4golVgcN1Sge9CO
zeq3U1U0UaaPn7Q01zYMTv6cat/on8gYCsnEJys/1N2fboBfhaU0Jij8J2yPdEBh
ufNXgDlI34Ljb1mNeir3Gf204s3OPfLQOtsIWXSI6OUEB/VI65yh4ExB/W0uSV/Q
6pS6uNa9P0oyuLk2BQ9c9PNLnL0bN5Gd+mPTLRUsWNaH+meZxhzGM7jX6MRY0AFW
jmzbObs/JjRqmSAeNiIW3BNfX7y1zytTCsvvqwzozQWcZgoeLNRyO+QiRspWu0g/
ltAO1PtLpq/H50t7YWSi8IZee4uhzccPk3I5lHS1adWimNb63UpavQzSQ4mwtqeA
na6fPJpvgnHSGd91l3Yxe15LwCQ9Dd8mf/0MBfaHO9+p+Hngzf7KTVivXoC2s9Fs
ImgSXzcCME3UWqiJCo6rwZ458ievtT8n6UXOiuymgt8eyxoOK6YdaJFbBkA8VMHS
IaoXKuGNBLxjNq7OcqhB
=6tD7
-----END PGP SIGNATURE-----

--tauoZ0QFNrdllat7--
