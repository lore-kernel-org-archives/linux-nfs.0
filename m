From: Ian Campbell <ijc-KcIKpvwj1kUDXYZnReoRVg@public.gmane.org>
Subject: Re: NFS regression?  Odd delays and lockups accessing an NFS
	export.
Date: Fri, 22 Aug 2008 19:13:38 +0100
Message-ID: <1219428818.27921.43.camel@localhost.localdomain>
References: <p6lha4te54h04qdbnos1mcemdmn1cfca6s@4ax.com>
	 <1219087258.7192.19.camel@localhost>
	 <1219400624.18774.67.camel@zakaz.uk.xensource.com>
	 <1219428489.6919.21.camel@localhost>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-3x0/XuuH4gaAYTKPEX+I"
Cc: Grant Coady <gcoady.lk@gmail.com>, linux-kernel@vger.kernel.org,
	neilb@suse.de, bfields@fieldses.org, linux-nfs@vger.kernel.org,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Bruce Allan <bruce.w.allan@intel.com>,
	PJ Waskiewicz <peter.p.waskiewicz.jr@intel.com>,
	John Ronciak <john.ronciak@intel.com>,
	e1000-devel@lists.sourceforge.net
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mtaout03-winn.ispmail.ntl.com ([81.103.221.49]:24778 "EHLO
	mtaout03-winn.ispmail.ntl.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756054AbYHVSNv (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 22 Aug 2008 14:13:51 -0400
In-Reply-To: <1219428489.6919.21.camel@localhost>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


--=-3x0/XuuH4gaAYTKPEX+I
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Fri, 2008-08-22 at 11:08 -0700, Trond Myklebust wrote:
> On Fri, 2008-08-22 at 11:23 +0100, Ian Campbell wrote:
> > On Mon, 2008-08-18 at 15:20 -0400, Trond Myklebust wrote:
> > > Please try to reproduce the hang, then do
> > >=20
> > > 	echo 0 >/proc/sys/sunrpc/rpc_debug
> > >=20
> > > and send the output from 'dmesg'...
> >=20
> > I've also been seeing some NFS related lockups, although I'm not sure i=
f
> > they are the same as the one in this thread or not. Client is 2.6.26
> > (Debian's kernel) and Server is 2.6.25 (also a Debian kernel, but from
> > backports.org).
> >=20
> > rpc_debug on the server gives nothing, on the client gives:
> > [144741.637997] -pid- proc flgs status -client- -prog- --rqstp- -timeou=
t -rpcwait -action- ---ops--
> > [144741.637997]  3439 0004 0080    -11 f3f48200 100003 f7770000        =
0 xprt_sending fa0ae88e fa0bddf4
> > [144741.637997]  3438 0001 00a0      0 f77f2a00 100003 f77700d0    1500=
0 xprt_pending fa0ae88e fa0bddf4
>=20
> That's probably also a networking device driver issue candidate: your
> RPC task is queued up waiting to be sent.
>=20
> What networking card+device driver are you using here?

# ethtool -i eth0
driver: e1000
version: 7.3.20-k2-NAPI
firmware-version: N/A
bus-info: 0000:01:0a.0

Adding CC's to peeps listed in MAINTAINERS

I have to reboot the system now (or else there will be no TV to watch
during my tea ;-). It will probably repro again quite soon though.

> > There are no processes running with pid 3439 3438 (I don't think it's
> > that sort of pid though).
>=20
> The 'pid' is an internal RPC cookie that just serves to identify and
> track specific RPC requests.

Right, thanks.

Ian.

--=20
Ian Campbell

Colors may fade.

--=-3x0/XuuH4gaAYTKPEX+I
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.9 (GNU/Linux)

iEYEABECAAYFAkivAdIACgkQM0+0qS9rzVlFcQCffxm5vgStyXKuaFGnuguUtXdk
PpYAoMD+hYRiMVPZa7ouxp5dZn/OP8BF
=HAJQ
-----END PGP SIGNATURE-----

--=-3x0/XuuH4gaAYTKPEX+I--

