From: Guochun Shi <gshi@ncsa.uiuc.edu>
Subject: NFS umount problem in server
Date: Tue, 18 May 2004 19:30:48 -0500
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <5.1.0.14.2.20040518173341.0453ae58@pop.ncsa.uiuc.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BQEyu-0004ae-Sk
	for nfs@lists.sourceforge.net; Tue, 18 May 2004 17:30:48 -0700
Received: from mail.ncsa.uiuc.edu ([141.142.2.28])
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.30)
	id 1BQEyu-0007aJ-GE
	for nfs@lists.sourceforge.net; Tue, 18 May 2004 17:30:48 -0700
Received: from gship4.ncsa.uiuc.edu (gship4.ncsa.uiuc.edu [141.142.98.127])
	by mail.ncsa.uiuc.edu (8.11.7/8.11.7) with ESMTP id i4J0Ujx01744
	for <nfs@lists.sourceforge.net>; Tue, 18 May 2004 19:30:45 -0500
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

hello,  

I met a problem in NFS server umount operation. I have a NFS server and a client running an application. 
The client is running  Connectathon lock test (http://www.connectathon.org/nfstests.html)
While the client is running the test, the server stops nfs, nfslock. Then the server kills processes associated 
with the  exported directory(fuser -mk <the mount point>) , then trying to umount the device. It failed returning "the device is busy"

I found when the lock application is running, mnt->mnt_count is increased to 4. But after
nfs/nfslock is stoped, mnt->mnt_count is only decreased to 3 instead of 2, which causes the umount failure. 
IMHO ';nfs/nfslock stop' should cleanup everything or it is a bug. 

I have tried  kernel 2.4.20, 2.4.26, 2.6.5-1.339, with nfs-utils-1.0.6. Same results.

anyone met this problem before?

thanks
-Guochun








-------------------------------------------------------
This SF.Net email is sponsored by: SourceForge.net Broadband
Sign-up now for SourceForge Broadband and get the fastest
6.0/768 connection for only $19.95/mo for the first 3 months!
http://ads.osdn.com/?ad_id=2562&alloc_id=6184&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
