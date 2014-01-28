Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ie0-f170.google.com ([209.85.223.170]:35022 "EHLO
	mail-ie0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755298AbaA1RY2 convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 28 Jan 2014 12:24:28 -0500
Received: by mail-ie0-f170.google.com with SMTP id u16so789843iet.29
        for <linux-nfs@vger.kernel.org>; Tue, 28 Jan 2014 09:24:27 -0800 (PST)
Content-Type: text/plain; charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 7.1 \(1827\))
Subject: Re: [PATCH v3] NFS: Fix races in nfs_revalidate_mapping
From: Trond Myklebust <trond.myklebust@primarydata.com>
In-Reply-To: <20140128110531.67516646@tlielax.poochiereds.net>
Date: Tue, 28 Jan 2014 12:24:34 -0500
Cc: linuxnfs <linux-nfs@vger.kernel.org>
Message-Id: <ADCA6406-8E6D-4B94-8420-E4A4C49DB5C1@primarydata.com>
References: <1390923699-11011-1-git-send-email-trond.myklebust@primarydata.com> <1390924222-12869-1-git-send-email-trond.myklebust@primarydata.com> <20140128110531.67516646@tlielax.poochiereds.net>
To: Layton Jeff <jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Jan 28, 2014, at 11:05, Jeff Layton <jlayton@redhat.com> wrote:

> On Tue, 28 Jan 2014 10:50:22 -0500
> Trond Myklebust <trond.myklebust@primarydata.com> wrote:
> 
>> Commit d529ef83c355f97027ff85298a9709fe06216a66 (NFS: fix the handling
>> of NFS_INO_INVALID_DATA flag in nfs_revalidate_mapping) introduces
>> a potential race, since it doesn't test the value of nfsi->cache_validity
>> and set the bitlock in nfsi->flags atomically.
>> 
>> Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
>> Cc: Jeff Layton <jlayton@redhat.com>
>> ---
>> fs/nfs/inode.c | 28 ++++++++++++++--------------
>> 1 file changed, 14 insertions(+), 14 deletions(-)
>> 
>> diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
>> index 0a972ee9ccc1..e5070aa5f175 100644
>> --- a/fs/nfs/inode.c
>> +++ b/fs/nfs/inode.c
>> @@ -1038,24 +1038,24 @@ int nfs_revalidate_mapping(struct inode *inode, struct address_space *mapping)
>> 				  nfs_wait_bit_killable, TASK_KILLABLE);
>> 		if (ret)
>> 			goto out;
>> -		if (!(nfsi->cache_validity & NFS_INO_INVALID_DATA))
>> -			goto out;
>> -		if (!test_and_set_bit_lock(NFS_INO_INVALIDATING, bitlock))
>> +		spin_lock(&inode->i_lock);
>> +		if (test_bit(NFS_INO_INVALIDATING, bitlock)) {
>> +			spin_unlock(&inode->i_lock);
>> +			continue;
>> +		}
>> +		if (nfsi->cache_validity & NFS_INO_INVALID_DATA)
>> 			break;
>> -	}
>> -
>> -	spin_lock(&inode->i_lock);
>> -	if (nfsi->cache_validity & NFS_INO_INVALID_DATA) {
>> -		nfsi->cache_validity &= ~NFS_INO_INVALID_DATA;
>> -		spin_unlock(&inode->i_lock);
>> -		trace_nfs_invalidate_mapping_enter(inode);
>> -		ret = nfs_invalidate_mapping(inode, mapping);
>> -		trace_nfs_invalidate_mapping_exit(inode, ret);
>> -	} else {
>> -		/* something raced in and cleared the flag */
>> 		spin_unlock(&inode->i_lock);
>> +		goto out;
>> 	}
>> 
>> +	set_bit(NFS_INO_INVALIDATING, bitlock);
> 
> Do we need a memory barrier here to ensure the ordering or does the
> set_bit() have one implied? Note that nfs_readdir_search_for_cookie and
> nfs_write_pageuptodate don't hold the i_lock when checking these values.

There seems little point in putting a barrier here. If we need stronger semantics, then we can and should use the spin lock. That said, neither nfs_readdir_search_for_cookie nor nfs_write_pageuptodate is required by close-to-open to have such semantics: the strong checks happen at open().

>> +	nfsi->cache_validity &= ~NFS_INO_INVALID_DATA;
>> +	spin_unlock(&inode->i_lock);
>> +	trace_nfs_invalidate_mapping_enter(inode);
>> +	ret = nfs_invalidate_mapping(inode, mapping);
>> +	trace_nfs_invalidate_mapping_exit(inode, ret);
>> +
>> 	clear_bit_unlock(NFS_INO_INVALIDATING, bitlock);
>> 	smp_mb__after_clear_bit();
>> 	wake_up_bit(bitlock, NFS_INO_INVALIDATING);
> 
> Other than the point about the mb, I think this will cover it. I think
> the patch I sent earlier is easier to prove correct however...
> 

--
Trond Myklebust
Linux NFS client maintainer

