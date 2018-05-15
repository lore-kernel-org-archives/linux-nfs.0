Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx3-rdu2.redhat.com ([66.187.233.73]:39594 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1752145AbeEOOwP (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 15 May 2018 10:52:15 -0400
Message-ID: <1cd0dc42bf058d88d2cf239ca04e81e3726203b1.camel@redhat.com>
Subject: Re: [PATCH v1 01/19] svcrdma: Add proper SPDX tags for
 NetApp-contributed source
From: Doug Ledford <dledford@redhat.com>
To: Chuck Lever <chuck.lever@oracle.com>,
        Bruce Fields <bfields@fieldses.org>
Cc: linux-rdma@vger.kernel.org,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Date: Tue, 15 May 2018 10:52:14 -0400
In-Reply-To: <32DBD8DB-07FD-4D89-B88A-348B0F6103BB@oracle.com>
References: <20180507192126.4608.63295.stgit@klimt.1015granger.net>
         <20180507192655.4608.26260.stgit@klimt.1015granger.net>
         <20180509202323.GA31959@fieldses.org>
         <32DBD8DB-07FD-4D89-B88A-348B0F6103BB@oracle.com>
Content-Type: multipart/signed; micalg="pgp-sha256";
        protocol="application/pgp-signature"; boundary="=-0kmFk/k97E46IAiSwFKI"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


--=-0kmFk/k97E46IAiSwFKI
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Wed, 2018-05-09 at 16:42 -0400, Chuck Lever wrote:
> > On May 9, 2018, at 4:23 PM, J. Bruce Fields <bfields@fieldses.org> wrot=
e:
> >=20
> > Looking at the git history, it looks like others are taking this as an
> > opportunity to replace the existing boilerplate.  Could we do this here=
?
> > Looks like "BSD-3-Clause" does in fact refer to a license that's
> > word-for-word the same as the one included here (except for the name of
> > the copyright holder), so I wonder if we need it written out here any
> > more.
> >=20
> > (Minor point, I'm applying this anyway and you can follow up with the
> > remval patch or not.)
>=20
> Because the holder's name is part of the boilerplate, I feel
> that it is up to the holder to submit a patch removing the
> whole copyright notice if they are comfortable doing that.
>=20
> But IANAL. Feel free to convince me that I'm being prudish.

As long as you leave their ownership statement, the SPDX replacement is
a direct replacement for the license text.  Just because the two are in
the same comment block (the ownership statement and date, and the text
of the actual license) does not mean they are a single item.  The
license is a license, the other is an ownership statement, and replacing
the long form license term with an accepted short form license term that
is regarded as being identical to the long form is perfectly acceptable.

>=20
> > --b.
> >=20
> > On Mon, May 07, 2018 at 03:26:55PM -0400, Chuck Lever wrote:
> > > Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
> > > ---
> > > include/linux/sunrpc/svc_rdma.h          |    1 +
> > > net/sunrpc/xprtrdma/svc_rdma.c           |    1 +
> > > net/sunrpc/xprtrdma/svc_rdma_recvfrom.c  |    1 +
> > > net/sunrpc/xprtrdma/svc_rdma_sendto.c    |    1 +
> > > net/sunrpc/xprtrdma/svc_rdma_transport.c |    1 +
> > > 5 files changed, 5 insertions(+)
> > >=20
> > > diff --git a/include/linux/sunrpc/svc_rdma.h b/include/linux/sunrpc/s=
vc_rdma.h
> > > index 7337e12..88da0c9 100644
> > > --- a/include/linux/sunrpc/svc_rdma.h
> > > +++ b/include/linux/sunrpc/svc_rdma.h
> > > @@ -1,3 +1,4 @@
> > > +/* SPDX-License-Identifier: GPL-2.0 OR BSD-3-Clause */
> > > /*
> > >  * Copyright (c) 2005-2006 Network Appliance, Inc. All rights reserve=
d.
> > >  *
> > > diff --git a/net/sunrpc/xprtrdma/svc_rdma.c b/net/sunrpc/xprtrdma/svc=
_rdma.c
> > > index dd8a431..a490532 100644
> > > --- a/net/sunrpc/xprtrdma/svc_rdma.c
> > > +++ b/net/sunrpc/xprtrdma/svc_rdma.c
> > > @@ -1,3 +1,4 @@
> > > +// SPDX-License-Identifier: GPL-2.0 OR BSD-3-Clause
> > > /*
> > >  * Copyright (c) 2005-2006 Network Appliance, Inc. All rights reserve=
d.
> > >  *
> > > diff --git a/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c b/net/sunrpc/xpr=
trdma/svc_rdma_recvfrom.c
> > > index 3d45015..9eae95d 100644
> > > --- a/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c
> > > +++ b/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c
> > > @@ -1,3 +1,4 @@
> > > +// SPDX-License-Identifier: GPL-2.0 OR BSD-3-Clause
> > > /*
> > >  * Copyright (c) 2016, 2017 Oracle. All rights reserved.
> > >  * Copyright (c) 2014 Open Grid Computing, Inc. All rights reserved.
> > > diff --git a/net/sunrpc/xprtrdma/svc_rdma_sendto.c b/net/sunrpc/xprtr=
dma/svc_rdma_sendto.c
> > > index 649441d..79bd3a3 100644
> > > --- a/net/sunrpc/xprtrdma/svc_rdma_sendto.c
> > > +++ b/net/sunrpc/xprtrdma/svc_rdma_sendto.c
> > > @@ -1,3 +1,4 @@
> > > +// SPDX-License-Identifier: GPL-2.0 OR BSD-3-Clause
> > > /*
> > >  * Copyright (c) 2016 Oracle. All rights reserved.
> > >  * Copyright (c) 2014 Open Grid Computing, Inc. All rights reserved.
> > > diff --git a/net/sunrpc/xprtrdma/svc_rdma_transport.c b/net/sunrpc/xp=
rtrdma/svc_rdma_transport.c
> > > index 96cc8f6..3633254 100644
> > > --- a/net/sunrpc/xprtrdma/svc_rdma_transport.c
> > > +++ b/net/sunrpc/xprtrdma/svc_rdma_transport.c
> > > @@ -1,3 +1,4 @@
> > > +// SPDX-License-Identifier: GPL-2.0 OR BSD-3-Clause
> > > /*
> > >  * Copyright (c) 2014 Open Grid Computing, Inc. All rights reserved.
> > >  * Copyright (c) 2005-2007 Network Appliance, Inc. All rights reserve=
d.
> >=20
> > --
> > To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> > the body of a message to majordomo@vger.kernel.org
> > More majordomo info at  http://vger.kernel.org/majordomo-info.html
>=20
> --
> Chuck Lever
>=20
>=20
>=20
> --
> To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

--=20
Doug Ledford <dledford@redhat.com>
    GPG KeyID: B826A3330E572FDD
    Key fingerprint =3D AE6B 1BDA 122B 23B4 265B  1274 B826 A333 0E57 2FDD
--=-0kmFk/k97E46IAiSwFKI
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----

iQIzBAABCAAdFiEErmsb2hIrI7QmWxJ0uCajMw5XL90FAlr69B4ACgkQuCajMw5X
L93lZg//Y/3glYx7/pE8LKvIRbFP15+fVhGjTthHLBgiHiexRR4hlhNpP9F69d4t
OqJ9dtMFqYo/34F8ajCGOKpvhEv78p2ex6l6Cx39xm+pRrP0H/QmbXUPxxo6jxXb
oWWW2N9/Yfg13hYI2Zg9XcZp4Qxif8KhsjjioC5+LSO5Mnd5kDkUXXpzgx0yMSLo
6Q+TM9ArFLw1+Hd8t41W8TUWVN5JS39XwhdEj6sQFBOcf90KdyiqEow/M0YsdgLU
kadsttVP+yCOoTSTQwGt01ojkfX8DgRH888WvyVjTghTWmgCmwMf89V0N6iLyWtv
l0WJ4WknXeUCT9oYFuTmUhMSrCEwq2oxvQLO6srwh3LQkVCbbdH1bC2Kw7j6GgpW
A4r8m/DHZEMASoxgr/WWg4tFgBxDWsecmEPPVHt8xI4hv1TygUloQhSgROnMdQHc
7UN5s9zgk15lSPMN4v7GKZItz4SFksbZcwc1k4h0JrQfnfIa90Y/kvjqtOGGXIXd
7kgn+b9dFW78JzDSmwg+LVJihCIrSU6bGmragQ9W0AddAYEh04shynW2o/IbnrHY
wObJhkf1F7cUi52wg8RlwOvDsLbvD0vJzGHKynMXQOOyCi+++in9eTlk+onMXbB0
bvlm6MzdtwZb1NumYmrI8bAvDdlsO+WhTORy++RXn3N92dhIhUA=
=//PQ
-----END PGP SIGNATURE-----

--=-0kmFk/k97E46IAiSwFKI--

