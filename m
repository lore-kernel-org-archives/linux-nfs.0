From: Bernd Schubert <bernd-schubert@web.de>
Subject: Re: async vs. sync
Date: Mon, 26 Jul 2004 19:05:32 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <200407261905.40248.bernd-schubert@web.de>
References: <482A3FA0050D21419C269D13989C61130435E51E@lavender-fe.eng.netapp.com>
Mime-Version: 1.0
Content-Type: multipart/signed;
  protocol="application/pgp-signature";
  micalg=pgp-sha1;
  boundary="Boundary-02=_knTBBjYg1WnoIab";
  charset="iso-8859-1"
Cc: Linux NFS Mailing List <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Bp8v9-0000jQ-1O
	for nfs@lists.sourceforge.net; Mon, 26 Jul 2004 10:05:51 -0700
Received: from smtp05.web.de ([217.72.192.209])
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:DES-CBC3-SHA:168)
	(Exim 4.34)
	id 1Bp8v8-00085r-IQ
	for nfs@lists.sourceforge.net; Mon, 26 Jul 2004 10:05:50 -0700
To: "Lever, Charles" <cel@netapp.com>
In-Reply-To: <482A3FA0050D21419C269D13989C61130435E51E@lavender-fe.eng.netapp.com>
Errors-To: nfs-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>


--Boundary-02=_knTBBjYg1WnoIab
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

On Monday 26 July 2004 18:26, you wrote:
> > Any ideas whats the issue with sync vs async in 2.4.x?
>
> <Sonorus>
> Read The FAQ, Luke
> </Sonorus>
>
> the async export option opens a window that allows silent data
> corruption.  did you have a specific question about it?

Exactly, therefore I would like to enable the sync-export option again.=20
However, reducing the speed to about 1/5 of async speed for large files and=
=20
to about 1/20 for smaller files is not an option. The people already=20
complained that compiling their projects takes ages now...=20

D'oh, sorry, I forgot to write that we use the tcp-mounts and nfs3. So  tho=
se=20
numbers really shouldn't happen, should they?


Cheers,
	Bernd

--Boundary-02=_knTBBjYg1WnoIab
Content-Type: application/pgp-signature
Content-Description: signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.4 (GNU/Linux)

iD8DBQBBBTnkC8BUnAF+ydYRAnE0AJ9Kz5J6qfwFZzs0WMawo2XB/uxSTwCfVohB
O/zXSaWIdWYE+rOqE/6wZ84=
=MCoG
-----END PGP SIGNATURE-----

--Boundary-02=_knTBBjYg1WnoIab--


-------------------------------------------------------
This SF.Net email is sponsored by BEA Weblogic Workshop
FREE Java Enterprise J2EE developer tools!
Get your free copy of BEA WebLogic Workshop 8.1 today.
http://ads.osdn.com/?ad_id=4721&alloc_id=10040&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
