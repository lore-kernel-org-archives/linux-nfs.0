From: Ian Campbell <ijc-KcIKpvwj1kUDXYZnReoRVg@public.gmane.org>
Subject: Re: NFS regression? Odd delays and lockups accessing an NFS export.
Date: Sun, 31 Aug 2008 22:18:25 +0100
Message-ID: <1220217505.31172.26.camel@localhost.localdomain>
References: <1219442213.9097.25.camel@localhost>
	 <1219603981.27921.145.camel@localhost.localdomain>
	 <1219605422.14389.2.camel@localhost> <1219605596.14389.5.camel@localhost>
	 <1219615789.27921.152.camel@localhost.localdomain>
	 <1219616136.14389.12.camel@localhost>
	 <48B2D7F8.5020206@opengridcomputing.com>
	 <20080826192711.GJ4380@fieldses.org>
	 <48B567F5.2090605@opengridcomputing.com>
	 <1220111261.31172.14.camel@localhost.localdomain>
	 <20080831193037.GB14876@fieldses.org>
	 <1220211842.31172.18.camel@localhost.localdomain>
	 <48BAF643.4070808@opengridcomputing.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-5cFuHFFWM7no6u50eDd+"
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
	Trond Myklebust <trond.myklebust@fys.uio.no>,
	John Ronciak <john.ronciak@gmail.com>,
	Grant Coady <gcoady.lk@gmail.com>,
	linux-kernel@vger.kernel.org, neilb@suse.de,
	linux-nfs@vger.kernel.org,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Bruce Allan <bruce.w.allan@intel.com>,
	PJ Waskiewicz <peter.p.waskiewicz.jr@intel.com>,
	John Ronciak <john.ronciak@intel.com>,
	e1000-devel@lists.sourceforge.net
To: Tom Tucker <tom@opengridcomputing.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mtaout01-winn.ispmail.ntl.com ([81.103.221.47]:60307 "EHLO
	mtaout01-winn.ispmail.ntl.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752412AbYHaVSd (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 31 Aug 2008 17:18:33 -0400
In-Reply-To: <48BAF643.4070808@opengridcomputing.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


--=-5cFuHFFWM7no6u50eDd+
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Sun, 2008-08-31 at 14:51 -0500, Tom Tucker wrote:
>=20
> Looks like you ran this on the client. Sorry, Ian, I should have been
> more specific. You need to modify the rpc_debug file on the server.

I tried this on the server but it's pretty crippling (the server is
quite weedy, 300MHz K3 or something).

I'll leave it logging overnight since things should be pretty quiet (and
that's often when the problem occurs) but if there's a less aggressive
setting than 256 but which would still be useful I could leave it on
permanently until the problem happens.

Ian.
--=20
Ian Campbell

Marriages are made in heaven and consummated on earth.
		-- John Lyly

--=-5cFuHFFWM7no6u50eDd+
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.9 (GNU/Linux)

iEYEABECAAYFAki7CqEACgkQM0+0qS9rzVlzCwCgmRve7F25dzDC+NeywP0hF4gr
F+cAoLhNPR1btyuZkr31AfLYHwg6pQAZ
=9h3S
-----END PGP SIGNATURE-----

--=-5cFuHFFWM7no6u50eDd+--

