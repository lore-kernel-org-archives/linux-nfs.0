From: "Lever, Charles" <Charles.Lever@netapp.com>
Subject: RE: Re: network storage solutions
Date: Fri, 16 May 2003 09:18:10 -0700
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <482A3FA0050D21419C269D13989C61131274DF@lavender-fe.eng.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Cc: "Beowulf" <beowulf@beowulf.org>, <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from mx01.netapp.com ([198.95.226.53])
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 19Ghue-0006Yo-00
	for <nfs@lists.sourceforge.net>; Fri, 16 May 2003 09:18:28 -0700
To: "Joseph Landman" <landman@scalableinformatics.com>
Errors-To: nfs-admin@lists.sourceforge.net
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>



> -----Original Message-----
> From: Joseph Landman [mailto:landman@scalableinformatics.com]
> Sent: Thursday, May 15, 2003 6:26 PM
> To: Lever, Charles
> Cc: Beowulf; nfs@lists.sourceforge.net
> Subject: RE: [NFS] Re: network storage solutions
>=20

  [ ... snip ... ]
=20
> I used it for remote file backup purposes, mount the file system to be
> backed up with the soft, intr options (and large rsize/wsize, and
> vers=3D3), and then dump.  With the hard option, when there was=20
> an error,
> I had machine crashes.  With soft, I could recover.

caveat:  using a soft mount for backups increases the probability
that your backups will be unusable for all the reasons we've
discussed.

if an error caused a machine crash, then there are bugs that should
be fixed.


-------------------------------------------------------
Enterprise Linux Forum Conference & Expo, June 4-6, 2003, Santa Clara
The only event dedicated to issues related to Linux enterprise solutions
www.enterpriselinuxforum.com

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
