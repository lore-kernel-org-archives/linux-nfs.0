Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp.gentoo.org ([140.211.166.183]:38982 "EHLO smtp.gentoo.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750843AbbEGPMx (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 7 May 2015 11:12:53 -0400
Date: Thu, 7 May 2015 11:12:52 -0400
From: Mike Frysinger <vapier@gentoo.org>
To: Thorsten Kukuk <kukuk@suse.de>
Cc: libtirpc-devel@lists.sourceforge.net, linux-nfs@vger.kernel.org
Subject: Re: [Libtirpc-devel] [PATCH libtirpc] fix build w/gssapi disabled
Message-ID: <20150507151252.GE30924@vapier>
References: <1430983149-22199-1-git-send-email-vapier@gentoo.org>
 <20150507115248.GA20243@suse.de>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
	protocol="application/pgp-signature"; boundary="lBPdJKrYqo3eKYSb"
In-Reply-To: <20150507115248.GA20243@suse.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


--lBPdJKrYqo3eKYSb
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On 07 May 2015 13:52, Thorsten Kukuk wrote:
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
> Here is my proof of concept how I think we should solve this.
> But there is one part of your patch I have no solution for:
>=20
> > --- a/tirpc/rpc/svc_auth.h
> > +++ b/tirpc/rpc/svc_auth.h
> [...]
> > @@ -63,8 +67,10 @@ typedef struct SVCAUTH {
> >  		int     (*svc_ah_destroy)(struct SVCAUTH *);
> >  		} *svc_ah_ops;
> >  	caddr_t svc_ah_private;
> > +#ifdef HAVE_RPCSEC_GSS
> >  	svc_rpc_gss_parms_t svc_gss_params;
> >  	rpc_gss_rawcred_t raw_cred;
> > +#endif
> >  } SVCAUTH;
>=20
> You are changeing the size of a struct here. I'm not sure
> if this will work, if an application is compiled with headers
> where it is disabled and then runs with a tirpc where it is
> enabled. Or the other way around.
> Does somebody have an idea how to solve that?

i did notice that, but i would point out that this struct in the 0.2.5 lack=
ed=20
these members.  they're new to the 0.3.0 release.  so if ABI is a concern, =
we=20
already lost that battle ;).
-mike

--lBPdJKrYqo3eKYSb
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCAAGBQJVS4D0AAoJEEFjO5/oN/WBv84QAMm5YCxoG4n/7R9k2LG45c6p
6w5jRM+gBwgVBz9pOVhAZLYTpRfKBPJem3mKMDu2rjKmuHSeRmcK5KP5v2c/hPtc
CQiKmW4MEXfN6CuJOXs4UEO+Y3MO7IeZBqk5nD+55i1/2E8J23LD/2ud6F11qwmK
XSlu0hmGfpnAdafskVBeCb5g+56455LYpnayX0WmjxKkWw3x4RVnzUu27ppfhPSc
lC+jqANA9EX6KsUb8+vBrXj+taV3t07n8st1dqxFu6GGfauKYMMiilAT/y75OH0T
Imi6u3LnRGoiHsQS6HANA50gdhEdGyHRJOvizhVbfi5utcanaIUpZrNEBr587UFa
URQUYRxhDyNPtLufedESO6pNuOvY6xB/b8Ut54cztAW6ls5rSAvhqkHlhGTZTsjG
VKY8nwTg5XYW31PyKtmeNpfbJzHGywgd6N+GxSo3XdcO7fD5cJoH3S45v5gvaQ8H
cuOaiTLLKX/6Wau558YFtXH/lHm1nmJr+HX6qV0BiHAZh+W+AkKmtcMcp9R2mCs8
f7rf+UjGvlcUyuLySLvetHb0tacAgVaNyGlgSLh9nou7L7Pg2NS6gpKA2WVjxF1w
0vP6bngAQ6p5y6LiZOp574P+1zW2yB2r9AWSXhKNSNbvyiQpfO7jAzkJio+ZWpMK
/++xeGQPtP8XJAl8mfd5
=JCii
-----END PGP SIGNATURE-----

--lBPdJKrYqo3eKYSb--
