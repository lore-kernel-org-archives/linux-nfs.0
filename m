From: Minerva Calderon <mc@srl.caltech.edu>
Subject: Solaris NFS server and Linux Client.
Date: Mon, 14 Jun 2004 16:47:10 -0700 (PDT)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <200406142347.i5ENlAMD005798@lodur.srl.caltech.edu>
Reply-To: Minerva Calderon <mc@srl.caltech.edu>
Mime-Version: 1.0
Content-Type: TEXT/plain; charset=us-ascii
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Ba1AV-0002Sc-20
	for nfs@lists.sourceforge.net; Mon, 14 Jun 2004 16:47:11 -0700
Received: from lodur.srl.caltech.edu ([131.215.120.1])
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.30)
	id 1Ba1AU-0008Oy-Q4
	for nfs@lists.sourceforge.net; Mon, 14 Jun 2004 16:47:10 -0700
Received: from lodur.srl.caltech.edu (lodur.srl.caltech.edu [131.215.120.1])
	by lodur.srl.caltech.edu (8.12.9/8.12.9) with SMTP id i5ENlAMD005798
	for <nfs@lists.sourceforge.net>; Mon, 14 Jun 2004 16:47:10 -0700 (PDT)
To: nfs@lists.sourceforge.net
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




I have a 3.0TB partition on a Solaris 9.0 server which is NFS mounted on
a Linux 7.2 client. When processing on the linux clients old directories
on these partition dissapear.  The directories can be listed on the server.
When the job is reran on the client after failure the directories appear
again.

Any comments or suggestions will be appreciated.

Thanks,

Minerva

Linux: 7.2  Filesystem type ext3
Solaris 9.0  Filesystem ufs



-------------------------------------------------------
This SF.Net email is sponsored by The 2004 JavaOne(SM) Conference
Learn from the experts at JavaOne(SM), Sun's Worldwide Java Developer
Conference, June 28 - July 1 at the Moscone Center in San Francisco, CA
REGISTER AND SAVE! http://java.sun.com/javaone/sf Priority Code NWMGYKND
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
