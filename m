From: Rosario Turrisi <turrisi@pd.infn.it>
Subject: action "debugfs-like" through nfs?
Date: Wed, 23 Jul 2003 15:10:03 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <3F1E892B.8020508@pd.infn.it>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from is01.lnl.infn.it ([192.135.30.245])
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 19fJNj-00054z-00
	for <nfs@lists.sourceforge.net>; Wed, 23 Jul 2003 06:10:12 -0700
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

Hi,
I have a fileserver from Raidtec which uses ext2 filesystems.
Due to a double (!!!) disk failure, I had the strange behaviour that
a directory is seen as a whole file, with strange attributes,
like "?r--r-sr-T" and changed owner/group.
I believe that an operation like "debugfs" could fix the problem,
but it cannot be done (it seems) on an nfs-mounted filesystem
(I cannot enter the fileserver system as it is "raidtec-copyrighted").
Any suggestion very very welcome.
Cheers,
       Rosario



-------------------------------------------------------
This SF.net email is sponsored by: VM Ware
With VMware you can run multiple operating systems on a single machine.
WITHOUT REBOOTING! Mix Linux / Windows / Novell virtual machines at the
same time. Free trial click here: http://www.vmware.com/wl/offer/345/0
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
