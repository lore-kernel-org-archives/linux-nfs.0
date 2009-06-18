From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: NFS: possible circular locking  i_mutex <> mmap_sem
Date: Thu, 18 Jun 2009 11:02:38 +0800
Message-ID: <20090618030238.GA850@localhost>
References: <20090618023208.GA28572@localhost> <20090617195251.e648dbb8.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>, Ingo Molnar <mingo@elte.hu>
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:14171 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752753AbZFRDCi (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 17 Jun 2009 23:02:38 -0400
In-Reply-To: <20090617195251.e648dbb8.akpm@linux-foundation.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Jun 18, 2009 at 10:52:51AM +0800, Andrew Morton wrote:
> On Thu, 18 Jun 2009 10:32:08 +0800 Wu Fengguang <fengguang.wu@intel.com> wrote:
> 
> > Hi,
> > 
> > I got a lockdep warning on a stress testing a nfsroot desktop.
> > The bits puzzled me is how come the page_fault() happens in
> > generic_file_buffered_write()?
> 
> write(fd, buf, count).  If the page at *buf isn't present, we take a
> fault to instantiate that page so we can copy_to_user() into it.

Thanks. I was cheated by the pagefault_disable() call, but the real
fault happened some time before at iov_iter_fault_in_readable().

> > 
> > [ 2638.515865] =======================================================
> > [ 2638.519743] [ INFO: possible circular locking dependency detected ]
> > [ 2638.519743] 2.6.30-rc8-mm1 #307
> > [ 2638.519743] -------------------------------------------------------
> > [ 2638.519743] firefox-bin/3399 is trying to acquire lock:
> > [ 2638.519743]  (&mm->mmap_sem){++++++}, at: [<ffffffff81548471>] do_page_fault+0x301/0x330
> > [ 2638.519743]
> > [ 2638.519743] but task is already holding lock:
> > [ 2638.519743]  (&sb->s_type->i_mutex_key#6){+.+.+.}, at: [<ffffffff810c2bd2>] generic_file_aio_write+0x52/0xd0
> > [ 2638.519743]
> > [ 2638.519743] which lock already depends on the new lock.
> > [ 2638.519743]
> > [ 2638.519743]
> > [ 2638.519743] the existing dependency chain (in reverse order) is:
> > [ 2638.519743]
> > [ 2638.519743] -> #1 (&sb->s_type->i_mutex_key#6){+.+.+.}:
> > [ 2638.519743]        [<ffffffff8107c066>] __lock_acquire+0x12b6/0x1b40
> > [ 2638.519743]        [<ffffffff8107c9d1>] lock_acquire+0xe1/0x120
> > [ 2638.519743]        [<ffffffff8154328e>] mutex_lock_nested+0x5e/0x390
> > [ 2638.519743]        [<ffffffff811be15c>] nfs_revalidate_mapping+0xac/0x110    ==> takes i_mutex in nfs_invalidate_mapping()
> > [ 2638.519743]        [<ffffffff811bba25>] nfs_file_mmap+0x55/0x80
> > [ 2638.519743]        [<ffffffff810e2bb7>] mmap_region+0x427/0x600
> > [ 2638.519743]        [<ffffffff810e305e>] do_mmap_pgoff+0x2ce/0x3f0
> > [ 2638.519743]        [<ffffffff81010c26>] sys_mmap+0x106/0x130                 ==> takes mmap_sem
> > [ 2638.519743]        [<ffffffff8100bf42>] system_call_fastpath+0x16/0x1b
> > [ 2638.519743]        [<ffffffffffffffff>] 0xffffffffffffffff
> 
> This is the faulty code path.  mmap_sem is supposed to nest inside i_mutex.

This could be a long stand bug: the nfs_revalidate_mapping() call was
there in the very beginning of git history.

> > [ 2638.519743] -> #0 (&mm->mmap_sem){++++++}:
> > [ 2638.519743]        [<ffffffff8107c206>] __lock_acquire+0x1456/0x1b40
> > [ 2638.519743]        [<ffffffff8107c9d1>] lock_acquire+0xe1/0x120
> > [ 2638.519743]        [<ffffffff81543d3b>] down_read+0x4b/0x80
> > [ 2638.519743]        [<ffffffff81548471>] do_page_fault+0x301/0x330            ==> takes mmap_sem
> > [ 2638.519743]        [<ffffffff81545b55>] page_fault+0x25/0x30
> > [ 2638.519743]        [<ffffffff810c1970>] generic_file_buffered_write+0x100/0x320
> > [ 2638.519743]        [<ffffffff810c202d>] __generic_file_aio_write_nolock+0x25d/0x450
> > [ 2638.519743]        [<ffffffff810c2be9>] generic_file_aio_write+0x69/0xd0     ==> takes i_mutex
> > [ 2638.519743]        [<ffffffff811bbd36>] nfs_file_write+0x136/0x230
> > [ 2638.519743]        [<ffffffff810fc991>] do_sync_write+0xf1/0x140
> > [ 2638.519743]        [<ffffffff810fd59b>] vfs_write+0xcb/0x1a0
> > [ 2638.519743]        [<ffffffff810fd760>] sys_write+0x50/0x90
> > [ 2638.519743]        [<ffffffff8100bf42>] system_call_fastpath+0x16/0x1b
> > [ 2638.519743]        [<ffffffffffffffff>] 0xffffffffffffffff
> > [ 2638.519743]
> 
> <digs around a bit>
> 
> afaict this was added by a fix-a-compile-warning patch!
> 
> : commit e1ebfd33be068ec933f8954060a499bd22ad6f69
> : Author:     Trond Myklebust <Trond.Myklebust@netapp.com>
> : AuthorDate: Wed Mar 11 14:37:54 2009 -0400
> : Commit:     Trond Myklebust <Trond.Myklebust@netapp.com>
> : CommitDate: Wed Mar 11 14:37:54 2009 -0400
> : 
> :     NFS: Kill the "defined but not used" compile error on nommu machines
> :     
> :     Bryan Wu reports that when compiling NFS on nommu machines he gets a
> :     "defined but not used" error on nfs_file_mmap().
> :     
> :     The easiest fix is simply to get rid of the special casing in NFS, and
> :     just always call generic_file_mmap() to set up the file.
> :     
> :     Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
> : 
> : diff --git a/fs/nfs/file.c b/fs/nfs/file.c
> : index 404c19c..1eab9c9 100644
> : --- a/fs/nfs/file.c
> : +++ b/fs/nfs/file.c
> : @@ -64,11 +64,7 @@ const struct file_operations nfs_file_operations = {
> :  	.write		= do_sync_write,
> :  	.aio_read	= nfs_file_read,
> :  	.aio_write	= nfs_file_write,
> : -#ifdef CONFIG_MMU
> :  	.mmap		= nfs_file_mmap,
> : -#else
> : -	.mmap		= generic_file_mmap,
> : -#endif
> :  	.open		= nfs_file_open,
> :  	.flush		= nfs_file_flush,
> :  	.release	= nfs_file_release,
> : @@ -304,11 +300,13 @@ nfs_file_mmap(struct file * file, struct vm_area_struct * vma)
> :  	dprintk("NFS: mmap(%s/%s)\n",
> :  		dentry->d_parent->d_name.name, dentry->d_name.name);
> :  
> : -	status = nfs_revalidate_mapping(inode, file->f_mapping);
> : +	/* Note: generic_file_mmap() returns ENOSYS on nommu systems
> : +	 *       so we call that before revalidating the mapping
> : +	 */
> : +	status = generic_file_mmap(file, vma);
> :  	if (!status) {
> :  		vma->vm_ops = &nfs_file_vm_ops;
> : -		vma->vm_flags |= VM_CAN_NONLINEAR;
> : -		file_accessed(file);
> : +		status = nfs_revalidate_mapping(inode, file->f_mapping);
> :  	}
> :  	return status;
> :  }
> 
> It's odd/worrying that this problem sat in linux-next for a month
> and nobody noticed.

Not the fault of this patch?  The above patch only moves the
nfs_revalidate_mapping() call around a bit.

Thanks,
Fengguang
