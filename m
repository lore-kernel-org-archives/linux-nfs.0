From: Andrew Schretter <schrett@math.duke.edu>
Subject: TCP locking problems
Date: Mon, 24 Feb 2003 12:20:36 -0500
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <200302241720.h1OHKat05293@roma.math.duke.edu>
Mime-Version: 1.0
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from augustus.math.duke.edu ([152.3.25.8] helo=math.duke.edu)
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 18nMHT-00035V-00
	for <nfs@lists.sourceforge.net>; Mon, 24 Feb 2003 09:20:43 -0800
Received: from roma.math.duke.edu (roma [152.3.25.13])
	by math.duke.edu (8.11.6/8.11.6) with ESMTP id h1OHKa213789
	for <nfs@lists.sourceforge.net>; Mon, 24 Feb 2003 12:20:36 -0500
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
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

Trond,
   Something changed after your 2.4.19-NFS-ALL patch that seems
to have broken locking in some specific instances over TCP NFS
mounts.

Sorry I can't get you some code that demonstrates the exact problem,
but I'll try to narrow it down as best I can, maybe its an obvious
problem.

I have a mail program that is reading a mailbox over a TCP mounted
NFS share.  Under 2.4.19 with the NFS_ALL patch, everything works fine.
Under any newer kernel (2.4.20 and 2.4.21pre) with the corresponding
NFS_ALL patch, checking for new mail quickly (i.e. repeatedly checking
for new mail) while mail is being delivered via sendmail causes file
corruption.  Switching back to UDP mounts works fine on these kernels,
but TCP is consistently broken.  

I'm assuming since this is a TCP only problem that it must have cropped
up in your patches, but if I'm off base here, let me know.

Thanks,
Andrew Schretter
Systems Programmer, Duke University
Dept. of Mathematics (919) 660-2866







-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
