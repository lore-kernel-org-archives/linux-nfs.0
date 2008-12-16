From: Ian Campbell <ijc-KcIKpvwj1kUDXYZnReoRVg@public.gmane.org>
Subject: Re: [PATCH 0/3] NFS regression in 2.6.26?, "task blocked for more
	than 120 seconds"
Date: Tue, 16 Dec 2008 18:39:35 +0000
Message-ID: <1229452775.3721.25.camel@localhost.localdomain>
References: <1227596962.16868.22.camel@localhost.localdomain>
	 <1227619696.7057.19.camel@heimdal.trondhjem.org>
	 <1227620339.9425.99.camel@zakaz.uk.xensource.com>
	 <1227621434.7057.33.camel@heimdal.trondhjem.org>
	 <1227621877.9425.102.camel@zakaz.uk.xensource.com>
	 <1227737539.31008.2.camel@localhost.localdomain>
	 <1228090631.7112.11.camel@heimdal.trondhjem.org>
	 <1228169383.20370.3.camel@localhost.localdomain>
	 <1228565812.10856.30.camel@localhost.localdomain>
	 <1229279045.3721.1.camel@localhost.localdomain>
	 <20081216175503.GG16388@fieldses.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-ZFpDXblzXlZwR0uz0c45"
Cc: Trond Myklebust <trond.myklebust@fys.uio.no>,
	linux-nfs@vger.kernel.org, Max Kellermann <mk-xMchvyqCc6DQT0dZR+AlfA@public.gmane.org>,
	linux-kernel@vger.kernel.org, gcosta@redhat.com,
	Grant Coady <grant_lkml-rGYn+TmxqGy6c6uEtOJ/EA@public.gmane.org>,
	Tom Tucker <tom@opengridcomputing.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mtaout01-winn.ispmail.ntl.com ([81.103.221.47]:16919 "EHLO
	mtaout01-winn.ispmail.ntl.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751000AbYLPSju (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 16 Dec 2008 13:39:50 -0500
In-Reply-To: <20081216175503.GG16388@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


--=-ZFpDXblzXlZwR0uz0c45
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Tue, 2008-12-16 at 12:55 -0500, J. Bruce Fields wrote:
> On Sun, Dec 14, 2008 at 06:24:05PM +0000, Ian Campbell wrote:
> > On Sat, 2008-12-06 at 12:16 +0000, Ian Campbell wrote:
> > > On Mon, 2008-12-01 at 22:09 +0000, Ian Campbell wrote:
> > > > On Sun, 2008-11-30 at 19:17 -0500, Trond Myklebust wrote:=20
> > > > > Can you see if the following 3 patches help? They're against 2.6.=
28-rc6,
> > > > > but afaics the problems are pretty much the same on 2.6.26.
> > > >=20
> > > > Thanks.
> > > >=20
> > > > The server was actually running 2.6.25.7 but the matching sources h=
ave
> > > > since been removed the backports.org so I've reproduce with 2.6.26 =
and
> > > > now I'll add the patches.
> > >=20
> > > Just a small progress report. Anecdotally I thought that unpatched
> > > 2.6.26.7 was worse than 2.6.25.7, mostly because it hung twice in the=
 ~1
> > > day I was running it where previously it was less frequent than once =
per
> > > day.
> > >=20
> > > With the patched server the client ran OK for 2.5 days then mysteriou=
sly
> > > hung, the logs show none of the normal symptoms and my wife reset it
> > > before I got home so I've no real clue what happened but I'm inclined=
 to
> > > think it was unrelated for now. I'll get back to you in a week or so =
if
> > > the problem hasn't reoccurred.
> >=20
> > $ uptime=20
> >  18:15:29 up 9 days, 22 min,  1 user,  load average: 0.74, 0.64, 0.46
> >=20
> > This is on the problematic client, so it looks like the server side fix
> > has sorted it. Thanks very much Trond.
>=20
> Thanks for the testing!  So this was with the following three patches
> applied on the server on top of 2.6.26?
>=20
> 	[PATCH 1/3] SUNRPC: Ensure the server closes sockets in a timely fashion
> 	[PATCH 2/3] SUNRPC: We only need to call svc_delete_xprt() once...
> 	[PATCH 3/3] SUNRPC: svc_xprt_enqueue should not refuse to enqueue 'XPT_D=
EAD' transports

That's right, it was actually 2.6.26.7 FWIW.

> I'll try to take a look at these before I leave for the holidays,
> assuming the versions Trond posted on Nov. 30 are the latest.

Thanks.

Ian.
--=20
Ian Campbell

The light of a hundred stars does not equal the light of the moon.

--=-ZFpDXblzXlZwR0uz0c45
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.9 (GNU/Linux)

iEYEABECAAYFAklH9ecACgkQM0+0qS9rzVnM/wCfb3ArQ2syhn5OhcsPOVBlzBrW
dMkAnilwZVMzML490u+fQlhd/DWVeQN9
=ySXr
-----END PGP SIGNATURE-----

--=-ZFpDXblzXlZwR0uz0c45--

