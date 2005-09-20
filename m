From: Reuti <reuti@staff.uni-marburg.de>
Subject: NFS client got stale NFS handle after server reboot
Date: Tue, 20 Sep 2005 16:36:28 +0200
Message-ID: <43301E6C.3060206@staff.uni-marburg.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1EHjEj-0007Ro-2K
	for nfs@lists.sourceforge.net; Tue, 20 Sep 2005 07:36:45 -0700
Received: from vhrz24.hrz.uni-marburg.de ([137.248.1.34])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1EHjEi-0004al-If
	for nfs@lists.sourceforge.net; Tue, 20 Sep 2005 07:36:45 -0700
Received: from staff.uni-marburg.de (pc15218.Chemie.Uni-Marburg.DE [137.248.152.52])
	by vhrz24.hrz.uni-marburg.de (8.13.4/8.13.4/Debian-3) with ESMTP id j8KEaSoT019347
	for <nfs@lists.sourceforge.net>; Tue, 20 Sep 2005 16:36:28 +0200
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

Hi all,

I set up a NFS server using kernel NFS in kernel 2.6.11.4-21.9 from 
SuSE. I defined three directories to be exported using netgroups and all 
is working fine, as they can be mounted as intended by all the nodes in 
the cluster.

Up to now I was used to have the NFS feature, that a "hard" mount on the 
nodes will survive a reboot of the NFS server. This is now no longer the 
case. If I reboot the server, all the nodes get a stale NFS handle. I 
can achieve the same effect by simple stopping and starting the nfsd - 
same result.

As we use a RAID card for the disks in the server, I got the idea of 
changing major-minor numbers and also tried to give in the "exports" 
file a chosen "fsid=" for each of the three exports. (Although 
starting/stopping the nfsd won't change the major-minor numbers I 
think.) No change.

Now the funny part: login to a node. Choose any of the three imported 
directories. Make an "umount" and "mount" on this dir - and also the 
other two dirs reappear and are accessible again.

Does anyone has an explanation and/or solution for this setup, to get 
the surviving feature back?

CU - Reuti

(BTW: all partitions are ext2 on x86 machines)



-------------------------------------------------------
This SF.Net email is sponsored by:
Power Architecture Resource Center: Free content, downloads, discussions,
and more. http://solutions.newsforge.com/ibmarch.tmpl
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
