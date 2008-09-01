From: Ian Campbell <ijc-KcIKpvwj1kUDXYZnReoRVg@public.gmane.org>
Subject: Re: NFS regression? Odd delays and lockups accessing an NFS export.
Date: Mon, 01 Sep 2008 18:46:03 +0100
Message-ID: <1220291163.31172.29.camel@localhost.localdomain>
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
	 <1220217505.31172.26.camel@localhost.localdomain>
	 <48BC2466.2070806@opengridcomputing.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-sUCVRBzqQpsesCtSuDxl"
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
Received: from mtaout02-winn.ispmail.ntl.com ([81.103.221.48]:21840 "EHLO
	mtaout02-winn.ispmail.ntl.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750957AbYIARvT (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 1 Sep 2008 13:51:19 -0400
In-Reply-To: <48BC2466.2070806@opengridcomputing.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


--=-sUCVRBzqQpsesCtSuDxl
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Mon, 2008-09-01 at 12:20 -0500, Tom Tucker wrote:
> Thanks Ian. Unfortunately, that's as fine grained as it gets. 256=20
> (0x100) is the bit for transport logging.

Doh, of course, I was thinking of 255...

No repro today. I'll let you know when I see something.

Ian.

--=20
Ian Campbell

History is nothing but a collection of fables and useless trifles,
cluttered up with a mass of unnecessary figures and proper names.
		-- Leo Tolstoy

--=-sUCVRBzqQpsesCtSuDxl
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.9 (GNU/Linux)

iEYEABECAAYFAki8KlsACgkQM0+0qS9rzVkPHQCgsAOGAHSt3eYeEJudAZWeR5KQ
ma4AoNoZlWra64hyjHMdTY5jc3cYWrtI
=pHPO
-----END PGP SIGNATURE-----

--=-sUCVRBzqQpsesCtSuDxl--

