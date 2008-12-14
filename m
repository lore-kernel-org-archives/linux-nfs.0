From: Ian Campbell <ijc-KcIKpvwj1kUDXYZnReoRVg@public.gmane.org>
Subject: Re: [PATCH 0/3] NFS regression in 2.6.26?, "task blocked for more
	than 120 seconds"
Date: Sun, 14 Dec 2008 18:24:05 +0000
Message-ID: <1229279045.3721.1.camel@localhost.localdomain>
References: <20081017123207.GA14979@rabbit.intern.cm-ag>
	 <1224484046.23068.14.camel@localhost.localdomain>
	 <1225539927.2221.3.camel@localhost.localdomain>
	 <1225546878.4390.3.camel@heimdal.trondhjem.org>
	 <1227596962.16868.22.camel@localhost.localdomain>
	 <1227619696.7057.19.camel@heimdal.trondhjem.org>
	 <1227620339.9425.99.camel@zakaz.uk.xensource.com>
	 <1227621434.7057.33.camel@heimdal.trondhjem.org>
	 <1227621877.9425.102.camel@zakaz.uk.xensource.com>
	 <1227737539.31008.2.camel@localhost.localdomain>
	 <1228090631.7112.11.camel@heimdal.trondhjem.org>
	 <1228169383.20370.3.camel@localhost.localdomain>
	 <1228565812.10856.30.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-84U0ymxV8LHT/KQ4Ne6R"
Cc: linux-nfs@vger.kernel.org, Max Kellermann <mk-xMchvyqCc6DQT0dZR+AlfA@public.gmane.org>,
	linux-kernel@vger.kernel.org, gcosta@redhat.com,
	Grant Coady <grant_lkml-rGYn+TmxqGy6c6uEtOJ/EA@public.gmane.org>,
	"J. Bruce Fields" <bfields@fieldses.org>,
	Tom Tucker <tom@opengridcomputing.com>
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mtaout03-winn.ispmail.ntl.com ([81.103.221.49]:32144 "EHLO
	mtaout03-winn.ispmail.ntl.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751001AbYLNSYf (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 14 Dec 2008 13:24:35 -0500
In-Reply-To: <1228565812.10856.30.camel-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


--=-84U0ymxV8LHT/KQ4Ne6R
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Sat, 2008-12-06 at 12:16 +0000, Ian Campbell wrote:
> On Mon, 2008-12-01 at 22:09 +0000, Ian Campbell wrote:
> > On Sun, 2008-11-30 at 19:17 -0500, Trond Myklebust wrote:=20
> > > Can you see if the following 3 patches help? They're against 2.6.28-r=
c6,
> > > but afaics the problems are pretty much the same on 2.6.26.
> >=20
> > Thanks.
> >=20
> > The server was actually running 2.6.25.7 but the matching sources have
> > since been removed the backports.org so I've reproduce with 2.6.26 and
> > now I'll add the patches.
>=20
> Just a small progress report. Anecdotally I thought that unpatched
> 2.6.26.7 was worse than 2.6.25.7, mostly because it hung twice in the ~1
> day I was running it where previously it was less frequent than once per
> day.
>=20
> With the patched server the client ran OK for 2.5 days then mysteriously
> hung, the logs show none of the normal symptoms and my wife reset it
> before I got home so I've no real clue what happened but I'm inclined to
> think it was unrelated for now. I'll get back to you in a week or so if
> the problem hasn't reoccurred.

$ uptime=20
 18:15:29 up 9 days, 22 min,  1 user,  load average: 0.74, 0.64, 0.46

This is on the problematic client, so it looks like the server side fix
has sorted it. Thanks very much Trond.

Ian.
--=20
Ian Campbell

You have only to mumble a few words in church to get married and few words
in your sleep to get divorced.

--=-84U0ymxV8LHT/KQ4Ne6R
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.9 (GNU/Linux)

iEYEABECAAYFAklFTzYACgkQM0+0qS9rzVnkfACaA+HfZO4cma2BEN0gLS9ImG2i
RvgAmgPRXKARJCHdV94NRENB8eqHQnnO
=rzIg
-----END PGP SIGNATURE-----

--=-84U0ymxV8LHT/KQ4Ne6R--

