From: Neil Brown <neilb@cse.unsw.edu.au>
Subject: Re: [PATCH] SGI 907674: document fsid export option
Date: Wed, 25 Feb 2004 11:04:35 +1100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <16443.59027.38890.186568@notabene.cse.unsw.edu.au>
References: <40188282.36FBA905@melbourne.sgi.com>
	<16442.51053.96888.392883@notabene.cse.unsw.edu.au>
	<403ACE01.2BBF39D6@melbourne.sgi.com>
	<16442.52922.613916.868991@notabene.cse.unsw.edu.au>
	<403AD38A.58FACE61@melbourne.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linux NFS Mailing List <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1AvmYY-0005P0-Ow
	for nfs@lists.sourceforge.net; Tue, 24 Feb 2004 16:05:42 -0800
Received: from note.orchestra.cse.unsw.edu.au ([129.94.242.24] ident=root)
	by sc8-sf-mx1.sourceforge.net with smtp (Exim 4.30)
	id 1AvmXd-0001PK-8e
	for nfs@lists.sourceforge.net; Tue, 24 Feb 2004 16:04:45 -0800
Received: From notabene ([129.94.211.194] == dulcimer.orchestra.cse.unsw.EDU.AU)
	(for <gnb@melbourne.sgi.com>) (for <nfs@lists.sourceforge.net>) By
	note With Smtp ; Wed, 25 Feb 2004 11:04:36 +1100
To: Greg Banks <gnb@melbourne.sgi.com>
In-Reply-To: message from Greg Banks on Tuesday February 24
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

On Tuesday February 24, gnb@melbourne.sgi.com wrote:
> Neil Brown wrote:
> > 
> > On Tuesday February 24, gnb@melbourne.sgi.com wrote:
> > >
> > > Aha, it's embarrassment time.  Since sending the patch I've discovered
> > > that this part
> > >
> > > > > +instead of a number derived from the major and minor number of the
> > > > > +block device on which the filesystem is mounted.  Any 32 bit number
> > > > > +can be used, but it must be unique amongst all the exported filesystems.
> > >
> > > is wrong; the fsid passes through a dev_t interface and is silently
> > > truncated to 16 bits.  The following fixes my gaffe.  Sorry.
> > >
> > 
> > Hmm... I'd much rather we actually used 32 bits. 
> 
> Actually the field in the file handle on the wire is 64 bits:
> 
> /* fs/nfsd/nfs3xdr.c */
> static inline u32 *
> encode_fattr3(struct svc_rqst *rqstp, u32 *p, struct svc_fh *fhp)
> {
> 	[...]
> 	if (rqstp->rq_reffh->fh_version == 1
> 	    && rqstp->rq_reffh->fh_fsid_type == 1
> 	    && (fhp->fh_export->ex_flags & NFSEXP_FSID))
> 		p = xdr_encode_hyper(p, (u64) fhp->fh_export->ex_fsid);
> 	else
> 		p = xdr_encode_hyper(p, (u64) inode->i_dev);
> 	[...]
> }
> 

The fsid is also use in the filehandle, and there only 32 bits are
used.  This was the usage I was thinking of - I had forgotten the
other one.


> 
> > Where does the
> > truncate happen?  nfs-utils / kernel-2.4 / kernel-2.6 ??
> 
> The fsid is passed through the ex_dev field in struct nfsctl_export,
> which (presumably for compatibility) is 16 bits both in 2.4 and 2.6.
> There are two copies, one each in the kernel and nfs-utils.
> 
> /* linux/include/linux/nfsd/syscall.h */
> /* EXPORT/UNEXPORT */
> struct nfsctl_export {
> 	char			ex_client[NFSCLNT_IDMAX+1];
> 	char			ex_path[NFS_MAXPATHLEN+1];
> 	__kernel_dev_t		ex_dev;			<---
> 	__nfsd_ino_t		ex_ino;

yuk... and there is probably 2 bytes of padding in there on most
architectures... not that we can really use it.

This interface is not needed in 2.6 and will be going away in 2.7, and
the new interface (via text written into /proc ) doesn't have the 16
bit limit.  

I think we should document it as a 32bit number, but note that only 16
bits are significant in certain situations.

> 
> I agree the truncate is unfortunate.  We have a 2.4.25 machine here with
> dozens of exports each with an fsid= option automatically created by taking
> the first 2 bytes of the md5sum of their names (because their devices aren't
> stable) and some of the fsids are uncomfortably close.

This related so the next big issue with filehandles - how to identify
the filesystem reliably.
We now have a nice interface into the filesystem so that "which
file in the filesystem" can be encoded in the filehandle reliably, but
at the same time, the way we identify the filesystem is become less
reliably due to device number instability.

I don't like the md5sum approach as it is only probabilistically
reliable.  If we could use all the bits it might be OK, but we clearly
cannot and with only 16 bits, you are already seeing some fsid's being
"uncomfortably close".  32bits will be better, but still not ideal.

There really needs to be a way for a site to centrally allocate fsid
numbers.  Each filesystems fsid would need to be stored on the
filesystem itself otherwise we would be back to the bad-old-days of
depending on a state file in /var like /var/lib/nfs/rmtab.

I'm leaning towards something like:

   fsid=auto
     means look in the exportpoint for a file called ".nfs-fsid"
     If it exists, read 8 hex bytes and use that to determine a 32bit
     number. 
     If it doesn't exist and /sbin/nfs-fsid does, run that pass it the
     export point.  It should write 8 hex bytes to stdout.
     It might also write them to .nfs-fsid if it wants to.
     If /etc/nfs-nfsid doesn't exist, assume /var/lib/nfs/fsid
     contains a hex number which should be used, stored in .nfs-fsid,
     and incremented.

This would allow a fairly reliable way of automatically allocating
unique fsids on a per-machine basis, but would allow admins to define
their own nfs-fsid program that allocated ids on a site-wide basis.


Thoughts?

NeilBrown


-------------------------------------------------------
SF.Net is sponsored by: Speed Start Your Linux Apps Now.
Build and deploy apps & Web services for Linux with
a free DVD software kit from IBM. Click Now!
http://ads.osdn.com/?ad_id=1356&alloc_id=3438&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
