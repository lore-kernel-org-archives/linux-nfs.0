From: Greg Banks <gnb@melbourne.sgi.com>
Subject: Re: [PATCH] SGI 907674: document fsid export option
Date: Wed, 25 Feb 2004 15:39:30 +1100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <403C2702.93152074@melbourne.sgi.com>
References: <40188282.36FBA905@melbourne.sgi.com>
		<16442.51053.96888.392883@notabene.cse.unsw.edu.au>
		<403ACE01.2BBF39D6@melbourne.sgi.com>
		<16442.52922.613916.868991@notabene.cse.unsw.edu.au>
		<403AD38A.58FACE61@melbourne.sgi.com>
		<16443.59027.38890.186568@notabene.cse.unsw.edu.au>
		<403BECC5.F8D65725@melbourne.sgi.com> <16444.5325.978979.117912@notabene.cse.unsw.edu.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linux NFS Mailing List <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Avqqn-0000Ra-8F
	for nfs@lists.sourceforge.net; Tue, 24 Feb 2004 20:40:49 -0800
Received: from mtvcafw.sgi.com ([192.48.171.6] helo=rj.sgi.com)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.30)
	id 1Avqpk-0002K4-70
	for nfs@lists.sourceforge.net; Tue, 24 Feb 2004 20:39:44 -0800
To: Neil Brown <neilb@cse.unsw.edu.au>
Errors-To: nfs-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

Neil Brown wrote:
> 
> On Wednesday February 25, gnb@melbourne.sgi.com wrote:
> > Neil Brown wrote:
> >
> > > This interface is not needed in 2.6 and will be going away in 2.7, and
> > > the new interface (via text written into /proc ) doesn't have the 16
> > > bit limit.
> > >
> > > I think we should document it as a 32bit number, but note that only 16
> > > bits are significant in certain situations.

Ok, is this patch suitable?

--- nfs-utils-1.0.6/utils/exportfs/exports.man.orig	Tue Feb 24 15:06:35 2004
+++ nfs-utils-1.0.6/utils/exportfs/exports.man	Wed Feb 25 15:31:20 2004
@@ -278,7 +278,9 @@
 .I num
 instead of a number derived from the major and minor number of the
 block device on which the filesystem is mounted.  Any 32 bit number
-can be used, but it must be unique amongst all the exported filesystems.
+can be used (although only the lower 16 bits will be significant in
+certain situations), as long as the number is unique for each export
+point.
 
 This can be useful for NFS failover, to ensure that both servers of
 the failover pair use the same NFS file handles for the shared filesystem


> > >From my reading of nfs-utils last night it seems it still gets truncated
> > even with the new interface, because a struct nfsctl_export is used as
> > temporary storage.
> 
> Hmm.  That can and should be fixed.  I will look at it.

FWIW my still-very-alpha patch addresses that as a side effect.

> An md5sum is 16bytes - half an NFSv2 filehandle (quarter NFSv3, eight NFSv4....)
> We would have to disallow it for NFSv2, but that probably isn't a big cost.

Agreed.

> We would have to use some hash of it for the fsid field in the GETATTR
> result, but I don't think that is a big deal.
> 
> So that might be an option.
> I'd rather not use the pathname as filesystems can be mounted in
> different places.  Most filesystems have some sort of UUID, but there
> is no standard way of extracting that information (and no guarantee
> that it is there).

Yes, the UUID solution would require per-fs plumbing which makes it
unnattractive as a solution.

> However an fsid really identifies an exportpoint, not a filesystem.
> There can be several exportpoints in one filesystem.  So a UUID from
> the filesystem isn't alway sufficient.

No but a combination of UUID + path of export from root of fs, would be.

Perhaps the easiest thing to do is to use the initial 8 bytes subset
of the md5hash if the export options have "fsid=md5", and warn in syslog
if the resulting fsids aren't unique.

BTW, I have another reason for not wanting to expand the fsid too much:
I need to expand the fileid part for XFS to handle 64-bit inode numbers.

> I guess that as the MOUNT protocol uses a path to identify an export
> point, we should be safe in identifying the one with the other in the
> fsid too.

Yep.  Certainly it's safer than a device pair.  We have two specific
cases here in the office where the device pair is unstable: loopback
mounts and SAN Fibre Channel disks.  In both cases the export point
pathname is stable.

> > Yes.  However I'd be much happier if the common cases were handled
> > completely automatically in exportfs or inside the kernel without any
> > further intervention being necessary.
> 
> Definitely.  But we need to know what the common cases are.
> 
> The simplest approach : md5sum of filename,  seems nice and general.
> However suppose someone wanted to export their cdrom which they always
> mounted at /mnt/cdrom (That desire has been mentioned on this list
> occasionally).

> When I change CDs should I get a different fsid, thereby forcing the
> client to unmount and remount (which seems reasonable)? 

Yes, you need to have different fsids for different insertions of
removable media.  I presume the current device number scheme is really
quite broken for cdroms ? (I've always been careful when doing that).

> That would
> require a different fsid for each cdrom.

Or incorporate a generation number into the fsid, e.g. by hashing
the path+mount generation.  This would imply either the VFS or the
block device maintaining a mount generation, or a notification mechanism
back into NFS when the mount/umount happens.

Actually, that notification mechanism could also deal with the other
issue that happens when an export point gets mounted over.

> If an auto-mounter were used which chose a mount-point name based on a
> label in the CDrom, then we could just use a name-based fsid and put
> the burden onto the auto-mounter :-)

Ugh, Solaris vold rises again.

> It might even be nice to have a different fsid for the filesystem root
> than for the rest of the fs.  Then if you change the filesystem
> mounted as the exportpoint, any filehandles into the content would go
> stale, but the mountpoint would still be accessible.

Sure, but I don't see how it helps to have one unstale filehandle
which doesn't let you get any unstale files from it.


Greg.
-- 
Greg Banks, R&D Software Engineer, SGI Australian Software Group.
I don't speak for SGI.


-------------------------------------------------------
SF.Net is sponsored by: Speed Start Your Linux Apps Now.
Build and deploy apps & Web services for Linux with
a free DVD software kit from IBM. Click Now!
http://ads.osdn.com/?ad_id=1356&alloc_id=3438&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
