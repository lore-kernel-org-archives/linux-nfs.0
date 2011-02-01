Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:16301 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752177Ab1BAPyC convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 1 Feb 2011 10:54:02 -0500
Subject: Re: [PATCH 3/3] pnfs: fix pnfs lock inversion of i_lock and cl_lock
Content-Type: text/plain; charset=us-ascii
From: Fred Isaman <iisaman@netapp.com>
In-Reply-To: <4D48299F.4070800@panasas.com>
Date: Tue, 1 Feb 2011 10:54:00 -0500
Cc: linux-nfs@vger.kernel.org, Trond Myklebust <Trond.Myklebust@netapp.com>
Message-Id: <80A4262E-EA90-44A4-96A6-23464177BAA6@netapp.com>
References: <1296487633-21057-1-git-send-email-iisaman@netapp.com> <1296487633-21057-4-git-send-email-iisaman@netapp.com> <4D48299F.4070800@panasas.com>
To: Benny Halevy <bhalevy@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0


On Feb 1, 2011, at 10:41 AM, Benny Halevy wrote:

> I'm actually seeing that with the pnfs tree over 2.8.38-rc3
> See signature below.
> Will re-test with this patch.
> 

In your retest, note that this patch depends on patch 1 of the series to work correctly.

Fred

> Benny
> 
> [ INFO: possible circular locking dependency detected ]                        
> 2.6.38-rc3-pnfs-00391-g13858b7 #5                                              
> -------------------------------------------------------                        
> test5/2174 is trying to acquire lock:                                          
> (&sb->s_type->i_lock_key#24){+.+...}, at: [<ffffffffa018e924>] nfs_inode_set_]
> 
> but task is already holding lock:                                              
> (&(&clp->cl_lock)->rlock){+.+...}, at: [<ffffffffa018e822>] nfs_inode_set_del]
> 
> which lock already depends on the new lock.                                    
> 
> 
> the existing dependency chain (in reverse order) is:                           
> 
> -> #1 (&(&clp->cl_lock)->rlock){+.+...}:                                       
>       [<ffffffff8108281f>] lock_acquire+0xd3/0x100                            
>       [<ffffffff8147df43>] _raw_spin_lock+0x36/0x69                           
>       [<ffffffffa0193b87>] pnfs_update_layout+0x2f5/0x4d9 [nfs]               
>       [<ffffffffa0166862>] nfs_write_begin+0x90/0x257 [nfs]                   
>       [<ffffffff810e1d7b>] generic_file_buffered_write+0x106/0x267            
>       [<ffffffff810e33a8>] __generic_file_aio_write+0x245/0x27a               
>       [<ffffffff810e3439>] generic_file_aio_write+0x5c/0xaa                   
>       [<ffffffffa016728b>] nfs_file_write+0xdf/0x177 [nfs]                    
>       [<ffffffff8112b599>] do_sync_write+0xcb/0x108                           
>       [<ffffffff8112bf97>] vfs_write+0xb1/0x10d                               
>       [<ffffffff8112c0bc>] sys_write+0x4d/0x77                                
>       [<ffffffff8100ab82>] system_call_fastpath+0x16/0x1b                     
> 
> -> #0 (&sb->s_type->i_lock_key#24){+.+...}:                                    
>       [<ffffffff81082457>] __lock_acquire+0xa45/0xd3a                         
>       [<ffffffff8108281f>] lock_acquire+0xd3/0x100                            
>       [<ffffffff8147df43>] _raw_spin_lock+0x36/0x69                           
>       [<ffffffffa018e924>] nfs_inode_set_delegation+0x1f4/0x250 [nfs]         
>       [<ffffffffa017cb9b>] nfs4_opendata_to_nfs4_state+0x26c/0x2c9 [nfs]      
>       [<ffffffffa0181827>] nfs4_do_open+0x364/0x37c [nfs]                     
>       [<ffffffffa0181867>] nfs4_atomic_open+0x28/0x45 [nfs]                   
>       [<ffffffffa0165edc>] nfs_open_revalidate+0xf8/0x1a1 [nfs]               
>       [<ffffffff81135111>] d_revalidate+0x21/0x56                             
>       [<ffffffff811351ca>] do_revalidate+0x1d/0x7a                            
>       [<ffffffff811353eb>] do_lookup+0x1c4/0x1f8                              
>       [<ffffffff81137406>] link_path_walk+0x260/0x485                         
>       [<ffffffff8113786a>] do_path_lookup+0x50/0x10d                          
>       [<ffffffff81138658>] do_filp_open+0x137/0x65e                           
>       [<ffffffff81129e6e>] do_sys_open+0x60/0xf2                              
>       [<ffffffff81129f33>] sys_open+0x20/0x22                                 
>       [<ffffffff8100ab82>] system_call_fastpath+0x16/0x1b                     
> 
> 
> On 2011-01-31 17:27, Fred Isaman wrote:
>> The pnfs code was using throughout the lock order i_lock, cl_lock.
>> This conflicts with the nfs delegation code.  Rework the pnfs code
>> to avoid taking both locks simultaneously.
>> 
>> Currently the code takes the double lock to add/remove the layout to a
>> nfs_client list, while atomically checking that the list of lsegs is
>> empty.  To avoid this, we rely on existing serializations.  When a
>> layout is initialized with lseg count equal zero, LAYOUTGET's
>> openstateid serialization is in effect, making it safe to assume it
>> stays zero unless we change it.  And once a layout's lseg count drops
>> to zero, it is set as DESTROYED and so will stay at zero.
>> 
>> Signed-off-by: Fred Isaman <iisaman@netapp.com>
>> ---
>> fs/nfs/callback_proc.c |    2 +-
>> fs/nfs/pnfs.c          |   50 +++++++++++++++++++++++++++--------------------
>> 2 files changed, 30 insertions(+), 22 deletions(-)
>> 
>> diff --git a/fs/nfs/callback_proc.c b/fs/nfs/callback_proc.c
>> index 8958757..2f41dcce 100644
>> --- a/fs/nfs/callback_proc.c
>> +++ b/fs/nfs/callback_proc.c
>> @@ -188,10 +188,10 @@ static u32 initiate_bulk_draining(struct nfs_client *clp,
>> 			rv = NFS4ERR_DELAY;
>> 		list_del_init(&lo->plh_bulk_recall);
>> 		spin_unlock(&ino->i_lock);
>> +		pnfs_free_lseg_list(&free_me_list);
>> 		put_layout_hdr(lo);
>> 		iput(ino);
>> 	}
>> -	pnfs_free_lseg_list(&free_me_list);
>> 	return rv;
>> }
>> 
>> diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
>> index f89c3bb..ee6c69a 100644
>> --- a/fs/nfs/pnfs.c
>> +++ b/fs/nfs/pnfs.c
>> @@ -247,13 +247,6 @@ put_lseg_locked(struct pnfs_layout_segment *lseg,
>> 		BUG_ON(test_bit(NFS_LSEG_VALID, &lseg->pls_flags));
>> 		list_del(&lseg->pls_list);
>> 		if (list_empty(&lseg->pls_layout->plh_segs)) {
>> -			struct nfs_client *clp;
>> -
>> -			clp = NFS_SERVER(ino)->nfs_client;
>> -			spin_lock(&clp->cl_lock);
>> -			/* List does not take a reference, so no need for put here */
>> -			list_del_init(&lseg->pls_layout->plh_layouts);
>> -			spin_unlock(&clp->cl_lock);
>> 			set_bit(NFS_LAYOUT_DESTROYED, &lseg->pls_layout->plh_flags);
>> 			/* Matched by initial refcount set in alloc_init_layout_hdr */
>> 			put_layout_hdr_locked(lseg->pls_layout);
>> @@ -319,14 +312,30 @@ mark_matching_lsegs_invalid(struct pnfs_layout_hdr *lo,
>> 	return invalid - removed;
>> }
>> 
>> +/* note free_me must contain lsegs from a single layout_hdr */
>> void
>> pnfs_free_lseg_list(struct list_head *free_me)
>> {
>> -	struct pnfs_layout_segment *lseg, *tmp;
>> +	if (!list_empty(free_me)) {
>> +		struct pnfs_layout_segment *lseg, *tmp;
>> +		struct pnfs_layout_hdr *lo;
>> 
>> -	list_for_each_entry_safe(lseg, tmp, free_me, pls_list) {
>> -		list_del(&lseg->pls_list);
>> -		free_lseg(lseg);
>> +		lo = list_first_entry(free_me,
>> +				      struct pnfs_layout_segment,
>> +				      pls_list)->pls_layout;
>> +
>> +		if (test_bit(NFS_LAYOUT_DESTROYED, &lo->plh_flags)) {
>> +			struct nfs_client *clp;
>> +
>> +			clp = NFS_SERVER(lo->plh_inode)->nfs_client;
>> +			spin_lock(&clp->cl_lock);
>> +			list_del_init(&lo->plh_layouts);
>> +			spin_unlock(&clp->cl_lock);
>> +		}
>> +		list_for_each_entry_safe(lseg, tmp, free_me, pls_list) {
>> +			list_del(&lseg->pls_list);
>> +			free_lseg(lseg);
>> +		}
>> 	}
>> }
>> 
>> @@ -704,6 +713,7 @@ pnfs_update_layout(struct inode *ino,
>> 	struct nfs_client *clp = NFS_SERVER(ino)->nfs_client;
>> 	struct pnfs_layout_hdr *lo;
>> 	struct pnfs_layout_segment *lseg = NULL;
>> +	bool first = false;
>> 
>> 	if (!pnfs_enabled_sb(NFS_SERVER(ino)))
>> 		return NULL;
>> @@ -734,7 +744,10 @@ pnfs_update_layout(struct inode *ino,
>> 	atomic_inc(&lo->plh_outstanding);
>> 
>> 	get_layout_hdr(lo);
>> -	if (list_empty(&lo->plh_segs)) {
>> +	if (list_empty(&lo->plh_segs))
>> +		first = true;
>> +	spin_unlock(&ino->i_lock);
>> +	if (first) {
>> 		/* The lo must be on the clp list if there is any
>> 		 * chance of a CB_LAYOUTRECALL(FILE) coming in.
>> 		 */
>> @@ -743,17 +756,12 @@ pnfs_update_layout(struct inode *ino,
>> 		list_add_tail(&lo->plh_layouts, &clp->cl_layouts);
>> 		spin_unlock(&clp->cl_lock);
>> 	}
>> -	spin_unlock(&ino->i_lock);
>> 
>> 	lseg = send_layoutget(lo, ctx, iomode);
>> -	if (!lseg) {
>> -		spin_lock(&ino->i_lock);
>> -		if (list_empty(&lo->plh_segs)) {
>> -			spin_lock(&clp->cl_lock);
>> -			list_del_init(&lo->plh_layouts);
>> -			spin_unlock(&clp->cl_lock);
>> -		}
>> -		spin_unlock(&ino->i_lock);
>> +	if (!lseg && first) {
>> +		spin_lock(&clp->cl_lock);
>> +		list_del_init(&lo->plh_layouts);
>> +		spin_unlock(&clp->cl_lock);
>> 	}
>> 	atomic_dec(&lo->plh_outstanding);
>> 	put_layout_hdr(lo);

