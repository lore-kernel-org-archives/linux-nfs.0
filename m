From: nhorman@redhat.com
Subject: [RFC] implementing BSD style locks on NLM (flocks)
Date: Sun, 27 Feb 2005 14:21:13 -0500
Message-ID: <20050227192113.GA5778@localhost.localdomain>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="OgqxwSJOaUobr8KG"
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1D5TyD-0007VW-Lt
	for nfs@lists.sourceforge.net; Sun, 27 Feb 2005 11:20:49 -0800
Received: from mx1.redhat.com ([66.187.233.31])
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.41)
	id 1D5TyC-0002hq-4U
	for nfs@lists.sourceforge.net; Sun, 27 Feb 2005 11:20:49 -0800
Received: from int-mx1.corp.redhat.com (int-mx1.corp.redhat.com [172.16.52.254])
	by mx1.redhat.com (8.12.11/8.12.11) with ESMTP id j1RJKftJ014383
	for <nfs@lists.sourceforge.net>; Sun, 27 Feb 2005 14:20:41 -0500
Received: from localhost.localdomain (vpn50-32.rdu.redhat.com [172.16.50.32])
	by int-mx1.corp.redhat.com (8.11.6/8.11.6) with ESMTP id j1RJKfK20176
	for <nfs@lists.sourceforge.net>; Sun, 27 Feb 2005 14:20:41 -0500
Received: from localhost.localdomain (localhost.localdomain [127.0.0.1])
	by localhost.localdomain (8.13.1/8.13.1) with ESMTP id j1RJLEfR005786
	for <nfs@lists.sourceforge.net>; Sun, 27 Feb 2005 14:21:14 -0500
Received: (from nhorman@localhost)
	by localhost.localdomain (8.13.1/8.13.1/Submit) id j1RJLDjp005785
	for nfs@lists.sourceforge.net; Sun, 27 Feb 2005 14:21:13 -0500
To: nfs@lists.sourceforge.net
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


--OgqxwSJOaUobr8KG
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hey all-
	I was wondering, how much interest there might be in the addition of
support for BSD style locks (flocks) over NLM.  I was thinking that a bit c=
ould
be added to differentiate the two namespaces.  Any thoughts appreciated. =
=20

Regards,
Neil
--=20
/***************************************************
 *Neil Horman
 *Software Engineer
 *Red Hat, Inc.
 *nhorman@redhat.com
 *gpg keyid: 1024D / 0x92A74FA1
 *http://pgp.mit.edu
 ***************************************************/

--OgqxwSJOaUobr8KG
Content-Type: application/pgp-signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.6 (GNU/Linux)

iD8DBQFCIh2pM+bEoZKnT6ERAoM1AJ470ZrdSAsKJ/2eWdvHzkgV17nQFwCeN9TV
RNy6W21StR+7UrCNn2D1AU8=
=eVpr
-----END PGP SIGNATURE-----

--OgqxwSJOaUobr8KG--


-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now.
http://ads.osdn.com/?ad_id=6595&alloc_id=14396&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
