From: wim delvaux <wim.delvaux@adaptiveplanet.com>
Subject: nfs / cdroms / autofs - revisited
Date: Sat, 14 Feb 2004 16:51:11 +0100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <200402141651.11820.wim.delvaux@adaptiveplanet.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1As278-0005k7-UA
	for nfs@lists.sourceforge.net; Sat, 14 Feb 2004 07:53:54 -0800
Received: from amsfep16-int.chello.nl ([213.46.243.26])
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.30)
	id 1As20u-0004Y4-RX
	for nfs@lists.sourceforge.net; Sat, 14 Feb 2004 07:47:29 -0800
Received: from cable-62-205-65-11.upc.chello.be ([62.205.65.11])
          by amsfep16-int.chello.nl
          (InterMail vM.6.00.05.02 201-2115-109-103-20031105) with ESMTP
          id <20040214155115.CPND17439.amsfep16-int.chello.nl@cable-62-205-65-11.upc.chello.be>
          for <nfs@lists.sourceforge.net>; Sat, 14 Feb 2004 16:51:15 +0100
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

Hi all,

Just read that many of you have the same problem as I do : how to unmount a 
cdrom using autofs and nfs.

It seems that you do not even have to mount the nfs-exported cdrom from some 
client for the cdrom to become unusable.  If you insert a medium and reboot 
the export (the nfsd) mounts but never unlocks the cdrom even if no remote 
nfs-mount request was issued.

I wonder why this happens ? What are the ussues here ? Why can't nfs 
lazy-mount filesystems ? I am using 2.6 kernel.

Thx

W



-------------------------------------------------------
SF.Net is sponsored by: Speed Start Your Linux Apps Now.
Build and deploy apps & Web services for Linux with
a free DVD software kit from IBM. Click Now!
http://ads.osdn.com/?ad_id=1356&alloc_id=3438&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
