From: Matthias Andree <ma@dt.e-technik.uni-dortmund.de>
Subject: Re: stale NFS file handle (2.4.20) ext3 LVM
Date: Fri, 20 Jun 2003 00:32:10 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <m38yrx3dhx.fsf@merlin.emma.line.org>
References: <m3isr2kanm.fsf@merlin.emma.line.org>
	<3EF1CC36.8F3EC825@moving-picture.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from krusty.dt.e-technik.uni-dortmund.de ([129.217.163.1] ident=postfix)
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 19T7x4-0007tw-00
	for <nfs@lists.sourceforge.net>; Thu, 19 Jun 2003 15:32:19 -0700
Received: from m2a2.dyndns.org (krusty.dt.e-technik.uni-dortmund.de [129.217.163.1])
	by mail.dt.e-technik.uni-dortmund.de (Postfix) with ESMTP id 8923CA381D
	for <nfs@lists.sourceforge.net>; Fri, 20 Jun 2003 00:32:15 +0200 (CEST)
To: nfs@lists.sourceforge.net
In-Reply-To: <3EF1CC36.8F3EC825@moving-picture.com> (James Pearson's message
 of "Thu, 19 Jun 2003 15:44:06 +0100")
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

James Pearson <james-p@moving-picture.com> writes:

> The device on the server containing the file system changes e.g. change
> of SCSI ID.
>  
> The file system not being mounted on the server when exported i.e. the
> 'wrong' file system is exported.

I can rule these two out.

> The contents of /var/lib/nfs/rmtab being missing or corrupt. If a
> client's entry is missing in rmtab after a server reboot, then the
> server no nothing about the clients claim to have mounted the file
> system - and gives a stale NFS file handle.
> As you didn't change anything between reboots, then I guess it could be
> the last case above. 

Possible, but unlikely, I typed "reboot" which went through init and has
worked fine, no hints about fsck checking file systems because of an
unclean shutdown. If it was rmtab, I sure won't find out any more before
the problem shows up again.

> I've seen similar problems - I use XFS for my file systems and I _think_
> the rmtab file contents got replaced with NULLs when the file server
> crashed (a known 'problem' with XFS).

That's specific to any file systems that only journal metadata and don't
enforce a special "data first" write order such as ext3fs or patched
reiserfs. Incidentally, /var is an XFS partition, in contrast to the
exported partition (which is ext3).

> Also, if a client attempts to umount the file system from the server,
> but the file system is busy, then rpc.mountd on the server will remove
> the client's entry from rmtab, but the umount on the client will fail
> and remain active. If the server now reboots, the client will get stale
> NFS file handles when the server comes back up.

Hum. I'd have to look at autofs4.0.0pre10 (that's what the clients use).

It appears as though I could make the client send a mount request to the
server, just by typing "mount $MOUNTPOINT", this increments the last
line in rmtab:

client.example.org:/exported:0x0000000e

So I'll try a plain "mount" from the client next time I see those stale
NFS file handles.

I wonder if the NFS client should try sending a mount request when it
gets stale NFS file handle if a simple mount request resolves the
condition because the server lost its rmtab.

I configured the machine to create a tar.gz file of /var/lib/nfs at
boot-up time so I can have a look should it go wrong again. Maybe /var
is still too precious for XFS ;-)

-- 
Matthias Andree


-------------------------------------------------------
This SF.Net email is sponsored by: INetU
Attention Web Developers & Consultants: Become An INetU Hosting Partner.
Refer Dedicated Servers. We Manage Them. You Get 10% Monthly Commission!
INetU Dedicated Managed Hosting http://www.inetu.net/partner/index.php
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
