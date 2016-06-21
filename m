Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from linuxhacker.ru ([217.76.32.60]:60078 "EHLO fiona.linuxhacker.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751537AbcFUWZT convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 21 Jun 2016 18:25:19 -0400
Subject: Re: [PATCH v2 03/12] NFS: Cache aggressively when file is open for writing
Mime-Version: 1.0 (Apple Message framework v1283)
Content-Type: text/plain; charset=us-ascii
From: Oleg Drokin <green@linuxhacker.ru>
In-Reply-To: <1466544893-12058-3-git-send-email-trond.myklebust@primarydata.com>
Date: Tue, 21 Jun 2016 18:25:09 -0400
Cc: linux-nfs@vger.kernel.org
Message-Id: <43F206E4-FCA8-4ED3-A4FC-4150AB927026@linuxhacker.ru>
References: <1466544893-12058-1-git-send-email-trond.myklebust@primarydata.com> <1466544893-12058-2-git-send-email-trond.myklebust@primarydata.com> <1466544893-12058-3-git-send-email-trond.myklebust@primarydata.com>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This patch still crashes for me.

[  183.814855] BUG: unable to handle kernel paging request at ffff88001b18cfe8
[  183.815403] IP: [<ffffffff81381b63>] nfs_update_inode+0x53/0xa30
[  183.815868] PGD 3580067 PUD 3581067 PMD 77f69067 PTE 800000001b18c060
[  183.816640] Oops: 0000 [#1] SMP DEBUG_PAGEALLOC
[  183.817252] Modules linked in: loop rpcsec_gss_krb5 joydev acpi_cpufreq tpm_tis virtio_console tpm i2c_piix4 pcspkr nfsd ttm drm_kms_helper syscopyarea sysfillrect sysimgblt fb_sys_fops virtio_blk serio_raw drm floppy
[  183.820203] CPU: 6 PID: 40935 Comm: rm Not tainted 4.7.0-rc3-vm-nfst+ #6
[  183.820818] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
[  183.821329] task: ffff88001b430c80 ti: ffff88001cf2c000 task.ti: ffff88001cf2c000
[  183.822223] RIP: 0010:[<ffffffff81381b63>]  [<ffffffff81381b63>] nfs_update_inode+0x53/0xa30
[  183.823007] RSP: 0018:ffff88001cf2fb08  EFLAGS: 00010283
[  183.823417] RAX: ffff88001b18d000 RBX: ffff880021b582a8 RCX: 0000000000000000
[  183.823845] RDX: ffff88001b18d000 RSI: ffff88001c3cdf00 RDI: ffff880021b582a8
[  183.824276] RBP: ffff88001cf2fb58 R08: 0000000000000000 R09: 0000000000000001
[  183.824701] R10: ffff88001b430c80 R11: 00000000fffe3818 R12: ffff88001c3cdf00
[  183.825190] R13: ffff88001c3cdf00 R14: ffff88001c3cdf00 R15: 0000000000000001
[  183.825651] FS:  00007fa0e9c5b700(0000) GS:ffff880075200000(0000) knlGS:0000000000000000
[  183.826396] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[  183.826884] CR2: ffff88001b18cfe8 CR3: 000000001bc1f000 CR4: 00000000000006e0
[  183.827460] Stack:
[  183.827825]  ffff880000000000 ffff88001cf2fb58 0000000000000246 ffffffff81382f33
[  183.828734]  0000000000000246 ffff880021b582a8 ffff880021b582a8 ffff88001c3cdf00
[  183.829634]  ffff88001c3cdf00 0000000000000001 ffff88001cf2fb80 ffffffff81382aa1
[  183.830562] Call Trace:
[  183.830938]  [<ffffffff81382f33>] ? nfs_refresh_inode.part.24+0x23/0x50
[  183.831368]  [<ffffffff81382aa1>] nfs_refresh_inode_locked+0x71/0x4e0
[  183.831785]  [<ffffffff81382f3e>] nfs_refresh_inode.part.24+0x2e/0x50
[  183.832209]  [<ffffffff81384024>] __nfs_revalidate_inode+0x314/0x4b0
[  183.832632]  [<ffffffff8137c6fe>] nfs_do_access+0x47e/0x620
[  183.833036]  [<ffffffff8137c2d1>] ? nfs_do_access+0x51/0x620
[  183.833456]  [<ffffffff818507ea>] ? generic_lookup_cred+0x1a/0x20
[  183.833872]  [<ffffffff8184ef7e>] ? rpcauth_lookupcred+0x8e/0xd0
[  183.834288]  [<ffffffff8137cb69>] nfs_permission+0x289/0x2e0
[  183.834699]  [<ffffffff8137c943>] ? nfs_permission+0x63/0x2e0
[  183.835108]  [<ffffffff812768da>] __inode_permission+0x6a/0xb0
[  183.835521]  [<ffffffff81276934>] inode_permission+0x14/0x50
[  183.835928]  [<ffffffff8127b2cf>] link_path_walk+0x2ef/0x6b0
[  183.837327]  [<ffffffff8127b6a9>] ? path_parentat+0x19/0x80
[  183.837988]  [<ffffffff8127b6be>] path_parentat+0x2e/0x80
[  183.838653]  [<ffffffff8127cb13>] filename_parentat+0xb3/0x190
[  183.839328]  [<ffffffff8123bc4c>] ? cache_alloc_debugcheck_after.isra.52+0x19c/0x1f0
[  183.840533]  [<ffffffff8123e0a0>] ? kmem_cache_alloc+0x300/0x3d0
[  183.841217]  [<ffffffff8127c89f>] ? getname_flags+0x4f/0x1f0
[  183.841888]  [<ffffffff810e6d0d>] ? trace_hardirqs_on+0xd/0x10
[  183.842570]  [<ffffffff8127d455>] do_unlinkat+0x65/0x2f0
[  183.843243]  [<ffffffff8100201a>] ? trace_hardirqs_on_thunk+0x1a/0x1c
[  183.843910]  [<ffffffff8127e17b>] SyS_unlinkat+0x1b/0x30
[  183.844582]  [<ffffffff8188aebc>] entry_SYSCALL_64_fastpath+0x1f/0xbd

(gdb) l *(nfs_update_inode+0x53)
0xffffffff81381b63 is in nfs_update_inode (/home/green/bk/linux-test/fs/nfs/inode.c:1233).
1228		 *       being placed at the head of the list.
1229		 *       See nfs_inode_attach_open_context()
1230		 */
1231		return (list_first_entry(&nfsi->open_files,
1232				struct nfs_open_context,
1233				list)->mode & FMODE_WRITE) == FMODE_WRITE;
1234	}
1235	
1236	static unsigned long nfs_wcc_update_inode(struct inode *inode, struct nfs_fattr *fattr)
1237	{

Reverting it makes the crash go away.

But there's also this other problem that I have not tracked to a particular patch yet:

[   25.830288] =============================================
[   25.830468] [ INFO: possible recursive locking detected ]
[   25.830658] 4.7.0-rc3-vm-nfst+ #8 Not tainted
[   25.830822] ---------------------------------------------
[   25.831009] cat/6588 is trying to acquire lock:
[   25.831179]  (&sb->s_type->i_mutex_key#13){++++++}, at: [<ffffffff813841f4>] __nfs_revalidate_mapping+0x124/0x3e0
[   25.832488] 
               but task is already holding lock:
[   25.833214]  (&sb->s_type->i_mutex_key#13){++++++}, at: [<ffffffff81388b7e>] nfs_start_io_read+0x1e/0x50
[   25.834209] 
               other info that might help us debug this:
[   25.834970]  Possible unsafe locking scenario:

[   25.835699]        CPU0
[   25.836077]        ----
[   25.836459]   lock(&sb->s_type->i_mutex_key#13);
[   25.836988]   lock(&sb->s_type->i_mutex_key#13);
[   25.837636] 
                *** DEADLOCK ***

[   25.838749]  May be due to missing lock nesting notation

[   25.839489] 1 lock held by cat/6588:
[   25.839878]  #0:  (&sb->s_type->i_mutex_key#13){++++++}, at: [<ffffffff81388b7e>] nfs_start_io_read+0x1e/0x50
[   25.840931] 
               stack backtrace:
[   25.841645] CPU: 0 PID: 6588 Comm: cat Not tainted 4.7.0-rc3-vm-nfst+ #8
[   25.842074] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
[   25.842497]  0000000000000086 00000000d8302202 ffff8800908c7c50 ffffffff814a0835
[   25.843418]  ffffffff82c82ac0 ffff880091890c80 ffff8800908c7d20 ffffffff810e7786
[   25.844354]  ffff8800908c7d28 ffffffff00000001 0000000000000000 ffffffff8257be00
[   25.845271] Call Trace:
[   25.845653]  [<ffffffff814a0835>] dump_stack+0x86/0xc1
[   25.846068]  [<ffffffff810e7786>] __lock_acquire+0x726/0x1210
[   25.846519]  [<ffffffff8104a425>] ? kvm_sched_clock_read+0x25/0x40
[   25.846941]  [<ffffffff8101f6f9>] ? sched_clock+0x9/0x10
[   25.847358]  [<ffffffff813841bc>] ? __nfs_revalidate_mapping+0xec/0x3e0
[   25.847787]  [<ffffffff8104a425>] ? kvm_sched_clock_read+0x25/0x40
[   25.848210]  [<ffffffff8101f6f9>] ? sched_clock+0x9/0x10
[   25.848630]  [<ffffffff810e86de>] lock_acquire+0xfe/0x1f0
[   25.849046]  [<ffffffff813841f4>] ? __nfs_revalidate_mapping+0x124/0x3e0
[   25.849503]  [<ffffffff818884aa>] down_write+0x5a/0xc0
[   25.849919]  [<ffffffff813841f4>] ? __nfs_revalidate_mapping+0x124/0x3e0
[   25.850355]  [<ffffffff813841f4>] __nfs_revalidate_mapping+0x124/0x3e0
[   25.850781]  [<ffffffff81384b53>] nfs_revalidate_mapping_protected+0x13/0x20
[   25.851214]  [<ffffffff8137f587>] nfs_file_read+0x47/0xc0
[   25.851636]  [<ffffffff8126a3f5>] __vfs_read+0xe5/0x150
[   25.852051]  [<ffffffff8126b569>] vfs_read+0x99/0x140
[   25.852485]  [<ffffffff8126cab8>] SyS_read+0x58/0xc0
[   25.852892]  [<ffffffff8188adbc>] entry_SYSCALL_64_fastpath+0x1f/0xbd

On Jun 21, 2016, at 5:34 PM, Trond Myklebust wrote:

> Unless the user is using file locking, we must assume close-to-open
> cache consistency when the file is open for writing. Adjust the
> caching algorithm so that it does not clear the cache on out-of-order
> writes and/or attribute revalidations.
> 
> Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
> ---
> fs/nfs/file.c  | 13 ++-----------
> fs/nfs/inode.c | 58 ++++++++++++++++++++++++++++++++++++++++------------------
> 2 files changed, 42 insertions(+), 29 deletions(-)
> 
> diff --git a/fs/nfs/file.c b/fs/nfs/file.c
> index 717a8d6af52d..2d39d9f9da7d 100644
> --- a/fs/nfs/file.c
> +++ b/fs/nfs/file.c
> @@ -780,11 +780,6 @@ do_unlk(struct file *filp, int cmd, struct file_lock *fl, int is_local)
> }
> 
> static int
> -is_time_granular(struct timespec *ts) {
> -	return ((ts->tv_sec == 0) && (ts->tv_nsec <= 1000));
> -}
> -
> -static int
> do_setlk(struct file *filp, int cmd, struct file_lock *fl, int is_local)
> {
> 	struct inode *inode = filp->f_mapping->host;
> @@ -817,12 +812,8 @@ do_setlk(struct file *filp, int cmd, struct file_lock *fl, int is_local)
> 	 * This makes locking act as a cache coherency point.
> 	 */
> 	nfs_sync_mapping(filp->f_mapping);
> -	if (!NFS_PROTO(inode)->have_delegation(inode, FMODE_READ)) {
> -		if (is_time_granular(&NFS_SERVER(inode)->time_delta))
> -			__nfs_revalidate_inode(NFS_SERVER(inode), inode);
> -		else
> -			nfs_zap_caches(inode);
> -	}
> +	if (!NFS_PROTO(inode)->have_delegation(inode, FMODE_READ))
> +		nfs_zap_mapping(inode, filp->f_mapping);
> out:
> 	return status;
> }
> diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
> index 60051e62d3f1..bd0390da3344 100644
> --- a/fs/nfs/inode.c
> +++ b/fs/nfs/inode.c
> @@ -878,7 +878,10 @@ void nfs_inode_attach_open_context(struct nfs_open_context *ctx)
> 	struct nfs_inode *nfsi = NFS_I(inode);
> 
> 	spin_lock(&inode->i_lock);
> -	list_add(&ctx->list, &nfsi->open_files);
> +	if (ctx->mode & FMODE_WRITE)
> +		list_add(&ctx->list, &nfsi->open_files);
> +	else
> +		list_add_tail(&ctx->list, &nfsi->open_files);
> 	spin_unlock(&inode->i_lock);
> }
> EXPORT_SYMBOL_GPL(nfs_inode_attach_open_context);
> @@ -1215,6 +1218,21 @@ int nfs_revalidate_mapping_protected(struct inode *inode, struct address_space *
> 	return __nfs_revalidate_mapping(inode, mapping, true);
> }
> 
> +static bool nfs_file_has_writers(struct nfs_inode *nfsi)
> +{
> +	assert_spin_locked(&nfsi->vfs_inode.i_lock);
> +
> +	if (list_empty(&nfsi->open_files))
> +		return false;
> +	/* Note: This relies on nfsi->open_files being ordered with writers
> +	 *       being placed at the head of the list.
> +	 *       See nfs_inode_attach_open_context()
> +	 */
> +	return (list_first_entry(&nfsi->open_files,
> +			struct nfs_open_context,
> +			list)->mode & FMODE_WRITE) == FMODE_WRITE;
> +}
> +
> static unsigned long nfs_wcc_update_inode(struct inode *inode, struct nfs_fattr *fattr)
> {
> 	struct nfs_inode *nfsi = NFS_I(inode);
> @@ -1279,22 +1297,24 @@ static int nfs_check_inode_attributes(struct inode *inode, struct nfs_fattr *fat
> 	if ((fattr->valid & NFS_ATTR_FATTR_TYPE) && (inode->i_mode & S_IFMT) != (fattr->mode & S_IFMT))
> 		return -EIO;
> 
> -	if ((fattr->valid & NFS_ATTR_FATTR_CHANGE) != 0 &&
> -			inode->i_version != fattr->change_attr)
> -		invalid |= NFS_INO_INVALID_ATTR|NFS_INO_REVAL_PAGECACHE;
> +	if (!nfs_file_has_writers(nfsi)) {
> +		/* Verify a few of the more important attributes */
> +		if ((fattr->valid & NFS_ATTR_FATTR_CHANGE) != 0 && inode->i_version != fattr->change_attr)
> +			invalid |= NFS_INO_INVALID_ATTR | NFS_INO_REVAL_PAGECACHE;
> 
> -	/* Verify a few of the more important attributes */
> -	if ((fattr->valid & NFS_ATTR_FATTR_MTIME) && !timespec_equal(&inode->i_mtime, &fattr->mtime))
> -		invalid |= NFS_INO_INVALID_ATTR;
> +		if ((fattr->valid & NFS_ATTR_FATTR_MTIME) && !timespec_equal(&inode->i_mtime, &fattr->mtime))
> +			invalid |= NFS_INO_INVALID_ATTR;
> 
> -	if (fattr->valid & NFS_ATTR_FATTR_SIZE) {
> -		cur_size = i_size_read(inode);
> -		new_isize = nfs_size_to_loff_t(fattr->size);
> -		if (cur_size != new_isize)
> -			invalid |= NFS_INO_INVALID_ATTR|NFS_INO_REVAL_PAGECACHE;
> +		if ((fattr->valid & NFS_ATTR_FATTR_CTIME) && !timespec_equal(&inode->i_ctime, &fattr->ctime))
> +			invalid |= NFS_INO_INVALID_ATTR;
> +
> +		if (fattr->valid & NFS_ATTR_FATTR_SIZE) {
> +			cur_size = i_size_read(inode);
> +			new_isize = nfs_size_to_loff_t(fattr->size);
> +			if (cur_size != new_isize)
> +				invalid |= NFS_INO_INVALID_ATTR|NFS_INO_REVAL_PAGECACHE;
> +		}
> 	}
> -	if (nfsi->nrequests != 0)
> -		invalid &= ~NFS_INO_REVAL_PAGECACHE;
> 
> 	/* Have any file permissions changed? */
> 	if ((fattr->valid & NFS_ATTR_FATTR_MODE) && (inode->i_mode & S_IALLUGO) != (fattr->mode & S_IALLUGO))
> @@ -1526,7 +1546,7 @@ EXPORT_SYMBOL_GPL(nfs_refresh_inode);
> 
> static int nfs_post_op_update_inode_locked(struct inode *inode, struct nfs_fattr *fattr)
> {
> -	unsigned long invalid = NFS_INO_INVALID_ATTR|NFS_INO_REVAL_PAGECACHE;
> +	unsigned long invalid = NFS_INO_INVALID_ATTR;
> 
> 	/*
> 	 * Don't revalidate the pagecache if we hold a delegation, but do
> @@ -1675,6 +1695,7 @@ static int nfs_update_inode(struct inode *inode, struct nfs_fattr *fattr)
> 	unsigned long invalid = 0;
> 	unsigned long now = jiffies;
> 	unsigned long save_cache_validity;
> +	bool have_writers = nfs_file_has_writers(nfsi);
> 	bool cache_revalidated = true;
> 
> 	dfprintk(VFS, "NFS: %s(%s/%lu fh_crc=0x%08x ct=%d info=0x%x)\n",
> @@ -1730,7 +1751,7 @@ static int nfs_update_inode(struct inode *inode, struct nfs_fattr *fattr)
> 			dprintk("NFS: change_attr change on server for file %s/%ld\n",
> 					inode->i_sb->s_id, inode->i_ino);
> 			/* Could it be a race with writeback? */
> -			if (nfsi->nrequests == 0) {
> +			if (!have_writers) {
> 				invalid |= NFS_INO_INVALID_ATTR
> 					| NFS_INO_INVALID_DATA
> 					| NFS_INO_INVALID_ACCESS
> @@ -1770,9 +1791,10 @@ static int nfs_update_inode(struct inode *inode, struct nfs_fattr *fattr)
> 		if (new_isize != cur_isize) {
> 			/* Do we perhaps have any outstanding writes, or has
> 			 * the file grown beyond our last write? */
> -			if ((nfsi->nrequests == 0) || new_isize > cur_isize) {
> +			if (nfsi->nrequests == 0 || new_isize > cur_isize) {
> 				i_size_write(inode, new_isize);
> -				invalid |= NFS_INO_INVALID_ATTR|NFS_INO_INVALID_DATA;
> +				if (!have_writers)
> +					invalid |= NFS_INO_INVALID_ATTR|NFS_INO_INVALID_DATA;
> 			}
> 			dprintk("NFS: isize change on server for file %s/%ld "
> 					"(%Ld to %Ld)\n",
> -- 
> 2.5.5
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

