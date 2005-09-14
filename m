From: "Lever, Charles" <Charles.Lever@netapp.com>
Subject: RE: NFS problem - close to open cache consistency broken ?
Date: Tue, 13 Sep 2005 19:22:31 -0700
Message-ID: <044B81DE141D7443BCE91E8F44B3C1E288E43D@exsvl02.hq.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Cc: <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1EFMuq-0002tv-8R
	for nfs@lists.sourceforge.net; Tue, 13 Sep 2005 19:22:28 -0700
Received: from mx1.netapp.com ([216.240.18.38])
	by mail.sourceforge.net with esmtp (Exim 4.44)
	id 1EFMun-00055M-WD
	for nfs@lists.sourceforge.net; Tue, 13 Sep 2005 19:22:28 -0700
To: "Thomas Stockheim" <tommi@bub-agema.de>
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

> I'm having a problem with NFS caching after updating from Redhat 8 to=20
> Fedora. Sometimes changes to files ( even when done on the=20
> server) just=20
> do not show up. At first we suspected timing problems, but=20
> all machines
> are synchronized with ntp.
>=20
> Then I found out how to reproduce it:
> 1 server: echo xxxx > testfile
> 2 client: Application 1 on client opens testfile, does=20
> nothing with it -=20
> keeps it open forever ( simple fortran program with an open and an
> endless loop )
> 3 client: cat testfile  gives xxxx
> 4 server: echo yyyy > testfile
> 5 client: cat testfile  still shows xxxx
>=20
> Its not a file attribute caching problem I think, ls -l shows the
> correct, updated modificiation time for the file. But the=20
> file contents
> never get updated. Once I kill the application that was=20
> holding open the=20
> testfile, it still shows the wrong content, but any new changes show=20
> immediately.
>=20
> At first, we tested this on kernel 2.6.11 and 2.6.9. Here, increasing
> file size by 1 worked to get the updated file contents on the client,=20
> but decreasing file size did not work.
>=20
> 6a server: echo zzzzz > testfile
> 7a client: cat testfile  shows zzzzz
>=20
> 6b server: echo zzz > testfile
> 7b server: cat testfile  shows xxxx
>=20
> With kernel 2.6.13, any file size changes show the new=20
> content directly,
> but if the file size stays constant it still does not work.
>=20
> I tried all the mount options, but even turning attribute
> caching totally off does not seem to help. Mouting as nfsv2=20
> did not help
> either.
>=20
> I assume its a problem of the client, not the server - mounting the
> same exports on old redhat 7 with kernel 2.4.2 everything works.
>=20
> If I understand Close-to-open cache consistency right, having the file
> opened from a different application on the same client should=20
> not be a problem ?

thomas-

the client uses mtime and size to detect file changes on the server.  if
the mtime doesn't change on the server, the clients won't detect any
data changes.

what physical file system are you using on the server?


-------------------------------------------------------
SF.Net email is sponsored by:
Tame your development challenges with Apache's Geronimo App Server. 
Download it for free - -and be entered to win a 42" plasma tv or your very
own Sony(tm)PSP.  Click here to play: http://sourceforge.net/geronimo.php
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
