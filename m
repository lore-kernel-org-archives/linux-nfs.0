From: Steve Wampler <swampler@noao.edu>
Subject: What might cause:  "NFS: Buggy server - nlink == 0!" message?
Date: Fri, 16 Jan 2004 15:45:42 -0700
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <1074293142.11334.63.camel@weaver.tuc.noao.edu>
Reply-To: swampler@noao.edu
Mime-Version: 1.0
Content-Type: text/plain
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Ahcin-000528-KC
	for nfs@lists.sourceforge.net; Fri, 16 Jan 2004 14:45:45 -0800
Received: from lsstmail.org ([140.252.1.54] helo=noao.edu)
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.30)
	id 1Ahcin-0003NL-DH
	for nfs@lists.sourceforge.net; Fri, 16 Jan 2004 14:45:45 -0800
To: Linux NFS List <nfs@lists.sourceforge.net>
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


We've been noticing that some of our NFS clients aren't catching
changes to NFS-accessed files.  This last time, dmesg
on the client reported:

   NFS: Buggy server - nlink == 0!
   __nfs_fhget: iget failed

What might cause this?  What's the best fix?

The NFS server is a Red Hat system:

   ->uname -a
   Linux friar.tuc.noao.edu 2.4.18-24.8.0smp #1 SMP Fri Jan 31 07:12:12
EST 2003 i686 athlon i386 GNU/Linux
   ->rpm -qa | grep nfs
   nfs-utils-1.0.1-2

Thanks in advance!
Steve

-- 
Steve Wampler -- swampler@noao.edu
The gods that smiled on your birth are now laughing out loud.


-------------------------------------------------------
The SF.Net email is sponsored by EclipseCon 2004
Premiere Conference on Open Tools Development and Integration
See the breadth of Eclipse activity. February 3-5 in Anaheim, CA.
http://www.eclipsecon.org/osdn
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
