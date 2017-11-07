Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:54186 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S934244AbdKGNbV (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 7 Nov 2017 08:31:21 -0500
Date: Tue, 7 Nov 2017 13:31:11 +0000
From: Stefan Hajnoczi <stefanha@redhat.com>
To: Jeff Layton <jlayton@redhat.com>
Cc: linux-nfs@vger.kernel.org, Abbas Naderi <abiusx@google.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH v3 08/14] SUNRPC: add AF_VSOCK support to svc_xprt.c
Message-ID: <20171107133111.GK6809@stefanha-x1.localdomain>
References: <20170630132352.32133-1-stefanha@redhat.com>
 <20170630132352.32133-9-stefanha@redhat.com>
 <1509459038.4553.26.camel@redhat.com>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
        protocol="application/pgp-signature"; boundary="vbzKE9fGfpHIBC6T"
In-Reply-To: <1509459038.4553.26.camel@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


--vbzKE9fGfpHIBC6T
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Tue, Oct 31, 2017 at 10:10:38AM -0400, Jeff Layton wrote:
> On Fri, 2017-06-30 at 14:23 +0100, Stefan Hajnoczi wrote:
> > @@ -595,6 +609,10 @@ int svc_port_is_privileged(struct sockaddr *sin)
> >  	case AF_INET6:
> >  		return ntohs(((struct sockaddr_in6 *)sin)->sin6_port)
> >  			< PROT_SOCK;
> > +	case AF_VSOCK:
> > +		return ((struct sockaddr_vm *)sin)->svm_port <=3D
> > +			LAST_RESERVED_PORT;
> > +
> >  	default:
> >  		return 0;
> >  	}
>=20
> Does vsock even have the concept of a privileged port? I would imagine
> that root in a guest VM would carry no particular significance from an
> export security standpoint
>=20
> Since you're defining a new transport here, it might be nice write the
> RFCs to avoid that distinction, if possible.
>=20
> Note that RDMA just has svc_port_is_privileged always return 1.

AF_VSOCK has the same 0-1023 privileged port range as TCP.

Stefan

--vbzKE9fGfpHIBC6T
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQEcBAEBAgAGBQJaAbWfAAoJEJykq7OBq3PI5dEH/0j3+GmPc4MgCdDHNMCpzdO1
lVTPAL39xHcXScZ4hLyu+y2NkmurVnkp1hy2EzjDYxYD3BM0hd97YjaGsTM1AO8d
GWmLrhLSBX2q/VxVwodTLPinG7n11eOFrQ83BwpeaJA3i+4OlVE+KkHhGZcHHSXW
WLBQJ0EZN8LW5bgfF6e8eYEWjOh0P+5/962ykXRucmcQ3zrUFM/mHXdcWaktIbtY
N/IlLc3eCfRtzuNc5Ij+uvauOFi9MVJogCmRKMXvMI251vUeJXoiWFBsObh7qKoR
aUgMzXNJOfVNwikhkOmCsjkhgDrtSW2VHFavtKucpBARj6gZcgR1TzYhakL/BXc=
=38/A
-----END PGP SIGNATURE-----

--vbzKE9fGfpHIBC6T--
