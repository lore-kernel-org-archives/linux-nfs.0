From: Christian Reis <kiko@async.com.br>
Subject: NFS server hangs
Date: Thu, 24 Apr 2003 23:41:23 -0300
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20030424234123.A28963@blackjesus.async.com.br>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: NFS@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
To: NeilBrown <neilb@cse.unsw.edu.au>
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


We've recently moved our (locking-problem-prone) server to new
ext3 filesystems. To do this, since we run on two-disk RAID-1 arrays, we
removed one of the drives, created the new raid set using a failed-disk
setup, created the new filesystems, and moved data from the original
ones to the new one.

We've been running with a failed-disk for a couple of days in order to
try and wash out any problems we have in the new configuration (since
it makes it much easier to move back to the old array). However, during
this time we're getting our nfsd to hang/deadlock when a lot of I/O
happens - it is reproducible by running from any client a bonnie of 1G
after a short while.

The symptoms are quite clear: the server stops answering to requests,
and a tcpdump shows the clients trying to contact the nfs server and
never getting answers back (they eventually start doing arp lookups).

Killing nfsd and starting it up again clears up the problem. I've pasted
here some logs from turning on debugging on nfsd_debug and rpc_debug:

Apr 24 22:50:47 anthem kernel: -pid- proc flgs status -client- -prog- --rqstp- -timeout -rpcwait -action- --exit--
Apr 24 22:50:47 anthem kernel: 00032 0000 0081 -00110 d14ab4c0 100003 0 00003000 nfs_flushd c0169a80 c0169b80
Apr 24 22:50:47 anthem kernel: 00028 0000 0081 -00110 d7325cc0 100003 0 00003000 nfs_flushd c0169a80 c0169b80
Apr 24 22:50:47 anthem kernel: 00024 0000 0081 -00110 d73259c0 100003 0 00003000 nfs_flushd c0169a80 c0169b80
Apr 24 22:50:47 anthem kernel: 00020 0000 0081 -00110 daa1f0c0 100003 0 00003000 nfs_flushd c0169a80 c0169b80
Apr 24 22:51:00 anthem kernel: RPC:   20 running timer
Apr 24 22:51:00 anthem kernel: RPC: 20 timeout (default timer)
Apr 24 22:51:00 anthem kernel: RPC:   20 __rpc_wake_up_task (now 9246265
inh 0)
Apr 24 22:51:00 anthem kernel: RPC:   20 disabling timer
Apr 24 22:51:00 anthem kernel: RPC:   20 removed from queue c02bcd60
"nfs_flushd"
Apr 24 22:51:00 anthem kernel: RPC:   20 added to queue c02cf954
"schedq"
Apr 24 22:51:00 anthem kernel: RPC:      __rpc_wake_up_task done
Apr 24 22:51:00 anthem kernel: RPC:   24 running timer
Apr 24 22:51:00 anthem kernel: RPC: 24 timeout (default timer)
Apr 24 22:51:00 anthem kernel: RPC:   24 __rpc_wake_up_task (now 9246265
inh 0)
Apr 24 22:51:00 anthem kernel: RPC:   24 disabling timer
Apr 24 22:51:00 anthem kernel: RPC:   24 removed from queue c02bcd60
"nfs_flushd"
Apr 24 22:51:00 anthem kernel: RPC:   24 added to queue c02cf954
"schedq"
Apr 24 22:51:00 anthem kernel: RPC:      __rpc_wake_up_task done
Apr 24 22:51:00 anthem kernel: RPC:   28 running timer

Since I've never seen this sort of problem before on this hardware, I'm
tending to think it is either a problem with ext3 or caused by the use
of a failed-disk RAID-1 array. Has anyone seen anything like this, or
similar symptoms? This is a Debian Woody box, running 2.4.21-pre5. All
mounts use the same options:

anthem:/home    /home   nfs defaults,rw,rsize=8192,wsize=8192,nfsvers=3 0 0

Tips on debugging are also welcome, of course.

Take care,
--
Christian Reis, Senior Engineer, Async Open Source, Brazil.
http://async.com.br/~kiko/ | [+55 16] 261 2331 | NMFL


-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
