From: Ian Campbell <ijc-KcIKpvwj1kUDXYZnReoRVg@public.gmane.org>
Subject: Re: [PATCH] NFS regression in 2.6.26?, "task blocked for more than
	120 seconds"
Date: Wed, 26 Nov 2008 22:12:19 +0000
Message-ID: <1227737539.31008.2.camel@localhost.localdomain>
References: <20081017123207.GA14979@rabbit.intern.cm-ag>
	 <1224484046.23068.14.camel@localhost.localdomain>
	 <1225539927.2221.3.camel@localhost.localdomain>
	 <1225546878.4390.3.camel@heimdal.trondhjem.org>
	 <1227596962.16868.22.camel@localhost.localdomain>
	 <1227619696.7057.19.camel@heimdal.trondhjem.org>
	 <1227620339.9425.99.camel@zakaz.uk.xensource.com>
	 <1227621434.7057.33.camel@heimdal.trondhjem.org>
	 <1227621877.9425.102.camel@zakaz.uk.xensource.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-i4LoPGFFNSGlA47N6EHp"
Cc: linux-nfs@vger.kernel.org, Max Kellermann <mk-xMchvyqCc6DQT0dZR+AlfA@public.gmane.org>,
	linux-kernel@vger.kernel.org, gcosta@redhat.com,
	Grant Coady <grant_lkml-rGYn+TmxqGy6c6uEtOJ/EA@public.gmane.org>,
	"J. Bruce Fields" <bfields@fieldses.org>,
	Tom Tucker <tom@opengridcomputing.com>
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mtaout02-winn.ispmail.ntl.com ([81.103.221.48]:56856 "EHLO
	mtaout02-winn.ispmail.ntl.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752167AbYKZWMe (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 26 Nov 2008 17:12:34 -0500
In-Reply-To: <1227621877.9425.102.camel-o4Be2W7LfRlXesXXhkcM7miJhflN2719@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


--=-i4LoPGFFNSGlA47N6EHp
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Tue, 2008-11-25 at 14:04 +0000, Ian Campbell wrote:
> On Tue, 2008-11-25 at 08:57 -0500, Trond Myklebust wrote:
> > On Tue, 2008-11-25 at 13:38 +0000, Ian Campbell wrote:
> > > > That would indicate that the server is failing to close the TCP
> > > > connection when the client closes on its end.
> > > >=20
> > > > Could you remind me what server you are using?
> > >=20
> > > 2.6.25-2-486 which is a Debian package from backports.org, changelog
> > > indicates that it contains 2.6.25.7.
> >=20
> > Hmm... It should normally close sockets when the state changes. There
> > might be a race, though...
> >=20
> > > > Also, does 'netstat -t'
> > > > show connections that are stuck in the CLOSE_WAIT state when you se=
e the
> > > > hang?
> > >=20
> > > I'd have to wait for it to reproduce again to be 100% sure but accord=
ing
> > > to http://lkml.indiana.edu/hypermail/linux/kernel/0808.3/0120.html
> > > I was seeing connections in FIN_WAIT2 but not CLOSE_WAIT.
> >=20
> > That would be on the client side. I'm talking about the server.
>=20
> Ah, OK. I'll abort my current test of 2.6.26+revert and wait for a repro
> so I can netstat the server, give me a couple of days...

So on the server I see the following. 192.168.1.4 is the problematic
client and 192.168.1.6 is the server.

Maybe not interesting but 192.168.1.5 also uses NFS for my $HOME and
runs 2.6.26 with no lockups.

# netstat -t -n
Active Internet connections (w/o servers)
Proto Recv-Q Send-Q Local Address           Foreign Address         State  =
   =20
tcp        1      0 192.168.1.6:2049        192.168.1.4:723         CLOSE_W=
AIT=20
tcp        1      0 192.168.1.6:2049        192.168.1.4:920         CLOSE_W=
AIT=20
tcp        1      0 192.168.1.6:2049        192.168.1.4:890         CLOSE_W=
AIT=20
tcp        1      0 192.168.1.6:2049        192.168.1.4:698         CLOSE_W=
AIT=20
tcp        1      0 192.168.1.6:2049        192.168.1.4:705         CLOSE_W=
AIT=20
tcp        1      0 192.168.1.6:2049        192.168.1.4:943         CLOSE_W=
AIT=20
tcp        1      0 192.168.1.6:2049        192.168.1.4:915         CLOSE_W=
AIT=20
tcp        0      0 192.168.1.6:2049        192.168.1.5:783         ESTABLI=
SHED
tcp        1      0 192.168.1.6:2049        192.168.1.4:998         CLOSE_W=
AIT=20
tcp        1      0 192.168.1.6:2049        192.168.1.4:758         CLOSE_W=
AIT=20
tcp        1      0 192.168.1.6:2049        192.168.1.4:955         CLOSE_W=
AIT=20
tcp        1      0 192.168.1.6:2049        192.168.1.4:845         CLOSE_W=
AIT=20
tcp        1      0 192.168.1.6:2049        192.168.1.4:827         CLOSE_W=
AIT=20
tcp        0      0 192.168.1.6:58464       128.31.0.36:80          ESTABLI=
SHED
tcp        1      0 192.168.1.6:2049        192.168.1.4:754         CLOSE_W=
AIT=20
tcp        1      0 192.168.1.6:2049        192.168.1.4:837         CLOSE_W=
AIT=20
tcp        1      0 192.168.1.6:2049        192.168.1.4:918         CLOSE_W=
AIT=20
tcp        1      0 192.168.1.6:2049        192.168.1.4:865         CLOSE_W=
AIT=20
tcp        0      0 192.168.1.6:48343       192.168.1.5:832         ESTABLI=
SHED
tcp        1      0 192.168.1.6:2049        192.168.1.4:840         CLOSE_W=
AIT=20
tcp        1      0 192.168.1.6:2049        192.168.1.4:883         CLOSE_W=
AIT=20
tcp        1      0 192.168.1.6:2049        192.168.1.4:785         CLOSE_W=
AIT=20
tcp        1      0 192.168.1.6:2049        192.168.1.4:720         CLOSE_W=
AIT=20
tcp6       0      0 ::ffff:192.168.1.6:22   ::ffff:192.168.1.:38206 ESTABLI=
SHED
tcp6       0      0 ::ffff:192.168.1.6:143  ::ffff:192.168.1.:41308 ESTABLI=
SHED
tcp6       0      0 ::ffff:192.168.1.6:143  ::ffff:192.168.1.:55784 ESTABLI=
SHED
tcp6       0      0 ::ffff:192.168.1.6:22   ::ffff:192.168.1.:39046 ESTABLI=
SHED

and on the client

# netstat -t -n
Active Internet connections (w/o servers)
Proto Recv-Q Send-Q Local Address           Foreign Address         State  =
   =20
tcp        0      0 192.168.1.4:943         192.168.1.6:2049        FIN_WAI=
T2 =20
tcp        0      0 192.168.1.4:33959       192.168.1.4:6543        ESTABLI=
SHED
tcp        0      0 192.168.1.4:6543        192.168.1.4:54157       ESTABLI=
SHED
tcp        0      0 127.0.0.1:13666         127.0.0.1:33364         ESTABLI=
SHED
tcp        0      0 192.168.1.4:22          192.168.1.5:54696       ESTABLI=
SHED
tcp        0      0 192.168.1.4:22          192.168.1.5:47599       ESTABLI=
SHED
tcp        0      0 192.168.1.4:54156       192.168.1.4:6543        ESTABLI=
SHED
tcp        0      0 192.168.1.4:6543        192.168.1.4:33957       ESTABLI=
SHED
tcp        0      0 192.168.1.4:33957       192.168.1.4:6543        ESTABLI=
SHED
tcp        0      0 192.168.1.4:54157       192.168.1.4:6543        ESTABLI=
SHED
tcp        0      0 192.168.1.4:6543        192.168.1.4:54156       ESTABLI=
SHED
tcp        0      0 192.168.1.4:6543        192.168.1.4:33959       ESTABLI=
SHED
tcp        0      0 127.0.0.1:47756         127.0.0.1:6545          ESTABLI=
SHED
tcp        0      0 127.0.0.1:33364         127.0.0.1:13666         ESTABLI=
SHED
tcp        0      0 127.0.0.1:6545          127.0.0.1:47756         ESTABLI=
SHED

>=20
> Ian.
--=20
Ian Campbell

Just once, I wish we would encounter an alien menace that wasn't
immune to bullets.
		-- The Brigadier, "Dr. Who"

--=-i4LoPGFFNSGlA47N6EHp
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.9 (GNU/Linux)

iEYEABECAAYFAkktyb8ACgkQM0+0qS9rzVlbbgCeLTSjvdPzUFGxg7awLCO2q38P
ZFQAoOUacHJqEJo3bxxGXmZLHSXBa7DJ
=hzyP
-----END PGP SIGNATURE-----

--=-i4LoPGFFNSGlA47N6EHp--

