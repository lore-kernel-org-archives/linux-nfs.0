From: Dan Stromberg <strombrg@dcs.nac.uci.edu>
Subject: Appro woes
Date: Tue, 19 Oct 2004 16:35:07 -0700
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <1098228900.3601.8.camel@tesuji.nac.uci.edu>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-FeF0xRMFFQJQADNaEAE7"
Cc: Dan Stromberg <strombrg@dcs.nac.uci.edu>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CK3VY-0001M3-Do
	for nfs@lists.sourceforge.net; Tue, 19 Oct 2004 16:35:12 -0700
Received: from dcs.nac.uci.edu ([128.200.34.32] ident=root)
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.41)
	id 1CK3VX-0008OV-Lm
	for nfs@lists.sourceforge.net; Tue, 19 Oct 2004 16:35:12 -0700
To: Linux NFS Mailing List <nfs@lists.sourceforge.net>
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


--=-FeF0xRMFFQJQADNaEAE7
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable


We're continuing to have troubles with our Appro NFS server running RHEL
3.

We managed to get rid of our copious IDE errors by turning off APIC,
however, uncompressing a large .iso image (this time, it's not a solaris
.iso, but rather a "redwall" .iso) continues to drive the machine's load
sky-high - over 21 in fact, meaning that the server starts rejecting
SMTP connections, and may have had NIS problems as well (at least it
used to before we turned off APIC).

Is there a tool I can use to provide the NFS and/or Redhat developers
with information they require to debug such a problem?  Perhaps I could
set up netdump and force a dump (the machine no longer crashes, since we
turned off APIC), and/or provide a tethereal packet trace?  Or is there
something I could strace?

The kernel we're using is 2.4.21-15.0.4.EL.

Thanks!

--=20
Dan Stromberg DCS/NACS/UCI <strombrg@dcs.nac.uci.edu>


--=-FeF0xRMFFQJQADNaEAE7
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.4 (GNU/Linux)

iD8DBQBBdaSko0feVm00f/8RAoyjAJoCrrNpUQiKKRAi+f2AygTP0aeysQCeKHYq
054C9eb8kCJkt3dYuANE1Wc=
=4zBv
-----END PGP SIGNATURE-----

--=-FeF0xRMFFQJQADNaEAE7--



-------------------------------------------------------
This SF.net email is sponsored by: IT Product Guide on ITManagersJournal
Use IT products in your business? Tell us what you think of them. Give us
Your Opinions, Get Free ThinkGeek Gift Certificates! Click to find out more
http://productguide.itmanagersjournal.com/guidepromo.tmpl
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
