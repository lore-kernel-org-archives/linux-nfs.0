From: Marc Schmitt <mschmitt@inf.ethz.ch>
Subject: Re: "nfsd Security: //u bad export" is triggered by IRIX
	clients
Date: 22 Jul 2003 17:07:02 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <1058886422.7602.29.camel@ikarus>
References: <1058884809.7602.25.camel@ikarus>
Mime-Version: 1.0
Content-Type: text/plain
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from medoc.inf.ethz.ch ([129.132.178.200])
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 19eyjN-0002lx-00
	for <nfs@lists.sourceforge.net>; Tue, 22 Jul 2003 08:07:09 -0700
Received: from localhost (localhost [127.0.0.1])
	by medoc.inf.ethz.ch (Postfix) with ESMTP id F194D58EE6
	for <nfs@lists.sourceforge.net>; Tue, 22 Jul 2003 17:07:02 +0200 (MEST)
Received: from medoc.inf.ethz.ch ([127.0.0.1])
 by localhost (medoc [127.0.0.1]) (amavisd-new, port 10024) with LMTP
 id 00726-01-4 for <nfs@lists.sourceforge.net>;
 Tue, 22 Jul 2003 17:07:02 +0200 (MEST)
Received: from ikarus (ikarus.inf.ethz.ch [129.132.10.58])
	by medoc.inf.ethz.ch (Postfix) with ESMTP id DF0BC58EC4
	for <nfs@lists.sourceforge.net>; Tue, 22 Jul 2003 17:07:01 +0200 (MEST)
In-Reply-To: <1058884809.7602.25.camel@ikarus>
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

Great, the current NFS HowTo has the solution:

Irix versions up to 6.5.12 have problems mounting file systems exported
from Linux boxes - the mount point "gets lost," e.g.,

	# mount linux:/disk1 /mnt
	# cd /mnt/xyz/abc
	# pwd
	/xyz/abc
   

This is known IRIX bug (SGI bug 815265 - IRIX not liking file handles of
less than 32 bytes), which is fixed in IRIX 6.5.13. If it is not
possible to upgrade to IRIX 6.5.13, then the unofficial workaround is to
force the Linux nfsd to always use 32 byte file handles.

A number of patches exist - see:

    http://www.geocrawler.com/archives/3/789/2001/8/50/6371896/
    http://oss.sgi.com/projects/xfs/mail_archive/0110/msg00006.html 


Sorry for the unnecessary initial post.

Regards,
    Marc



-------------------------------------------------------
This SF.net email is sponsored by: VM Ware
With VMware you can run multiple operating systems on a single machine.
WITHOUT REBOOTING! Mix Linux / Windows / Novell virtual machines at the
same time. Free trial click here: http://www.vmware.com/wl/offer/345/0
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
