From: Guochun Shi <gshi@ncsa.uiuc.edu>
Subject: failover-NFS server problem
Date: Mon, 19 Apr 2004 13:14:24 -0500
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <5.1.0.14.2.20040419123002.00acb6a8@pop.ncsa.uiuc.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: alan Robertson <alanr@unix.sh>, bruce.allan@us.ibm.com
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BFdHo-0004DK-CM
	for nfs@lists.sourceforge.net; Mon, 19 Apr 2004 11:14:28 -0700
Received: from mail.ncsa.uiuc.edu ([141.142.2.28])
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.30)
	id 1BFdHo-0003xu-1o
	for nfs@lists.sourceforge.net; Mon, 19 Apr 2004 11:14:28 -0700
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

hi, all

I ran into some problem in running Connectathon with NFS. The scenario I want to test is if NFS works fine in case of the server is failed back and forth (linuxHA controls that. Linux-Ha is in www.linux-ha.org ). The following is my setup:

1. Machine A and Machine B are servers, there is one and only server active any time. The active machine has a floating IP as the service IP.
2. Machine C is the client. It mounts a directory from the floating IP
3. Machine A and Machine B have a fiber channel share disk. The exported filesystem resides in shared disk. On both machines, 
/var/lib/nfs is a symbolic link to a directory in the shared disk.

all machines are running Redhat 9, kernel 2.4.26, with nfs-utils-1.0.1-2.9

The server will switch between A and B, in each switching:
the original server will stop nfs, stop nfslock, umount from the shared disk and give out the floating ip, 
the backup server will grab the floaing ip, mount the shared disk, start nfslock and start nfs


in testing, I ran the locking test in Connectathon in the client site while servers are switching back and forth. 
Usually I will get an error in the 7th or 8th pass,  the error code is 37- no lock record available. There are several cases
for this failure for now (two processes--parent and child process-- are competing for the same lock)

1. the child gets the lock, then the child process is killed, then the parent tries to lock the file, it shall return success,
however it return an error with errno=37
2. the child locks the file, the it unlocks; the parent then tries to lock the file, it shall return success,
however it return an error with errno=37
3. this is similar to case 2, the parent locks the file, the it unlocks; the child then tries to lock the file, it shall return success,
however it return an error with errno=37

By the way, running bonnie++  instead of Connectathon in the above scenario finishes successfully, which is good :-)

any comment/suggestion is welcome. 
Thanks
-Guochun



-------------------------------------------------------
This SF.Net email is sponsored by: IBM Linux Tutorials
Free Linux tutorial presented by Daniel Robbins, President and CEO of
GenToo technologies. Learn everything from fundamentals to system
administration.http://ads.osdn.com/?ad_id=1470&alloc_id=3638&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
