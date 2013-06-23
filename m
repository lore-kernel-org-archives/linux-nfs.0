Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ie0-f170.google.com ([209.85.223.170]:45269 "EHLO
	mail-ie0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751148Ab3FWPfg (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 23 Jun 2013 11:35:36 -0400
Received: by mail-ie0-f170.google.com with SMTP id e11so23194317iej.1
        for <linux-nfs@vger.kernel.org>; Sun, 23 Jun 2013 08:35:36 -0700 (PDT)
Message-ID: <1372001734.28295.15.camel@freed.purpleidea.com>
Subject: Re: NFS clientaddr, kerberos
From: James <purpleidea@gmail.com>
To: Chuck Lever <chuck.lever@oracle.com>,
        "Myklebust, Trond" <Trond.Myklebust@netapp.com>
Cc: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Date: Sun, 23 Jun 2013 11:35:34 -0400
In-Reply-To: <1371926549.9337.7.camel@leira.trondhjem.org>
References: <1371913167.28295.8.camel@freed.purpleidea.com>
	 <E910FB58-8E56-4E96-A197-B25084B135BD@oracle.com>
	 <1371926549.9337.7.camel@leira.trondhjem.org>
Content-Type: multipart/signed; micalg="pgp-sha1"; protocol="application/pgp-signature";
	boundary="=-QItOP9941DSvSfjs1mwe"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


--=-QItOP9941DSvSfjs1mwe
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Sat, 2013-06-22 at 18:42 +0000, Myklebust, Trond wrote:
> On Sat, 2013-06-22 at 11:22 -0400, Chuck Lever wrote:
> > On Jun 22, 2013, at 10:59 AM, James <purpleidea@gmail.com> wrote:
> >=20
> > > Dear NFS experts, I have a few questions:
> > >=20
> > > 1) Concerning the NFSv4 clientaddr option, I'm curious about the
> > > technical details of why the server needs a callback address, and wha=
t
> > > to do if the client isn't directly routable? (eg: behind NAT) I am
> > > thinking of the situation with *many* clients.
> >=20
> > If a callback path is not available, the server will not grant delegati=
ons to the client.  Delegation is simply a performance optimization.  Norma=
l operation can proceed.
> >=20
> > > Also, what ports need to be open on the client? Does it need to respo=
nd
> > > to "NEW" traffic, or only "ESTABLISHED" or ?
> >=20
> > Typically the client will choose a port at random.  The client's callba=
ck address and port are provided to the server by the NFSv4 SETCLIENTID ope=
ration.
> >=20
> > The server tests the provided callback arguments with a CB_NULL request=
 (and a new TCP connection) either at mount time or when a client applicati=
on first opens a file on that server.  If the arguments do not result in a =
successful CB_NULL, the server simply disables delegation for that client.
> >=20
> > You can fix the port the client uses, if you have a firewall in place a=
nd want to leave an open port.  A kernel command-line parameter is used on =
the client:
> >=20
> >         nfs.callback_tcpport=3D
> >                         [NFS] set the TCP port on which the NFSv4 callb=
ack
> >                         channel should listen.
> >=20
> > Although, these days, it may be a per-namespace thing.  A quick browse =
of the documentation wasn't revealing.
Thank you Chuck, Trond for your prompt replies, it really helped me have
a productive weekend of hacking.

>=20
> Kernel parameters cannot be per-namespace; containers don't boot a
> separate kernel.
>=20
> Note that if you have compiled nfs as a module, you will want to do
> something along the lines of:
>=20
> 	echo "options nfs callback_tcpport=3D<port>" >>/etc/modprobe.d/options-l=
ocal.conf
This is very useful to know.
Is there any way to specify this as a mount option?

Will NFSv4.1 silently ignore this and use the same RPC connection if I
include it for both 4.0, and 4.1 machines?

Cheers,
James


>=20
> Also note that this requirement is for NFSv4 only. NFSv4.1 callbacks use
> the same connection as the outgoing RPC calls, and so support callbacks
> through NAT without requiring you to open for incoming connections.
>=20


--=-QItOP9941DSvSfjs1mwe
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.13 (GNU/Linux)

iQIcBAABAgAGBQJRxxXGAAoJEKDo88AkCQ1mCSIP/25hdUZCAKgQpJX1Cy5fLM+K
vZtrUtKaokbqYt7NAnjN4Ubzel9QiBtlY/uLphXUrVW23qtBKzkSZjHASpV6tVjZ
gyk0tB3wKbmzVVQPyUFjTAnfsd1WiE37DXMHVoHuZMGBa62CbiG/e4so0qSlQZJq
f7LavVq6XRmNgMrrgvNu6oeP1oVwgJi44w2IX4f/4Hn2VzRZtG0Vk24aygwV1+ur
LRosG8zZ80LxRWsOeyypn3NVmGnnjUnr7cIyuoh9uHnVXDI/qjtP8QLhljiSx7Nx
bH97YnH4F6cf96DuoZfCy2LPwUI6gFRZYhtnVmEsOdoLXPu9w+DBPmA9qveMrUKE
kwrJzFl589eUD3NYvjBLRsNesK3CWMMpk6x2xiXYyfft+w2S8dxoP7Khk4bdIYuU
+puzy3qAUtrhtLCuqGlo/8etRYZYYHEyR3q7q3+YGDUGGjfRAjsCFXbkh5ScGxHm
idZunKHB6m0ifc84zUor83dgccC2l7Vm4ls3XyU0Ak7LmGsODpnbs3+3UjLOJyrf
8QLJlPu7sJYm637SzqkZqNCeTgxqBkq+Lcqp3uY1rtUFK1+S1/SXHHqfGrjORmmM
kJtb20KiaAoMTIlceFil1QkYpuDuUDo9VizWB56Ua2vWuxHB7GdnbMOBRQrn8dkQ
eii3CrIVlE52hdQLqk1s
=LgSF
-----END PGP SIGNATURE-----

--=-QItOP9941DSvSfjs1mwe--

