From: Andre Noll <maan@systemlinux.org>
Subject: Re: 2.6.21.x kernel panic (tg3 and nfs related)
Date: Wed, 27 Jun 2007 18:12:28 +0200
Message-ID: <20070627161228.GS22589@skl-net.de>
References: <20070627101608.GQ22589@skl-net.de> <4682891A.2070900@redhat.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============0433852091=="
Cc: nfs@lists.sourceforge.net, linux-kernel@vger.kernel.org,
	mchan@broadcom.com
To: Chuck Ebbert <cebbert@redhat.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1I3aA7-0005Tj-1P
	for nfs@lists.sourceforge.net; Wed, 27 Jun 2007 09:14:35 -0700
Received: from systemlinux.org ([83.151.29.59] helo=m18s25.vlinux.de)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1I3aA8-0000Tf-4z
	for nfs@lists.sourceforge.net; Wed, 27 Jun 2007 09:14:38 -0700
In-Reply-To: <4682891A.2070900@redhat.com>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net


--===============0433852091==
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="lCKkSrrNUaKEhaIQ"
Content-Disposition: inline


--lCKkSrrNUaKEhaIQ
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On 11:58, Chuck Ebbert wrote:
> > Screenshots of the resulting kernel panics are available at
> >=20
> > 	http://www.systemlinux.org/~maan/shots/huangho-crash-2.6.21.1.png
> > and
> > 	http://www.systemlinux.org/~maan/shots/huangho-crash-2.6.21.5.png
> >=20
>=20
> Looks the the known oops in show_mem(); patch is queued for 2.6.21.6.

I see. Thanks.

> But it is hard to tell when the screen shot doesn't show the whole
> message...

There's no way to scroll up after a kernel panic. I already changed
the video setting to use a smaller font, so if it happens again,
there will be more info visible.

Andre
--=20
The only person who always got his work done by Friday was Robinson Crusoe

--lCKkSrrNUaKEhaIQ
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.1 (GNU/Linux)

iD8DBQFGgoxsWto1QDEAkw8RAhRVAJ40vEvKxoMbYql5i0jKsfLmv/JEXACffmdg
gx5aNuyGe4ggds3LBp/oHvo=
=hAwp
-----END PGP SIGNATURE-----

--lCKkSrrNUaKEhaIQ--


--===============0433852091==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
--===============0433852091==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

--===============0433852091==--
