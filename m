Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from linuxhacker.ru ([217.76.32.60]:40564 "EHLO fiona.linuxhacker.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754113AbcFQBLm convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 16 Jun 2016 21:11:42 -0400
Subject: Re: [PATCH 03/12] NFS: Cache aggressively when file is open for writing
Mime-Version: 1.0 (Apple Message framework v1283)
Content-Type: text/plain; charset=us-ascii
From: Oleg Drokin <green@linuxhacker.ru>
In-Reply-To: <1465931115-30784-3-git-send-email-trond.myklebust@primarydata.com>
Date: Thu, 16 Jun 2016 21:11:32 -0400
Cc: linux-nfs@vger.kernel.org
Message-Id: <87A9597E-A1F5-4DBE-B3C1-12369E5DF994@linuxhacker.ru>
References: <1465931115-30784-1-git-send-email-trond.myklebust@primarydata.com> <1465931115-30784-2-git-send-email-trond.myklebust@primarydata.com> <1465931115-30784-3-git-send-email-trond.myklebust@primarydata.com>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

I get almost-insta-crash with this patch (really, just testing
the testing branch, but in the code this patch introduced).
-rc2 did not have this sort of crash, so it must be a new one.

On Jun 14, 2016, at 3:05 PM, Trond Myklebust wrote:

> Unless the user is using file locking, we must assume close-to-open
> cache consistency when the file is open for writing. Adjust the
> caching algorithm so that it does not clear the cache on out-of-order
> writes and/or attribute revalidations.
> 
> Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
> ---
> fs/nfs/file.c  | 13 ++-----------
> fs/nfs/inode.c | 56 +++++++++++++++++++++++++++++++++++++++-----------------
> 2 files changed, 41 insertions(+), 28 deletions(-)
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
> index 60051e62d3f1..8a808d25dbc8 100644
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

The crash address points here ^^:
gdb> l *(nfs_refresh_inode_locked+0x249)
0xffffffff81382c39 is in nfs_refresh_inode_locked (/home/green/bk/linux-test/fs/nfs/inode.c:1301).
1301		if (!nfs_file_has_writers(nfsi)) {

Did some racing thread just kill the inode under this thread I wonder?

[  264.739757] BUG: unable to handle kernel paging request at ffff88009875ffe8
[  264.740468] IP: [<ffffffff81382c39>] nfs_refresh_inode_locked+0x249/0x4e0
[  264.741080] PGD 3580067 PUD 3583067 PMD bce56067 PTE 800000009875f060
[  264.741836] Oops: 0000 [#1] SMP DEBUG_PAGEALLOC
[  264.742357] Modules linked in: loop rpcsec_gss_krb5 acpi_cpufreq tpm_tis joydev tpm virtio_console pcspkr i2c_piix4 nfsd ttm drm_kms_helper syscopyarea sysfillrect sysimgblt fb_sys_fops drm floppy serio_raw
[  264.785009] CPU: 7 PID: 34494 Comm: ls Not tainted 4.7.0-rc3-vm-nfs+ #2
[  264.785559] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS 1.8.2-20150714_191134- 04/01/2014
[  264.786545] task: ffff88009f78cac0 ti: ffff88009f780000 task.ti: ffff88009f780000
[  264.787596] RIP: 0010:[<ffffffff81382c39>]  [<ffffffff81382c39>] nfs_refresh_inode_locked+0x249/0x4e0
[  264.788628] RSP: 0018:ffff88009f783b58  EFLAGS: 00010246
[  264.789151] RAX: 0000000000000000 RBX: ffff8800aa48b348 RCX: ffff880098760000
[  264.789708] RDX: 0000000000027e7f RSI: 0000000000000001 RDI: ffff8800aa48b348
[  264.792533] RBP: ffff88009f783b70 R08: 0000000000000000 R09: 0000000000000001
[  264.793090] R10: ffff8800aa48b3e8 R11: 0000000000000000 R12: ffff8800aa48b348
[  264.793647] R13: ffff880093f8cf00 R14: ffff880089eb10c0 R15: ffff88009f783de0
[  264.794204] FS:  00007fefee488800(0000) GS:ffff8800b9000000(0000) knlGS:0000000000000000
[  264.795154] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[  264.795686] CR2: ffff88009875ffe8 CR3: 000000009f3ab000 CR4: 00000000000006e0
[  264.796243] Stack:
[  264.796708]  ffff8800aa48b3d0 ffff8800aa48b348 ffff880093f8cf00 ffff88009f783b98
[  264.797853]  ffffffff81382efe ffff8800aa48b348 ffff88009f783c38 0000000000000000
[  264.798996]  ffff88009f783ba8 ffffffff81382f39 ffff88009f783c18 ffffffff81396fe3
[  264.824881] Call Trace:
[  264.825366]  [<ffffffff81382efe>] nfs_refresh_inode.part.24+0x2e/0x50
[  264.825908]  [<ffffffff81382f39>] nfs_refresh_inode+0x19/0x20
[  264.826441]  [<ffffffff81396fe3>] nfs3_proc_access+0xd3/0x190
[  264.826971]  [<ffffffff8137c66c>] nfs_do_access+0x3ec/0x620
[  264.837497]  [<ffffffff8137c2d1>] ? nfs_do_access+0x51/0x620
[  264.838029]  [<ffffffff818507ea>] ? generic_lookup_cred+0x1a/0x20
[  264.838585]  [<ffffffff8184ef7e>] ? rpcauth_lookupcred+0x8e/0xd0
[  264.839120]  [<ffffffff8137cb69>] nfs_permission+0x289/0x2e0
[  264.839667]  [<ffffffff8137c943>] ? nfs_permission+0x63/0x2e0
[  264.840201]  [<ffffffff812768da>] __inode_permission+0x6a/0xb0
[  264.850580]  [<ffffffff81276934>] inode_permission+0x14/0x50
[  264.851113]  [<ffffffff81276a8c>] may_open+0x8c/0x100
[  264.851635]  [<ffffffff8127bdc6>] path_openat+0x596/0xc20
[  264.852160]  [<ffffffff8127d9b1>] do_filp_open+0x91/0x100
[  264.852689]  [<ffffffff8188a557>] ? _raw_spin_unlock+0x27/0x40
[  264.853223]  [<ffffffff8128f010>] ? __alloc_fd+0x100/0x200
[  264.861053]  [<ffffffff81269f90>] do_sys_open+0x130/0x220
[  264.861582]  [<ffffffff8126a09e>] SyS_open+0x1e/0x20
[  264.862101]  [<ffffffff8188aebc>] entry_SYSCALL_64_fastpath+0x1f/0xbd

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

