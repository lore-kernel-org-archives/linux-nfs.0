From: squale@vaala.mine.nu
Subject: Cache on NFS
Date: Thu, 20 Apr 2006 09:41:19 +0200 (CEST)
Message-ID: <17088.195.6.25.114.1145518879.squirrel@vaala.mine.nu>
Mime-Version: 1.0
Content-Type: text/plain;charset=iso-8859-1
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1FWTnI-0007Hi-QZ
	for nfs@lists.sourceforge.net; Thu, 20 Apr 2006 00:41:40 -0700
Received: from vaala.mine.nu ([82.225.110.118])
	by mail.sourceforge.net with esmtp (Exim 4.44)
	id 1FWTnH-000557-Bp
	for nfs@lists.sourceforge.net; Thu, 20 Apr 2006 00:41:40 -0700
Received: from localhost (localhost [127.0.0.1])
	by vaala.mine.nu (Postfix) with ESMTP id B6EA930844
	for <nfs@lists.sourceforge.net>; Thu, 20 Apr 2006 09:41:22 +0200 (CEST)
Received: from vaala.mine.nu ([127.0.0.1])
	by localhost (zion [127.0.0.1]) (amavisd-new, port 10024) with ESMTP
	id 07665-03 for <nfs@lists.sourceforge.net>;
	Thu, 20 Apr 2006 09:41:19 +0200 (CEST)
Received: from vaala.mine.nu (zion.groove.org [192.168.1.1])
	by vaala.mine.nu (Postfix) with ESMTP id 8166130842
	for <nfs@lists.sourceforge.net>; Thu, 20 Apr 2006 09:41:19 +0200 (CEST)
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

hi,

i d like to get you experience on the following problem.

I want to access a NFS server but also to have a cache of all the files t=
o
access those if (and only if) the NFS server is unreachable.

What would better work for that case ?

Thanks,



-------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
