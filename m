Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:56320 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S934244AbdKGNcf (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 7 Nov 2017 08:32:35 -0500
Date: Tue, 7 Nov 2017 13:32:27 +0000
From: Stefan Hajnoczi <stefanha@redhat.com>
To: Jeff Layton <jlayton@redhat.com>
Cc: linux-nfs@vger.kernel.org, Abbas Naderi <abiusx@google.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH v3 05/14] VSOCK: add tcp_read_sock()-like
 vsock_read_sock() function
Message-ID: <20171107133227.GL6809@stefanha-x1.localdomain>
References: <20170630132352.32133-1-stefanha@redhat.com>
 <20170630132352.32133-6-stefanha@redhat.com>
 <1509456912.4553.12.camel@redhat.com>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
        protocol="application/pgp-signature"; boundary="c8JyeaiReRNoiMDS"
In-Reply-To: <1509456912.4553.12.camel@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


--c8JyeaiReRNoiMDS
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Tue, Oct 31, 2017 at 09:35:12AM -0400, Jeff Layton wrote:
> On Fri, 2017-06-30 at 14:23 +0100, Stefan Hajnoczi wrote:
> > @@ -2061,6 +2068,7 @@ static const struct vsock_transport vmci_transpor=
t =3D {
> >  	.stream_rcvhiwat =3D vmci_transport_stream_rcvhiwat,
> >  	.stream_is_active =3D vmci_transport_stream_is_active,
> >  	.stream_allow =3D vmci_transport_stream_allow,
> > +	.stream_read_sock =3D vmci_transport_stream_read_sock,
> >  	.notify_poll_in =3D vmci_transport_notify_poll_in,
> >  	.notify_poll_out =3D vmci_transport_notify_poll_out,
> >  	.notify_recv_init =3D vmci_transport_notify_recv_init,
>=20
> Do we need this for the hyperv driver as well?

Yes, thank you for pointing it out.  Will add in the next revision.

Stefan

--c8JyeaiReRNoiMDS
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQEcBAEBAgAGBQJaAbXrAAoJEJykq7OBq3PIAZkH/3dDM+NHu4VWlzCoDdD+FRDw
436vprGH7SmbhDYGeQl0S3sTeuunkq2ytyDl7RpDRYDr1lvFWqOVjW2l4dYzXMaD
V+ILwDtN/NnPxyTL04Q0MoEESbwZ4Xp6AaDYhveMGgHO0WI0RJz77DT4YBnkY37i
86S/ZUY/1sKepijzsIAXy4eyJxiQij9Ui5dIV5jFav8bat2oJLQb0WKrh9ho+LH6
8R71ijgR7Ox/rN0GS5HA8Q14+F/YB9O4zttjOIFtKUoInYozr7I1F378tfGbWUnI
fFxHIX4482au6UoZf0YYd+RsjRfyX9PpnWouf3OFB45kTDOAJ8zPyscmYsI/1d0=
=yWT4
-----END PGP SIGNATURE-----

--c8JyeaiReRNoiMDS--
