From: Gerald Stieglbauer <gstiegl@cosy.sbg.ac.at>
Subject: Wrong file size (large file problem)
Date: Fri, 13 Feb 2004 14:21:48 +0100 (CET)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <Pine.LNX.4.44.0402131420000.13346-100000@kakadu.cosy.sbg.ac.at>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1ArdID-0007H2-Co
	for nfs@lists.sourceforge.net; Fri, 13 Feb 2004 05:23:41 -0800
Received: from dobermann.cosy.sbg.ac.at ([141.201.2.56])
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.30)
	id 1ArdDZ-0003pU-Bx
	for nfs@lists.sourceforge.net; Fri, 13 Feb 2004 05:18:53 -0800
Received: from hydra.cosy.sbg.ac.at (kakadu.cosy.sbg.ac.at [141.201.151.33])
	by dobermann.cosy.sbg.ac.at (Postfix) with ESMTP id 8FF74F8FED
	for <nfs@lists.sourceforge.net>; Fri, 13 Feb 2004 14:21:48 +0100 (CET)
Received: from localhost (localhost [127.0.0.1])
	by hydra.cosy.sbg.ac.at (Postfix) with ESMTP id 2F08C23490
	for <nfs@lists.sourceforge.net>; Fri, 13 Feb 2004 14:21:48 +0100 (CET)
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

Hello,

I have some strange problems with large files on Client side. In the
concrete case, a file with a size of 4504526848 Bytes lies on my server (kernel
2.4.24). If I mount the directory with this file via nfs, the client
(kernel 2.4.24) informs me that the file size is only 209559552 Bytes. For
"debugging" I copied the file and watch the grow of the file size during
the copy job on both machines. Nothing suspicious happens until the file size
reached a level of about 4300000000 Bytes. The the client began counting
from 0 Bytes up to the 209559552; some form of overflow. On the server
side, nothing went wrong.
On a previous posting (http://sourceforge.net/mailarchive/
forum.php?thread_id=3874012&forum_id=4930) Vincent ROQUETA reports
problems with files that exceeds 4294967294 Bytes. Is there may be the same
underlying problem? BTW: 4294967294 + 209559552 = 4504526846 -> this is
very, very close to 4504526848; so can this be only luck?

Thanks!

cu,
Gerald.



-------------------------------------------------------
SF.Net is sponsored by: Speed Start Your Linux Apps Now.
Build and deploy apps & Web services for Linux with
a free DVD software kit from IBM. Click Now!
http://ads.osdn.com/?ad_id=1356&alloc_id=3438&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
