From: ctierney@hypermall.net
Subject: Follow-up on NFS mount/umount problem
Date: Tue, 21 Jan 2003 17:19:58 GMT
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <E18b246-0003qt-00@mail2.hypermall.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from mail.hypermall.net
	([216.241.37.118] helo=mail2.hypermall.com ident=exim)
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 18b247-0000sV-00
	for <nfs@lists.sourceforge.net>; Tue, 21 Jan 2003 09:19:59 -0800
Received: from dialup by mail2.hypermall.com with local (Exim 3.36 #1)
	id 18b246-0003qt-00
	for nfs@lists.sourceforge.net; Tue, 21 Jan 2003 10:19:58 -0700
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


Last week I reported a problem that I was having after upgrading to Redhat
8.0 and linux-2.4.20 (+ Trond's patches).  If I tried to touch a NFS
filesystem by all nodes simultaneously (768 nodes) I would get many
failures.
I am using autofs to mount the filesystems.

My old software, linux-2.4.14 and Redhat 7.1 did not have this problem.
I could repetitively umount the filesystem from all nodes, and then access
all of the filesystems again an all nodes would correctly mount the
filesystem.

I determine that the problem is with nfs-utils.  Using the latest
nfs-utils,
1.0.1, there are problems when lots of mounts are attempted simultaneously.
I do not have this problem when I use 0.3.1.

I rebuilt nfs-utils from source for 0.3.1 and 1.0.1 and still have the
problem with version 1.0.1 (versus the Redhat nfs-utils-1.0.1 package).

Is anyone aware of any timing changes that might have been introduced to
1.0.1 that could change the behavior of mountd? 

Craig




-------------------------------------------------------
This SF.net email is sponsored by: Scholarships for Techies!
Can't afford IT training? All 2003 ictp students receive scholarships.
Get hands-on training in Microsoft, Cisco, Sun, Linux/UNIX, and more.
www.ictp.com/training/sourceforge.asp
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
