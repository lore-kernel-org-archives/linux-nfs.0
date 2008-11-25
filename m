From: Ian Campbell <ijc@hellion.org.uk>
Subject: Re: [PATCH] NFS regression in 2.6.26?, "task blocked for more than
	120 seconds"
Date: Tue, 25 Nov 2008 07:09:22 +0000
Message-ID: <1227596962.16868.22.camel@localhost.localdomain>
References: <20081017123207.GA14979@rabbit.intern.cm-ag>
	 <1224484046.23068.14.camel@localhost.localdomain>
	 <1225539927.2221.3.camel@localhost.localdomain>
	 <1225546878.4390.3.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-6b1jhfOm3xmsjk4QJplq"
Cc: Max Kellermann <mk@cm4all.com>, linux-kernel@vger.kernel.org,
	gcosta@redhat.com, Grant Coady <grant_lkml@dodo.com.au>,
	"J. Bruce Fields" <bfields@fieldses.org>,
	Tom Tucker <tom@opengridcomputing.com>
To: Trond Myklebust <trond.myklebust@fys.uio.no>,
	linux-nfs@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1752681AbYKYHJ5@vger.kernel.org>
In-Reply-To: <1225546878.4390.3.camel@heimdal.trondhjem.org>
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


--=-6b1jhfOm3xmsjk4QJplq
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Sat, 2008-11-01 at 09:41 -0400, Trond Myklebust wrote:
> On Sat, 2008-11-01 at 11:45 +0000, Ian Campbell wrote:
> > On Mon, 2008-10-20 at 07:27 +0100, Ian Campbell wrote:
> > > So far I have bisected down to this range and am currently testing
> > > acee478 which has been up for >4days.
> >=20
> > Another update. It has now bisected down to a small range=20
> >=20
> > 7272dcd31d56580dee7693c21e369fd167e137fe SUNRPC: xprt_autoclose() shoul=
d not call xprt_disconnect()
> > e06799f958bf7f9f8fae15f0c6f519953fb0257c SUNRPC: Use shutdown() instead=
 of close() when disconnecting a TCP socket
> > ef80367071dce7d2533e79ae8f3c84ec42708dc8 SUNRPC: TCP clear XPRT_CLOSE_W=
AIT when the socket is closed for writes
> > 3b948ae5be5e22532584113e2e02029519bbad8f SUNRPC: Allow the client to de=
tect if the TCP connection is closed
> > 67a391d72ca7efb387c30ec761a487e50a3ff085 SUNRPC: Fix TCP rebinding logi=
c
> > 66af1e558538137080615e7ad6d1f2f80862de01 SUNRPC: Fix a race in xs_tcp_s=
tate_change()
> >=20
> > I'm currently testing 3b948ae5be5e22532584113e2e02029519bbad8f.
> >=20
> > 7272dcd31d56580dee7693c21e369fd167e137fe repro'd in half a day while
> > ef818a28fac9bd214e676986d8301db0582b92a9 (parent of
> > 66af1e558538137080615e7ad6d1f2f80862de01) survived for 7 days.

According to bisect:

e06799f958bf7f9f8fae15f0c6f519953fb0257c is first bad commit
commit e06799f958bf7f9f8fae15f0c6f519953fb0257c
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Mon Nov 5 15:44:12 2007 -0500

    SUNRPC: Use shutdown() instead of close() when disconnecting a TCP sock=
et
   =20
    By using shutdown() rather than close() we allow the RPC client to wait
    for the TCP close handshake to complete before we start trying to recon=
nect
    using the same port.
    We use shutdown(SHUT_WR) only instead of shutting down both directions,
    however we wait until the server has closed the connection on its side.
   =20
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

I've started testing 2.6.26 + revert. It's been a long while since I
started this process so I'll also have a go at an up to date version.

Cheers,
Ian.
--=20
Ian Campbell

By failing to prepare, you are preparing to fail.

--=-6b1jhfOm3xmsjk4QJplq
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.9 (GNU/Linux)

iEYEABECAAYFAkkrpKIACgkQM0+0qS9rzVnVIQCcCLhKGIQDhnZHI+acfuPCOkFK
9ZEAnRRrd+75WYK9/xSiOnz0fdPUNXbR
=xhmF
-----END PGP SIGNATURE-----

--=-6b1jhfOm3xmsjk4QJplq--
