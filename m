From: Matt Schillinger <mschilli@vss.fsi.com>
Subject: rpc.mountd problems
Date: 19 Jun 2003 13:30:03 -0500
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <1056047403.15737.278.camel@mosix>
Mime-Version: 1.0
Content-Type: text/plain
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from adsl-66-136-174-212.dsl.stlsmo.swbell.net ([66.136.174.212] helo=esds.vss.fsi.com)
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 19T4A6-00054J-00
	for <nfs@lists.sourceforge.net>; Thu, 19 Jun 2003 11:29:31 -0700
Received: from mosix.vss.fsi.com (mosix [198.51.27.89])
	by esds.vss.fsi.com (8.11.6+Sun/8.9.1) with ESMTP id h5JITMK06105
	for <nfs@lists.sourceforge.net>; Thu, 19 Jun 2003 13:29:23 -0500 (CDT)
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
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

	I am having problems with rpc.mountd. 

I have found that after a while, mount requests cease to be honored.
Clients see a stall when trying to do a file operation on an NFS
mountpoint (ls for instance), followed by a 'Permission Denied'. On the
NFS server, there is no long entries that show any activity of mountd or
otherwise pointing to the Permission Denied. This is in a mixed
environment of Linux, Irix 6.x, Solaris 6, 7, and 8, using automounting
tools.

On the NFS Server, /var/log/messages does not show any rpc.mountd
activity at the point at which mount requests start stalling. I have
bumped file descriptors for rpc.mountd from 512, to 1024, and now up to
2048. 2048 is currently running (as of this morning), and has yet to
fail, but it's only been running a short time. 512 and 1024 did not seem
to help alot. I really don't even know if file descriptors are related.

Killing rpc.mountd and restarting it causes mount operations to
continue.

Here is my configuration

Dual Xeon 2.4Ghz
2G RAM
NICS Utilized: 3 - 1Gigabit Interfaces
Clients: About 100 - mix of OS's. 
Services: nfs (100 clients) - Samba (70-130 clients)
There are two mountpoints served, and are primarily for Image
Processing, so they do see a good amount of load. 
Disks: Ataboy2 ATA Raid (RAID 5)
Filesystem: Reiserfs

Kernel: linux-2.4.19, with the fh32 patch for CWD issues with IRIX <
6.5.13.
nfs-utils-1.0.3




Please let me know if there's anything else i can include to help solve
this problem.



-- 
Matt Schillinger
mschilli@vss.fsi.com





-------------------------------------------------------
This SF.Net email is sponsored by: INetU
Attention Web Developers & Consultants: Become An INetU Hosting Partner.
Refer Dedicated Servers. We Manage Them. You Get 10% Monthly Commission!
INetU Dedicated Managed Hosting http://www.inetu.net/partner/index.php
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
