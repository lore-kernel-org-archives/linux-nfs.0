From: Greg Banks <gnb@melbourne.sgi.com>
Subject: Re: [PATCH] SGI 907674: document fsid export option
Date: Wed, 25 Feb 2004 11:31:01 +1100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <403BECC5.F8D65725@melbourne.sgi.com>
References: <40188282.36FBA905@melbourne.sgi.com>
		<16442.51053.96888.392883@notabene.cse.unsw.edu.au>
		<403ACE01.2BBF39D6@melbourne.sgi.com>
		<16442.52922.613916.868991@notabene.cse.unsw.edu.au>
		<403AD38A.58FACE61@melbourne.sgi.com> <16443.59027.38890.186568@notabene.cse.unsw.edu.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linux NFS Mailing List <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Avmy9-0002FH-IE
	for nfs@lists.sourceforge.net; Tue, 24 Feb 2004 16:32:09 -0800
Received: from mtvcafw.sgi.com ([192.48.171.6] helo=rj.sgi.com)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.30)
	id 1AvmxD-0004WW-Nf
	for nfs@lists.sourceforge.net; Tue, 24 Feb 2004 16:31:11 -0800
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
> 
> The fsid is also use in the filehandle, and there only 32 bits are
> used.  This was the usage I was thinking of - I had forgotten the
> other one.

Yep, realised I was looking at the wrong code after I got home.  Doh!
So the reak limit is 32b.

> > > Where does the
> > > truncate happen?  nfs-utils / kernel-2.4 / kernel-2.6 ??
> >
> > The fsid is passed through the ex_dev field in struct nfsctl_export,
> > which (presumably for compatibility) is 16 bits both in 2.4 and 2.6.
> > There are two copies, one each in the kernel and nfs-utils.
> >
> > /* linux/include/linux/nfsd/syscall.h */
> > /* EXPORT/UNEXPORT */
> > struct nfsctl_export {
> >       char                    ex_client[NFSCLNT_IDMAX+1];
> >       char                    ex_path[NFS_MAXPATHLEN+1];
> >       __kernel_dev_t          ex_dev;                 <---
> >       __nfsd_ino_t            ex_ino;
> 
> yuk... and there is probably 2 bytes of padding in there on most
> architectures... not that we can really use it.

I think any solution would involve extending the nfsctl_export structure,
hopefully in a compatible way.  I have a very alpha patch I hacked up
last night to do that.  With luck I might get to see if it compiles today.

> This interface is not needed in 2.6 and will be going away in 2.7, and
> the new interface (via text written into /proc ) doesn't have the 16
> bit limit.
> 
> I think we should document it as a 32bit number, but note that only 16
> bits are significant in certain situations.

>From my reading of nfs-utils last night it seems it still gets truncated
even with the new interface, because a struct nfsctl_export is used as
temporary storage.

> > I agree the truncate is unfortunate.  We have a 2.4.25 machine here with
> > dozens of exports each with an fsid= option automatically created by taking
> > the first 2 bytes of the md5sum of their names (because their devices aren't
> > stable) and some of the fsids are uncomfortably close.
> 
> This related so the next big issue with filehandles - how to identify
> the filesystem reliably.
> We now have a nice interface into the filesystem so that "which
> file in the filesystem" can be encoded in the filehandle reliably, but
> at the same time, the way we identify the filesystem is become less
> reliably due to device number instability.
> 
> I don't like the md5sum approach as it is only probabilistically
> reliable.  If we could use all the bits it might be OK, but we clearly
> cannot and with only 16 bits, you are already seeing some fsid's being
> "uncomfortably close".  32bits will be better, but still not ideal.

Good point.  How about defining a new fsid type in the file handle
which has enough space to store the md5sum of the path?  We could then
fall back to using that automatically when we can tell from the underlying
fs that it either hasn't got a device or has an unstable device.  This
would solve an issue seen here in SGI Melbourne when we tried using
userfs to present all those exports as a single fs union: userfs doesn't
have enough support to allows NFS export.

> There really needs to be a way for a site to centrally allocate fsid
> numbers.  Each filesystems fsid would need to be stored on the
> filesystem itself otherwise we would be back to the bad-old-days of
> depending on a state file in /var like /var/lib/nfs/rmtab.

On XFS you could use the SCSI UUID of the filesystem which is 16B,
generated to be unique, and has uniqueness enforced at mount time
(to handle the case of ghosting an fs).

> I'm leaning towards something like:
> 
>    fsid=auto
>      means look in the exportpoint for a file called ".nfs-fsid"
>      If it exists, read 8 hex bytes and use that to determine a 32bit
>      number.

This is interesting, but we would have a problem for the machine here
in Melbourne: all the exports are readonly loopback-mounted ISO9660
images.

Also, if the export point is writable by non-root (which IRIC might
happen for some NIS setups) you have an entertaining security issue.
Also, if it's accidentally written or deleted by non-squashed root
remotely you have a problem.

I don't think putting the fsid inside the export is going to work.

>      If it doesn't exist and /sbin/nfs-fsid does, run that pass it the
>      export point.  It should write 8 hex bytes to stdout.
>      It might also write them to .nfs-fsid if it wants to.
>      If /etc/nfs-nfsid doesn't exist, assume /var/lib/nfs/fsid
>      contains a hex number which should be used, stored in .nfs-fsid,
>      and incremented.

Ok, nice and general; handles the case of multiple exports from a single
local fs.  But the nfs-fsid program needs to be per-fstype to handle
those cases where the fs already gives you a useful number, like XFS.

> This would allow a fairly reliable way of automatically allocating
> unique fsids on a per-machine basis, but would allow admins to define
> their own nfs-fsid program that allocated ids on a site-wide basis.

Yes.  However I'd be much happier if the common cases were handled
completely automatically in exportfs or inside the kernel without any
further intervention being necessary.

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
