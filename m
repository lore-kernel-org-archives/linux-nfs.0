From: David Woodhouse <dwmw2@infradead.org>
Subject: Re: [RFC] Reinstate NFS exportability for JFFS2.
Date: Fri, 02 May 2008 12:37:18 +0100
Message-ID: <1209728238.25560.686.camel@pmac.infradead.org>
References: <1209670979.25560.587.camel@pmac.infradead.org>
	 <20080501204820.GA5951@infradead.org>
	 <1209681898.25560.613.camel@pmac.infradead.org>
	 <18458.28833.539314.455215@notabene.brown>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Christoph Hellwig <hch@infradead.org>,
	linux-fsdevel@vger.kernel.org, linux-mtd@lists.infradead.org,
	linux-nfs@vger.kernel.org
To: Neil Brown <neilb@suse.de>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
In-Reply-To: <18458.28833.539314.455215@notabene.brown>
Sender: linux-fsdevel-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 2008-05-02 at 11:38 +1000, Neil Brown wrote:
> On Thursday May 1, dwmw2@infradead.org wrote:
> > On Thu, 2008-05-01 at 16:48 -0400, Christoph Hellwig wrote:
> > > Yes, and get_fsid would be extremly useful, especially for those
> > > filesystems that already have an uuid in the superblock
> > > (*cough*, XFS, *cough*), but it'll need some co-operations with
> > > nfs-utils on when to use it.
> > 
> > Why do you need to co-operate with userspace? Userspace shouldn't need
> > to do anything -- we'll just generate a suitable fsid/uuid for
> > ourselves, unless userspace deliberately overrides it for the export in
> > question.
> 
> Actually it is the kernel that doesn't need to do anything....
> Mapping between the filesystem and the filesystem part of the
> filehandle is done entirely in user space.
> The kernel says "Here is a filehandle fragement, what filesystem
> should I be accessing".
> 
> So what you really want is to teach nfs-utils to recognise JFFS2 and
> extract an appropriate uuid.
> It already uses libblkid to get uuids for ext3 and XFS and others.
> Extending that to handle JFFS2 should be much of a drama.

For JFFS2, there is no UUID; only i_sb->s_dev. Actually. if we just set
FS_REQUIRES_DEV then it would work out OK -- at least for the NFS
export. We don't do that though, because it gives behaviour we don't
want in other situations,

> Why is there a deadlock here?

Many file systems have their own locking, and lookup() can end up trying
to re-take a lock which readdir() is already holding. In the JFFS2 case,
it's the fs-internal inode mutex, which is required because the garbage
collector can't use i_mutex for lock ordering reasons.

See also the readdir implementation and surrounding comments in
fs/xfs/linux-2.6/xfs_file.c -- and the way GFS2 uses
gfs2_glock_is_locked_by_me() to avoid the deadlock.

The annoying thing is that JFFS2 doesn't even _implement_ i_generation,
so you get no more useful information out of the lookup() call anyway :)

> Both readdir and lookup are called with i_mutex held on the directory
> so there should need to do any extra locking (he said, naively).  In
> the readdirplus cases, i_mutex is held across both the readdir and the
> lookup....
> 
> One problem with your proposed solution is that filehandles aren't all
> the same length, so you cannot reliably leave space for them.

Not without moving stuff around during the postprocessing, I suppose.
Which isn't very pretty -- but it's prettier than some of the hacks we
have at the moment to avoid the deadlock.

-- 
dwmw2

