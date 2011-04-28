Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:33983 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933356Ab1D1SVv convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 28 Apr 2011 14:21:51 -0400
Subject: Re: [PATCH] NFS: move pnfs layouts to nfs_server structure
Content-Type: text/plain; charset=us-ascii
From: Dros Adamson <dros@netapp.com>
In-Reply-To: <4DB8EA18.1030508@panasas.com>
Date: Thu, 28 Apr 2011 14:21:48 -0400
Cc: trond@netapp.com, linux-nfs@vger.kernel.org
Message-Id: <77373F14-888D-4817-9388-44DE4CD16607@netapp.com>
References: <1303944050-29932-1-git-send-email-dros@netapp.com> <1303944050-29932-2-git-send-email-dros@netapp.com> <4DB8EA18.1030508@panasas.com>
To: Benny Halevy <bhalevy@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0


On Apr 28, 2011, at 12:16 AM, Benny Halevy wrote:

> On 2011-04-28 01:40, Weston Andros Adamson wrote:
> ...
> 
>> @@ -167,18 +176,27 @@ static u32 initiate_bulk_draining(struct nfs_client *clp,
>> 	};
>> 
>> 	spin_lock(&clp->cl_lock);
>> -	list_for_each_entry(lo, &clp->cl_layouts, plh_layouts) {
>> +	rcu_read_lock();
>> +	list_for_each_entry_rcu(server, &clp->cl_superblocks, client_link) {
>> 		if ((args->cbl_recall_type == RETURN_FSID) &&
>> -		    memcmp(&NFS_SERVER(lo->plh_inode)->fsid,
>> -			   &args->cbl_fsid, sizeof(struct nfs_fsid)))
>> -			continue;
>> -		if (!igrab(lo->plh_inode))
>> +		    memcmp(&server->fsid, &args->cbl_fsid,
>> +			   sizeof(struct nfs_fsid)))
>> 			continue;
>> -		get_layout_hdr(lo);
>> -		BUG_ON(!list_empty(&lo->plh_bulk_recall));
>> -		list_add(&lo->plh_bulk_recall, &recall_list);
>> +
>> +		list_for_each_entry(lo, &server->layouts, plh_layouts) {
>> +			if (!igrab(lo->plh_inode))
>> +				continue;
>> +			get_layout_hdr(lo);
>> +			BUG_ON(!list_empty(&lo->plh_bulk_recall));
>> +			list_add(&lo->plh_bulk_recall, &recall_list);
>> +		}
>> +
>> +		if (args->cbl_recall_type == RETURN_FSID)
>> +			break;
> 
> I actually thought of suggesting that yesterday but
> I'm not sure fsid is unique per nfs_server.  Is it?
> 
> Benny

Ah!  I incorrectly assumed that fsids are unique.  client.c:nfs_clone_server() proves otherwise.

Thanks!

-dros


