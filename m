From: "Lever, Charles" <cel@netapp.com>
Subject: RE: sendmail "cannot fsync directory" after 2.4 -> 2.6
Date: Thu, 9 Sep 2004 11:54:23 -0700
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <482A3FA0050D21419C269D13989C61130435E7A8@lavender-fe.eng.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Cc: <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1C5U3y-0002Br-RB
	for nfs@lists.sourceforge.net; Thu, 09 Sep 2004 11:54:30 -0700
Received: from mx01.netapp.com ([198.95.226.53])
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.34)
	id 1C5U3y-0007q3-5T
	for nfs@lists.sourceforge.net; Thu, 09 Sep 2004 11:54:30 -0700
To: "Ara.T.Howard" <Ara.T.Howard@noaa.gov>
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

> > Yep. We forgot to add the stub to Linux 2.6.x. Please=20
> confirm that the=20
> > following patch fixes the problem for you.
>=20
> will fsync'ing a directory have any affect on the client=20
> inode cache for that dir?  eg. will it invalidate that cache?

ara-

looking at the patch trond posted, it appears to add a "no-op" function
for fsyncing NFS directories.  this means fsync against an NFS directory
will not complain, but otherwise does nothing.


-------------------------------------------------------
This SF.Net email is sponsored by: YOU BE THE JUDGE. Be one of 170
Project Admins to receive an Apple iPod Mini FREE for your judgement on
who ports your project to Linux PPC the best. Sponsored by IBM. 
Deadline: Sept. 13. Go here: http://sf.net/ppc_contest.php
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
