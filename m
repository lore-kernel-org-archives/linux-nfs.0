From: Ian Campbell <ijc-KcIKpvwj1kUDXYZnReoRVg@public.gmane.org>
Subject: Re: NFS regression? Odd delays and lockups accessing an NFS export.
Date: Tue, 23 Sep 2008 08:59:30 +0100
Message-ID: <1222156770.6869.13.camel@localhost.localdomain>
References: <48B2D7F8.5020206@opengridcomputing.com>
	 <20080826192711.GJ4380@fieldses.org>
	 <48B567F5.2090605@opengridcomputing.com>
	 <1220111261.31172.14.camel@localhost.localdomain>
	 <20080831193037.GB14876@fieldses.org>
	 <1220211842.31172.18.camel@localhost.localdomain>
	 <48BAF643.4070808@opengridcomputing.com>
	 <1220217505.31172.26.camel@localhost.localdomain>
	 <48BC2466.2070806@opengridcomputing.com>
	 <1221036015.24993.27.camel@zakaz.uk.xensource.com>
	 <20080912224323.GN22126@fieldses.org>
	 <48CAF80A.4010109@opengridcomputing.com>
	 <1221296243.2534.7.camel@localhost.localdomain>
	 <1221544139.2534.18.camel@localhost.localdomain>
	 <48CF9AC3.6060801@opengridcomputing.com>
	 <1221577412.28572.60.camel@zakaz.uk.xensource.com>
	 <48CFD7C3.5080207@opengridcomputing.com>
	 <1221582285.28572.67.camel@zakaz.uk.xensource.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-fC+yxt09xc2hPQUhPRJR"
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
	Trond Myklebust <trond.myklebust@fys.uio.no>,
	Grant Coady <gcoady.lk@gmail.com>,
	linux-kernel@vger.kernel.org, neilb@suse.de,
	linux-nfs@vger.kernel.org
To: Tom Tucker <tom@opengridcomputing.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mtaout02-winn.ispmail.ntl.com ([81.103.221.48]:41043 "EHLO
	mtaout02-winn.ispmail.ntl.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751103AbYIWH7j (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 23 Sep 2008 03:59:39 -0400
In-Reply-To: <1221582285.28572.67.camel-o4Be2W7LfRlXesXXhkcM7miJhflN2719@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


--=-fC+yxt09xc2hPQUhPRJR
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

I've found that the problem was backported into the stable stream since
I cannot reproduce the issue with 2.6.26 but I can with 2.6.26.5. This
is quite useful since there are only 3 relevant looking changesets in
that range. I will bisect between these before confirming the culprit on
mainline.

I've had a private reply from someone who is seeing the same issue with
2.6.26.5 against a server running 2.6.18 (Debian Etch) which I think
largely discounts the server from being at fault.

Ian.
--=20
Ian Campbell

Everything ends badly.  Otherwise it wouldn't end.

--=-fC+yxt09xc2hPQUhPRJR
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.9 (GNU/Linux)

iEYEABECAAYFAkjYoeIACgkQM0+0qS9rzVn6gQCfZ4oGa0GgBJnIR9iIh3FV7ePm
NvQAoMoyKeeA5Rot5o+w+2uZHmdKfnxe
=INM6
-----END PGP SIGNATURE-----

--=-fC+yxt09xc2hPQUhPRJR--

