From: Neil Brown <neilb@cse.unsw.edu.au>
Subject: Re: NFS server replacement troubles
Date: Wed, 9 Oct 2002 19:38:23 +1000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <15779.63759.746381.973207@notabene.cse.unsw.edu.au>
References: <3FF929A3082ED211B9D700A0C9CFDC8801428E23@exchange.bestivr.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from tone.orchestra.cse.unsw.edu.au ([129.94.242.28])
	by usw-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17zDIg-0006sb-00
	for <nfs@lists.sourceforge.net>; Wed, 09 Oct 2002 02:38:42 -0700
Received: From
	notabene.cse.unsw.edu.au ([129.94.242.45] == bartok.orchestra.cse.unsw.EDU.AU)
	(for <tswaine@prosodiemail.com>) (for <nfs@lists.sourceforge.net>) By
	tone With Smtp ; Wed, 9 Oct 2002 19:38:27 +1000
To: tswaine@prosodiemail.com
In-Reply-To: message from tswaine@prosodiemail.com on Tuesday October 8
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

On Tuesday October 8, tswaine@prosodiemail.com wrote:
> I currently have a SCO NFS server, however I'm replacing it with Redhat
> Linux.
> I have taking down the box replaced it and NFS fails. The hostname, ip, etc.
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
> Starting NFS quotas: Cannot register service: RPC: Unable to receive; errno
> = Connection refused
> [FAILED]
> Starting NFS mountd: Cannot register service: RPC: Unable to receive; errno
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
