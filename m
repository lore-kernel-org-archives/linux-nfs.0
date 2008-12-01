From: Ian Campbell <ijc-KcIKpvwj1kUDXYZnReoRVg@public.gmane.org>
Subject: Re: [PATCH 0/3] NFS regression in 2.6.26?, "task blocked for more
	than 120 seconds"
Date: Mon, 01 Dec 2008 22:09:43 +0000
Message-ID: <1228169383.20370.3.camel@localhost.localdomain>
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
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-fdxN1Lu/rB3vInNey/+0"
Cc: linux-nfs@vger.kernel.org, Max Kellermann <mk-xMchvyqCc6DQT0dZR+AlfA@public.gmane.org>,
	linux-kernel@vger.kernel.org, gcosta@redhat.com,
	Grant Coady <grant_lkml-rGYn+TmxqGy6c6uEtOJ/EA@public.gmane.org>,
	"J. Bruce Fields" <bfields@fieldses.org>,
	Tom Tucker <tom@opengridcomputing.com>
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mtaout02-winn.ispmail.ntl.com ([81.103.221.48]:25037 "EHLO
	mtaout02-winn.ispmail.ntl.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751352AbYLAWJx (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 1 Dec 2008 17:09:53 -0500
In-Reply-To: <1228090631.7112.11.camel-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


--=-fdxN1Lu/rB3vInNey/+0
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Sun, 2008-11-30 at 19:17 -0500, Trond Myklebust wrote:=20
> Can you see if the following 3 patches help? They're against 2.6.28-rc6,
> but afaics the problems are pretty much the same on 2.6.26.

Thanks.

The server was actually running 2.6.25.7 but the matching sources have
since been removed the backports.org so I've reproduce with 2.6.26 and
now I'll add the patches.

Ian.

--=20
Ian Campbell

It has been said that man is a rational animal.  All my life I have
been searching for evidence which could support this.
		-- Bertrand Russell

--=-fdxN1Lu/rB3vInNey/+0
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.9 (GNU/Linux)

iEYEABECAAYFAkk0YKQACgkQM0+0qS9rzVnbfgCeI9t5hcCZr1uJOdXqiL9JTIlF
bLQAniodHB39FqnSdZvWbEMJPh0Sxp1i
=dJAs
-----END PGP SIGNATURE-----

--=-fdxN1Lu/rB3vInNey/+0--

