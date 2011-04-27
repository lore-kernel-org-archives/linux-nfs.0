Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:41778 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755963Ab1D0S4p convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 27 Apr 2011 14:56:45 -0400
Subject: Re: [PATCH] NFS: move pnfs layouts to nfs_server structure
Content-Type: text/plain; charset=us-ascii
From: Dros Adamson <dros@netapp.com>
In-Reply-To: <4DB8659A.8020206@panasas.com>
Date: Wed, 27 Apr 2011 14:56:31 -0400
Cc: trond@netapp.com, linux-nfs@vger.kernel.org
Message-Id: <B2051E16-6792-4DE7-B679-C28BED3D3B3F@netapp.com>
References: <1303922649-25478-1-git-send-email-dros@netapp.com> <4DB8659A.8020206@panasas.com>
To: Benny Halevy <bhalevy@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0


On Apr 27, 2011, at 2:51 PM, Benny Halevy wrote:

> On 2011-04-27 19:44, Weston Andros Adamson wrote:
>> Layouts should be tracked per FSID (aka superblock, aka struct nfs_server)
>> instead of per struct nfs_client, which may have multiple FSIDs associated
>> with it.
>> 
>> Signed-off-by: Weston Andros Adamson <dros@netapp.com>
>> ---
>> fs/nfs/callback_proc.c    |   60 +++++++++++++++++++++++++++-----------------
>> fs/nfs/client.c           |    6 ++--
>> fs/nfs/pnfs.c             |   13 +++++++--
>> include/linux/nfs_fs_sb.h |    2 +-
>> 4 files changed, 51 insertions(+), 30 deletions(-)
>> 
>> diff --git a/fs/nfs/callback_proc.c b/fs/nfs/callback_proc.c
>> index 2f41dcce..3964467 100644
>> --- a/fs/nfs/callback_proc.c
>> +++ b/fs/nfs/callback_proc.c
>> @@ -111,6 +111,7 @@ int nfs4_validate_delegation_stateid(struct nfs_delegation *delegation, const nf
>> static u32 initiate_file_draining(struct nfs_client *clp,
>> 				  struct cb_layoutrecallargs *args)
>> {
>> +	struct nfs_server *server;
>> 	struct pnfs_layout_hdr *lo;
>> 	struct inode *ino;
>> 	bool found = false;
>> @@ -118,21 +119,28 @@ static u32 initiate_file_draining(struct nfs_client *clp,
>> 	LIST_HEAD(free_me_list);
>> 
>> 	spin_lock(&clp->cl_lock);
>> -	list_for_each_entry(lo, &clp->cl_layouts, plh_layouts) {
>> -		if (nfs_compare_fh(&args->cbl_fh,
>> -				   &NFS_I(lo->plh_inode)->fh))
>> -			continue;
>> -		ino = igrab(lo->plh_inode);
>> -		if (!ino)
>> -			continue;
>> -		found = true;
>> -		/* Without this, layout can be freed as soon
>> -		 * as we release cl_lock.
>> -		 */
>> -		get_layout_hdr(lo);
>> -		break;
>> +	rcu_read_lock();
>> +	list_for_each_entry_rcu(server, &clp->cl_superblocks, client_link) {
>> +		list_for_each_entry(lo, &server->layouts, plh_layouts) {
>> +			if (nfs_compare_fh(&args->cbl_fh,
>> +					   &NFS_I(lo->plh_inode)->fh))
>> +				continue;
>> +			ino = igrab(lo->plh_inode);
>> +			if (!ino)
>> +				continue;
>> +			found = true;
>> +			/* Without this, layout can be freed as soon
>> +			 * as we release cl_lock.
>> +			 */
>> +			get_layout_hdr(lo);
>> +			break;
>> +		}
>> +		if (found)
>> +			break;
>> 	}
>> +	rcu_read_unlock();
>> 	spin_unlock(&clp->cl_lock);
>> +
>> 	if (!found)
>> 		return NFS4ERR_NOMATCHING_LAYOUT;
>> 
>> @@ -154,6 +162,7 @@ static u32 initiate_file_draining(struct nfs_client *clp,
>> static u32 initiate_bulk_draining(struct nfs_client *clp,
>> 				  struct cb_layoutrecallargs *args)
>> {
>> +	struct nfs_server *server;
>> 	struct pnfs_layout_hdr *lo;
>> 	struct inode *ino;
>> 	u32 rv = NFS4ERR_NOMATCHING_LAYOUT;
>> @@ -167,18 +176,23 @@ static u32 initiate_bulk_draining(struct nfs_client *clp,
>> 	};
>> 
>> 	spin_lock(&clp->cl_lock);
>> -	list_for_each_entry(lo, &clp->cl_layouts, plh_layouts) {
>> -		if ((args->cbl_recall_type == RETURN_FSID) &&
>> -		    memcmp(&NFS_SERVER(lo->plh_inode)->fsid,
>> -			   &args->cbl_fsid, sizeof(struct nfs_fsid)))
>> -			continue;
>> -		if (!igrab(lo->plh_inode))
>> -			continue;
>> -		get_layout_hdr(lo);
>> -		BUG_ON(!list_empty(&lo->plh_bulk_recall));
>> -		list_add(&lo->plh_bulk_recall, &recall_list);
>> +	rcu_read_lock();
>> +	list_for_each_entry_rcu(server, &clp->cl_superblocks, client_link) {
>> +		list_for_each_entry(lo, &server->layouts, plh_layouts) {
>> +			if ((args->cbl_recall_type == RETURN_FSID) &&
>> +			    memcmp(&server->fsid, &args->cbl_fsid,
>> +				   sizeof(struct nfs_fsid)))
>> +				continue;
> 
> This condition can be popped up to the outer loop now...
> (or break rather than continue)
> 
> Benny

Good point.  Fred wanted me to wait until this patch got in to optimize handling RETURN_FSID.  Comments?

-dros