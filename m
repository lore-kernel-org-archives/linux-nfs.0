From: Dan Stromberg <strombrg@dcs.nac.uci.edu>
Subject: NFS trouble with large data transfer on an opteron with RHEL 3
Date: Thu, 30 Sep 2004 09:13:09 -0700
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <1096560789.3320.3.camel@tesuji.nac.uci.edu>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-ZMAvyTu+l2b+Hiw2gey3"
Cc: Dan Stromberg <strombrg@dcs.nac.uci.edu>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CD3YP-0002Km-DY
	for nfs@lists.sourceforge.net; Thu, 30 Sep 2004 09:13:13 -0700
Received: from dcs.nac.uci.edu ([128.200.34.32] ident=root)
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.41)
	id 1CD3YO-00033y-BM
	for nfs@lists.sourceforge.net; Thu, 30 Sep 2004 09:13:13 -0700
To: nfs@lists.sourceforge.net
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


--=-ZMAvyTu+l2b+Hiw2gey3
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable


I wrote some time ago, mentioning a problem we were having extracting a
Solaris .iso over NFS onto an RHEL 3 opteron NFS server.  The machine is
from a linux vendor named "Appro".

It turns out that by disabling the NFS server's APIC, we were able to
get NFS (actually, IDE) to stabilize.

Thanks.

--=20
Dan Stromberg DCS/NACS/UCI <strombrg@dcs.nac.uci.edu>


--=-ZMAvyTu+l2b+Hiw2gey3
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.4 (GNU/Linux)

iD8DBQBBXDCUo0feVm00f/8RAu8dAJ9QkWYmALmyY69nsuVKL+yOMg7k3ACfRjaZ
aUdCGwGIqnSQDi9xECxBUkA=
=K8f8
-----END PGP SIGNATURE-----

--=-ZMAvyTu+l2b+Hiw2gey3--



-------------------------------------------------------
This SF.net email is sponsored by: IT Product Guide on ITManagersJournal
Use IT products in your business? Tell us what you think of them. Give us
Your Opinions, Get Free ThinkGeek Gift Certificates! Click to find out more
http://productguide.itmanagersjournal.com/guidepromo.tmpl
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
