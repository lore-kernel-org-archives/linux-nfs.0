From: Christian Reis <kiko@async.com.br>
Subject: Stale fcntl lock never released
Date: Mon, 23 Jun 2003 19:14:05 -0300
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20030623221405.GA4320@async.com.br>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Guilherme Salgado <salgado@async.com.br>
Return-path: <nfs-admin@lists.sourceforge.net>
To: NFS@lists.sourceforge.net
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


Just saw this from one of the diskless boxes on our system (clients
using vanilla 2.4.21, server running 2.4.20-rc3). The client was running
mutt and was editing a message when it hung. We shut down the box and
started another one up, but when the user tried to read his mail, mutt
was hanging upon fcntl(); strace shows it was returning Resource
temporarily unavailable (ENOLCK IIRC). 

On the server side, we have:

    kiko@anthem:~$ cat /proc/locks  | grep 09:06
    1: POSIX  ADVISORY  WRITE 11771 09:06:60316 0 EOF d0d51300 c02d1048
    d0d51424 00000000 d0d5130c
    2: POSIX  ADVISORY  WRITE 11752 09:06:60311 0 EOF d0d51420 d0d51304
    f7c367e4 00000000 d0d5142c
    4: POSIX  ADVISORY  WRITE 10560 09:06:60312 0 EOF f7c36840 f7c367e4
    f7c36f64 00000000 f7c3684c
    5: POSIX  ADVISORY  WRITE 599 09:06:30193 0 EOF f7c36f60 f7c36844
    f7c36964 00000000 f7c36eac
    5: -> POSIX  ADVISORY  WRITE 10569 09:06:30193 191252 EOF f7c36ea0
    f7c36604 c02d1050 f7c36f60 f7c3660c
    5: -> POSIX  ADVISORY  WRITE 11787 09:06:30193 191252 EOF f7c36600
    c02d1050 f7c36ea4 f7c36f60 f7c36f6c

(All these locks were held only by the crashed workstation)

Client mount options are:

    anthem:/var/spool/mail on /var/mail type nfs 
    (rw,sync,v3,rsize=8192,wsize=8192,acregmin=0,acregmax=0,
     acdirmin=0,acdirmax=0,hard,udp,noac,lock,addr=anthem)

Restarting the nfs service frees the locks, but shouldn't it be done
automatically? I'm not sure if it's a case of the server not clearing
the lock, or the client not tickling the server into it.. any ideas?

(Trond, do any of the lockd patches in
http://www.fys.uio.no/~trondmy/src/2.4.21/ fix something like this?)

Take care,
--
Christian Reis, Senior Engineer, Async Open Source, Brazil.
http://async.com.br/~kiko/ | [+55 16] 261 2331 | NMFL


-------------------------------------------------------
This SF.Net email is sponsored by: INetU
Attention Web Developers & Consultants: Become An INetU Hosting Partner.
Refer Dedicated Servers. We Manage Them. You Get 10% Monthly Commission!
INetU Dedicated Managed Hosting http://www.inetu.net/partner/index.php
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
