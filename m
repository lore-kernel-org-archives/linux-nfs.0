From: Garrick Staples <garrick@usc.edu>
Subject: possible client stale filehandle bug?
Date: Tue, 25 Jan 2005 09:39:45 -0800
Message-ID: <20050125173945.GU12269@polop.usc.edu>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="Lf2umH5nvHrcpMUt"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CtUg3-0004y8-9E
	for nfs@lists.sourceforge.net; Tue, 25 Jan 2005 09:40:31 -0800
Received: from polop.usc.edu ([128.125.10.9])
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.41)
	id 1CtUg2-0000MR-SA
	for nfs@lists.sourceforge.net; Tue, 25 Jan 2005 09:40:31 -0800
Received: from polop.usc.edu (localhost.localdomain [127.0.0.1])
	by polop.usc.edu (8.12.11/8.12.11) with ESMTP id j0PHdjD6003976
	for <nfs@lists.sourceforge.net>; Tue, 25 Jan 2005 09:39:45 -0800
Received: (from garrick@localhost)
	by polop.usc.edu (8.12.11/8.12.11/Submit) id j0PHdjSE003974
	for nfs@lists.sourceforge.net; Tue, 25 Jan 2005 09:39:45 -0800
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


--Lf2umH5nvHrcpMUt
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi all,
   I have lots of storage in a large Solaris samfs environment that is NFS
shared to a large number of Solaris and RHEL3 clients.  Under some conditio=
ns,
linux apps have been getting stale filehandles during the normal course of
their activity.  Various file handling syscalls like read() or open() might
error.  Lots of renames and setattrs calls seem to trigger the problem. =20
'ci' and 'cvs commit' are particularly good at this.

It seems that the Solaris clients never report any such errors, only the Li=
nux
clients.  However, watching 'snoop' on the Solaris NFS server, I see that i=
t IS
returning stale file handles to both OSes, but Solaris clients seem to retry
the request several times; and the Linux clients immediately pass the error=
 up
to the application.

Is there some condition that the 2.4 kernel is handling incorrectly?


Sample snippet from the 'snoop' on the Solaris server with a Solaris client
waiting...

rcf102.usc.edu -> almaak.usc.edu NFS C LOOKUP3 FH=3DB41B Entries.Log
almaak.usc.edu -> rcf102.usc.edu NFS R LOOKUP3 OK FH=3D7BFE
rcf102.usc.edu -> almaak.usc.edu TCP D=3D2049 S=3D610     Ack=3D3071279992 =
Seq=3D337022612 Len=3D0 Win=3D64240
rcf102.usc.edu -> almaak.usc.edu NFS C ACCESS3 FH=3D7BFE (read,modify,exten=
d,execute)
almaak.usc.edu -> rcf102.usc.edu TCP D=3D610 S=3D2049     Ack=3D337022752 S=
eq=3D3071279992 Len=3D0 Win=3D64240
almaak.usc.edu -> rcf102.usc.edu NFS R ACCESS3 Stale NFS file handle
rcf102.usc.edu -> almaak.usc.edu NFS C LOOKUP3 FH=3DB41B Entries.Log
almaak.usc.edu -> rcf102.usc.edu NFS R LOOKUP3 OK FH=3D7BFE
rcf102.usc.edu -> almaak.usc.edu NFS C LOOKUP3 FH=3DB41B Entries.Log
almaak.usc.edu -> rcf102.usc.edu NFS R LOOKUP3 OK FH=3D7BFE
rcf102.usc.edu -> almaak.usc.edu TCP D=3D2049 S=3D610     Ack=3D3071280516 =
Seq=3D337023056 Len=3D0 Win=3D64240
rcf102.usc.edu -> almaak.usc.edu NFS C ACCESS3 FH=3D7BFE (read,modify,exten=
d,execute)
almaak.usc.edu -> rcf102.usc.edu TCP D=3D610 S=3D2049     Ack=3D337023196 S=
eq=3D3071280516 Len=3D0 Win=3D64240
almaak.usc.edu -> rcf102.usc.edu NFS R ACCESS3 Stale NFS file handle
rcf102.usc.edu -> almaak.usc.edu NFS C LOOKUP3 FH=3DB41B Entries.Log
almaak.usc.edu -> rcf102.usc.edu NFS R LOOKUP3 OK FH=3D7BFE
rcf102.usc.edu -> almaak.usc.edu TCP D=3D2049 S=3D610     Ack=3D3071280796 =
Seq=3D337023348 Len=3D0 Win=3D64240
rcf102.usc.edu -> almaak.usc.edu NFS C LOOKUP3 FH=3DB41B Entries.Log
almaak.usc.edu -> rcf102.usc.edu NFS R LOOKUP3 OK FH=3D7BFE
rcf102.usc.edu -> almaak.usc.edu TCP D=3D2049 S=3D610     Ack=3D3071281040 =
Seq=3D337023500 Len=3D0 Win=3D64240
rcf102.usc.edu -> almaak.usc.edu NFS C ACCESS3 FH=3D7BFE (read,modify,exten=
d,execute)
almaak.usc.edu -> rcf102.usc.edu TCP D=3D610 S=3D2049     Ack=3D337023640 S=
eq=3D3071281040 Len=3D0 Win=3D64240
almaak.usc.edu -> rcf102.usc.edu NFS R ACCESS3 Stale NFS file handle
rcf102.usc.edu -> almaak.usc.edu NFS C LOOKUP3 FH=3DB41B Entries.Log
almaak.usc.edu -> rcf102.usc.edu NFS R LOOKUP3 OK FH=3D7BFE
rcf102.usc.edu -> almaak.usc.edu NFS C LOOKUP3 FH=3DB41B Entries.Log
almaak.usc.edu -> rcf102.usc.edu NFS R LOOKUP3 OK FH=3D7BFE

--=20
Garrick Staples, Linux/HPCC Administrator
University of Southern California

--Lf2umH5nvHrcpMUt
Content-Type: application/pgp-signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.3 (GNU/Linux)

iD8DBQFB9oRh0SBUxJbm9HMRAuJeAJ9fSF2QE1Y+YuSMNPg4XPGznVfaiwCfdoUV
9BfPGWq9N9xUcB2E89N4siw=
=0Tf+
-----END PGP SIGNATURE-----

--Lf2umH5nvHrcpMUt--


-------------------------------------------------------
This SF.Net email is sponsored by: IntelliVIEW -- Interactive Reporting
Tool for open source databases. Create drag-&-drop reports. Save time
by over 75%! Publish reports on the web. Export to DOC, XLS, RTF, etc.
Download a FREE copy at http://www.intelliview.com/go/osdn_nl
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
