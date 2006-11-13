From: Bernd Schubert <bernd.schubert@pci.uni-heidelberg.de>
Subject: nfs caching problem
Date: Mon, 13 Nov 2006 16:47:37 +0100
Message-ID: <200611131647.38606.bernd.schubert@pci.uni-heidelberg.de>
Reply-To: bernd-schubert@gmx.de
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Gje2g-0006mO-03
	for nfs@lists.sourceforge.net; Mon, 13 Nov 2006 07:48:14 -0800
Received: from externalmx-1.sourceforge.net ([12.152.184.25])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1Gje2d-0004oH-Q0
	for nfs@lists.sourceforge.net; Mon, 13 Nov 2006 07:48:15 -0800
Received: from relay2.uni-heidelberg.de ([129.206.210.211])
	by externalmx-1.sourceforge.net with esmtp (Exim 4.41)
	id 1Gje2U-00021z-W0
	for nfs@lists.sourceforge.net; Mon, 13 Nov 2006 07:48:03 -0800
To: Trond Myklebust <trond.myklebust@fys.uio.no>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

Hi Trond,

I already postet this problem a couple of months before to this list, but =

never got an answer. I think there's a serious problem with nfs caching in =

2.6.16 (don't know about other kernel versions yet, we never had this probl=
em =

with 2.6.11 and below).

Here the stat output for the same directory, just on two different systems:

bernd@zuse test-wine>stat /usr/local/wine
  File: `/usr/local/wine'
  Size: 344             Blocks: 0          IO Block: 8192   directory
Device: 18h/24d Inode: 168810      Links: 4
Access: (0755/drwxr-xr-x)  Uid: (    0/    root)   Gid: (    0/    root)
Access: 2006-11-13 15:48:50.000000000 +0100
Modify: 2006-04-24 13:40:00.000000000 +0200
Change: 2006-11-13 16:24:48.000000000 +0100


bernd@gauss bernd>stat /usr/local/wine
  File: `/usr/local/wine'
  Size: 400             Blocks: 0          IO Block: 8192   directory
Device: 17h/23d Inode: 181641      Links: 4
Access: (0755/drwxr-xr-x)  Uid: (    0/    root)   Gid: (    0/    root)
Access: 2006-11-13 16:35:12.000000000 +0100
Modify: 2006-11-13 15:58:29.000000000 +0100
Change: 2006-11-13 16:25:20.000000000 +0100


On sytem zuse stat is actually reading the information =

of /usr/local/wine.old-2006-11-13. I had just moved wine to =

wine.old-2006-11-13. =


bernd@zuse test-wine>stat /usr/local/wine.old-2006-11-13/
  File: `/usr/local/wine.old-2006-11-13/'
  Size: 344             Blocks: 0          IO Block: 8192   directory
Device: 18h/24d Inode: 168810      Links: 4
Access: (0755/drwxr-xr-x)  Uid: (    0/    root)   Gid: (    0/    root)
Access: 2006-11-13 15:48:50.000000000 +0100
Modify: 2006-04-24 13:40:00.000000000 +0200
Change: 2006-11-13 16:24:48.000000000 +0100


Please, this is a serious issue which already happend many time during the =

past months. Any idea how to debug this?


Thanks,
Bernd


-- =

Bernd Schubert
Physikalisch Chemisches Institut / Theoretische Chemie
Universit=E4t Heidelberg
INF 229
69120 Heidelberg
e-mail: bernd.schubert@pci.uni-heidelberg.de

-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easi=
er
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=3Dlnk&kid=3D120709&bid=3D263057&dat=3D1=
21642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
