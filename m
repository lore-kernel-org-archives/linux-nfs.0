From: Greg Banks <gnb@melbourne.sgi.com>
Subject: Re: [PATCH] SGI 907674: document fsid export option
Date: Tue, 24 Feb 2004 15:31:06 +1100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <403AD38A.58FACE61@melbourne.sgi.com>
References: <40188282.36FBA905@melbourne.sgi.com>
		<16442.51053.96888.392883@notabene.cse.unsw.edu.au>
		<403ACE01.2BBF39D6@melbourne.sgi.com> <16442.52922.613916.868991@notabene.cse.unsw.edu.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linux NFS Mailing List <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1AvUET-0000Sp-Vf
	for nfs@lists.sourceforge.net; Mon, 23 Feb 2004 20:31:45 -0800
Received: from mtvcafw.sgi.com ([192.48.171.6] helo=rj.sgi.com)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.30)
	id 1AvUE2-0006R3-7D
	for nfs@lists.sourceforge.net; Mon, 23 Feb 2004 20:31:18 -0800
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
> On Tuesday February 24, gnb@melbourne.sgi.com wrote:
> >
> > Aha, it's embarrassment time.  Since sending the patch I've discovered
> > that this part
> >
> > > > +instead of a number derived from the major and minor number of the
> > > > +block device on which the filesystem is mounted.  Any 32 bit number
> > > > +can be used, but it must be unique amongst all the exported filesystems.
> >
> > is wrong; the fsid passes through a dev_t interface and is silently
> > truncated to 16 bits.  The following fixes my gaffe.  Sorry.
> >
> 
> Hmm... I'd much rather we actually used 32 bits. 

Actually the field in the file handle on the wire is 64 bits:

/* fs/nfsd/nfs3xdr.c */
static inline u32 *
encode_fattr3(struct svc_rqst *rqstp, u32 *p, struct svc_fh *fhp)
{
	[...]
	if (rqstp->rq_reffh->fh_version == 1
	    && rqstp->rq_reffh->fh_fsid_type == 1
	    && (fhp->fh_export->ex_flags & NFSEXP_FSID))
		p = xdr_encode_hyper(p, (u64) fhp->fh_export->ex_fsid);
	else
		p = xdr_encode_hyper(p, (u64) inode->i_dev);
	[...]
}


> Where does the
> truncate happen?  nfs-utils / kernel-2.4 / kernel-2.6 ??

The fsid is passed through the ex_dev field in struct nfsctl_export,
which (presumably for compatibility) is 16 bits both in 2.4 and 2.6.
There are two copies, one each in the kernel and nfs-utils.

/* linux/include/linux/nfsd/syscall.h */
/* EXPORT/UNEXPORT */
struct nfsctl_export {
	char			ex_client[NFSCLNT_IDMAX+1];
	char			ex_path[NFS_MAXPATHLEN+1];
	__kernel_dev_t		ex_dev;			<---
	__nfsd_ino_t		ex_ino;
	int			ex_flags;
	__kernel_uid_t		ex_anon_uid;
	__kernel_gid_t		ex_anon_gid;
};

/* nfs-utils/support/include/nfs/nfs.h */
/* EXPORT/UNEXPORT */
struct nfsctl_export {
	char			ex_client[NFSCLNT_IDMAX+1];
	char			ex_path[NFS_MAXPATHLEN+1];
	__nfsd_dev_t		ex_dev;			<---
	__kernel_ino_t		ex_ino;
	int			ex_flags;
	__kernel_uid_t		ex_anon_uid;
	__kernel_gid_t		ex_anon_gid;
};


I agree the truncate is unfortunate.  We have a 2.4.25 machine here with
dozens of exports each with an fsid= option automatically created by taking
the first 2 bytes of the md5sum of their names (because their devices aren't
stable) and some of the fsids are uncomfortably close.


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
