Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:48593 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751225AbbEGPbS (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 7 May 2015 11:31:18 -0400
Date: Thu, 7 May 2015 11:31:16 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Kinglong Mee <kinglongmee@gmail.com>
Cc: NeilBrown <neilb@suse.de>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH RFC] NFSD: fix cannot umounting mount points under pseudo
 root
Message-ID: <20150507153116.GI27106@fieldses.org>
References: <553E2784.6020906@gmail.com>
 <20150429125728.69ddfc6c@notabene.brown>
 <20150429191934.GA23980@fieldses.org>
 <20150430075225.21a71056@notabene.brown>
 <20150430213602.GB9509@fieldses.org>
 <20150501115326.51f5613a@notabene.brown>
 <20150504220130.GB16827@fieldses.org>
 <5548CBA3.9080608@gmail.com>
 <20150505141801.GB27106@fieldses.org>
 <20150505155203.GD27106@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20150505155203.GD27106@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, May 05, 2015 at 11:52:03AM -0400, J. Bruce Fields wrote:
> On Tue, May 05, 2015 at 10:18:01AM -0400, J. Bruce Fields wrote:
> > On Tue, May 05, 2015 at 09:54:43PM +0800, Kinglong Mee wrote:
> > > On 5/5/2015 6:01 AM, J. Bruce Fields wrote:
> > > > + * Unlike lookup_one_len, it should be called without the parent
> > > > + * i_mutex held, and will take the i_mutex itself if necessary.
> > > > + */
> > > > +struct dentry *lookup_one_len_unlocked(const char *name,
> > > > +				       struct dentry *base, int len)
> > > > +{
> > > > +	struct qstr this;
> > > > +	unsigned int c;
> > > > +	int err;
> > > > +	struct dentry *ret;
> > > > +
> > > > +	WARN_ON_ONCE(!mutex_is_locked(&base->d_inode->i_mutex));
> > > 
> > > Remove this line.
> > 
> > Whoops, thanks.
> > 
> > > > diff --git a/fs/nfsd/vfs.c b/fs/nfsd/vfs.c
> > > > index a30e79900086..cc7995762190 100644
> > > > --- a/fs/nfsd/vfs.c
> > > > +++ b/fs/nfsd/vfs.c
> > > > @@ -217,6 +217,13 @@ nfsd_lookup_dentry(struct svc_rqst *rqstp, struct svc_fh *fhp,
> > > >  		host_err = PTR_ERR(dentry);
> > > >  		if (IS_ERR(dentry))
> > > >  			goto out_nfserr;
> > > > +		if (!S_ISREG(d_inode(dentry)->i_mode)) {
> > > 
> > > Got a crash here tested by pynfs,
> > 
> > OK, I guess I just forgot to take into account negative dentries.
> > Testing that now with (!(d_inode(dentry) && S_ISREG(..))).
> 
> And I also forgot nfs3xdr.c.

But, this doesn't look good.

OK, to be fair I'm not sure whether this was already happening before this
patch.

--b.

[57287.226846] ======================================================
[57287.227499] [ INFO: possible circular locking dependency detected ]
[57287.228009] 4.1.0-rc2-22946-g6c942d3 #174 Not tainted
[57287.228009] -------------------------------------------------------
[57287.228009] updatedb/19312 is trying to acquire lock:
[57287.228009]  (&mm->mmap_sem){++++++}, at: [<ffffffff811980bf>] might_fault+0x5f/0xb0
[57287.228009] 
but task is already holding lock:
[57287.228009]  (&xfs_dir_ilock_class){++++..}, at: [<ffffffff81400c1a>] xfs_ilock+0x10a/0x2e0
[57287.228009] 
which lock already depends on the new lock.

[57287.228009] 
the existing dependency chain (in reverse order) is:
[57287.228009] 
-> #2 (&xfs_dir_ilock_class){++++..}:
[57287.228009]        [<ffffffff810cf1c2>] __lock_acquire+0x15f2/0x1920
[57287.228009]        [<ffffffff810cfe40>] lock_acquire+0xc0/0x280
[57287.228009]        [<ffffffff810c8e0d>] down_read_nested+0x4d/0x70
[57287.228009]        [<ffffffff81400c1a>] xfs_ilock+0x10a/0x2e0
[57287.228009]        [<ffffffff81400e68>] xfs_ilock_attr_map_shared+0x38/0x50
[57287.228009]        [<ffffffff8139b9e1>] xfs_attr_get+0xc1/0x180
[57287.228009]        [<ffffffff8140ff87>] xfs_xattr_get+0x37/0x50
[57287.228009]        [<ffffffff811e866f>] generic_getxattr+0x4f/0x70
[57287.228009]        [<ffffffff816535d2>] inode_doinit_with_dentry+0x152/0x670
[57287.228009]        [<ffffffff81657f8b>] sb_finish_set_opts+0xdb/0x260
[57287.228009]        [<ffffffff81658604>] selinux_set_mnt_opts+0x2c4/0x600
[57287.228009]        [<ffffffff816589ff>] superblock_doinit+0xbf/0xd0
[57287.228009]        [<ffffffff81658a6d>] selinux_sb_kern_mount+0x3d/0xa0
[57287.228009]        [<ffffffff8164efa6>] security_sb_kern_mount+0x16/0x20
[57287.228009]        [<ffffffff811c29dd>] mount_fs+0x7d/0x190
[57287.228009]        [<ffffffff811e2258>] vfs_kern_mount+0x68/0x160
[57287.228009]        [<ffffffff811e58b4>] do_mount+0x204/0xc60
[57287.228009]        [<ffffffff811e660f>] SyS_mount+0x6f/0xb0
[57287.228009]        [<ffffffff81b6b697>] system_call_fastpath+0x12/0x6f
[57287.228009] 
-> #1 (&isec->lock){+.+.+.}:
[57287.228009]        [<ffffffff810cf1c2>] __lock_acquire+0x15f2/0x1920
[57287.228009]        [<ffffffff810cfe40>] lock_acquire+0xc0/0x280
[57287.228009]        [<ffffffff81b675f3>] mutex_lock_nested+0x63/0x400
[57287.228009]        [<ffffffff81653525>] inode_doinit_with_dentry+0xa5/0x670
[57287.228009]        [<ffffffff81653b0c>] selinux_d_instantiate+0x1c/0x20
[57287.228009]        [<ffffffff8164eb2b>] security_d_instantiate+0x1b/0x30
[57287.228009]        [<ffffffff811d9ce4>] d_instantiate+0x54/0x80
[57287.228009]        [<ffffffff811894fe>] __shmem_file_setup+0xce/0x250
[57287.228009]        [<ffffffff8118c5f8>] shmem_zero_setup+0x28/0x70
[57287.228009]        [<ffffffff811a1818>] mmap_region+0x5c8/0x5e0
[57287.228009]        [<ffffffff811a1ba3>] do_mmap_pgoff+0x373/0x420
[57287.228009]        [<ffffffff8118cb00>] vm_mmap_pgoff+0x90/0xc0
[57287.228009]        [<ffffffff811a0000>] SyS_mmap_pgoff+0x1b0/0x240
[57287.228009]        [<ffffffff81008c92>] SyS_mmap+0x22/0x30
[57287.228009]        [<ffffffff81b6b697>] system_call_fastpath+0x12/0x6f
[57287.228009] 
-> #0 (&mm->mmap_sem){++++++}:
[57287.228009]        [<ffffffff810ccafb>] check_prev_add+0x51b/0x860
[57287.228009]        [<ffffffff810cf1c2>] __lock_acquire+0x15f2/0x1920
[57287.228009]        [<ffffffff810cfe40>] lock_acquire+0xc0/0x280
[57287.228009]        [<ffffffff811980ec>] might_fault+0x8c/0xb0
[57287.228009]        [<ffffffff811d3ff2>] filldir+0x92/0x120
[57287.228009]        [<ffffffff813ec51a>] xfs_dir2_sf_getdents.isra.10+0x1ba/0x220
[57287.228009]        [<ffffffff813ed0de>] xfs_readdir+0x15e/0x300
[57287.228009]        [<ffffffff813f116b>] xfs_file_readdir+0x2b/0x30
[57287.228009]        [<ffffffff811d3dca>] iterate_dir+0x9a/0x140
[57287.228009]        [<ffffffff811d42b1>] SyS_getdents+0x81/0x100
[57287.228009]        [<ffffffff81b6b697>] system_call_fastpath+0x12/0x6f
[57287.228009] 
other info that might help us debug this:

[57287.228009] Chain exists of:
  &mm->mmap_sem --> &isec->lock --> &xfs_dir_ilock_class

[57287.228009]  Possible unsafe locking scenario:

[57287.228009]        CPU0                    CPU1
[57287.228009]        ----                    ----
[57287.228009]   lock(&xfs_dir_ilock_class);
[57287.228009]                                lock(&isec->lock);
[57287.228009]                                lock(&xfs_dir_ilock_class);
[57287.228009]   lock(&mm->mmap_sem);
[57287.228009] 
 *** DEADLOCK ***

[57287.228009] 2 locks held by updatedb/19312:
[57287.228009]  #0:  (&type->i_mutex_dir_key#5){+.+.+.}, at: [<ffffffff811d3d91>] iterate_dir+0x61/0x140
[57287.228009]  #1:  (&xfs_dir_ilock_class){++++..}, at: [<ffffffff81400c1a>] xfs_ilock+0x10a/0x2e0
[57287.228009] 
stack backtrace:
[57287.228009] CPU: 0 PID: 19312 Comm: updatedb Not tainted 4.1.0-rc2-22946-g6c942d3 #174
[57287.228009] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS 1.7.5-20140709_153950- 04/01/2014
[57287.228009]  ffffffff82c61ed0 ffff880060d0faa8 ffffffff81b61a1a 0000000080000001
[57287.228009]  ffffffff82c345d0 ffff880060d0faf8 ffffffff810cb843 0000000000000000
[57287.228009]  ffff880060d0fb28 0000000000000000 0000000000000001 0000000000000000
[57287.228009] Call Trace:
[57287.228009]  [<ffffffff81b61a1a>] dump_stack+0x4f/0x7b
[57287.228009]  [<ffffffff810cb843>] print_circular_bug+0x203/0x310
[57287.228009]  [<ffffffff810ccafb>] check_prev_add+0x51b/0x860
[57287.228009]  [<ffffffff810ce018>] ? __lock_acquire+0x448/0x1920
[57287.228009]  [<ffffffff810cf1c2>] __lock_acquire+0x15f2/0x1920
[57287.228009]  [<ffffffff810cfe40>] lock_acquire+0xc0/0x280
[57287.228009]  [<ffffffff811980bf>] ? might_fault+0x5f/0xb0
[57287.228009]  [<ffffffff811980ec>] might_fault+0x8c/0xb0
[57287.228009]  [<ffffffff811980bf>] ? might_fault+0x5f/0xb0
[57287.228009]  [<ffffffff811d3ff2>] filldir+0x92/0x120
[57287.228009]  [<ffffffff81400e24>] ? xfs_ilock_data_map_shared+0x34/0x40
[57287.228009]  [<ffffffff813ec51a>] xfs_dir2_sf_getdents.isra.10+0x1ba/0x220
[57287.228009]  [<ffffffff81400c1a>] ? xfs_ilock+0x10a/0x2e0
[57287.228009]  [<ffffffff813ed0de>] xfs_readdir+0x15e/0x300
[57287.228009]  [<ffffffff810cd6b5>] ? mark_held_locks+0x75/0xa0
[57287.228009]  [<ffffffff81b6800a>] ? mutex_lock_killable_nested+0x27a/0x4e0
[57287.228009]  [<ffffffff813f116b>] xfs_file_readdir+0x2b/0x30
[57287.228009]  [<ffffffff811d3dca>] iterate_dir+0x9a/0x140
[57287.228009]  [<ffffffff811dfceb>] ? __fget_light+0x7b/0xa0
[57287.228009]  [<ffffffff811d42b1>] SyS_getdents+0x81/0x100
[57287.228009]  [<ffffffff811d3f60>] ? fillonedir+0xf0/0xf0
[57287.228009]  [<ffffffff81b6b697>] system_call_fastpath+0x12/0x6f

