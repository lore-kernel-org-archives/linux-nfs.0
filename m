From: Bruce Guenter <lists-nfs@bruce-guenter.dyndns.org>
Subject: NFSv3 and exporting bind mounts
Date: Wed, 3 Aug 2005 16:39:34 -0600
Message-ID: <20050803223934.GB18973@untroubled.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="liOOAslEiF7prFVr"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1E0Rtm-00011f-CD
	for nfs@lists.sourceforge.net; Wed, 03 Aug 2005 15:39:42 -0700
Received: from zak.futurequest.net ([69.5.6.152])
	by mail.sourceforge.net with smtp (Exim 4.44)
	id 1E0Rti-0001Jd-3q
	for nfs@lists.sourceforge.net; Wed, 03 Aug 2005 15:39:42 -0700
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


--liOOAslEiF7prFVr
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi.

I am trying to get a directory linked with mount --bind to export
without needing a separate client mount with NFSv3.  Is this possible?

That is, if I export /share, and do
	mount --bind /usr/portage /share/portage
I would like the contents of /share/portage to show up on the clients.
I have tried many combinations of nohide, crossmnt, and no_subtree_check
in the exports file to no avail.

Thanks.
--=20
Bruce Guenter <bruce@untroubled.org> http://untroubled.org/
OpenPGP key: 699980E8 / D0B7 C8DD 365D A395 29DA  2E2A E96F B2DC 6999 80E8

--liOOAslEiF7prFVr
Content-Type: application/pgp-signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.1 (GNU/Linux)

iD8DBQFC8Uem6W+y3GmZgOgRAt+0AKCl6TexjTHDOnfL3hK2XdwUawEUZgCfSRjE
gxNqaTGy++LQdKxpACQyrW0=
=NPSE
-----END PGP SIGNATURE-----

--liOOAslEiF7prFVr--


-------------------------------------------------------
SF.Net email is Sponsored by the Better Software Conference & EXPO
September 19-22, 2005 * San Francisco, CA * Development Lifecycle Practices
Agile & Plan-Driven Development * Managing Projects & Teams * Testing & QA
Security * Process Improvement & Measurement * http://www.sqe.com/bsce5sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
