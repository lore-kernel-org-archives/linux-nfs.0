From: "Mikko Rahkonen" <mikko.rahkonen@gmail.com>
Subject: NFS: exporting a hfsplus volume in Linux 2.6.19
Date: Sun, 3 Dec 2006 11:47:59 +0200
Message-ID: <ff320860612030147r6e2fe53dl2c30dd71badf3adb@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Gqnx3-0006l7-TK
	for nfs@lists.sourceforge.net; Sun, 03 Dec 2006 01:48:02 -0800
Received: from ug-out-1314.google.com ([66.249.92.174])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1Gqnx3-00073Y-1X
	for nfs@lists.sourceforge.net; Sun, 03 Dec 2006 01:48:03 -0800
Received: by ug-out-1314.google.com with SMTP id z38so2751661ugc
	for <nfs@lists.sourceforge.net>; Sun, 03 Dec 2006 01:47:59 -0800 (PST)
To: nfs@lists.sourceforge.net
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

Hi

Is exporting a hfsplus filesystem currently supported in Linux NFS
implementation?

I'm trying to NFS export a hfsplus volume in Linux. I get a permission denied
error when mounting the Linux NFS export from a client (Mac OS X or Linux) even
though user permissions are correct for the volume and mount point (other NFS
exports of different filesystems are working as expected).

I know I can use a samba export (it works) but NFS is much more
efficient. The main
reason for using the hfsplus filesystem is that I can use this
external hard drive volume
locally from Mac OS X if needed without any filesystem drivers
installed in Mac OS X
(there is an ext2 driver for OS X but it's still quite unstable) and
FAT has this 4GB file
size limit.

Thanks!
-- 
Mikko

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys - and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
