From: Ian Campbell <ijc-KcIKpvwj1kUDXYZnReoRVg@public.gmane.org>
Subject: Re: NFS regression? Odd delays and lockups accessing an NFS export.
Date: Fri, 22 Aug 2008 21:00:07 +0100
Message-ID: <1219435207.27921.51.camel@localhost.localdomain>
References: <p6lha4te54h04qdbnos1mcemdmn1cfca6s@4ax.com>
	 <1219087258.7192.19.camel@localhost>
	 <1219400624.18774.67.camel@zakaz.uk.xensource.com>
	 <1219428489.6919.21.camel@localhost>
	 <1219428818.27921.43.camel@localhost.localdomain>
	 <56a8daef0808221233h68853587n6015ca7d809b17e1@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-CBwd4TKqH0W80+UCawfT"
Cc: Trond Myklebust <trond.myklebust@fys.uio.no>,
	Grant Coady <gcoady.lk@gmail.com>,
	linux-kernel@vger.kernel.org, neilb@suse.de, bfields@fieldses.org,
	linux-nfs@vger.kernel.org,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Bruce Allan <bruce.w.allan@intel.com>,
	PJ Waskiewicz <peter.p.waskiewicz.jr@intel.com>,
	John Ronciak <john.ronciak@intel.com>,
	e1000-devel@lists.sourceforge.net
To: John Ronciak <john.ronciak@gmail.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mtaout01-winn.ispmail.ntl.com ([81.103.221.47]:7593 "EHLO
	mtaout01-winn.ispmail.ntl.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752394AbYHVUAU (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 22 Aug 2008 16:00:20 -0400
In-Reply-To: <56a8daef0808221233h68853587n6015ca7d809b17e1-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


--=-CBwd4TKqH0W80+UCawfT
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Fri, 2008-08-22 at 12:33 -0700, John Ronciak wrote:
> On Fri, Aug 22, 2008 at 11:13 AM, Ian Campbell <ijc-KcIKpvwj1kUDXYZnReoRVg@public.gmane.org> wrote=
:
>=20
> >> That's probably also a networking device driver issue candidate: your
> >> RPC task is queued up waiting to be sent.
> >>
> >> What networking card+device driver are you using here?
> >
> > # ethtool -i eth0
> > driver: e1000
> > version: 7.3.20-k2-NAPI
> > firmware-version: N/A
> > bus-info: 0000:01:0a.0
> There is nothing indicating that the NIC/driver is causing any sort of
> problem here, at least not with what has been presented so far.  When
> the NFS mount isn't working is the networking still active and
> working?

So far as I can tell, yes. I can login via ssh so long as the user
doesn't have NFS $HOME, I haven't tried much else and the box isn't
locked up at the moment, I'd bet it's fine though.

Ian.

--=20
Ian Campbell

"On a normal ascii line, the only safe condition to detect is a 'BREAK'
- everything else having been assigned functions by Gnu EMACS."
(By Tarl Neustaedter)

--=-CBwd4TKqH0W80+UCawfT
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.9 (GNU/Linux)

iEYEABECAAYFAkivGsYACgkQM0+0qS9rzVk1qACeILsY9z8su3G1T9vcBFtVDalF
h6YAn2hHgJc4Zkd/AjoasBMl2qzt58ir
=+jje
-----END PGP SIGNATURE-----

--=-CBwd4TKqH0W80+UCawfT--

