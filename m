From: Marc Eshel <eshel@almaden.ibm.com>
Subject: NFSv3 blocking locks broken in 2.6.7
Date: Sat, 17 Jul 2004 14:24:05 -0700
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <OF8844A494.BAA47906-ON88256ED4.00751DBF-88256ED4.0075274A@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Return-path: <nfs-admin@lists.sourceforge.net>
To: NFS@lists.sourceforge.net
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





Hi,

There appears to be a problem with blocking locks granted by lockd
(observed on 2.6.7 and some previous versions of 2.6). An NFS client
waiting for a blocking lock unlocks the file incorrectly right after being
granted the lock even though the application still holds the lock; thereby
allowing another NFS client or local fcntl locks to be granted. This
problem will not manifest itself while using two processes from the same
NFS client because of the local locking on the client machine.

The problem can be easily reproduced using two different NFS client
machines and issuing the following sequence of locking calls (assume that
/mnt is the NFS mount point on both NFS clients in the example):

Client 1: fcntl(F_SETLK) /mnt/f1 granted and held
Client 2: fcntl(F_SETLKW) /mnt/f1 blocked
Client 1: fcntl(F_UNLC
Client 1: fcntl(F_UNLCK) /mnt/f1 unlocked on Machine 1; granted on Machine
2
Client 2: After a delay, lock granted and held
Client 1: fcntl(F_SETLK) /mnt/f1 granted (should be DENIED)

The problem also occurs when the first process is executing the fcntl locks
locally.

Thanks, Marc.



-------------------------------------------------------
This SF.Net email is sponsored by BEA Weblogic Workshop
FREE Java Enterprise J2EE developer tools!
Get your free copy of BEA WebLogic Workshop 8.1 today.
http://ads.osdn.com/?ad_id=4721&alloc_id=10040&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
