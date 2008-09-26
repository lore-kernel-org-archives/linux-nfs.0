From: Ian Campbell <ijc-KcIKpvwj1kUDXYZnReoRVg@public.gmane.org>
Subject: Re: NFS regression? Odd delays and lockups accessing an NFS export.
Date: Fri, 26 Sep 2008 19:17:33 +0100
Message-ID: <1222453053.3949.21.camel@localhost.localdomain>
References: <20080912224323.GN22126@fieldses.org>
	 <48CAF80A.4010109@opengridcomputing.com>
	 <1221296243.2534.7.camel@localhost.localdomain>
	 <1221544139.2534.18.camel@localhost.localdomain>
	 <48CF9AC3.6060801@opengridcomputing.com>
	 <1221577412.28572.60.camel@zakaz.uk.xensource.com>
	 <48CFD7C3.5080207@opengridcomputing.com>
	 <1221582285.28572.67.camel@zakaz.uk.xensource.com>
	 <1222156770.6869.13.camel@localhost.localdomain>
	 <1222169589.6869.20.camel@localhost.localdomain>
	 <20080923170344.GC2700@fieldses.org>
	 <1222443426.3949.18.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-GrfiCwdn8hFeHg9fofwS"
Cc: Tom Tucker <tom@opengridcomputing.com>,
	Trond Myklebust <trond.myklebust@fys.uio.no>,
	Grant Coady <gcoady.lk@gmail.com>,
	linux-kernel@vger.kernel.org, neilb@suse.de,
	linux-nfs@vger.kernel.org
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mtaout01-winn.ispmail.ntl.com ([81.103.221.47]:23200 "EHLO
	mtaout01-winn.ispmail.ntl.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752503AbYIZSRm (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 26 Sep 2008 14:17:42 -0400
In-Reply-To: <1222443426.3949.18.camel-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


--=-GrfiCwdn8hFeHg9fofwS
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Fri, 2008-09-26 at 16:37 +0100, Ian Campbell wrote:
> It's possible, the good case is naturally quite hard to establish with
> 100% certainty. I declared v2.6.26 OK after an uptime of 4 days and 19
> hours, compared with failure normally within 1-2 days. It's possible I
> was premature in doing so. I'll run 2e96d2867 for at least a full week
> before reporting back.

Or it'll reproduce after just a few hours :-/

Looks like a false negative on v2.6.26 -- I'll retest from there.

Ian.

--=20
Ian Campbell

That secret you've been guarding, isn't.

--=-GrfiCwdn8hFeHg9fofwS
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.9 (GNU/Linux)

iEYEABECAAYFAkjdJzwACgkQM0+0qS9rzVlhXgCfVfi+FgdOHW3/5wkWUmhU4dqS
Z9QAniJhdkWjeeg1WjgEWTK2hN7Yot/J
=xvRm
-----END PGP SIGNATURE-----

--=-GrfiCwdn8hFeHg9fofwS--

