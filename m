From: tswaine@prosodiemail.com
Subject: NFS server replacement troubles
Date: Tue, 8 Oct 2002 10:28:52 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <3FF929A3082ED211B9D700A0C9CFDC8801428E23@exchange.bestivr.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from exchange.bestivr.com ([65.217.47.130] helo=kenny.bestivr.com)
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17yvMG-0004a9-00
	for <nfs@lists.sourceforge.net>; Tue, 08 Oct 2002 07:29:12 -0700
To: nfs@lists.sourceforge.net
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
List-Archive: <http://sourceforge.net/mailarchives/forum.php?forum=nfs>

I currently have a SCO NFS server, however I'm replacing it with Redhat
Linux.
I have taking down the box replaced it and NFS fails. The hostname, ip, etc.
is 
the same on the new machine.
New box info....
	Stock Redhat Linux 6.2
	kernel 2.2.14-6.0.1 on i686
	partition being exported is Reiser filesystem

Before new box was put in to production its hostname was different.
Exporting was fine, NFS worked properly, however as soon as box
is brought up under new name NFS fails, errors(see below ).

Snapshot of errors.......

Starting portmapper: [  OK  ]
master:/var/lib/nfs 23# /etc/rc.d/init.d/nfs start
Starting NFS quotas: Cannot register service: RPC: Unable to receive; errno
= Connection refused
[FAILED]
Starting NFS mountd: Cannot register service: RPC: Unable to receive; errno
= Connection refused
mountd: unable to register (mountd, 1, udp).
[FAILED]
Starting NFS daemon: nfssvc: Connection refused
[FAILED]
Starting NFS services:  [  OK  ]


I have restarted portmapper and nfs with no success, unmount nfs on all
connected machines, still no workee....
Any help would be appreciated...
Thanks.


Troy L. Swaine
System Administrator / Engineer



-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
