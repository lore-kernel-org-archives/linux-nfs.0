Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.kernel.org ([198.145.29.99]:36666 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1755094AbeASLSL (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 19 Jan 2018 06:18:11 -0500
Date: Fri, 19 Jan 2018 13:18:07 +0200
From: Leon Romanovsky <leon@kernel.org>
To: Jason Gunthorpe <jgg@ziepe.ca>
Cc: Anna Schumaker <Anna.Schumaker@Netapp.com>,
        Chuck Lever <chuck.lever@oracle.com>,
        linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Subject: Re: [PATCH v1 01/12] rdma/ib: Add trace point macros to display
 human-readable values
Message-ID: <20180119111807.GC1393@mtr-leonro.local>
References: <20171220210236.29321.59307.stgit@manet.1015granger.net>
 <20171220213023.29321.97527.stgit@manet.1015granger.net>
 <1245d090-99ee-c517-5f8f-afdb7ffc0456@Netapp.com>
 <20180118223446.GB17294@ziepe.ca>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
        protocol="application/pgp-signature"; boundary="z4+8/lEcDcG5Ke9S"
In-Reply-To: <20180118223446.GB17294@ziepe.ca>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


--z4+8/lEcDcG5Ke9S
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Thu, Jan 18, 2018 at 03:34:46PM -0700, Jason Gunthorpe wrote:
> On Thu, Jan 18, 2018 at 04:49:20PM -0500, Anna Schumaker wrote:
> > Hi Folks,
> >
> > On 12/20/2017 04:30 PM, Chuck Lever wrote:
> > > These can be shared with all kernel ULPs, and more can easily be
> > > added as needed.
> > >
> > > Note: checkpatch.pl has some heartburn with the TRACE_DEFINE_ENUM
> > > macros and the LIST macros. These follow the same style as other
> > > header files under include/tracing/events , thus should be
> > > considered acceptable exceptions.
> > >
> > > Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
> > >  include/trace/events/rdma.h |  128 +++++++++++++++++++++++++++++++++++++++++++
> > >  1 file changed, 128 insertions(+)
> > >  create mode 100644 include/trace/events/rdma.h
> >
> > Just checking that it's okay to send this through the NFS tree,
> > since it goes along with the rest of Chuck's patches?
>
> New file, won't create any conflicts, so should be fine.
>
> Is this API or anything that needs a really special look?

It can be easily start to be API, for example "this battle" is not
finished yet: https://lwn.net/Articles/442113/

>
> > > +++ b/include/trace/events/rdma.h
> > > @@ -0,0 +1,128 @@
> > > +/*
> > > + * Copyright (c) 2017 Oracle.  All rights reserved.
> > > + */
>
> This should have a SPDX header though, from what I understand.
>
> Jason
> --
> To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

--z4+8/lEcDcG5Ke9S
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEkhr/r4Op1/04yqaB5GN7iDZyWKcFAlph0+4ACgkQ5GN7iDZy
WKcSiA/8D2E4oQX9qxFt2gbKJZJ/oqqJkPMspgJyCEEeLsjAos92QRcJCvDQiIGy
mgIw5OimET+dquPJZX1c7YIAl8b9jO3Dwik4J5No3G9ld/U5QA4PHf1n5b1mPYTo
CesSJNdB7sN24DthUOL5I20B0mDaH9uZKj3nsijk0n8snhTMPfXXs9FyykAaKl1R
C/KN+/2E6jZHqRwhWfBqED9D0k8z2LqexUml65Aa5iXjpGGEgpFIQ0rJpdhC35pT
QvfvXrJMGkErZmFXj+bf3Rrd//wuQJhU1Q1So5K5QPgQHlZEXvAfmel/3ZjFWr6M
2bK/YVokPbq+Rr0rw6piEHvW3lhoUIJQzKPaLQ+oT4JHl2hZsoueu5Ythzw9m3Jd
bUL3j4a+1WRJJpW/e9nfTHli6v8exvxZnpZn0MDPSAuK6Eml2UIncRtwxBxKoo4U
x9AUURLAuSaFkdp8oNjVTBZwSR/QP4O8dJvu2LPD+t1tRGv8lxbjo+xLesYtMeWp
mXriP80cG0TuEvTgPktYax0i2I5nmAQDtgiHmZlLe4nC0kZikV526bfpYLXBIsr6
8qHf0hdLxWOxLPBJrQrM+UPHgVrLsfBT/9DsY1KNKJjdX58Z5/3vgKvDqrMMdEm1
xWmPQxSidZx2sJk4iAkEIK2WU0bLUM/RozvR6LVoJcd65cab/RM=
=jUCE
-----END PGP SIGNATURE-----

--z4+8/lEcDcG5Ke9S--
