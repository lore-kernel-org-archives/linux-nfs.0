Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:3488 "EHLO
	daytona.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756121Ab1D0UcG (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 27 Apr 2011 16:32:06 -0400
Message-ID: <4DB87D31.2060808@panasas.com>
Date: Wed, 27 Apr 2011 23:31:45 +0300
From: Benny Halevy <bhalevy@panasas.com>
To: Dros Adamson <dros@netapp.com>
CC: trond@netapp.com, linux-nfs@vger.kernel.org
Subject: Re: [PATCH] NFS: move pnfs layouts to nfs_server structure
References: <1303922649-25478-1-git-send-email-dros@netapp.com> <4DB8659A.8020206@panasas.com> <B2051E16-6792-4DE7-B679-C28BED3D3B3F@netapp.com>
In-Reply-To: <B2051E16-6792-4DE7-B679-C28BED3D3B3F@netapp.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 2011-04-27 21:56, Dros Adamson wrote:
> 
> On Apr 27, 2011, at 2:51 PM, Benny Halevy wrote:
> 
>> On 2011-04-27 19:44, Weston Andros Adamson wrote:
>>> Layouts should be tracked per FSID (aka superblock, aka struct nfs_server)
>>> instead of per struct nfs_client, which may have multiple FSIDs associated
>>> with it.
>>>
>>> Signed-off-by: Weston Andros Adamson <dros@netapp.com>
>>> ---
>>> fs/nfs/callback_proc.c    |   60 +++++++++++++++++++++++++++-----------------
>>> fs/nfs/client.c           |    6 ++--
>>> fs/nfs/pnfs.c             |   13 +++++++--
>>> include/linux/nfs_fs_sb.h |    2 +-
>>> 4 files changed, 51 insertions(+), 30 deletions(-)
>>>
>>> diff --git a/fs/nfs/callback_proc.c b/fs/nfs/callback_proc.c
>>> index 2f41dcce..3964467 100644
>>> --- a/fs/nfs/callback_proc.c
>>> +++ b/fs/nfs/callback_proc.c
>>> @@ -111,6 +111,7 @@ int nfs4_validate_delegation_stateid(struct nfs_delegation *delegation, const nf
>>> static u32 initiate_file_draining(struct nfs_client *clp,
>>> 				  struct cb_layoutrecallargs *args)
>>> {
>>> +	struct nfs_server *server;
>>> 	struct pnfs_layout_hdr *lo;
>>> 	struct inode *ino;
>>> 	bool found = false;
>>> @@ -118,21 +119,28 @@ static u32 initiate_file_draining(struct nfs_client *clp,
>>> 	LIST_HEAD(free_me_list);
>>>
>>> 	spin_lock(&clp->cl_lock);
>>> -	list_for_each_entry(lo, &clp->cl_layouts, plh_layouts) {
>>> -		if (nfs_compare_fh(&args->cbl_fh,
>>> -				   &NFS_I(lo->plh_inode)->fh))
>>> -			continue;
>>> -		ino = igrab(lo->plh_inode);
>>> -		if (!ino)
>>> -			continue;
>>> -		found = true;
>>> -		/* Without this, layout can be freed as soon
>>> -		 * as we release cl_lock.
>>> -		 */
>>> -		get_layout_hdr(lo);
>>> -		break;
>>> +	rcu_read_lock();
>>> +	list_for_each_entry_rcu(server, &clp->cl_superblocks, client_link) {
>>> +		list_for_each_entry(lo, &server->layouts, plh_layouts) {
>>> +			if (nfs_compare_fh(&args->cbl_fh,
>>> +					   &NFS_I(lo->plh_inode)->fh))
>>> +				continue;
>>> +			ino = igrab(lo->plh_inode);
>>> +			if (!ino)
>>> +				continue;
>>> +			found = true;
>>> +			/* Without this, layout can be freed as soon
>>> +			 * as we release cl_lock.
>>> +			 */
>>> +			get_layout_hdr(lo);
>>> +			break;
>>> +		}
>>> +		if (found)
>>> +			break;
>>> 	}
>>> +	rcu_read_unlock();
>>> 	spin_unlock(&clp->cl_lock);
>>> +
>>> 	if (!found)
>>> 		return NFS4ERR_NOMATCHING_LAYOUT;
>>>
>>> @@ -154,6 +162,7 @@ static u32 initiate_file_draining(struct nfs_client *clp,
>>> static u32 initiate_bulk_draining(struct nfs_client *clp,
>>> 				  struct cb_layoutrecallargs *args)
>>> {
>>> +	struct nfs_server *server;
>>> 	struct pnfs_layout_hdr *lo;
>>> 	struct inode *ino;
>>> 	u32 rv = NFS4ERR_NOMATCHING_LAYOUT;
>>> @@ -167,18 +176,23 @@ static u32 initiate_bulk_draining(struct nfs_client *clp,
>>> 	};
>>>
>>> 	spin_lock(&clp->cl_lock);
>>> -	list_for_each_entry(lo, &clp->cl_layouts, plh_layouts) {
>>> -		if ((args->cbl_recall_type == RETURN_FSID) &&
>>> -		    memcmp(&NFS_SERVER(lo->plh_inode)->fsid,
>>> -			   &args->cbl_fsid, sizeof(struct nfs_fsid)))
>>> -			continue;
>>> -		if (!igrab(lo->plh_inode))
>>> -			continue;
>>> -		get_layout_hdr(lo);
>>> -		BUG_ON(!list_empty(&lo->plh_bulk_recall));
>>> -		list_add(&lo->plh_bulk_recall, &recall_list);
>>> +	rcu_read_lock();
>>> +	list_for_each_entry_rcu(server, &clp->cl_superblocks, client_link) {
>>> +		list_for_each_entry(lo, &server->layouts, plh_layouts) {
>>> +			if ((args->cbl_recall_type == RETURN_FSID) &&
>>> +			    memcmp(&server->fsid, &args->cbl_fsid,
>>> +				   sizeof(struct nfs_fsid)))
>>> +				continue;
>>
>> This condition can be popped up to the outer loop now...
>> (or break rather than continue)
>>
>> Benny
> 
> Good point.  Fred wanted me to wait until this patch got in to optimize handling RETURN_FSID.  Comments?

In this case, I think it is overly careful since the mechanical
change of indenting the whole block in the inner loop doesn't
make sense here. The whole purpose of this patch, as mentioned
in the description is to track layouts per fsid, therefore
testing the fsid at the right level need not be separated
into a separate, optimizing patch, but rather it can be included
in this one as a self-sufficient version.

Benny

> 
> -dros--
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

