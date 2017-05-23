Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:49268 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1763258AbdEWNLH (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 23 May 2017 09:11:07 -0400
Date: Tue, 23 May 2017 14:11:05 +0100
From: Stefan Hajnoczi <stefanha@redhat.com>
To: Jeff Layton <jlayton@redhat.com>
Cc: linux-nfs@vger.kernel.org,
        Anna Schumaker <anna.schumaker@netapp.com>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        Trond Myklebust <trond.myklebust@primarydata.com>
Subject: Re: [PATCH v2 01/10] SUNRPC: add AF_VSOCK support to addr.[ch]
Message-ID: <20170523131105.GA17369@stefanha-x1.localdomain>
References: <1475834514-4058-1-git-send-email-stefanha@redhat.com>
 <1475834514-4058-2-git-send-email-stefanha@redhat.com>
 <1495116264.3956.3.camel@redhat.com>
 <20170522122105.GH12205@stefanha-x1.localdomain>
 <1495457696.2816.2.camel@redhat.com>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
        protocol="application/pgp-signature"; boundary="qMm9M+Fa2AknHoGS"
In-Reply-To: <1495457696.2816.2.camel@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


--qMm9M+Fa2AknHoGS
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Mon, May 22, 2017 at 08:54:56AM -0400, Jeff Layton wrote:
> On Mon, 2017-05-22 at 13:21 +0100, Stefan Hajnoczi wrote:
> > On Thu, May 18, 2017 at 10:04:24AM -0400, Jeff Layton wrote:
> > > On Fri, 2016-10-07 at 11:01 +0100, Stefan Hajnoczi wrote:
> > > > @@ -249,6 +302,10 @@ size_t rpc_pton(struct net *net, const char *b=
uf, const size_t buflen,
> > > >  {
> > > >  	unsigned int i;
> > > > =20
> > > > +	/* TODO is there a nicer way to distinguish vsock addresses? */
> > > > +	if (strncmp(buf, "vsock:", 6) =3D=3D 0)
> > > > +		return rpc_pton_vsock(buf, buflen, sap, salen);
> > > > +
> > >=20
> > > Ick, what if I have a host on the network named "vsock"? I think you'=
ll
> > > need to come up with a different way to do this.
> >=20
> > There is no collision.  This function doesn't do name resolution and no
> > valid IPv4/IPv6 address starts with "vsock:".
> >=20
>=20
> Doh! Of course... :)
>=20
> > I am open to suggestions for a cleaner way of doing it though :).
>=20
> Does lsof recognize vsock sockets? How does it format them?

lsof only prints a generic socket representation:

COMMAND     PID   TID       USER   FD      TYPE             DEVICE  SIZE/OF=
F       NODE NAME
nc-vsock  20775         stefanha    3u     sock                0,9       0t=
0    1518648 protocol: AF_VSOCK

Depending on a program's command-line syntax, addresses are usually
written as CID:PORT, or vsock:CID:PORT if the program must differentiate
between address types from the string itself.

QEMU, qemu-guest-agent, and systemd have syntax for specifying AF_VSOCK
sockets.  For example:
https://github.com/systemd/systemd/blob/master/src/test/test-socket-util.c#=
L98

If I have time to submit lsof patches I'll propose the following syntax
(a combination of how AF_UNIX and AF_INET TCP sockets are formatted):

COMMAND     PID   TID       USER   FD      TYPE             DEVICE  SIZE/OF=
F       NODE NAME
nc-vsock  20775         stefanha    3u     vsock           1520136       0t=
0    1520136 local=3D2:1234 state=3DLISTEN type=3DSTREAM
nc-vsock  20775         stefanha    4u     vsock           1520138       0t=
0    1520138 local=3D2:1234 remote=3D3:51213 state=3DCONNECTED type=3DSTREAM

Stefan

--qMm9M+Fa2AknHoGS
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQEcBAEBAgAGBQJZJDTpAAoJEJykq7OBq3PIzMMH/iQndk7NHVep4QRvP6J1QdnL
5oawx+x6mtJ6SI1t40QExbkeQsZYbcNHCyWqPT05r0lfAFzrg4m9Ek6nDZEpKRjk
atw6AX6CPp7pMaUWv61ngaSxrvBosWQs/wlZJxIaMdqU90QwcOZv24zKNGNiYBAf
SaBoHaobm5JaA6dGnJx0ssN6r1pAZHas6Wmc3BpNVg60gMKNO2piBLeD5mywofkd
RW9f5ruK/fI0bc+azBTY+BxqHn1SFBuRv4+/ZqCJZDyo6IkhfF85S5ymueOTCgQD
i40d48HM0tH7oymDBSyvbmy//BDCKrSMv+nhHon+0HtUNd9tYocsCU3gYN6e7Gk=
=YIxC
-----END PGP SIGNATURE-----

--qMm9M+Fa2AknHoGS--
