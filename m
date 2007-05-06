From: Neil Brown <neilb@suse.de>
Subject: Re: [NFS] [PATCH 0/18] export operations rewrite
Date: Mon, 7 May 2007 09:52:35 +1000
Message-ID: <17982.27203.841272.221428@notabene.brown>
References: <20070317010946.GA24947@infradead.org>
	<17932.34141.590792.120454@notabene.brown>
	<20070501103905.GA30906@infradead.org>
	<17978.55182.198497.902215@notabene.brown>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: Christoph Hellwig <hch@infradead.org>,
	linux-fsdevel@vger.kernel.org, nfs@lists.sourceforge.net
Return-path: <linux-fsdevel-owner@vger.kernel.org>
In-Reply-To: message from Neil Brown on Friday May 4
Sender: linux-fsdevel-owner@vger.kernel.org
List-ID: <nfs.lists.sourceforge.net>

On Friday May 4, neilb@suse.de wrote:
> On Tuesday May 1, hch@infradead.org wrote:
> >  - the calling conversion on the decode side where we first call
> >    ->decode_fh to split the filehandle into two blobs only to
> >    recurse back into exportfs and then recurse back into the filesystem
> >    seems rather odd.  By having two methods to get the dentry and
> >    parent directly from the on the wire file handle this big callstack
> >    collapses to a very simple one.
> 
> This is the bit I was particularly missing.  I see now how this aspect
> was awkward before, and how your changes make the flow clearer.
> 
> Getting rid of s_export_op->find_exported_dentry is something I'm very
> happy about.  There was actually bug lurking there that I never got
> around to fixing.  The code:
> -	/* Ok, we can export it */;
> -	if (!inode->i_sb->s_export_op->find_exported_dentry)
> -		inode->i_sb->s_export_op->find_exported_dentry =
> -			find_exported_dentry;
> 
> assumes that the address of find_exported_dentry will never change.
> But if you unload nfsd.ko, then re-load it. it could be different, yet a
> filesystem could still have to old value in it's s_export_op.  That
> would be bad.
> I'm glad it is gone.

...but now I remember why it was there...

I didn't want filesystems to depend on exportfs.ko.
nfsd, depends on exportfs, but currently filesystems don't.  They
can be compiled into the kernel without including exportfs.

With your patches in place, I got a compile error with a config in
which nfsd is a module (and so exportfs is) but ext2 and ext3 are
compiled in.
The error was that generic_fh_to_dentry and generic_fh_to_parent were
not defined.

Now those two functions together with exportfs_d_alloc are fairly
small and could go directly in fs/something.c.  They could almost be
inlined in linux/exportfs.h.

Would you be able to respin that second patch series with one of those
changes?

Thanks,
NeilBrown
