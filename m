From: "Lever, Charles" <Charles.Lever@netapp.com>
Subject: RE: nfs: server X not responding, still trying
Date: Tue, 4 Nov 2003 08:34:14 -0800
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <482A3FA0050D21419C269D13989C6113020AC622@lavender-fe.eng.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Cc: <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 1AH4DW-0006Qh-00
	for <nfs@lists.sourceforge.net>; Tue, 04 Nov 2003 08:39:43 -0800
Received: from mx01.netapp.com ([198.95.226.53])
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.24)
	id 1AH4DW-0004qi-NZ
	for nfs@lists.sourceforge.net; Tue, 04 Nov 2003 08:39:42 -0800
To: "Timothy G. Wesemann" <timwese@voicenet.com>
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

it was pointed out to me that this was not entirely clear:

> > The client mount/fstab options are:
> > "rw,async,intr,vers=3D3,rsize=3D32768,wsize=3D32768" and the=20
> > server's exports
> > options are: "rw,no_root_squash,async,no_subtree_check".
>=20
> i am obligated to provide a friendly warning about using
> the "async" export option.  see the Linux NFS FAQ
> (http://nfs.sourceforge.net) for details.
>=20
> the async mount option is not needed, as async is the default.

the async export option is to be avoided.
          ^^^^^^
the async mount option is superfluous.
          ^^^^^

especially with NFSv3, async in either place is really not
necessary.  the Linux NFS FAQ has some explanatory text that
details why this is the case.


-------------------------------------------------------
This SF.net email is sponsored by: SF.net Giveback Program.
Does SourceForge.net help you be more productive?  Does it
help you create better code?   SHARE THE LOVE, and help us help
YOU!  Click Here: http://sourceforge.net/donate/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
