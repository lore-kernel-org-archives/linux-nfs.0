From: Matthew Moldvan <mmoldvan@trilogyintl.com>
Subject: Solaris 8 to Linux Red Hat 9 - NFS Goes up and down and up and do
 wn ...
Date: Mon, 25 Aug 2003 10:39:58 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <2840B2764868D51189420090277B7699FD8F30@trilogy_pub.trilogyintl.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from [209.187.237.19] (helo=proxy.trilogyintl.com)
	by sc8-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 19rIbW-00065q-00
	for <nfs@lists.sourceforge.net>; Mon, 25 Aug 2003 07:45:58 -0700
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

Hi everyone,

I've finally just about given up on trying to figure this out myself ...
here's my issue:

We have a Sun E450 running Solaris 8 with not enough disk space on a few of
the partitions.  Our solution: an x86 machine running Red Hat 9 with a 3Ware
Escalade 4 port IDE RAID card and a few big HDDs.

So, we have the two machines communicating just fine through a Gigabit
ethernet interface with a subnet.  Now, we've tried the rest two ways: 

	1. Our E450 mounts the RH9 NFS share, then exports that as it's own
NFS share
		or
	2. We mount the RH9 NFS share directly from the other Solaris
workstations

Now, the issue we're facing is this: The whole setup works fine for awhile,
with a minor amount of collisions ... BUT, after a few hours, the whole
thing falls apart.  Workstations can't login because NFS shares aren't being
mounted, the main server is not allowing connections because it can't mount
the NFS itself, etc etc etc.

This is all incredibly frustrating to me, and we've tried everything from
changing the gigabit ethernet configuration to trying new network cards to
blaming it on wiring to god knows what now ...

Any ideas??

Regards,
Matthew Moldvan
 
System Administrator
Trilogy International, Inc.


-------------------------------------------------------
This SF.net email is sponsored by: VM Ware
With VMware you can run multiple operating systems on a single machine.
WITHOUT REBOOTING! Mix Linux / Windows / Novell virtual machines
at the same time. Free trial click here:http://www.vmware.com/wl/offer/358/0
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
