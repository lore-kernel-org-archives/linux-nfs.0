From: tswaine@prosodiemail.com
Subject: RE: NFS server replacement troubles
Date: Wed, 9 Oct 2002 07:20:00 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <3FF929A3082ED211B9D700A0C9CFDC8801428E3B@exchange.bestivr.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from exchange.bestivr.com ([65.217.47.130] helo=kenny.bestivr.com)
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17zEsz-0007yH-00
	for <nfs@lists.sourceforge.net>; Wed, 09 Oct 2002 04:20:18 -0700
To: neilb@cse.unsw.edu.au, tswaine@prosodiemail.com
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

Thanks Neil but I looked at that also. My exports file looks like
this....

/somedir (rw)

Allowing anyone to connect. Also my hosts.allow is...

ALL: ALL

Allowing everyone also. Right after the new box comes online 
and fails(when it worked with a different hostname). Something
gets corrupted in nfs. No matter what I do, nfs will not work.
I have tried replacing binaries ( rpc.* )with no avail.

Could it be stale clients that were not unmounted before the switch?

Thanks....

-----Original Message-----
From: Neil Brown [mailto:neilb@cse.unsw.edu.au]
Sent: Wednesday, October 09, 2002 5:38 AM
To: tswaine@prosodiemail.com
Cc: nfs@lists.sourceforge.net
Subject: Re: [NFS] NFS server replacement troubles


On Tuesday October 8, tswaine@prosodiemail.com wrote:
> I currently have a SCO NFS server, however I'm replacing it with Redhat
> Linux.
> I have taking down the box replaced it and NFS fails. The hostname, ip,
etc.
> is 
> the same on the new machine.
> New box info....
> 	Stock Redhat Linux 6.2
> 	kernel 2.2.14-6.0.1 on i686
> 	partition being exported is Reiser filesystem
> 
> Before new box was put in to production its hostname was different.
> Exporting was fine, NFS worked properly, however as soon as box
> is brought up under new name NFS fails, errors(see below ).
> 
> Snapshot of errors.......
> 
> Starting portmapper: [  OK  ]
> master:/var/lib/nfs 23# /etc/rc.d/init.d/nfs start
> Starting NFS quotas: Cannot register service: RPC: Unable to receive;
errno
> = Connection refused
> [FAILED]
> Starting NFS mountd: Cannot register service: RPC: Unable to receive;
errno
> = Connection refused

At a guess, I would say tcpwrappers problem.  Maybe you have to old
host-name in /etc/hosts.allow, or something like that??

NeilBrown

> mountd: unable to register (mountd, 1, udp).
> [FAILED]
> Starting NFS daemon: nfssvc: Connection refused
> [FAILED]
> Starting NFS services:  [  OK  ]
> 
> 
> I have restarted portmapper and nfs with no success, unmount nfs on all
> connected machines, still no workee....
> Any help would be appreciated...
> Thanks.
> 
> 
> Troy L. Swaine
> System Administrator / Engineer
> 
> 
> 
> -------------------------------------------------------
> This sf.net email is sponsored by:ThinkGeek
> Welcome to geek heaven.
> http://thinkgeek.com/sf
> _______________________________________________
> NFS maillist  -  NFS@lists.sourceforge.net
> https://lists.sourceforge.net/lists/listinfo/nfs


-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
