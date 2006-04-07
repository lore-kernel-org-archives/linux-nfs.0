From: Garrick Staples <garrick@usc.edu>
Subject: Re: nfs over 2tb limitation
Date: Fri, 7 Apr 2006 00:48:42 -0700
Message-ID: <20060407074842.GE18673@polop.usc.edu>
References: <E80C016468F5454E93FBC2FBF2F93AE47FB4F6@EINSTEIN.idg.idgrup.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="vCLt983cbvqbeEnR"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1FRlhz-0002um-SS
	for nfs@lists.sourceforge.net; Fri, 07 Apr 2006 00:48:43 -0700
Received: from polop.usc.edu ([128.125.10.9])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1FRlhy-0005mq-S4
	for nfs@lists.sourceforge.net; Fri, 07 Apr 2006 00:48:44 -0700
Received: from polop.usc.edu (localhost.localdomain [127.0.0.1])
	by polop.usc.edu (8.12.11.20060308/8.12.11) with ESMTP id k377mgFK007907
	for <nfs@lists.sourceforge.net>; Fri, 7 Apr 2006 00:48:42 -0700
Received: (from garrick@localhost)
	by polop.usc.edu (8.12.11.20060308/8.12.11/Submit) id k377mg2L007905
	for nfs@lists.sourceforge.net; Fri, 7 Apr 2006 00:48:42 -0700
To: nfs@lists.sourceforge.net
In-Reply-To: <E80C016468F5454E93FBC2FBF2F93AE47FB4F6@EINSTEIN.idg.idgrup.com>
Sender: nfs-admin@lists.sourceforge.net
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


--vCLt983cbvqbeEnR
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Fri, Apr 07, 2006 at 09:34:30AM +0200, Julio Prada alleged:
>=20
> Please, could you confirm whether nfs client cannot see more than 2 TB fi=
le systems?

No problem here!

$ uname -r
2.4.21-37.0.1.EL.1uschugemem
$ df -h .
Filesystem            Size  Used Avail Use% Mounted on
samfs3:/export/samfs-ddn/rcf-104
                       30T   21T  8.5T  72% /auto/rcf-104

--=20
Garrick Staples, Linux/HPCC Administrator
University of Southern California

--vCLt983cbvqbeEnR
Content-Type: application/pgp-signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.3 (GNU/Linux)

iD8DBQFENhla0SBUxJbm9HMRApuZAKCn68Pu909DlRdafr8IzdZN/NsMDACginDB
rWGD1sg6i/jV0Wx8lKO2aRU=
=6+5+
-----END PGP SIGNATURE-----

--vCLt983cbvqbeEnR--


-------------------------------------------------------
This SF.Net email is sponsored by xPML, a groundbreaking scripting language
that extends applications into web and mobile media. Attend the live webcast
and join the prime developer group breaking into this new coding territory!
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=110944&bid=241720&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
