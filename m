From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: RE: Issues with nfs solaris server
Date: Thu, 19 Jun 2003 17:10:01 -0700
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <16114.20697.50617.699965@charged.uio.no>
References: <EE335453C5C57840823404C684F9F617012D684B@exmbx01sj.Cadence.COM>
Reply-To: trond.myklebust@fys.uio.no
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from pat.uio.no ([129.240.130.16] ident=7411)
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 19T9Tm-0004Xx-00
	for <nfs@lists.sourceforge.net>; Thu, 19 Jun 2003 17:10:10 -0700
To: "Chris Croswhite" <csc@cadence.com>
In-Reply-To: <EE335453C5C57840823404C684F9F617012D684B@exmbx01sj.Cadence.COM>
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

>>>>> " " == Chris Croswhite <csc@cadence.com> writes:

     > By die, I mean any action on that mount point hangs (ls, cd ,
     > etc.)?  I can "ctl c" out which returns me to the console.  I
     > can not unmount the mount point, the error returned is that the
     > mount point is busy.  mount options:
     > rsize=8192,wsize=8192,nfsvers=2,proto=udp,bg,intr

     > I have also tried adding hard to the list.

"hard" is the default, so it is automatically true given the above
mount options.

     > These hung mount points are seemed to affect dual cpu machines.

Hmm... Are there any kernel messages appearing in the syslog (or do
you see any if you type 'dmesg')?

Could you also try the following:

echo "1" >/proc/sys/sunrpc/rpc_debug

and then send me the syslogged results of doing 'ls' on the hanging
mountpoint together with a tcpdump?

Cheers,
  Trond


-------------------------------------------------------
This SF.Net email is sponsored by: INetU
Attention Web Developers & Consultants: Become An INetU Hosting Partner.
Refer Dedicated Servers. We Manage Them. You Get 10% Monthly Commission!
INetU Dedicated Managed Hosting http://www.inetu.net/partner/index.php
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
