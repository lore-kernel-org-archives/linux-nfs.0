From: Steve Dickson <SteveD@redhat.com>
Subject: Re: [NFS] Re: [PATCH][RFC] NFS: Improving the access cache
Date: Sat, 06 May 2006 10:35:06 -0400
Message-ID: <445CB41A.9040400@RedHat.com>
References: <444EC96B.80400@RedHat.com>	<17486.64825.942642.594218@cse.unsw.edu.au>	<444F88EF.5090105@RedHat.com> <17487.62730.16297.979429@cse.unsw.edu.au> <44572B33.4070100@RedHat.com> <445834CB.4050408@citi.umich.edu> <445B5C2D.5040404@RedHat.com> <445B66E6.7030700@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: linux-fsdevel@vger.kernel.org
Return-path: <linux-fsdevel-owner@vger.kernel.org>
To: nfs@lists.sourceforge.net
In-Reply-To: <445B66E6.7030700@redhat.com>
Sender: linux-fsdevel-owner@vger.kernel.org
List-ID: <nfs.lists.sourceforge.net>

Peter Staubach wrote:
>>>
>>> 2.  Use a radix tree per inode.  
>>
>>
>> Using radix trees actual makes things much simpler... Good idea, imo.
>>
> 
> It does seem like a good idea, although just using the uid is not sufficient
> to identify the correct access cache entry.  The group and groups list must
> also be used.  Can the radix tree implementation support this?
We could use (nfsi + uid) as the index... but its not clear what that
would buys us... And the group and group list were never part of the
cache in the first place.... is this something you feel needs to be
added or am I just not understanding....

>> static int nfs_do_access(struct inode *inode, struct rpc_cred *cred, 
>> int mask)
>> @@ -1674,19 +1706,42 @@ static int nfs_do_access(struct inode *i
>>
>>     status = nfs_access_get_cached(inode, cred, &cache);
>>     if (status == 0)
>> -        goto out;
>> +        goto out_nowait;
>> +
>> +    if (test_and_set_bit(NFS_INO_ACCESS, &NFS_FLAGS(inode))) {
>> +        status = nfs_wait_on_inode(inode, NFS_INO_ACCESS);
>> +        if (status < 0)
>> +            return status;
>> +
>> +        nfs_access_get_cached(inode, cred, &cache);
>> +        goto out_nowait;
>>  
>>
> 
> You can't just go to out_nowait here, can you?  What happens if something
> happened to the file while you were asleep?  
point... after the nfs_wait_on_inode() call, nfs_access_get_cached()
will be retried ala...

static int nfs_do_access(struct inode *inode, struct rpc_cred *cred, int 
mask)
{
     struct nfs_access_entry cache;
     int status;

retry:
     status = nfs_access_get_cached(inode, cred, &cache);
     if (status == 0)
         goto out_nowait;

     if (test_and_set_bit(NFS_INO_ACCESS, &NFS_FLAGS(inode))) {
         status = nfs_wait_on_inode(inode, NFS_INO_ACCESS);
         if (status < 0)
             return status;

         goto retry;
     }



>> +static inline void nfs_zap_access_cache(struct inode *inode)
>> +{
>> +    struct nfs_access_entry *cache;
>> +
>> +    cache = radix_tree_delete(&NFS_I(inode)->access_cache, 
>> inode->i_uid);
>>  
>>
> 
> Do you need to be hold access_lock here?
Yes...

> 
>> +    if (cache) {
>> +        put_rpccred(cache->cred);
>> +        kfree(cache);
>> +    }
>>  
>>
> 
> What happens if there was more than 1 entry in the cache?
I thought that since nfs_clear_inode() is called for
each and every inode that cache would drain "naturally"
but that turns out to be a bit brain dead... :-\

The problem is there does not seems to be a radix tree interface
that will simply destroy the tree... It appears you need to know
at least the beginning index and since the indexes in this tree are
not symmetrical I'm not sure that would even help...

Anybody.... Is there a way to destroy a radix tree without
known any of the indexes?

steved.

