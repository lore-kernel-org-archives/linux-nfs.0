Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:33574 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1760460AbcLBN4g (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 2 Dec 2016 08:56:36 -0500
From: "Benjamin Coddington" <bcodding@redhat.com>
To: "Trond Myklebust" <trondmy@primarydata.com>
Cc: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 2/3] NFS: Be more targeted about readdirplus use when
 doing lookup/revalidation
Date: Fri, 02 Dec 2016 08:56:33 -0500
Message-ID: <60326804-0548-43C5-94B4-97FE1AE4B16B@redhat.com>
In-Reply-To: <1480625258.10526.1.camel@primarydata.com>
References: <1479574497-38268-1-git-send-email-trond.myklebust@primarydata.com>
 <1479574497-38268-2-git-send-email-trond.myklebust@primarydata.com>
 <1479574497-38268-3-git-send-email-trond.myklebust@primarydata.com>
 <28E39796-E929-4D65-A6F6-D0AF803AB390@redhat.com>
 <1480625258.10526.1.camel@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 1 Dec 2016, at 15:47, Trond Myklebust wrote:

> On Wed, 2016-11-30 at 14:09 -0500, Benjamin Coddington wrote:
>> .. this one breaks things again:
>>
>> On 19 Nov 2016, at 11:54, Trond Myklebust wrote:
>>
>>>  static
>>>  void nfs_advise_use_readdirplus(struct inode *dir)
>>>  {
>>> -	set_bit(NFS_INO_ADVISE_RDPLUS, &NFS_I(dir)->flags);
>>> +	struct nfs_inode *nfsi = NFS_I(dir);
>>> +
>>> +	if (nfs_server_capable(dir, NFS_CAP_READDIRPLUS) &&
>>> +	    !list_empty(&nfsi->open_files)) {
>>> +		set_bit(NFS_INO_ADVISE_RDPLUS, &nfsi->flags);
>>> +		invalidate_mapping_pages(dir->i_mapping, 0, -1);
>>> +	}
>>>  }
>>
>> So every time advise_use_readdirplus it drops the mapping.. but what 
>> about
>> subsequent calls into nfs_readdir() to get the next batch of
>> entries?  
>> For
>> the ls -l case, we want to keep setting NFS_INO_ADVISE_RDPLUS, but we
>> shouldn't start over filling the mapping from the beginning again.
>
> How do I ensure that the readdir isn't being served from cache, if I
> don't invalidate the mapping?

The way it is now.  Isn't advise_use_readdirplus() just a marker to say
"continue to use readdirplus" after nfs_force_use_readdirplus() has
invalidated the mapping?

> The intention of the patch is to ensure that we only call this on a dcache
> or inode attribute cache miss.

I think it also needs to be called when we detect if a child of the
directory is looked up/revalidated in order to set NFS_INO_ADVISE_RDPLUS
again.  Otherwise we lose the optimization in commit 311324ad1713.

Maybe I am just really confused..

>>> @@ -1211,9 +1220,6 @@ static int nfs_lookup_revalidate(struct
>>> dentry 
>>> *dentry, unsigned int flags)
>>>  out_set_verifier:
>>>  	nfs_set_verifier(dentry, nfs_save_change_attribute(dir));
>>>   out_valid:
>>> -	/* Success: notify readdir to use READDIRPLUS */
>>> -	nfs_advise_use_readdirplus(dir);
>>> - out_valid_noent:
>>>  	if (flags & LOOKUP_RCU) {
>>>  		if (parent != ACCESS_ONCE(dentry->d_parent))
>>>  			return -ECHILD;
>>
>>
>> Now when listing with `ls -l`:  the second call into nfs_readdir()
>> to 
>> get
>> the next batch of entries will not have NFS_INO_ADVISE_RDPLUS.
>>
>> I think this removes nfs_advise_use_readdirplus(dir) from the common 
>> "goto
>> out_valid" path through nfs_lookup_revalidate() (the block with the 
>> 'iff'
>> typo).
>>
>
> Actually, 'iff' is intentionally used there as the common shorthand for
> 'if and only if' (https://www.merriam-webster.com/dictionary/iff).

Ah, and now I see it used everywhere.  Thank you for filling in that hole
in my head.

> As I said above, the point is to only trigger READDIRPLUS when we know
> the dcache or the inode cache needs revalidation. Otherwise we want to
> use the less expensive READDIR.

Not if using ls -l.  With this patch, an ls -l of a directory of 2000
entries follows this pattern:

- nfs_readdir() returns first 1024 entries obtained with READDIRPLUS
- nfs_readdir() returns last 976 entries with READDIR
- stat()/LOOKUPs are done on those 976
- ls -l does its final getdents() on the last position, but we've now
  invalidated the pages, so finally:
- nfs_readdir() is called with position 2000, and we do READDIRPLUS for
  _every_ entry all over again.

This seems to break commit 311324ad1713's optimization, since now we'll send
RPC to read the entire directory twice for ls -l.

> I'm open for suggestions as to how we can improve that heuristic.

OK.  Right now I've got nothing to suggest, but I'll spend some time thinking
about it.

Ben
