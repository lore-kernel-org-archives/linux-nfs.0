From: James Pearson <james-p@moving-picture.com>
Subject: Re: stale NFS file handle (2.4.20) ext3 LVM
Date: Fri, 20 Jun 2003 10:35:08 +0100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <3EF2D54C.73B9EDAA@moving-picture.com>
References: <m3isr2kanm.fsf@merlin.emma.line.org>
		<3EF1CC36.8F3EC825@moving-picture.com> <m38yrx3dhx.fsf@merlin.emma.line.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from mpc-26.sohonet.co.uk ([193.203.82.251] helo=moving-picture.com)
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 19TIJs-0002uy-00
	for <nfs@lists.sourceforge.net>; Fri, 20 Jun 2003 02:36:32 -0700
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

Matthias Andree wrote:
> 
> James Pearson <james-p@moving-picture.com> writes:
> 
> > The device on the server containing the file system changes e.g. change
> > of SCSI ID.
> >
> > The file system not being mounted on the server when exported i.e. the
> > 'wrong' file system is exported.
> 
> I can rule these two out.
> 
> > The contents of /var/lib/nfs/rmtab being missing or corrupt. If a
> > client's entry is missing in rmtab after a server reboot, then the
> > server no nothing about the clients claim to have mounted the file
> > system - and gives a stale NFS file handle.
> > As you didn't change anything between reboots, then I guess it could be
> > the last case above.
> 
> Possible, but unlikely, I typed "reboot" which went through init and has
> worked fine, no hints about fsck checking file systems because of an
> unclean shutdown. If it was rmtab, I sure won't find out any more before
> the problem shows up again.
> 
> > I've seen similar problems - I use XFS for my file systems and I _think_
> > the rmtab file contents got replaced with NULLs when the file server
> > crashed (a known 'problem' with XFS).
> 
> That's specific to any file systems that only journal metadata and don't
> enforce a special "data first" write order such as ext3fs or patched
> reiserfs. Incidentally, /var is an XFS partition, in contrast to the
> exported partition (which is ext3).
> 
> > Also, if a client attempts to umount the file system from the server,
> > but the file system is busy, then rpc.mountd on the server will remove
> > the client's entry from rmtab, but the umount on the client will fail
> > and remain active. If the server now reboots, the client will get stale
> > NFS file handles when the server comes back up.
> 
> Hum. I'd have to look at autofs4.0.0pre10 (that's what the clients use).

autofs does its own checks before doing an actual umount, so this is
unlikely.

It would be a problem if you manually ran 'umount -at nfs' on the
clients (I've been caught by this).

> It appears as though I could make the client send a mount request to the
> server, just by typing "mount $MOUNTPOINT", this increments the last
> line in rmtab:
> 
> client.example.org:/exported:0x0000000e
> 
> So I'll try a plain "mount" from the client next time I see those stale
> NFS file handles.
> 
> I wonder if the NFS client should try sending a mount request when it
> gets stale NFS file handle if a simple mount request resolves the
> condition because the server lost its rmtab.

There was a posting from Neil Brown recently about possible changes for
2.6 kernels, that mentions doing away with rmtab - see:

http://marc.theaimsgroup.com/?l=linux-nfs&m=105331510308653&w=2

I don't know enough about this, but I _assume_ this will make things a
bit more 'solid'.

> I configured the machine to create a tar.gz file of /var/lib/nfs at
> boot-up time so I can have a look should it go wrong again. Maybe /var
> is still too precious for XFS ;-)

Something I've considered doing, but never got round to it ...

James Pearson


-------------------------------------------------------
This SF.Net email is sponsored by: INetU
Attention Web Developers & Consultants: Become An INetU Hosting Partner.
Refer Dedicated Servers. We Manage Them. You Get 10% Monthly Commission!
INetU Dedicated Managed Hosting http://www.inetu.net/partner/index.php
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
