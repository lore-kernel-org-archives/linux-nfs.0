From: Bruce Guenter <lists-nfs@bruce-guenter.dyndns.org>
Subject: Re: NFSv3 and exporting bind mounts
Date: Wed, 3 Aug 2005 16:53:23 -0600
Message-ID: <20050803225323.GC18973@untroubled.org>
References: <20050803223934.GB18973@untroubled.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="bCsyhTFzCvuiizWE"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1E0S77-0001RG-8F
	for nfs@lists.sourceforge.net; Wed, 03 Aug 2005 15:53:29 -0700
Received: from zak.futurequest.net ([69.5.6.152])
	by mail.sourceforge.net with smtp (Exim 4.44)
	id 1E0S76-0003zP-45
	for nfs@lists.sourceforge.net; Wed, 03 Aug 2005 15:53:29 -0700
To: nfs@lists.sourceforge.net
In-Reply-To: <20050803223934.GB18973@untroubled.org>
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


--bCsyhTFzCvuiizWE
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Wed, Aug 03, 2005 at 04:39:34PM -0600, Bruce Guenter wrote:
> I have tried many combinations of nohide, crossmnt, and no_subtree_check
> in the exports file to no avail.

Sorry for this waste of time.  I tried many, but obviously not every,
combination, as I have got it to work now.
--=20
Bruce Guenter <bruce@untroubled.org> http://untroubled.org/
OpenPGP key: 699980E8 / D0B7 C8DD 365D A395 29DA  2E2A E96F B2DC 6999 80E8

--bCsyhTFzCvuiizWE
Content-Type: application/pgp-signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.1 (GNU/Linux)

iD8DBQFC8Urj6W+y3GmZgOgRAtNFAKCIm3qyMHPGB05rmCcvLI7Ijf8xzwCfW9F2
qdVaarZCVrqytbnaDpQYmuo=
=NZiN
-----END PGP SIGNATURE-----

--bCsyhTFzCvuiizWE--


-------------------------------------------------------
SF.Net email is Sponsored by the Better Software Conference & EXPO
September 19-22, 2005 * San Francisco, CA * Development Lifecycle Practices
Agile & Plan-Driven Development * Managing Projects & Teams * Testing & QA
Security * Process Improvement & Measurement * http://www.sqe.com/bsce5sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
