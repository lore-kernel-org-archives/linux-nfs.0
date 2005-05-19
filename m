From: Rauch Wolke <rauchwolke@gmx.net>
Subject: nfs v4 exports
Date: Thu, 19 May 2005 03:14:22 +0200
Message-ID: <200505190314.22576.rauchwolke@gmx.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DYZbd-00020T-7F
	for nfs@lists.sourceforge.net; Wed, 18 May 2005 18:13:45 -0700
Received: from stud4.tuwien.ac.at ([193.170.75.14])
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.41)
	id 1DYZbb-00053W-C6
	for nfs@lists.sourceforge.net; Wed, 18 May 2005 18:13:44 -0700
Received: from tux (chello062178198206.5.15.tuwien.teleweb.at [62.178.198.206])
	by stud4.tuwien.ac.at (8.9.3 (PHNE_29774)/8.9.3) with ESMTP id DAA09848
	for <nfs@lists.sourceforge.net>; Thu, 19 May 2005 03:13:40 +0200 (METDST)
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

hello,

i use gentoo linux and i exported this directories

root@Server puchu # exportfs -v
/home/puchu     Tux(rw,wdelay,insecure,root_squash,no_subtree_check,fsid=0)
/mnt/backup     Tux(rw,wdelay,insecure,root_squash,no_subtree_check,fsid=0)


but when i do (a on the client)

mount -t nfs4 server:/ /mnt/server

i can only see the content of /home/puchu....

with wrong group and owner ...think its the nobody user...explained in man 
exports...but the gid and guid is the same on the client and on the server 
for  all files 

user: puchu 
groups: users
gid: 100
uid: 1000

what can i do about this?

greets puchu



-------------------------------------------------------
This SF.Net email is sponsored by Oracle Space Sweepstakes
Want to be the first software developer in space?
Enter now for the Oracle Space Sweepstakes!
http://ads.osdn.com/?ad_id=7412&alloc_id=16344&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
