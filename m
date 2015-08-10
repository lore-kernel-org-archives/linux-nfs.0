Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pd0-f169.google.com ([209.85.192.169]:34964 "EHLO
	mail-pd0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751612AbbHJLgt (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 10 Aug 2015 07:36:49 -0400
Received: by pdrg1 with SMTP id g1so70785674pdr.2
        for <linux-nfs@vger.kernel.org>; Mon, 10 Aug 2015 04:36:49 -0700 (PDT)
Subject: Re: [PATCH v2 04/18] nfsd: add a new struct file caching facility to
 nfsd
To: Jeff Layton <jlayton@poochiereds.net>
References: <1438264341-18048-1-git-send-email-jeff.layton@primarydata.com>
 <1438809216-4846-1-git-send-email-jeff.layton@primarydata.com>
 <1438809216-4846-5-git-send-email-jeff.layton@primarydata.com>
 <55C4CEA9.306@gmail.com> <20150807131857.0a94bdfe@synchrony.poochiereds.net>
 <55C549D6.4030104@gmail.com>
 <20150808063624.24b6fcc3@tlielax.poochiereds.net>
Cc: bfields@fieldses.org, linux-nfs@vger.kernel.org, kinglongmee@gmail.com
From: Kinglong Mee <kinglongmee@gmail.com>
Message-ID: <55C88CB9.2050306@gmail.com>
Date: Mon, 10 Aug 2015 19:36:25 +0800
MIME-Version: 1.0
In-Reply-To: <20150808063624.24b6fcc3@tlielax.poochiereds.net>
Content-Type: text/plain; charset=windows-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 8/8/2015 18:36, Jeff Layton wrote:
> On Sat, 8 Aug 2015 08:14:14 +0800
> Kinglong Mee <kinglongmee@gmail.com> wrote:
> 
>> On 8/8/2015 01:18, Jeff Layton wrote:
>>> On Fri, 7 Aug 2015 23:28:41 +0800
>>> Kinglong Mee <kinglongmee@gmail.com> wrote:
>>>
>>>> On 8/6/2015 05:13, Jeff Layton wrote:
>>>>> Currently, NFSv2/3 reads and writes have to open a file, do the read or
>>>>> write and then close it again for each RPC. This is highly inefficient,
>>>>> especially when the underlying filesystem has a relatively slow open
>>>>> routine.
>>>>>
>>>>> This patch adds a new open file cache to knfsd. Rather than doing an
>>>>> open for each RPC, the read/write handlers can call into this cache to
>>>>> see if there is one already there for the correct filehandle and
>>>>> NFS_MAY_READ/WRITE flags.
>>>>>
>>>>> If there isn't an entry, then we create a new one and attempt to
>>>>> perform the open. If there is, then we wait until the entry is fully
>>>>> instantiated and return it if it is at the end of the wait. If it's
>>>>> not, then we attempt to take over construction.
>>>>>
>>>>> Since the main goal is to speed up NFSv2/3 I/O, we don't want to
>>>>> close these files on last put of these objects. We need to keep them
>>>>> around for a little while since we never know when the next READ/WRITE
>>>>> will come in.
>>>>>
>>>>> Cache entries have a hardcoded 1s timeout, and we have a recurring
>>>>> workqueue job that walks the cache and purges any entries that have
>>>>> expired.
>>>>>
>>>>> Signed-off-by: Jeff Layton <jeff.layton@primarydata.com>
>>>> ... snip ... 
>>>>> diff --git a/fs/nfsd/filecache.h b/fs/nfsd/filecache.h
>>>>> index 9051ee54faa3..adf7e78b8e43 100644
>>>>> --- a/fs/nfsd/filecache.h
>>>>> +++ b/fs/nfsd/filecache.h
>>>>> @@ -4,6 +4,7 @@
>>>>>  #include <linux/jhash.h>
>>>>>  #include <linux/sunrpc/xdr.h>
>>>>>  
>>>>> +#include "nfsfh.h"
>>>>>  #include "export.h"
>>>>>  
>>>>>  /* hash table for nfs4_file */
>>>>> @@ -22,4 +23,24 @@ file_hashval(struct knfsd_fh *fh)
>>>>>  	return nfsd_fh_hashval(fh) & (NFSD_FILE_HASH_SIZE - 1);
>>>>>  }
>>>>>  
>>>>> +struct nfsd_file {
>>>>
>>>> There is a nfs4_file in nfsd, it's not easy to distinguish them for a new folk.
>>>> More comments or a meaningful name is better.
>>>>
>>>
>>> Maybe. Again, any suggestions? My hope was that eventually we can unify
>>> the two caches somehow but maybe that's naive.
>>
>> I cannot find a better name for the new file cache. More comments.
>>
>> I don't agree with merging those two into one cache.
>>
>> nfsv4's file cache is a state resource of client which will exist since close
>> or lease expire. But nfsd_file cache is a temporary resource for nfsv2/v3 client
>> without state. 
>>
> 
> You're probably right here. It was idle thought from when I first
> started this work. What we probably would want to do however is to
> layer the nfs4_file cache on top of this cache instead of having it
> manage filps on its own.
> 
> I tried to design this cache so that it can handle O_RDWR opens, even
> though the current callers don't actually ever request those. It should
> be possible to hook up the nfs4_file cache to it, though I'd prefer to
> wait until we have this code in place first and then do that later.
> 
>> Also, for nfsv4's conflict checking, should we check the temporary file cache
>> for nfsv2/v3 too?
>>
> 
> You mean for share/deny modes? We traditionally have not done that, and
> I don't see a compelling reason to start now. That would be a separate
> project in its own right, IMO. We'd need to lift the share/deny mode
> handling into this new cache.

OK.
I will look forward to the new project.

> 
> There's also the problem of there not being any protocol support for
> that in NFSv2/3. What would we return to the client if there's a deny
> mode conflict when it's trying to do (e.g.) a READ?
> 

It's my worry too.
Without this cache, this case only influence an NFSv2/3 RPC process time,
but, with this cache, it's more than 1s at worst.

> 
>>>
>>>>> +	struct hlist_node	nf_node;
>>>>> +	struct list_head	nf_dispose;
>>>>> +	struct rcu_head		nf_rcu;
>>>>> +	struct file		*nf_file;
>>>>> +	unsigned long		nf_time;
>>>>> +#define NFSD_FILE_HASHED	(0)
>>>>
>>>> Why not using hlist_unhashed()? 
>>>>
>>>
>>> These entries are removed from the list using hlist_del_rcu(), and
>>> hlist_unhashed will not return true after that.
>>
>> As I understand, NFSD_FILE_HASHED means the file cache is added to 
>> nfsd_file_hashtbl, and increased the global file count.
>>
>> With calling hlist_del_rcu, file cache has be deleted from the hashtbl,
>> and clear the NFSD_FILE_HASHED bit. 
>>
> 
> That's correct.
> 
>> As using in the codes, the bit and hlist_unhashed have the same meaning.
>> Any mistake of my understand?
>>
> 
> hlist_unhashed() won't work here:
> 
> static inline int hlist_unhashed(const struct hlist_node *h)
> {
>         return !h->pprev;
> }
> 
> ...but:
> 
> static inline void hlist_del_rcu(struct hlist_node *n)
> {
>         __hlist_del(n);
>         n->pprev = LIST_POISON2;
> }

Got it.
You are right.

thanks,
Kinglong Mee
