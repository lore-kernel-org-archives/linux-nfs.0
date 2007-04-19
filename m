From: Anibal Monsalve Salazar <anibal@debian.org>
Subject: Re: Does mountd/statd really need to listen on a privileged
	port??
Date: Fri, 20 Apr 2007 08:50:16 +1000
Message-ID: <20070419225016.GQ6175@debianrules.debiancolombia.org>
References: <17950.44333.118970.276558@notabene.brown>
	<4623BCD9.3090501@RedHat.com>
	<200704171208.51797.olaf.kirch@oracle.com>
	<17957.50539.958277.446719@notabene.brown>
	<17958.48121.280256.493824@notabene.brown>
	<46278794.6050307@RedHat.com> <20070419152149.GA9101@fieldses.org>
	<46278DE3.9020509@RedHat.com> <20070419155044.GD9101@fieldses.org>
	<46279AA2.4040105@RedHat.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============1491113772=="
Cc: Neil Brown <neilb@suse.de>,
	"J. Bruce Fields" <bfields@fieldses.org>,
	Matthias Koenig <mkoenig@novell.com>, nfs@lists.sourceforge.net,
	Javier =?iso-8859-1?Q?Fern=E1ndez-Sanguino_Pe=F1a?= <jfs@computer.org>,
	Olaf Kirch <olaf.kirch@oracle.com>
To: Steve Dickson <SteveD@redhat.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HefVO-0003X6-FU
	for nfs@lists.sourceforge.net; Thu, 19 Apr 2007 15:53:34 -0700
Received: from cpe-60-224-173-234.vic.bigpond.net.au ([60.224.173.234]
	helo=elida.v7w.com) by mail.sourceforge.net with esmtp (Exim 4.44)
	id 1HefVP-0002PB-Ib
	for nfs@lists.sourceforge.net; Thu, 19 Apr 2007 15:53:37 -0700
In-Reply-To: <46279AA2.4040105@RedHat.com>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net


--===============1491113772==
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="zGqVP2YgkFRp/g3j"
Content-Disposition: inline


--zGqVP2YgkFRp/g3j
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Thu, Apr 19, 2007 at 12:36:50PM -0400, Steve Dickson wrote:
>J. Bruce Fields wrote:
>>On Thu, Apr 19, 2007 at 11:42:27AM -0400, Steve Dickson wrote:
>>>J. Bruce Fields wrote:
>>>>And it that upstream version could still live in the nfs-utils tree,
>>>>couldn't it?  Or it annoying to build multiple binary packages from one
>>>>upstream tree for some reason?

I'd prefer to have them as separate upstream packages. However, it
won't really be much of a problem for debian as I'm the maintainer
of portmap and nfs-utils.

>>>Its not so much the annoyance... its the fact that other services
>>>like NIS also depend on portmap/rpcbind. Why should we require an
>>>AFS shop to install nfs-utils just so they can run NIS?
>>
>>Right.  I mean:  can't you build separate portmap and nfs-utils rpms
>>from the same nfs-utils source, and then make AFS depend only on the
>>portmap package?  I thought it was pretty common to do that sort of
>>thing.

The source package will generate a number of binary packages
(including the portmap binary package) and other binary packages
will depend on the portmap binary package as it happens now.

One problem that I see is that users will have to deal with a much
bigger source package to create patches for portmap.

Another problem is that to build portmapt, users only interested on
portmap and not interested on NFS will have to build-depend on all
the nfs-utils build-dependecies.

>Talking with people that know more about rpms that I ever
>want to know ;-) Yes... it is possible to create multiple
>rpms, with different names, from one source tree and it is
>done, but it does cause confusion... so its not clear how
>common it is...
>>
>>But maybe there's no particular advantage to having the two together
>>anyway.
>I really don't see any...  I think it would become for a headache
>than its worth...
>
>steved.

Anyway, I like Neil's proposal. :)

Best Regards,

An=EDbal Monsalve Salazar
--=20
http://v7w.com/anibal

--zGqVP2YgkFRp/g3j
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.6 (GNU/Linux)

iD8DBQFGJ/IogY5NIXPNpFURAmiOAKCwTxTSK/7Vb+SEeLd7Lo+dezZ4kACghs6I
EvlA3/EUUPItSxbJ+6CBsDM=
=XguR
-----END PGP SIGNATURE-----

--zGqVP2YgkFRp/g3j--


--===============1491113772==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
--===============1491113772==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

--===============1491113772==--
