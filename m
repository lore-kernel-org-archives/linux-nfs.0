From: Steve Dickson <SteveD@RedHat.com>
Subject: Re: rpc.mountd problems
Date: Sat, 21 Jun 2003 08:56:04 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <3EF455E4.9090207@RedHat.com>
References: <1056047403.15737.278.camel@mosix>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from host-64-179-20-100.man.choiceone.net ([64.179.20.100] helo=Odyssey.Home.4Dicksons.Org)
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 19Thul-0002pF-00
	for <nfs@lists.sourceforge.net>; Sat, 21 Jun 2003 05:56:19 -0700
To: Matt Schillinger <mschilli@vss.fsi.com>
In-Reply-To: <1056047403.15737.278.camel@mosix>
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

Where the exports changed in some way? I sounds like one
got lost or removed...

SteveD.

Matt Schillinger wrote:

>	I am having problems with rpc.mountd. 
>
>I have found that after a while, mount requests cease to be honored.
>Clients see a stall when trying to do a file operation on an NFS
>mountpoint (ls for instance), followed by a 'Permission Denied'. On the
>NFS server, there is no long entries that show any activity of mountd or
>otherwise pointing to the Permission Denied. This is in a mixed
>environment of Linux, Irix 6.x, Solaris 6, 7, and 8, using automounting
>tools.
>
>On the NFS Server, /var/log/messages does not show any rpc.mountd
>activity at the point at which mount requests start stalling. I have
>bumped file descriptors for rpc.mountd from 512, to 1024, and now up to
>2048. 2048 is currently running (as of this morning), and has yet to
>fail, but it's only been running a short time. 512 and 1024 did not seem
>to help alot. I really don't even know if file descriptors are related.
>
>Killing rpc.mountd and restarting it causes mount operations to
>continue.
>
>Here is my configuration
>
>Dual Xeon 2.4Ghz
>2G RAM
>NICS Utilized: 3 - 1Gigabit Interfaces
>Clients: About 100 - mix of OS's. 
>Services: nfs (100 clients) - Samba (70-130 clients)
>There are two mountpoints served, and are primarily for Image
>Processing, so they do see a good amount of load. 
>Disks: Ataboy2 ATA Raid (RAID 5)
>Filesystem: Reiserfs
>
>Kernel: linux-2.4.19, with the fh32 patch for CWD issues with IRIX <
>6.5.13.
>nfs-utils-1.0.3
>
>
>
>
>Please let me know if there's anything else i can include to help solve
>this problem.
>
>
>
>  
>



-------------------------------------------------------
This SF.Net email is sponsored by: INetU
Attention Web Developers & Consultants: Become An INetU Hosting Partner.
Refer Dedicated Servers. We Manage Them. You Get 10% Monthly Commission!
INetU Dedicated Managed Hosting http://www.inetu.net/partner/index.php
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
