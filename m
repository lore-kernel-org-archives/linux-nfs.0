From: "Robert Merrill" <grievre@gmail.com>
Subject: BUG_ON being triggered for readdir of +r-x
Date: Thu, 20 Apr 2006 10:35:58 -0700
Message-ID: <b3be17f30604201035s6e4c4977wfa804f367c64657e@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1FWd4T-0002Ye-QG
	for nfs@lists.sourceforge.net; Thu, 20 Apr 2006 10:36:01 -0700
Received: from wproxy.gmail.com ([64.233.184.226])
	by mail.sourceforge.net with esmtp (Exim 4.44)
	id 1FWd4S-0008TS-Jc
	for nfs@lists.sourceforge.net; Thu, 20 Apr 2006 10:36:01 -0700
Received: by wproxy.gmail.com with SMTP id 70so169837wra
        for <nfs@lists.sourceforge.net>; Thu, 20 Apr 2006 10:35:58 -0700 (PDT)
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

Our machine nfs-mounts its /home from a FreeBSD machine (this may be
an NFS v3 mount, don't know how to check), and we've found that if a
directory under /home is readable but not execable, trying to ls it
(or use readdir() or getdents() on it at all) causes the kernel to
give a BUG_ON in __copy_from_user_ll for invalid operand.

Is this known?


-------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
