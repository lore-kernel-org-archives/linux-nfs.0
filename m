From: Ian Campbell <ijc-KcIKpvwj1kUDXYZnReoRVg@public.gmane.org>
Subject: Re: NFS regression? Odd delays and lockups accessing an NFS export.
Date: Fri, 22 Aug 2008 23:41:43 +0100
Message-ID: <1219444903.27921.65.camel@localhost.localdomain>
References: <p6lha4te54h04qdbnos1mcemdmn1cfca6s@4ax.com>
	 <1219087258.7192.19.camel@localhost>
	 <1219400624.18774.67.camel@zakaz.uk.xensource.com>
	 <1219428489.6919.21.camel@localhost>
	 <1219428818.27921.43.camel@localhost.localdomain>
	 <56a8daef0808221233h68853587n6015ca7d809b17e1@mail.gmail.com>
	 <1219435207.27921.51.camel@localhost.localdomain>
	 <1219440202.9097.14.camel@localhost>
	 <1219441041.27921.57.camel@localhost.localdomain>
	 <1219442213.9097.25.camel@localhost>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-bxvbPgWU/qS2+K/bctcs"
Cc: John Ronciak <john.ronciak@gmail.com>,
	Grant Coady <gcoady.lk@gmail.com>,
	linux-kernel@vger.kernel.org, neilb@suse.de, bfields@fieldses.org,
	linux-nfs@vger.kernel.org,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Bruce Allan <bruce.w.allan@intel.com>,
	PJ Waskiewicz <peter.p.waskiewicz.jr@intel.com>,
	John Ronciak <john.ronciak@intel.com>,
	e1000-devel@lists.sourceforge.net
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mtaout02-winn.ispmail.ntl.com ([81.103.221.48]:40818 "EHLO
	mtaout02-winn.ispmail.ntl.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752351AbYHVWlv (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 22 Aug 2008 18:41:51 -0400
In-Reply-To: <1219442213.9097.25.camel@localhost>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


--=-bxvbPgWU/qS2+K/bctcs
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Fri, 2008-08-22 at 14:56 -0700, Trond Myklebust wrote:
> On Fri, 2008-08-22 at 22:37 +0100, Ian Campbell wrote:
> > I can ssh to the server fine. The same server also serves my NFS home
> > directory to the box I'm writing this from and I've not seen any troubl=
e
> > with this box at all, it's a 2.6.18-xen box.
>=20
> OK... Are you able to reproduce the problem reliably?

It usually happens in around a day, but I can't make it happen at will
so that I can arrange to be present at the time. It has usually locked
up over night in the past.

> If so, can you provide me with a binary tcpdump or wireshark dump? If
> using tcpdump, then please use something like
>=20
>    tcpdump -w /tmp/dump.out -s 90000 host myserver.foo.bar and port 2049

I'll try leaving this going overnight but using -C and -W to limit the
size to the disk space available.

> Please also try to provide a netstat dump of the current TCP connections
> as soon as the hang occurs:
>=20
>   netstat -t

Will do it ASAP after it happens.

Ian.
--=20
Ian Campbell

revision 1.17.2.7
date: 2001/05/31 21:32:44;  author: branden;  state: Exp;  lines: +1 -1
ARRRRGH!!  GOT THE G** D*** SENSE OF A F******* TEST BACKWARDS!

--=-bxvbPgWU/qS2+K/bctcs
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.9 (GNU/Linux)

iEYEABECAAYFAkivQKcACgkQM0+0qS9rzVmsKgCeMaRkuiWw6jzKAcu2lWWP2oGl
N4AAoIBRSMwibWM9yIxIRXlyEt4siGKM
=EAxU
-----END PGP SIGNATURE-----

--=-bxvbPgWU/qS2+K/bctcs--

