From: Genco YILMAZ <gyilmaz@beriltech.com>
Subject: 230GB partition mount problem
Date: Fri, 31 Mar 2006 11:48:39 +0300
Message-ID: <442CECE7.1040806@beriltech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-9; format=flowed
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1FPFJB-0002tP-6F
	for nfs@lists.sourceforge.net; Fri, 31 Mar 2006 00:48:41 -0800
Received: from mail.posta.tc ([85.111.0.146] helo=mira.yonlendir.net)
	by mail.sourceforge.net with esmtp (Exim 4.44)
	id 1FPFJA-0002zQ-Vc
	for nfs@lists.sourceforge.net; Fri, 31 Mar 2006 00:48:41 -0800
Received: from localhost (localhost [127.0.0.1])
	by mira.yonlendir.net (Postfix) with ESMTP id BC35321B598
	for <nfs@lists.sourceforge.net>; Fri, 31 Mar 2006 11:48:37 +0300 (EEST)
Received: from mira.yonlendir.net ([127.0.0.1])
 by localhost (mira.yonlendir.net [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id 26723-01 for <nfs@lists.sourceforge.net>;
 Fri, 31 Mar 2006 11:48:37 +0300 (EEST)
Received: from [192.168.1.3] (xdfk.beriltech.com [81.214.141.112])
	by mira.yonlendir.net (Postfix) with ESMTP id 353DA21B4D8
	for <nfs@lists.sourceforge.net>; Fri, 31 Mar 2006 11:48:37 +0300 (EEST)
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

Hello,
   I have mounted a partition from NFS server. The partitions on the 
server is

/var/images/apachelogs
/var/images/www/uploads

/var/images is a directory on the / filesystem
apachelogs(ext3) is a 230GB partition with block size 1024KB and inode 
count 30519296
uploads is a reiserfs file system.

My problem is :
       I mount /var/images directory to the client machine through NFS 
server and I can see uploads folder but even if I have given all the 
permissions on the source folder I cannot see any subdirectory in the 
apachelogs folder as if there is nothing in it.

My mount options: 
noauto,nolock,nosuid,noexec,rw,hard,intr,rsize=1024,wsize=1024 0 0
Server parameters exportfs: (rw,sync,no_subtree_check,no_root_squash)

I dont understand why one partition is reachable but the other one is 
not. I have search in FAQ whether there is any inode limitations or not 
but I havent seen any clue.

Any help is really appreciated.

Thanks in advance.







-------------------------------------------------------
This SF.Net email is sponsored by xPML, a groundbreaking scripting language
that extends applications into web and mobile media. Attend the live webcast
and join the prime developer group breaking into this new coding territory!
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=110944&bid=241720&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
