From: Neil Brown <neilb@cse.unsw.edu.au>
Subject: Re: [PATCH] SGI 907674: document fsid export option
Date: Wed, 25 Feb 2004 14:21:49 +1100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <16444.5325.978979.117912@notabene.cse.unsw.edu.au>
References: <40188282.36FBA905@melbourne.sgi.com>
	<16442.51053.96888.392883@notabene.cse.unsw.edu.au>
	<403ACE01.2BBF39D6@melbourne.sgi.com>
	<16442.52922.613916.868991@notabene.cse.unsw.edu.au>
	<403AD38A.58FACE61@melbourne.sgi.com>
	<16443.59027.38890.186568@notabene.cse.unsw.edu.au>
	<403BECC5.F8D65725@melbourne.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linux NFS Mailing List <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Avpdh-0005pa-3i
	for nfs@lists.sourceforge.net; Tue, 24 Feb 2004 19:23:13 -0800
Received: from note.orchestra.cse.unsw.edu.au ([129.94.242.24] ident=root)
	by sc8-sf-mx2.sourceforge.net with smtp (Exim 4.30)
	id 1AvpQ5-0005Tv-7B
	for nfs@lists.sourceforge.net; Tue, 24 Feb 2004 19:09:09 -0800
Received: From notabene ([129.94.211.194] == dulcimer.orchestra.cse.unsw.EDU.AU)
	(for <gnb@melbourne.sgi.com>) (for <nfs@lists.sourceforge.net>) By
	note With Smtp ; Wed, 25 Feb 2004 14:21:55 +1100
To: Greg Banks <gnb@melbourne.sgi.com>
In-Reply-To: message from Greg Banks on Wednesday February 25
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

On Wednesday February 25, gnb@melbourne.sgi.com wrote:
> Neil Brown wrote:
> 
> > This interface is not needed in 2.6 and will be going away in 2.7, and
> > the new interface (via text written into /proc ) doesn't have the 16
> > bit limit.
> > 
> > I think we should document it as a 32bit number, but note that only 16
> > bits are significant in certain situations.
> 
> >From my reading of nfs-utils last night it seems it still gets truncated
> even with the new interface, because a struct nfsctl_export is used as
> temporary storage.

Hmm.  That can and should be fixed.  I will look at it.

> 
> Good point.  How about defining a new fsid type in the file handle
> which has enough space to store the md5sum of the path?  We could then
> fall back to using that automatically when we can tell from the underlying
> fs that it either hasn't got a device or has an unstable device.  This
> would solve an issue seen here in SGI Melbourne when we tried using
> userfs to present all those exports as a single fs union: userfs doesn't
> have enough support to allows NFS export.

An md5sum is 16bytes - half an NFSv2 filehandle (quarter NFSv3, eight
NFSv4....) 
We would have to disallow it for NFSv2, but that probably isn't a big
cost. 
We would have to use some hash of it for the fsid field in the GETATTR
result, but I don't think that is a big deal.

So that might be an option.
I'd rather not use the pathname as filesystems can be mounted in
different places.  Most filesystems have some sort of UUID, but there
is no standard way of extracting that information (and no guarantee
that it is there).

However an fsid really identifies an exportpoint, not a filesystem.
There can be several exportpoints in one filesystem.  So a UUID from
the filesystem isn't alway sufficient.

I guess that as the MOUNT protocol uses a path to identify an export
point, we should be safe in identifying the one with the other in the
fsid too.

> > I'm leaning towards something like:
> > 
> >    fsid=auto
> >      means look in the exportpoint for a file called ".nfs-fsid"
> >      If it exists, read 8 hex bytes and use that to determine a 32bit
> >      number.
> 
> This is interesting, but we would have a problem for the machine here
> in Melbourne: all the exports are readonly loopback-mounted ISO9660
> images.

That would need to be handled by the /sbin/nfs-fsid program, but you
are right that it would be best if most common scenarios were handled
transparently, and the .nfs-fsid file does seem to have a number of
issues.

> 
> Yes.  However I'd be much happier if the common cases were handled
> completely automatically in exportfs or inside the kernel without any
> further intervention being necessary.

Definitely.  But we need to know what the common cases are.

The simplest approach : md5sum of filename,  seems nice and general.
However suppose someone wanted to export their cdrom which they always
mounted at /mnt/cdrom (That desire has been mentioned on this list
occasionally). 
When I change CDs should I get a different fsid, thereby forcing the
client to unmount and remount (which seems reasonable)?  That would
require a different fsid for each cdrom.
If an auto-mounter were used which chose a mount-point name based on a
label in the CDrom, then we could just use a name-based fsid and put
the burden onto the auto-mounter :-)

It might even be nice to have a different fsid for the filesystem root
than for the rest of the fs.  Then if you change the filesystem
mounted as the exportpoint, any filehandles into the content would go
stale, but the mountpoint would still be accessible.

So as you can probably tell, it really isn't clear to me what is
best.  Thankyou for your thoughts and suggestions.

NeilBrown


-------------------------------------------------------
SF.Net is sponsored by: Speed Start Your Linux Apps Now.
Build and deploy apps & Web services for Linux with
a free DVD software kit from IBM. Click Now!
http://ads.osdn.com/?ad_id=1356&alloc_id=3438&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
