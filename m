From: Gavin Hamill <gdh@acentral.co.uk>
Subject: lockd / statd fun (sorry)
Date: Fri, 23 Apr 2004 11:37:29 +0100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <200404231137.29216.gdh@acentral.co.uk>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BGy3p-00080A-JA
	for nfs@lists.sourceforge.net; Fri, 23 Apr 2004 03:37:33 -0700
Received: from pop.nation-net.com
	([194.200.209.13] helo=pop.walshsimmons.co.uk ident=foobar)
	by sc8-sf-mx2.sourceforge.net with smtp (Exim 4.30)
	id 1BGy3o-0006xY-VR
	for nfs@lists.sourceforge.net; Fri, 23 Apr 2004 03:37:33 -0700
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

Hullo,

I'm afraid I have to dredge up old ground here...

I'm running about 30 diskless workstations PXE-booting to an NFS-root and 
NFS-homedir with NIS logins, and the workstations are regularly getting the 
familiar

Apr 23 11:17:18 10.0.0.13 kernel: nsm_mon_unmon: rpc failed, status=-13
Apr 23 11:17:18 10.0.0.13 kernel: lockd: cannot monitor 10.0.0.253
Apr 23 11:17:18 10.0.0.13 kernel: lockd: failed to monitor 10.0.0.253
Apr 23 11:17:18 10.0.0.13 kernel: nsm_mon_unmon: rpc failed, status=-13
Apr 23 11:17:18 10.0.0.13 kernel: lockd: cannot monitor 10.0.0.253

kernel messages. Now, I've read as much as I can on the topic, and I have made 
sure that both statd and lockd are running on both the client and the server.

The machines have generally worked well, but OpenOffice.org's setup seems to 
require locking, and the messages have increasingly irritated me, so I need 
to turn to the oracles on such matters :)

I'm using kernel-mode NFS server on both the physical server and the 
workstations... On the server, I see 

10714 ?        S      0:00 /sbin/rpc.statd
10733 ?        SW     0:00 [lockd]
10734 ?        SW     0:00  \_ [rpciod]

and on the clients I see the same (from memory - I can't access them via SSH 
from here). Clients are using a 2.4.22 kernel and the server is on 2.4.24.

I checked the manpage for statd, and was interested by the /var/lib/nfs/sm 
directory - on the server, this directory is completely empty, 
and /var/lib/nfs/state contains only 4 bytes: 001d 0000  - does this sound 
normal?

/etc/hosts.allow was always blank , but today I tried the advice I found in 
another mailing list posting, to add 

statd: 10.0.0.

I then restarted nfs-common (rpc.statd) and nfs-kernel-server (rpc.nfsd and 
rpc.mountd) with logs thusly:

Apr 23 11:06:26 10.0.0.9 kernel: nsm_mon_unmon: rpc failed, status=-13
Apr 23 11:06:26 10.0.0.9 kernel: lockd: cannot monitor 10.0.0.253
Apr 23 11:06:26 10.0.0.9 kernel: lockd: failed to monitor 10.0.0.253
Apr 23 11:06:40 fon kernel: nfsd: last server has exited
Apr 23 11:06:40 fon kernel: nfsd: unexporting all filesystems
Apr 23 11:06:42 10.0.0.24 kernel: nfs: server 10.0.0.253 not responding, still 
trying
Apr 23 11:06:43 10.0.0.19 kernel: nfs: server 10.0.0.253 not responding, still 
trying
Apr 23 11:06:43 10.0.0.9 kernel: nfs: server 10.0.0.253 not responding, still 
Apr 23 11:06:45 10.0.0.19 kernel: nfs: server 10.0.0.253 OK
Apr 23 11:06:56 10.0.0.19 kernel: nsm_mon_unmon: rpc failed, status=-13
Apr 23 11:06:56 10.0.0.19 kernel: lockd: cannot monitor 10.0.0.253
Apr 23 11:06:56 10.0.0.19 kernel: lockd: failed to monitor 10.0.0.253

i.e. nothing's changed :(

Should the /var/lib/nfs be in use for the clients, too? My boot-sequence is 
based on KNOPPIX and uses an initrd to symlink much of the filesystem to a 
ramdisk, so I'm a bit concerned I might have messed up the permissions here.

Any advice warmly welcomed.

Cheers,
Gavin.
P.S. Olaf Kirch's "statd simplified" looks very interesting! :))


-------------------------------------------------------
This SF.net email is sponsored by: The Robotic Monkeys at ThinkGeek
For a limited time only, get FREE Ground shipping on all orders of $35
or more. Hurry up and shop folks, this offer expires April 30th!
http://www.thinkgeek.com/freeshipping/?cpg=12297
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
