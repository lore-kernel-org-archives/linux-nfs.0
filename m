Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:38860 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1759056AbdKPPZE (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 16 Nov 2017 10:25:04 -0500
Date: Thu, 16 Nov 2017 15:25:02 +0000
From: Stefan Hajnoczi <stefanha@redhat.com>
To: Jeff Layton <jlayton@redhat.com>
Cc: linux-nfs@vger.kernel.org, Abbas Naderi <abiusx@google.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH v3 08/14] SUNRPC: add AF_VSOCK support to svc_xprt.c
Message-ID: <20171116152502.GG29106@stefanha-x1.localdomain>
References: <20170630132352.32133-1-stefanha@redhat.com>
 <20170630132352.32133-9-stefanha@redhat.com>
 <1509459038.4553.26.camel@redhat.com>
 <20171107133111.GK6809@stefanha-x1.localdomain>
 <1510063286.4518.34.camel@redhat.com>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
        protocol="application/pgp-signature"; boundary="eMnpOGXCMazMAbfp"
In-Reply-To: <1510063286.4518.34.camel@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


--eMnpOGXCMazMAbfp
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Tue, Nov 07, 2017 at 09:01:26AM -0500, Jeff Layton wrote:
> On Tue, 2017-11-07 at 13:31 +0000, Stefan Hajnoczi wrote:
> > On Tue, Oct 31, 2017 at 10:10:38AM -0400, Jeff Layton wrote:
> > > On Fri, 2017-06-30 at 14:23 +0100, Stefan Hajnoczi wrote:
> > > > @@ -595,6 +609,10 @@ int svc_port_is_privileged(struct sockaddr *si=
n)
> > > >  	case AF_INET6:
> > > >  		return ntohs(((struct sockaddr_in6 *)sin)->sin6_port)
> > > >  			< PROT_SOCK;
> > > > +	case AF_VSOCK:
> > > > +		return ((struct sockaddr_vm *)sin)->svm_port <=3D
> > > > +			LAST_RESERVED_PORT;
> > > > +
> > > >  	default:
> > > >  		return 0;
> > > >  	}
> > >=20
> > > Does vsock even have the concept of a privileged port? I would imagine
> > > that root in a guest VM would carry no particular significance from an
> > > export security standpoint
> > >=20
> > > Since you're defining a new transport here, it might be nice write the
> > > RFCs to avoid that distinction, if possible.
> > >=20
> > > Note that RDMA just has svc_port_is_privileged always return 1.
> >=20
> > AF_VSOCK has the same 0-1023 privileged port range as TCP.
> >=20
>=20
> But why? And, given that you have 32-bits for a port with AF_VSOCK vs
> the 16 bits on an AF_INET/AF_INET6, why is the range so pitifully small?
>=20
> Reserved ports are a bit of a dinosaur holdover from when being root on
> a machine on the Internet meant something. With v4.1 it's much less of
> an issue, but in the "olden days", reserved port exhaustion could be a
> real problem.
>=20
> Mandating low ports can also be a problem in other way. Some well known
> services use ports in the ephemeral range, and if your service starts
> late and someone else has taken the port for an ephemeral one, you're
> out of luck.
>=20
> I think we have to ask ourselves:
>=20
> Should the ability to open a low port inside of a VM carry any
> significance at all to an RPC server? I'd suggest not, and I think it'd
> be good to word the RFC to make that explicitly clear.

AF_VSOCK has had the reserved port range since it was first merged in
2013.  That's before my time but I do see some use for identifying
connections coming from privileged processes.

Given that TCP has the same privileged port range, is there any reason
why AF_VSOCK would be any worse off than TCP for having it?

Stefan

--eMnpOGXCMazMAbfp
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQEcBAEBAgAGBQJaDa3OAAoJEJykq7OBq3PId3sIAJuMs6dcxxWaz4a7U3iNHUex
T/8ccUr+zLP9VunFl0nywlXNQCXBnqfNpcT5tj7yPZ07Y1hqZqMbJe1f6fXtKr0h
+VUwqSTY7/n1/6CoGlwV9Ac7LzYCHlgrOSdT8KFkqF2L+/dDc/U/jF54F3+LNcEh
qtN1qb+wEq8NglcEO7D+ur3n+Ulnn98WSqebakozRK0Af/IPL+LH9r6z8e8gbPWn
vBMo7mAkm03Ntr/GorlLJU7GcTgHewPd0yGSzrjXQcYq9Ahu3NUF+wvK+MiW2SoA
dEtHuvZkeeDtmZKcQEOCiykV0gGnBvuEGPgnMzoeO+KlshRWtROBc/+7PmhYqtw=
=QFNj
-----END PGP SIGNATURE-----

--eMnpOGXCMazMAbfp--
