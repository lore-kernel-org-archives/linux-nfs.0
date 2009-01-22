From: Ian Campbell <ijc-KcIKpvwj1kUDXYZnReoRVg@public.gmane.org>
Subject: Re: [PATCH 0/3] NFS regression in 2.6.26?, "task blocked for more
	than 120 seconds"
Date: Thu, 22 Jan 2009 08:27:40 +0000
Message-ID: <1232612860.29604.57.camel@localhost.localdomain>
References: <1227737539.31008.2.camel@localhost.localdomain>
	 <1228090631.7112.11.camel@heimdal.trondhjem.org>
	 <1228169383.20370.3.camel@localhost.localdomain>
	 <1228565812.10856.30.camel@localhost.localdomain>
	 <1229279045.3721.1.camel@localhost.localdomain>
	 <20081216175503.GG16388@fieldses.org>
	 <1229452775.3721.25.camel@localhost.localdomain>
	 <20090107222115.GI965@fieldses.org> <20090108182003.GB17623@fieldses.org>
	 <1231449753.21688.12.camel@localhost.localdomain>
	 <20090108212605.GG19312@fieldses.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-uHRqfsyV6HZS9hIRcwKT"
Cc: Trond Myklebust <trond.myklebust@fys.uio.no>,
	linux-nfs@vger.kernel.org, Max Kellermann <mk-xMchvyqCc6DQT0dZR+AlfA@public.gmane.org>,
	linux-kernel@vger.kernel.org, gcosta@redhat.com,
	Grant Coady <grant_lkml-rGYn+TmxqGy6c6uEtOJ/EA@public.gmane.org>,
	Tom Tucker <tom@opengridcomputing.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mtaout01-winn.ispmail.ntl.com ([81.103.221.47]:14594 "EHLO
	mtaout01-winn.ispmail.ntl.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750761AbZAVI1x (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 22 Jan 2009 03:27:53 -0500
In-Reply-To: <20090108212605.GG19312@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


--=-uHRqfsyV6HZS9hIRcwKT
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Thu, 2009-01-08 at 16:26 -0500, J. Bruce Fields wrote:
>=20
> > > (Merged now, so testing mainline as of today should work too.)
> >=20
> > The server isn't really a machine I want to test random kernels on,
> is
> > there some subset of those changesets which it would be useful for
> me to
> > pull back onto the 2.6.26 kernel I'm using to test? (I can most like
> > manage the backporting myself).
> >=20
> > These two look like the relevant ones to me but I'm not sure:
> > 22945e4a1c7454c97f5d8aee1ef526c83fef3223 svc: Clean up deferred
> requests on transport destruction
> > 69b6ba3712b796a66595cfaf0a5ab4dfe1cf964a SUNRPC: Ensure the server
> closes sockets in a timely fashion
> >=20
> > I think 69b6 was in the set of three I tested previously and the
> other
> > two turned into 2294?
>=20
> Yep, exactly.--b.

The client machine now has an uptime of ten days without error after
these two patches were applied to the server.

Thanks everybody,
Ian.

--=20
Ian Campbell

I used to think that the brain was the most wonderful organ in
my body.  Then I realized who was telling me this.
		-- Emo Phillips

--=-uHRqfsyV6HZS9hIRcwKT
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.9 (GNU/Linux)

iEYEABECAAYFAkl4LfwACgkQM0+0qS9rzVlkXwCgvpL+UOpmjrfNlYjQZOY4g6fn
jYYAoIDboUhwTpo8mIocPrAyN8ONTlnl
=4tQq
-----END PGP SIGNATURE-----

--=-uHRqfsyV6HZS9hIRcwKT--

