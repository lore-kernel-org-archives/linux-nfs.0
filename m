From: Ian Campbell <ijc-KcIKpvwj1kUDXYZnReoRVg@public.gmane.org>
Subject: Re: NFS regression? Odd delays and lockups accessing an NFS export.
Date: Sun, 24 Aug 2008 23:09:49 +0100
Message-ID: <1219615789.27921.152.camel@localhost.localdomain>
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
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-p1dxoo+YnTJGB8+/EopU"
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
Received: from queueout03-winn.ispmail.ntl.com ([81.103.221.33]:24936 "EHLO
	queueout03-winn.ispmail.ntl.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753424AbYHXWLy (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 24 Aug 2008 18:11:54 -0400
In-Reply-To: <1219605596.14389.5.camel@localhost>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


--=-p1dxoo+YnTJGB8+/EopU
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

(added some quoting from previous mail to save replying twice)

On Sun, 2008-08-24 at 15:19 -0400, Trond Myklebust wrote:
> On Sun, 2008-08-24 at 15:17 -0400, Trond Myklebust wrote:
> > >From the tcpdump, it looks as if the NFS server is failing to close th=
e
> > socket, when the client closes its side. You therefore end up getting
> > stuck in the FIN_WAIT2 state (as netstat clearly shows above).
> >
> > Is the server keeping the client in this state for a very long
> > period?

Well, it had been around an hour and a half on this occasion. Next time
it happens I can wait longer but I'm pretty sure I've come back from
time away and it's been wedged for at least a day. How long would you
expect it to remain in this state for?

> BTW: the RPC client is closing the socket because it detected no NFS
> activity for 5 minutes. Did you expect any NFS activity during this
> time?

It's a mythtv box so at times where no one is watching anything and
there isn't anything to record I expect NFS activity is pretty minimal.

Ian.

--=20
Ian Campbell

Can anyone remember when the times were not hard, and money not scarce?

--=-p1dxoo+YnTJGB8+/EopU
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.9 (GNU/Linux)

iEYEABECAAYFAkix3C0ACgkQM0+0qS9rzVmURACguazY+lWoleZzzyfgZPrWBcIS
vXMAnREV6AxOXisTmIhn8N65rkwxB2oM
=DhUL
-----END PGP SIGNATURE-----

--=-p1dxoo+YnTJGB8+/EopU--

