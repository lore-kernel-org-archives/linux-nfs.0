From: James Pearson <james-p@moving-picture.com>
Subject: Re: stale NFS file handle (2.4.20) ext3 LVM
Date: Thu, 19 Jun 2003 15:04:15 +0100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <3EF1C2DF.4055BE8@moving-picture.com>
References: <m3isr2kanm.fsf@merlin.emma.line.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from mpc-26.sohonet.co.uk ([193.203.82.251] helo=moving-picture.com)
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 19T023-0008Rf-00
	for <nfs@lists.sourceforge.net>; Thu, 19 Jun 2003 07:04:56 -0700
To: Matthias Andree <ma@dt.e-technik.uni-dortmund.de>
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

There are a number of things that can cause stale NFS file handles on
all clients with file systems mounted from the server when the server
reboots - they include:

The device on the server containing the file system changes e.g. change
of SCSI ID.

The file system not being mounted on the server when exported i.e. the
'wrong' file system is exported.

The contents of /var/lib/nfs/rmtab being missing or corrupt. If a
client's entry is missing in rmtab after a server reboot, then the
server no nothing about the clients clain to have mounetd the file
system - and gives a stale NFS file handle.


As you didn't change anything between reboots, then I guess it could be
the last case a bove. 

Matthias Andree wrote:
> 
> Hi,
> 
> I rebooted one of my NFS servers (no configuration changed), and when it
> came back up, all clients that had the exported file system mounted
> (NFSv3 hard mount) reported stale NFS file handles, for the file system
> root and for files within. The STALE error travelled across the wire
> according to ethereal.
> 
> The server system runs SuSE Linux 8.2, they ship a 2.4.20 kernel with
> some patches (POSIX ACL stuff, SuSE claim it's Solaris compatible,
> haven't tested yet). Their start script is below.
> 
> The clients run SuSE Linux 8.1 with a patched 2.4.19 (no ACL stuff). The
> server configuration wasn't changed across the reboot except for
> replacing a SCSI terminator (I borrowed one I gave back when my own
> arrived.)
> 
> Is there any known issue with NFS-exporting file systems that are hosted
> in LVM volumes? Is there an issue with SuSE's ACL patches?
> 
> How is the file handle obtained and under what circumstances will it
> become stale after a reboot? SuSE's RPM on the server is
> nfs-utils-1.0.1-89.
> 
> I was under the impression that rebooting a server into the same
> configuration would NOT give stale NFS file handles, in fact, this has
> worked before with a SuSE Linux 8.1 server (but that one didn't use LVM
> either, so there are two -- for me inseparable -- major differences
> here.)
> 
> Sometimes on frustrated days like these I think I should just replace
> this Linux NFS with Solaris. :-/
> 
> Can somebody point me to documents about NFS file handle internals or
> try to explain the situation? Testing directions are welcome, as are
> "kill LVM" or "kill ACL patches", the server isn't in production yet, so
> there's still time to fix things for good. (Even kill SuSE, replace with
> Debian/RedHat is an acceptable suggestion if there are technical
> reasons.)
> 
> I also wonder if NFS clients should have a "masochistically_hard" mount
> options that issue SIGKILL to processes that use stale NFS file handles,
> I could use this...
> 
> SuSE 8.2 nfsserver start script excerpt (the nfslock daemon is started
> before execution of this script):
> 
>       PARAMS=3
>       test "$USE_KERNEL_NFSD_NUMBER" -gt 0 && PARAMS="$USE_KERNEL_NFSD_NUMBER"
> 
>       echo -n "Starting kernel based NFS server"
>       /usr/sbin/exportfs -r
>       /usr/sbin/rpc.nfsd $PARAMS
>       startproc /usr/sbin/rpc.mountd
> 
> --
> Matthias 'NFS sucks some days' Andree
> 
> -------------------------------------------------------
> This SF.Net email is sponsored by: INetU
> Attention Web Developers & Consultants: Become An INetU Hosting Partner.
> Refer Dedicated Servers. We Manage Them. You Get 10% Monthly Commission!
> INetU Dedicated Managed Hosting http://www.inetu.net/partner/index.php
> _______________________________________________
> NFS maillist  -  NFS@lists.sourceforge.net
> https://lists.sourceforge.net/lists/listinfo/nfs


-------------------------------------------------------
This SF.Net email is sponsored by: INetU
Attention Web Developers & Consultants: Become An INetU Hosting Partner.
Refer Dedicated Servers. We Manage Them. You Get 10% Monthly Commission!
INetU Dedicated Managed Hosting http://www.inetu.net/partner/index.php
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
