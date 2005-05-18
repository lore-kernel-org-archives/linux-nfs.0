From: "Henrik Schmiediche" <henrik@stat.tamu.edu>
Subject: Extremely high load on NFS clients wen the NFS server is down...
Date: Wed, 18 May 2005 09:28:38 -0500
Message-ID: <200505181429.j4IET8GK023074@s7.stat.tamu.edu>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DYPXy-0002Th-Ll
	for nfs@lists.sourceforge.net; Wed, 18 May 2005 07:29:18 -0700
Received: from s7.stat.tamu.edu ([165.91.117.61])
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.41)
	id 1DYPXx-0005Rb-64
	for nfs@lists.sourceforge.net; Wed, 18 May 2005 07:29:18 -0700
Received: from luthien (luthien [165.91.114.154])
	by s7.stat.tamu.edu (8.12.11/8.12.11) with ESMTP id j4IET8GK023074
	(version=TLSv1/SSLv3 cipher=RC4-MD5 bits=128 verify=NO)
	for <nfs@lists.sourceforge.net>; Wed, 18 May 2005 09:29:08 -0500
To: <nfs@lists.sourceforge.net>
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
I have two Redhat AS3 servers. One of them (among other things) serves NFS
file systems to my other systems including to the other server. When my NFS
file server goes down or is restarted the load on the other AS3 server
increases to the point it is completely useless (it goes to 50+ in a minute
or two). I never observed this behavior when I was serving NFS file systems
using a Solaris system.

Has anyone observed this phenomenon?  Any solution to it?

Sincerely,

   - Henrik




-------------------------------------------------------
This SF.Net email is sponsored by Oracle Space Sweepstakes
Want to be the first software developer in space?
Enter now for the Oracle Space Sweepstakes!
http://ads.osdn.com/?ad_id=7412&alloc_id=16344&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
