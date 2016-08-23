Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:47546 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1757409AbcHWWiD (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 23 Aug 2016 18:38:03 -0400
From: "Benjamin Coddington" <bcodding@redhat.com>
To: "Trond Myklebust" <trondmy@primarydata.com>
Cc: "List Linux NFS Mailing" <linux-nfs@vger.kernel.org>
Subject: Re: I can't get no readdir satisfaction
Date: Tue, 23 Aug 2016 17:21:17 -0400
Message-ID: <98E39192-4203-4EB8-BDE0-2A4ABFCAA92B@redhat.com>
In-Reply-To: <F9D0E173-9E64-4BC4-87FB-0F6F4EEBF4C7@primarydata.com>
References: <778246F3-8F24-48FD-AEA9-0BCC0DCD93B3@redhat.com>
 <F9D0E173-9E64-4BC4-87FB-0F6F4EEBF4C7@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 23 Aug 2016, at 11:36, Trond Myklebust wrote:

>> On Aug 23, 2016, at 11:09, Benjamin Coddington <bcodding@redhat.com> 
>> wrote:
>>
>> Hi linux-nfs,
>>
>> 311324ad1713 ("NFS: Be more aggressive in using readdirplus for 'ls 
>> -l'
>> situations") changed when nfs_readdir() decides to revalidate the
>> directory's mapping, which contains all the entries.  In addition to 
>> just
>> checking if the attribute cache has expired, it includes a check to 
>> see if
>> NFS_INO_INVALID_DATA is set on the directory.
>>
>> Well, customers that have directories with very many dentries and 
>> that same
>> directory's attributes are frequently updated are now grouchy that 
>> `ls -l`
>> takes so long since any update of the directory causes the mapping to 
>> be
>> invalidated and we have to start over filling the directory's 
>> mapping.
>>
>> I actually haven't put real hard thought into it yet (because often 
>> for me
>> that just wastes a lot of time), so I am doing the lazy thing by 
>> asking this
>> question:
>>
>> Can we go back to just the using the attribute cache timeout, or 
>> should we
>> get all heuristical about readdir?
>>
>
> We are all heuristical at this point. How are the heuristics failing?
>
> The original problem those heuristics were designed to solve was that 
> all
> the stat() calls took forever to complete, since they are all 
> synchronous;
> Tigran showed some very convincing numbers for a large directory where 
> the
> difference in performance was an order of magnitude improved by using
> readdirplus instead of readdir…

I'll try to present a better explanation.  While `ls -l` is walking 
through
a directory repeatedly entering nfs_readdir(), a CREATE response send us
through nfs_post_op_update_inode_locked():

1531     if (S_ISDIR(inode->i_mode))
1532         invalid |= NFS_INO_INVALID_DATA;
1533     nfs_set_cache_invalid(inode, invalid);

Now, the next entry into nfs_readdir() has us do 
nfs_revalidate_mapping(),
which will do nfs_invalidate_mapping() for the directory, and so we have 
to
start over with cookie 0 sending READDIRPLUS to re-fill the directory's
mapping to get back to where we are for the current nfs_readdir().

This process repeats for every entry into nfs_readdir() if the directory
keeps getting updated, and it becomes more likely that it will be 
updated as
each pass takes longer and longer to re-fill the mapping as the current
nfs_readdir() invocation is further along.

READDIRPLUS isn't the problem, the problem is invalidating the directory
mapping in the middle of a series of getdents() if we do a CREATE.  
Also, I
think a similar thing happens if the directory's mtime or ctime is 
updated -
but in that case we set NFS_INO_INVALID_DATA because the change_attr
updates.

So, for directories with a large number of entries that updates often, 
it can
be very slow to list the directory.

Why did 311324ad1713 change nfs_readdir from

if (nfs_attribute_cache_expired(inode))
     nfs_revalidate_mapping(inode, file->f_mapping);
to

if (nfs_attribute_cache_expired(inode) || nfsi->cache_validity & 
NFS_INO_INVALID_DATA)
     nfs_revalidate_mapping(inode, file->f_mapping);

.. and can we go back to the way it was before?

OK.. I understand why -- it is more correct since if we know the 
directory has
changed, we might as well fetch the change.  Otherwise, we might be 
creating
files and then wondering why they aren't listed.

It might be nicer to not invalidate the mapping we're currently using 
for
readdir, though.  Maybe there's a way to keep the mapping for the 
currently
opened directory and invalidate it once it's closed.

I'm using v3 for all this, but I think the problem is the same for v4.

Ben
