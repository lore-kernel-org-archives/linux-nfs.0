From: David Dougall <davidd@et.byu.edu>
Subject: NFS locking question
Date: Mon, 24 May 2004 11:15:56 -0600 (MDT)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <Pine.LNX.4.58.0405241106040.2340@lewis.et.byu.edu>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BSJ3Y-0003wX-7E
	for nfs@lists.sourceforge.net; Mon, 24 May 2004 10:16:08 -0700
Received: from postal1.et.byu.edu ([128.187.122.131])
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.30)
	id 1BSJ3X-0003oh-PT
	for nfs@lists.sourceforge.net; Mon, 24 May 2004 10:16:07 -0700
Received: from lewis.et.byu.edu (lewis.et.byu.edu [128.187.112.50])
	by postal1.et.byu.edu (8.12.10/8.12.10) with ESMTP id i4OHFuoq000610
	for <nfs@lists.sourceforge.net>; Mon, 24 May 2004 11:15:56 -0600
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

I am having a somewhat weird problem with nfs locking.  My servers are
linux version 2.4.21.  The server filesystems are xfs.  My clients are
HPUX 11i and linux(tested with 2.4.21 and 2.4.25 stock kernels).
When I try to use fcntl, the HPUX client will always fail to lock unless
the file is world readable.  Even if the user is the owner with rwx, the
lock will fail.  As soon as I chmod a+r on the file, the lock will
succeed.
On linux clients, I have not been able to get the file to lock at all.
The fcntl returns EBADF which implies I passed a bad file descriptor, but
I have verified that it is a valid file descriptor.
Are there any issues with the linux NFS locking code that I am obviously
overlooking?  I know in the past there was some discussion about some
locking techniques that were supported or not supported.  Am I facing one
of these?
Thanks.
--David Dougall



-------------------------------------------------------
This SF.Net email is sponsored by: Oracle 10g
Get certified on the hottest thing ever to hit the market... Oracle 10g. 
Take an Oracle 10g class now, and we'll give you the exam FREE.
http://ads.osdn.com/?ad_id=3149&alloc_id=8166&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
