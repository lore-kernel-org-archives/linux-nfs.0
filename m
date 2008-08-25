From: Ian Campbell <ijc-KcIKpvwj1kUDXYZnReoRVg@public.gmane.org>
Subject: Re: NFS regression? Odd delays and lockups accessing an NFS export.
Date: Mon, 25 Aug 2008 10:59:31 +0100
Message-ID: <1219658371.27921.157.camel@localhost.localdomain>
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
	 <1219603981.27921.145.camel@localhost.localdomain>
	 <1219605422.14389.2.camel@localhost>  <1219605596.14389.5.camel@localhost>
	 <1219615789.27921.152.camel@localhost.localdomain>
	 <1219616136.14389.12.camel@localhost>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-cz/Ia6Wgxs2FwBYSOVYv"
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
Received: from mtaout03-winn.ispmail.ntl.com ([81.103.221.49]:33947 "EHLO
	mtaout03-winn.ispmail.ntl.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752736AbYHYKAh (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 25 Aug 2008 06:00:37 -0400
In-Reply-To: <1219616136.14389.12.camel@localhost>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


--=-cz/Ia6Wgxs2FwBYSOVYv
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Sun, 2008-08-24 at 18:15 -0400, Trond Myklebust wrote:
> The server should ideally start to close the socket as soon as it
> receives the FIN from the client. I'll have a look at the code.

The server is a 2.6.25 kernel from Debian backports.org. I was planning
to downgrade to the 2.6.24 "Etch and a half" kernel but was holding off
while this thread was in progress. If you think it would be a useful
data point I can do it sooner rather than later.

It's changing the client kernel which seems to make a difference since
running 2.6.24 against this server has given me no trouble. I guess the
newer client could expose a bug in the server though.

Ian.
--=20
Ian Campbell

I can't understand why a person will take a year or two to write a
novel when he can easily buy one for a few dollars.
		-- Fred Allen

--=-cz/Ia6Wgxs2FwBYSOVYv
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.9 (GNU/Linux)

iEYEABECAAYFAkiygoMACgkQM0+0qS9rzVnsagCgzryVDvY2DQ/Trdq5Co7Vvbpx
sr4AnR3rwXc7aCbdRKGaj44oQuIYinRZ
=Weq0
-----END PGP SIGNATURE-----

--=-cz/Ia6Wgxs2FwBYSOVYv--

