From: David Shirley <dave@cs.curtin.edu.au>
Subject: Problem with permissions
Date: Thu, 18 Apr 2002 11:58:32 +0800
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <5.1.0.14.2.20020418115542.058a25a0@pop.cs.curtin.edu.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"; format=flowed
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from smtp.cs.curtin.edu.au ([134.7.1.4])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 16y3cX-00076z-00
	for <nfs@lists.sourceforge.net>; Wed, 17 Apr 2002 21:34:09 -0700
Received: from dave.cs.curtin.edu.au ([134.7.1.100])
	by smtp.cs.curtin.edu.au with esmtp (Exim 3.34 #2)
	id 16y36s-0005bL-00
	for nfs@lists.sourceforge.net; Thu, 18 Apr 2002 12:01:26 +0800
To: nfs@lists.sourceforge.net
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
List-Archive: <http://www.geocrawler.com/redir-sf.php3?list=nfs>

Hi All,

We have a NFSV3 server (UDP) and NFSV3 clients. Now
when the permissions on a file are say rwx-----x
ie world executable, then none owners and non group
members can read the file as well as execute it?

This shouldn't be the case?

Are there any switches or anything on the server that
I need to configure?

Cheers
Dave


/-----------------------------------
David Shirley
System's Administrator
Computer Science - Curtin University
(08) 9266 2986
-----------------------------------/


_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
