Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:46896 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753507AbdKNOUa (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 14 Nov 2017 09:20:30 -0500
Date: Tue, 14 Nov 2017 14:20:28 +0000
From: Stefan Hajnoczi <stefanha@redhat.com>
To: Jeff Layton <jlayton@redhat.com>
Cc: linux-nfs@vger.kernel.org, Abbas Naderi <abiusx@google.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH v3 13/14] SUNRPC: vsock svcsock support
Message-ID: <20171114142028.GB16154@stefanha-x1.localdomain>
References: <20170630132352.32133-1-stefanha@redhat.com>
 <20170630132352.32133-14-stefanha@redhat.com>
 <1510063951.4705.2.camel@redhat.com>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
        protocol="application/pgp-signature"; boundary="TRYliJ5NKNqkz5bu"
In-Reply-To: <1510063951.4705.2.camel@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


--TRYliJ5NKNqkz5bu
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Tue, Nov 07, 2017 at 09:12:31AM -0500, Jeff Layton wrote:
> On Fri, 2017-06-30 at 14:23 +0100, Stefan Hajnoczi wrote:
> > @@ -1417,6 +1564,10 @@ static struct svc_sock *svc_setup_socket(struct =
svc_serv *serv,
> >  	/* Initialize the socket */
> >  	if (sock->type =3D=3D SOCK_DGRAM)
> >  		svc_udp_init(svsk, serv);
> > +#ifdef CONFIG_SUNRPC_XPRT_VSOCK
> > +	else if (inet->sk_family =3D=3D AF_VSOCK)
> > +		svc_vsock_init(svsk, serv);
> > +#endif
> >  	else
> >  		svc_tcp_init(svsk, serv);
>=20
> The above conditional is a bit of a mess and doesn't really handle the
> case where the upper layer might pass it something non-sensical (i.e.
> SOCK_DGRAM + AF_VSOCK).
>=20
> I think this should vet both values and return ERR_PTR(-EINVAL) if it's
> not right. Maybe a switch statement on the address family and then check
> the sock->type in each? We can afford to code a little defensively here.

Good idea, will fix in v4.

--TRYliJ5NKNqkz5bu
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQEcBAEBAgAGBQJaCvurAAoJEJykq7OBq3PIhZ8H/2UzrLbN8TTJd+OsHj5UlOlr
/bkhhTeELDQsQYqDMZ1GTLM44mY3zj4KpBHGePqkF8oZPVeEE7bSd4Bw73mKxzfg
8AJRywEp7ljzOCrosCKIEwMZd5whIFI8qbrusJGqU5JAVXiIab3TU7gXsEvsNhg5
bJ0MjlLgfB4AQIanx4ykvIQWUOCnA7CO3GeYRc3g0S1k43+y3xDOdtOHoP5wb6YZ
SAZBK/oBlivh53MQijuG7wxCjnveGEAJw/J89gQzjVT/g22KayOF0EP41Ni7EcYi
+ndw84HbmsSEyP9a4q10/JVPXdxDbvrqOGaAHI08BsmdoW9dWkjPI8UFzAVqKqs=
=syLA
-----END PGP SIGNATURE-----

--TRYliJ5NKNqkz5bu--
