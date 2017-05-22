Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:42426 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751965AbdEVMVN (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 22 May 2017 08:21:13 -0400
Date: Mon, 22 May 2017 13:21:05 +0100
From: Stefan Hajnoczi <stefanha@redhat.com>
To: Jeff Layton <jlayton@redhat.com>
Cc: linux-nfs@vger.kernel.org,
        Anna Schumaker <anna.schumaker@netapp.com>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        Trond Myklebust <trond.myklebust@primarydata.com>
Subject: Re: [PATCH v2 01/10] SUNRPC: add AF_VSOCK support to addr.[ch]
Message-ID: <20170522122105.GH12205@stefanha-x1.localdomain>
References: <1475834514-4058-1-git-send-email-stefanha@redhat.com>
 <1475834514-4058-2-git-send-email-stefanha@redhat.com>
 <1495116264.3956.3.camel@redhat.com>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
        protocol="application/pgp-signature"; boundary="gKijDXBCEH69PxaN"
In-Reply-To: <1495116264.3956.3.camel@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


--gKijDXBCEH69PxaN
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Thu, May 18, 2017 at 10:04:24AM -0400, Jeff Layton wrote:
> On Fri, 2016-10-07 at 11:01 +0100, Stefan Hajnoczi wrote:
> > @@ -249,6 +302,10 @@ size_t rpc_pton(struct net *net, const char *buf, =
const size_t buflen,
> >  {
> >  	unsigned int i;
> > =20
> > +	/* TODO is there a nicer way to distinguish vsock addresses? */
> > +	if (strncmp(buf, "vsock:", 6) =3D=3D 0)
> > +		return rpc_pton_vsock(buf, buflen, sap, salen);
> > +
>=20
> Ick, what if I have a host on the network named "vsock"? I think you'll
> need to come up with a different way to do this.

There is no collision.  This function doesn't do name resolution and no
valid IPv4/IPv6 address starts with "vsock:".

I am open to suggestions for a cleaner way of doing it though :).

Stefan

--gKijDXBCEH69PxaN
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQEcBAEBAgAGBQJZItexAAoJEJykq7OBq3PIP6gIAKghnI++MF8mpyBgqNd+4neR
8aqzlE/r2mgXA3DoqJU5axwREryFLYXl0SvgDGBQ01wY51ZxGgceZKkoUatgOP3n
Oa3EiLaJbkpjWAxsJRQ1Q72LhNCDBKrlBiuwpKGllPWxeyGWOFGAgmJQI3I9cuDW
4ZQP/7N+nlsLotPqEcB3XR88zfzIcVwPTSPNIbPJwLfwc6uOFKOr1x4W3pSEb1Cd
JAJQFMwlYYL0jEpQEO9msm0GpuHzKJ1oyIxoqNbm+cIiWjf9aWAl+bghJ4tAdU3J
0OVPXv5++0NdfR7D33LajNdncHbxy2o19ipUPKNWeTGuVmjDl3sLiFqgb9h+tVo=
=e9nb
-----END PGP SIGNATURE-----

--gKijDXBCEH69PxaN--
