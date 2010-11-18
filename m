Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:40553 "EHLO
	daytona.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755557Ab0KRMop (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 18 Nov 2010 07:44:45 -0500
Message-ID: <4CE51FBA.6060806@panasas.com>
Date: Thu, 18 Nov 2010 14:44:42 +0200
From: Boaz Harrosh <bharrosh@panasas.com>
To: Benny Halevy <bhalevy@panasas.com>
CC: linux-nfs@vger.kernel.org, Andy Adamson <andros@netapp.com>
Subject: Re: [PATCH] SQUASHME: pnfs: move synchronize_rcu out side of spin_lock
References: <1290015704-6221-1-git-send-email-bhalevy@panasas.com>
In-Reply-To: <1290015704-6221-1-git-send-email-bhalevy@panasas.com>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 11/17/2010 07:41 PM, Benny Halevy wrote:
> squash into 4a28356  pnfs: CB_NOTIFY_DEVICEID
> 
> We currently call pnfs_unhash_deviceid under spin_lock c->dc_lock
> But pnfs_unhash_deviceid calls synchronize_rcu which may sched.
> This resulted in the following BUG with the cthon tests:
> 
> Nov 17 18:54:56 tl1 kernel: BUG: spinlock wrong CPU on CPU#1, test5/2170
> Nov 17 18:54:56 tl1 kernel: lock: ffff880070559ff0, .magic: dead4ead, .owner: test5/2170, .owner_cpu: 0
> Nov 17 18:54:56 tl1 kernel: Pid: 2170, comm: test5 Not tainted 2.6.37-rc2-pnfs #167
> Nov 17 18:54:56 tl1 kernel: Call Trace:
> Nov 17 18:54:56 tl1 kernel: [<ffffffff8122cfc5>] spin_bug+0x9c/0xa3
> Nov 17 18:54:56 tl1 kernel: [<ffffffff8122d042>] do_raw_spin_unlock+0x76/0x8d
> Nov 17 18:54:56 tl1 kernel: [<ffffffff814534ea>] _raw_spin_unlock+0x2b/0x30
> Nov 17 18:54:56 tl1 kernel: [<ffffffffa03c62fc>] pnfs_put_deviceid+0x59/0x64 [nfs]
> Nov 17 18:54:56 tl1 kernel: [<ffffffffa0018551>] filelayout_free_lseg+0x5a/0x6f [nfs_layout_nfsv41_files]
> Nov 17 18:54:56 tl1 kernel: [<ffffffffa03c6ea8>] pnfs_free_lseg_list+0x4e/0x8b [nfs]
> Nov 17 18:54:56 tl1 kernel: [<ffffffffa03c85a4>] _pnfs_return_layout+0xe3/0x213 [nfs]
> Nov 17 18:54:56 tl1 kernel: [<ffffffffa039bcb2>] nfs4_evict_inode+0x41/0x74 [nfs]
> Nov 17 18:54:56 tl1 kernel: [<ffffffff8112cab6>] evict+0x27/0x97
> Nov 17 18:54:56 tl1 kernel: [<ffffffff8112d051>] iput+0x20c/0x243
> Nov 17 18:54:56 tl1 kernel: [<ffffffff8112476c>] do_unlinkat+0x11c/0x16f
> Nov 17 18:54:56 tl1 kernel: [<ffffffff81118750>] ? fsnotify_modify+0x66/0x6e
> Nov 17 18:54:56 tl1 kernel: [<ffffffff81452cbe>] ? lockdep_sys_exit_thunk+0x35/0x67
> Nov 17 18:54:56 tl1 kernel: [<ffffffff810a0b51>] ? audit_syscall_entry+0x11e/0x14a
> Nov 17 18:54:56 tl1 kernel: [<ffffffff811247d5>] sys_unlink+0x16/0x18
> Nov 17 18:54:56 tl1 kernel: [<ffffffff8100acf2>] system_call_fastpath+0x16/0x1b
> 
> Signed-off-by: Benny Halevy <bhalevy@panasas.com>
> ---
>  fs/nfs/pnfs.c |    5 ++---
>  1 files changed, 2 insertions(+), 3 deletions(-)
> 
> diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
> index 559fcce..39c7d9f 100644
> --- a/fs/nfs/pnfs.c
> +++ b/fs/nfs/pnfs.c
> @@ -1651,7 +1651,6 @@ pnfs_unhash_deviceid(struct pnfs_deviceid_cache *c,
>  	hlist_for_each_entry_rcu(d, n, &c->dc_deviceids[h], de_node)
>  		if (!memcmp(&d->de_id, id, sizeof(*id))) {
>  			hlist_del_rcu(&d->de_node);
> -			synchronize_rcu();
>  			return d;
>  		}
>  
> @@ -1672,7 +1671,7 @@ pnfs_put_deviceid(struct pnfs_deviceid_cache *c,
>  
>  	pnfs_unhash_deviceid(c, &devid->de_id);
>  	spin_unlock(&c->dc_lock);
> -
> +	synchronize_rcu();
>  	c->dc_free_callback(devid);
>  }
>  EXPORT_SYMBOL_GPL(pnfs_put_deviceid);
> @@ -1686,7 +1685,7 @@ pnfs_delete_deviceid(struct pnfs_deviceid_cache *c,
>  	spin_lock(&c->dc_lock);
>  	devid = pnfs_unhash_deviceid(c, id);
>  	spin_unlock(&c->dc_lock);
> -
> +	synchronize_rcu();
>  	dprintk("%s [%d]\n", __func__, atomic_read(&devid->de_ref));
>  	if (atomic_dec_and_test(&devid->de_ref))
>  		c->dc_free_callback(devid);

OK, so I don't like this fix because before we only synchronize_rcu()
after an actual hlist_del_rcu. 

If we look at the two callers

  pnfs_put_deviceid()
	if (!atomic_dec_and_lock(&devid->de_ref, &c->dc_lock))
		return;

	pnfs_unhash_deviceid(c, &devid->de_id);
	spin_unlock(&c->dc_lock);

  pnfs_delete_deviceid
  	spin_lock(&c->dc_lock);
  	devid = pnfs_unhash_deviceid(c, id);
  	spin_unlock(&c->dc_lock);


The pnfs_put_deviceid does an atomic_dec_and_lock so not to race with
pnfs_find_get_deviceid. But in pnfs_find_get_deviceid we do atomic_inc_not_zero
so we don't need that we can change pnfs_put_deviceid to just atomic_dec_and_test
and then take the lock inside pnfs_unhash_deviceid, and remove from callers.
Some thing like below. (Untested, only compiled)

---
diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index 61310c7..5d4e14d 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -1598,16 +1598,21 @@ pnfs_unhash_deviceid(struct pnfs_deviceid_cache *c,
 {
 	struct pnfs_deviceid_node *d;
 	struct hlist_node *n;
-	long h = nfs4_deviceid_hash(id);
+	long h;
+
+	spin_lock(&c->dc_lock);
+	h = nfs4_deviceid_hash(id);
 
 	dprintk("%s hash %ld\n", __func__, h);
 	hlist_for_each_entry_rcu(d, n, &c->dc_deviceids[h], de_node)
 		if (!memcmp(&d->de_id, id, sizeof(*id))) {
 			hlist_del_rcu(&d->de_node);
+			spin_unlock(&c->dc_lock);
 			synchronize_rcu();
 			return d;
 		}
 
+	spin_unlock(&c->dc_lock);
 	return NULL;
 }
 
@@ -1620,11 +1625,10 @@ pnfs_put_deviceid(struct pnfs_deviceid_cache *c,
 		  struct pnfs_deviceid_node *devid)
 {
 	dprintk("%s [%d]\n", __func__, atomic_read(&devid->de_ref));
-	if (!atomic_dec_and_lock(&devid->de_ref, &c->dc_lock))
+	if (!atomic_dec_and_test(&devid->de_ref))
 		return;
 
 	pnfs_unhash_deviceid(c, &devid->de_id);
-	spin_unlock(&c->dc_lock);
 
 	c->dc_free_callback(devid);
 }
@@ -1636,9 +1640,7 @@ pnfs_delete_deviceid(struct pnfs_deviceid_cache *c,
 {
 	struct pnfs_deviceid_node *devid;
 
-	spin_lock(&c->dc_lock);
 	devid = pnfs_unhash_deviceid(c, id);
-	spin_unlock(&c->dc_lock);
 
 	dprintk("%s [%d]\n", __func__, atomic_read(&devid->de_ref));
 	if (atomic_dec_and_test(&devid->de_ref))


