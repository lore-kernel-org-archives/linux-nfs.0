From: Neil Brown <neilb@cse.unsw.edu.au>
Subject: Re: Solaris 8 to Linux Red Hat 9 - NFS Goes up and down and up and do
 wn ...
Date: Tue, 26 Aug 2003 08:45:45 +1000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <16202.37273.301748.912462@gargle.gargle.HOWL>
References: <2840B2764868D51189420090277B7699FD8F30@trilogy_pub.trilogyintl.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 19rQjy-0004Zp-00
	for <nfs@lists.sourceforge.net>; Mon, 25 Aug 2003 16:27:14 -0700
Received: from note.orchestra.cse.unsw.edu.au ([129.94.242.24])
	by sc8-sf-mx1.sourceforge.net with smtp (Exim 4.22)
	id 19rQ64-0005Dv-5s
	for nfs@lists.sourceforge.net; Mon, 25 Aug 2003 15:46:00 -0700
Received: From notabene ([129.94.242.45] == bartok.orchestra.cse.unsw.EDU.AU)
	(for <mmoldvan@trilogyintl.com>) (for <nfs@lists.sourceforge.net>) By
	note With Smtp ; Tue, 26 Aug 2003 08:45:52 +1000
To: Matthew Moldvan <mmoldvan@trilogyintl.com>
In-Reply-To: message from Matthew Moldvan on Monday August 25
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

On Monday August 25, mmoldvan@trilogyintl.com wrote:
> Hi everyone,
> 
> I've finally just about given up on trying to figure this out myself ...
> here's my issue:
> 
> We have a Sun E450 running Solaris 8 with not enough disk space on a few of
> the partitions.  Our solution: an x86 machine running Red Hat 9 with a 3Ware
> Escalade 4 port IDE RAID card and a few big HDDs.
> 
> So, we have the two machines communicating just fine through a Gigabit
> ethernet interface with a subnet.  Now, we've tried the rest two ways: 
> 
> 	1. Our E450 mounts the RH9 NFS share, then exports that as it's own
> NFS share

This is unlikely to work.  NFS is not designed to allow re-exporting.
The Linux NFS server doesn't allow this.
The Solaris NFS server might give it it's best-shot, I don't know.
But it isn't a configuration that I would recommend.


> 		or
> 	2. We mount the RH9 NFS share directly from the other Solaris
> workstations

This would be the most reliable approach.

> 
> Now, the issue we're facing is this: The whole setup works fine for awhile,
> with a minor amount of collisions ... BUT, after a few hours, the whole
> thing falls apart.  Workstations can't login because NFS shares aren't being
> mounted, the main server is not allowing connections because it can't mount
> the NFS itself, etc etc etc.
> 
> This is all incredibly frustrating to me, and we've tried everything from
> changing the gigabit ethernet configuration to trying new network cards to
> blaming it on wiring to god knows what now ...

We would need some precise details.  Specific error messages.
Try mounting various things by hand, note the error messages and
anything that appears in logs on the server or the client.

NeilBrown



-------------------------------------------------------
This SF.net email is sponsored by: VM Ware
With VMware you can run multiple operating systems on a single machine.
WITHOUT REBOOTING! Mix Linux / Windows / Novell virtual machines
at the same time. Free trial click here:http://www.vmware.com/wl/offer/358/0
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
