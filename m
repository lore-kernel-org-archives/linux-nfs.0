From: Benny Halevy <bhalevy@panasas.com>
Subject: Re: [RFC 10/11] nfsd: close delegation only on last reference
Date: Thu, 17 Dec 2009 00:04:37 +0200
Message-ID: <4B295975.5010007@panasas.com>
References: <4B291B4C.3060603@panasas.com> <1260985349-21701-1-git-send-email-bhalevy@panasas.com> <20091216211848.GD28822@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: linux-nfs@vger.kernel.org, pnfs@linux-nfs.org
To: "J. Bruce Fields" <bfields@citi.umich.edu>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:34862 "EHLO
	daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S932421AbZLPWEj (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 16 Dec 2009 17:04:39 -0500
In-Reply-To: <20091216211848.GD28822@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Dec. 16, 2009, 23:18 +0200, " J. Bruce Fields" <bfields@citi.umich.edu> wrote:
> On Wed, Dec 16, 2009 at 07:42:29PM +0200, Benny Halevy wrote:
>> as dl_vfs_file may be used while the delegation structure is
>> being referenced.
> 
> A callback to the client (which can last a while if the client is
> unresponsive) can also hold a reference to the delegation.  It doesn't
> need a reference on the file.
> 
> I guess I can't see any bug in holding a reference on the file in that
> case, but it seems better not to (if only to allow freeing it earlier).
> 
> Maybe the limited amount of information used by the callback should be
> reference-counted separately.  I'm not sure.
> 

If we lock the delegation, say by grabbing the global deleg_lock
(or a fine-grained per-deleg lock) we can make sure dl_vfs_file
is accessed atomically in nfs4_new_open and nfs4_preprocess_stateid_op
vs. being freed in close_delegation.

That said, it looks like get_file on the *filpp nfs4_preprocess_stateid_op
is setting (on both legs of the is_delegation_stateid() condition)
should happen inside nfs4_preprocess_stateid_op rather while it holds
a ref count on the delegation (and under the lock proposed above)
rather than by its callers, nfsd4_read and nfsd4_write.

Benny

> --b.
> 
>> Signed-off-by: Benny Halevy <bhalevy@panasas.com>
>> ---
>>  fs/nfsd/nfs4state.c |   27 +++++++++++++--------------
>>  1 files changed, 13 insertions(+), 14 deletions(-)
>>
>> diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
>> index 411226a..053fd2b 100644
>> --- a/fs/nfsd/nfs4state.c
>> +++ b/fs/nfsd/nfs4state.c
>> @@ -203,29 +203,17 @@ alloc_init_deleg(struct nfs4_client *clp, struct nfs4_stateid *stp, struct svc_f
>>  	return dp;
>>  }
>>  
>> -void
>> -nfs4_put_delegation(struct nfs4_delegation *dp)
>> -{
>> -	if (atomic_dec_and_test(&dp->dl_count)) {
>> -		dprintk("NFSD: freeing dp %p\n",dp);
>> -		put_nfs4_file(dp->dl_file);
>> -		kmem_cache_free(deleg_slab, dp);
>> -		num_delegations--;
>> -	}
>> -}
>> -
>>  /* Remove the associated file_lock first, then remove the delegation.
>>   * lease_modify() is called to remove the FS_LEASE file_lock from
>>   * the i_flock list, eventually calling nfsd's lock_manager
>>   * fl_release_callback.
>>   */
>>  static void
>> -nfs4_close_delegation(struct nfs4_delegation *dp)
>> +__close_delegation(struct nfs4_delegation *dp)
>>  {
>>  	struct file *filp = dp->dl_vfs_file;
>>  
>>  	dprintk("NFSD: close_delegation dp %p\n",dp);
>> -	dp->dl_vfs_file = NULL;
>>  	/* The following nfsd_close may not actually close the file,
>>  	 * but we want to remove the lease in any case. */
>>  	if (dp->dl_flock)
>> @@ -233,6 +221,18 @@ nfs4_close_delegation(struct nfs4_delegation *dp)
>>  	nfsd_close(filp);
>>  }
>>  
>> +void
>> +nfs4_put_delegation(struct nfs4_delegation *dp)
>> +{
>> +	if (atomic_dec_and_test(&dp->dl_count)) {
>> +		dprintk("NFSD: freeing dp %p\n",dp);
>> +		__close_delegation(dp);
>> +		put_nfs4_file(dp->dl_file);
>> +		kmem_cache_free(deleg_slab, dp);
>> +		num_delegations--;
>> +	}
>> +}
>> +
>>  /* Called under the state lock. */
>>  static void
>>  unhash_delegation(struct nfs4_delegation *dp)
>> @@ -242,7 +242,6 @@ unhash_delegation(struct nfs4_delegation *dp)
>>  	list_del_init(&dp->dl_perclnt);
>>  	list_del_init(&dp->dl_recall_lru);
>>  	spin_unlock(&deleg_lock);
>> -	nfs4_close_delegation(dp);
>>  	nfs4_put_delegation(dp);
>>  }
>>  
>> -- 
>> 1.6.5.1
>>
