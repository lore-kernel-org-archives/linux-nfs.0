From: Stephen Beahm <stephenbeahm@adelphia.net>
Subject: NFS write speed and file permissions (2.6.0-test10 kernel)
Date: Mon, 24 Nov 2003 03:58:17 -0500
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20031124085817.GA1680@pc1.sbeahm.net>
Mime-Version: 1.0
Content-Type: text/plain; Format=Flowed; DelSp=Yes; charset=ISO-8859-1
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 1AOCY5-0000WE-00
	for <nfs@lists.sourceforge.net>; Mon, 24 Nov 2003 00:58:25 -0800
Received: from mta13.mail.adelphia.net ([68.168.78.44] helo=mta13.adelphia.net)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.24)
	id 1AOCY4-00058f-Uh
	for nfs@lists.sourceforge.net; Mon, 24 Nov 2003 00:58:25 -0800
Received: from pc1 ([67.23.51.126]) by mta13.adelphia.net
          (InterMail vM.5.01.06.05 201-253-122-130-105-20030824) with ESMTP
          id <20031124085818.DQJH4878.mta13.adelphia.net@pc1>
          for <nfs@lists.sourceforge.net>; Mon, 24 Nov 2003 03:58:18 -0500
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

Hello,

I am seeing huge speed differences in NFS file writes based on file
permissions.

create a test file:
dd if=/dev/zero of=testfile bs=4k count=65535

chmod 664 testfile
time cp testfile /mnt/gwpub
real    0m36.818s
user    0m0.018s
sys     0m2.574s

chmod 755 testfile
time cp testfile /mnt/gwpub
real    4m6.056s
user    0m0.054s
sys     0m5.835s


I can consistently reproduce this problem with a 2.6.0-test9 or 2.6.0- 
test10 kernel on the client side. There does not seem to be any  
problems here with a 2.4.22 kernel. Reading does not seem to be  
affected, only writes. Neither export nor mount options make a  
difference. If the test is performed as root, all is fast.

I am using NFSv3 and nfs-utils-1.06.

This is only an observation and not mean anything:
using a 2.4.22 client, open() does not pass any mode,
but a 2.6.0-testX client does this: open("/mnt/gwpub/testfile",  
O_WRONLY|O_CREAT|O_LARGEFILE, 0100755)


Thanks,


-- 
Stephen Beahm
mailto:stephenbeahm@adelphia.net



-------------------------------------------------------
This SF.net email is sponsored by: SF.net Giveback Program.
Does SourceForge.net help you be more productive?  Does it
help you create better code?  SHARE THE LOVE, and help us help
YOU!  Click Here: http://sourceforge.net/donate/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
