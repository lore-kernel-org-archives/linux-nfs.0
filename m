From: Neil Brown <neilb@cse.unsw.edu.au>
Subject: Introducing 19 kNFSd patches for 2.4.20-pre
Date: Tue, 6 Aug 2002 20:06:57 +1000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <15695.40897.185974.865980@notabene.cse.unsw.edu.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from tone.orchestra.cse.unsw.edu.au ([129.94.242.28])
	by usw-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17c1Ei-00006F-00
	for <nfs@lists.sourceforge.net>; Tue, 06 Aug 2002 03:06:44 -0700
Received: From notabene ([129.94.242.45] == bartok.orchestra.cse.unsw.EDU.AU)
	(for <marcelo@conectiva.com.br>) (for <nfs@lists.sourceforge.net>) By
	tone With Smtp ; Tue, 6 Aug 2002 20:06:17 +1000
To: Marcelo Tosatti <marcelo@conectiva.com.br>
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
List-Archive: <http://www.geocrawler.com/redir-sf.php3?list=nfs>


Marcelo,
 I am about to send you 19 patches for knfsd in 2.4.20-pre.
A brief list is below and people on nfs@lists.sourceforge.net can get them from
   http://www.cse.unsw.edu.au/~neilb/patches/linux-stable/
if interested.

These have all (except 19) been in -ac for a while, and are in 2.5, and I have
been using them in production for quite a while.
The main enhancements offered are:

  'fsid=' export option so that filehandles can be independant of 
        the device number of device holding the filesystem.
  removal of BKL - replaces by a semaphore and a few spinlocks.
  TCP/IP support (still marked experimental)

I am quite confident that these patches are reliable and suitable for
2.4.20.

NeilBrown


1     patch-D-NfsdLookupTidy
            Tidy up code in nfsd_lookup 
2     patch-E-NfsdInit
            Tidyup init/exit fof nfsd module 
3     patch-F-NfsdFsid
            Support fsid= export option to be device number independent 
4     patch-G-NfsdLocksExplock
            Change export table lock to (SMP safe) rwsemaphore 
5     patch-H-NfsdLocksCachelock
            Lock reply cache with SMP safety. 
6     patch-I-NfsdLocksNfssvc
            Tidy up locking in nfssvc - preparing for BKL removal 
7     patch-J-NfsdLocksRename
            Protect rename and related operations by kernel_lock 
8     patch-K-NfsdFhLock
            Protect file handle lookup by kernel lock 
9     patch-L-NfsdLocksRacache
            Protect read-ahead cache with SMP safe locking 
10    patch-M-NfsdBKLgone
            Remove last unneeded bit of BKL from knfsd 
11    patch-N-RpcLists
            Change sunrpc to use more list.h lists 
12    patch-O-RpcInit
            Get sunrpc to use module_init properly 
13    patch-P-RpcSvcLocking
            Tidy up SMP locking for svc_sock 
14    patch-Q-RpcTcpCloseBad
            Detect and close tcp connections that we cannot work with. 
15    patch-R-RpcTcpCloseIdle
            Close idle rpc/tcp sockets 
16    patch-S-RpcTcpReserve
            Make sure there is alway adequate sndbuf space for replies. 
17    patch-T-RpcSvcTcpLimit
            Limit number of active tcp connections to an RPC service 
18    patch-U-NfsdTcpEnable
            Enable NFS over TCP via config option 
19    patch-c-NfsfhErrFix
            Correct some error codes reutrned in nfsfh.c 


-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
