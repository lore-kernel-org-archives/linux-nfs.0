From: "dan carpenter" <error27@email.com>
Subject: declaring large variables
Date: Sat, 16 Nov 2002 18:04:20 -0500
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20021116230420.29059.qmail@email.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Cc: smatch-kbugs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from 205-158-62-68.outblaze.com ([205.158.62.68] helo=spf0.us4.outblaze.com)
	by sc8-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 18DBzG-0003Al-00
	for <nfs@lists.sourceforge.net>; Sat, 16 Nov 2002 15:04:26 -0800
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

I have a project smatch.sf.net that checks the kernel for certain types of errors.  My newest code checks that functions do not declare too much data to fit on the kernel's 8kB stack.  These functions both use up 2.5kB (16512b) so they're probably not a problem.  But it might be worth declaring nfsctl_export as a pointer and using kmalloc to set aside memory.

linux-2.5.44/fs/nfsd/nfsctl.c 212 write_export 16512
linux-2.5.44/fs/nfsd/nfsctl.c 222 write_unexport 16512

Regards,
dan carpenter
-- 
_______________________________________________
Sign-up for your own FREE Personalized E-mail at Mail.com
http://www.mail.com/?sr=signup

Single & ready to mingle? lavalife.com:  Where singles click. Free to Search!
http://www.lavalife.com/wp.epl?a=2716



-------------------------------------------------------
This sf.net email is sponsored by: To learn the basics of securing 
your web site with SSL, click here to get a FREE TRIAL of a Thawte 
Server Certificate: http://www.gothawte.com/rd524.html
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
