From: David Woodhouse <dwmw2@infradead.org>
Subject: Re: [RFC] Reinstate NFS exportability for JFFS2.
Date: Fri, 01 Aug 2008 14:35:59 +0100
Message-ID: <1217597759.3454.356.camel@pmac.infradead.org>
References: <1209670979.25560.587.camel@pmac.infradead.org>
	 <20080501204820.GA5951@infradead.org>
	 <1209681898.25560.613.camel@pmac.infradead.org>
	 <18458.28833.539314.455215@notabene.brown>
	 <1217541264.1126.15.camel@shinybook.infradead.org>
	 <18578.21997.529551.676627@notabene.brown>
	 <1217551230.3719.15.camel@shinybook.infradead.org>
	 <76bd70e30807311753m2785c6d3kd82edd1fe8b5f8b7@mail.gmail.com>
	 <1217552437.3719.30.camel@shinybook.infradead.org>
	 <76bd70e30807311831p771d0f1eia3e303bd84919422@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Neil Brown <neilb@suse.de>, Christoph Hellwig <hch@infradead.org>,
	linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org,
	linux-mtd@lists.infradead.org
To: chucklever@gmail.com, viro@zeniv.linux.org.uk
Return-path: <linux-fsdevel-owner@vger.kernel.org>
In-Reply-To: <76bd70e30807311831p771d0f1eia3e303bd84919422@mail.gmail.com>
Sender: linux-fsdevel-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 2008-07-31 at 21:31 -0400, Chuck Lever wrote:
> On Thu, Jul 31, 2008 at 9:00 PM, David Woodhouse <dwmw2@infradead.org> wrote:
> > On Thu, 2008-07-31 at 20:53 -0400, Chuck Lever wrote:
> >> For now it is sufficient, IMO.  NFSv4 doesn't implement a readdirplus
> >> operation, and the performance benefits of NFSv3 readdirplus are
> >> equivocal -- there isn't a strong desire to replicate the complexity
> >> of NFSv3 readdirplus in NFSv4.  I'm not even sure you can do it even
> >> with a single compound RPC, so even in the long run NFSv4 may not ever
> >> have the locking issues that NFSv3 does here.
> >
> > AFAICT NFSv4 does have the same recursion issues already. The call trace
> > goes fs->readdir() ... nfsd4_encode_dirent() ...
> > nfsd4_encode_dirent_fattr() ... lookup_one_len() ... fs->lookup().
> >
> > Or am I mistaken?
> 
> It looks like it needs a directory entry's dentry for a couple of reasons:
> 
> 1.  To determine whether a directory entry is a mount point
> 
> 2.  If the client has asked for file handles (via a bitmask) for the
> directory entries

Those are needed by NFSv3 too -- and can be handled with a lookup_fh()
method in the file system which is guaranteed to be called from within
the filldir callback, and some support in the VFS for checking if it's a
mountpoint.

NFSv4 introduces another problem though, which is that it seems to be
able to return the _full_ getattr() results for each object, and there's
no real way round the fact that we need to do the ->lookup() for that.

If sane clients aren't expected to _ask_ for that, though, then perhaps
it would be OK to fall back to something like the existing
readdir-to-buffer hack for that case, while most normal clients won't
trigger it.

-- 
David Woodhouse                            Open Source Technology Centre
David.Woodhouse@intel.com                              Intel Corporation



