From: Ian Campbell <ijc-KcIKpvwj1kUDXYZnReoRVg@public.gmane.org>
Subject: Re: NFS regression? Odd delays and lockups accessing an NFS export.
Date: Fri, 22 Aug 2008 22:37:21 +0100
Message-ID: <1219441041.27921.57.camel@localhost.localdomain>
References: <p6lha4te54h04qdbnos1mcemdmn1cfca6s@4ax.com>
	 <1219087258.7192.19.camel@localhost>
	 <1219400624.18774.67.camel@zakaz.uk.xensource.com>
	 <1219428489.6919.21.camel@localhost>
	 <1219428818.27921.43.camel@localhost.localdomain>
	 <56a8daef0808221233h68853587n6015ca7d809b17e1@mail.gmail.com>
	 <1219435207.27921.51.camel@localhost.localdomain>
	 <1219440202.9097.14.camel@localhost>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-8xcMljYBej7XE9kYy7DV"
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
Received: from mtaout02-winn.ispmail.ntl.com ([81.103.221.48]:23424 "EHLO
	mtaout02-winn.ispmail.ntl.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753800AbYHVVhf (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 22 Aug 2008 17:37:35 -0400
In-Reply-To: <1219440202.9097.14.camel@localhost>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


--=-8xcMljYBej7XE9kYy7DV
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Fri, 2008-08-22 at 14:23 -0700, Trond Myklebust wrote:
> On Fri, 2008-08-22 at 21:00 +0100, Ian Campbell wrote:
> > On Fri, 2008-08-22 at 12:33 -0700, John Ronciak wrote:
> > > On Fri, Aug 22, 2008 at 11:13 AM, Ian Campbell <ijc-KcIKpvwj1kUDXYZnReoRVg@public.gmane.org> w=
rote:
> > >=20
> > > >> That's probably also a networking device driver issue candidate: y=
our
> > > >> RPC task is queued up waiting to be sent.
> > > >>
> > > >> What networking card+device driver are you using here?
> > > >
> > > > # ethtool -i eth0
> > > > driver: e1000
> > > > version: 7.3.20-k2-NAPI
> > > > firmware-version: N/A
> > > > bus-info: 0000:01:0a.0
> > > There is nothing indicating that the NIC/driver is causing any sort o=
f
> > > problem here, at least not with what has been presented so far.  When
> > > the NFS mount isn't working is the networking still active and
> > > working?
> >=20
> > So far as I can tell, yes. I can login via ssh so long as the user
> > doesn't have NFS $HOME, I haven't tried much else and the box isn't
> > locked up at the moment, I'd bet it's fine though.
>=20
> ...and the server? Something is preventing that RPC payload from being
> delivered...

I can ssh to the server fine. The same server also serves my NFS home
directory to the box I'm writing this from and I've not seen any trouble
with this box at all, it's a 2.6.18-xen box.

If I downgrade the problematic box to 2.6.24 then the hangs do not
occur. They do occur with 2.6.25. (sorry that's a critical bit of
information which I stupidly forgot to mention up til now).

Ian.

--=20
Ian Campbell

It is much easier to be critical than to be correct.
		-- Benjamin Disraeli

--=-8xcMljYBej7XE9kYy7DV
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.9 (GNU/Linux)

iEYEABECAAYFAkivMZEACgkQM0+0qS9rzVm+gACgwe5kMxefdRi4JPleL/HXxply
qUoAnRtMiB4jG88FbVYyGZfhNkaXSywh
=PLA2
-----END PGP SIGNATURE-----

--=-8xcMljYBej7XE9kYy7DV--

