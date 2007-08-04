From: Malte =?UTF-8?B?U2NocsO2ZGVy?= <maltesch@gmx.de>
Subject: Re: OOPS in shrink_dcache_for_umount
Date: Sat, 4 Aug 2007 12:01:05 +0200
Message-ID: <20070804120105.47ae82fc@highlander.home.lan>
References: <92cbf19b0708021427l7c88c642g3901e393ac2b90b9@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============1311646090=="
Cc: nfs@lists.sourceforge.net, linux-kernel@vger.kernel.org
To: "Chakri n" <chakriin5@gmail.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IHGRf-0001R6-Hw
	for nfs@lists.sourceforge.net; Sat, 04 Aug 2007 03:01:15 -0700
Received: from mail.gmx.net ([213.165.64.20])
	by mail.sourceforge.net with smtp (Exim 4.44) id 1IHGRg-000296-Rv
	for nfs@lists.sourceforge.net; Sat, 04 Aug 2007 03:01:19 -0700
In-Reply-To: <92cbf19b0708021427l7c88c642g3901e393ac2b90b9@mail.gmail.com>
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

--===============1311646090==
Content-Type: multipart/signed; boundary=Sig_e4W3c19RHe5ff9CRa7Dn8pB;
	protocol="application/pgp-signature"; micalg=PGP-SHA1

--Sig_e4W3c19RHe5ff9CRa7Dn8pB
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

On Thu, 2 Aug 2007 14:27:04 -0700
"Chakri n" <chakriin5@gmail.com> wrote:

> Hi,
>=20
> We are seeing this problem while unmounting file systems. It happens
> once in a while.
> I am able to grab the trace and core from linux-2.6.18-1.8.el5, but I
> have observed the same problem with linux-2.6.20.1 kernel.
>=20
> Has this problem fixed in recent kernel?
>=20

I had those too ... but I haven't seen one in a while.
I currently run 2.6.22 + cfs-v19 + the Patch from
http://linux-nfs.org/Linux-2.6.x/2.6.22/linux-2.6.22-NFS_ALL.dif

--=20
---------------------------------------
Malte Schr=C3=B6der
MalteSch@gmx.de
ICQ# 68121508
---------------------------------------


--Sig_e4W3c19RHe5ff9CRa7Dn8pB
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.6 (GNU/Linux)

iD8DBQFGtE5h4q3E2oMjYtURAtATAKDxxFKJtJ9fIF2o7MeCSs1WWVCE6wCfY8+c
SRhCkvQdIUSUo1wJiDvzDVY=
=MycX
-----END PGP SIGNATURE-----

--Sig_e4W3c19RHe5ff9CRa7Dn8pB--


--===============1311646090==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
--===============1311646090==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

--===============1311646090==--
