Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pd0-f171.google.com ([209.85.192.171]:34394 "EHLO
	mail-pd0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1946426AbbHHAOp (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 7 Aug 2015 20:14:45 -0400
Received: by pdbfa8 with SMTP id fa8so10509943pdb.1
        for <linux-nfs@vger.kernel.org>; Fri, 07 Aug 2015 17:14:44 -0700 (PDT)
Subject: Re: [PATCH v2 04/18] nfsd: add a new struct file caching facility to
 nfsd
To: Jeff Layton <jlayton@poochiereds.net>
References: <1438264341-18048-1-git-send-email-jeff.layton@primarydata.com>
 <1438809216-4846-1-git-send-email-jeff.layton@primarydata.com>
 <1438809216-4846-5-git-send-email-jeff.layton@primarydata.com>
 <55C4CEA9.306@gmail.com> <20150807131857.0a94bdfe@synchrony.poochiereds.net>
Cc: bfields@fieldses.org, linux-nfs@vger.kernel.org, kinglongmee@gmail.com
From: Kinglong Mee <kinglongmee@gmail.com>
Message-ID: <55C549D6.4030104@gmail.com>
Date: Sat, 8 Aug 2015 08:14:14 +0800
MIME-Version: 1.0
In-Reply-To: <20150807131857.0a94bdfe@synchrony.poochiereds.net>
Content-Type: text/plain; charset=windows-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 8/8/2015 01:18, Jeff Layton wrote:
> On Fri, 7 Aug 2015 23:28:41 +0800
> Kinglong Mee <kinglongmee@gmail.com> wrote:
> 
>> On 8/6/2015 05:13, Jeff Layton wrote:
>>> Currently, NFSv2/3 reads and writes have to open a file, do the read or
>>> write and then close it again for each RPC. This is highly inefficient,
>>> especially when the underlying filesystem has a relatively slow open
>>> routine.
>>>
>>> This patch adds a new open file cache to knfsd. Rather than doing an
>>> open for each RPC, the read/write handlers can call into this cache to
>>> see if there is one already there for the correct filehandle and
>>> NFS_MAY_READ/WRITE flags.
>>>
>>> If there isn't an entry, then we create a new one and attempt to
>>> perform the open. If there is, then we wait until the entry is fully
>>> instantiated and return it if it is at the end of the wait. If it's
>>> not, then we attempt to take over construction.
>>>
>>> Since the main goal is to speed up NFSv2/3 I/O, we don't want to
>>> close these files on last put of these objects. We need to keep them
>>> around for a little while since we never know when the next READ/WRITE
>>> will come in.
>>>
>>> Cache entries have a hardcoded 1s timeout, and we have a recurring
>>> workqueue job that walks the cache and purges any entries that have
>>> expired.
>>>
>>> Signed-off-by: Jeff Layton <jeff.layton@primarydata.com>
>> ... snip ... 
>>> diff --git a/fs/nfsd/filecache.h b/fs/nfsd/filecache.h
>>> index 9051ee54faa3..adf7e78b8e43 100644
>>> --- a/fs/nfsd/filecache.h
>>> +++ b/fs/nfsd/filecache.h
>>> @@ -4,6 +4,7 @@
>>>  #include <linux/jhash.h>
>>>  #include <linux/sunrpc/xdr.h>
>>>  
>>> +#include "nfsfh.h"
>>>  #include "export.h"
>>>  
>>>  /* hash table for nfs4_file */
>>> @@ -22,4 +23,24 @@ file_hashval(struct knfsd_fh *fh)
>>>  	return nfsd_fh_hashval(fh) & (NFSD_FILE_HASH_SIZE - 1);
>>>  }
>>>  
>>> +struct nfsd_file {
>>
>> There is a nfs4_file in nfsd, it's not easy to distinguish them for a new folk.
>> More comments or a meaningful name is better.
>>
> 
> Maybe. Again, any suggestions? My hope was that eventually we can unify
> the two caches somehow but maybe that's naive.

I cannot find a better name for the new file cache. More comments.

I don't agree with merging those two into one cache.

nfsv4's file cache is a state resource of client which will exist since close
or lease expire. But nfsd_file cache is a temporary resource for nfsv2/v3 client
without state. 

Also, for nfsv4's conflict checking, should we check the temporary file cache
for nfsv2/v3 too?

> 
>>> +	struct hlist_node	nf_node;
>>> +	struct list_head	nf_dispose;
>>> +	struct rcu_head		nf_rcu;
>>> +	struct file		*nf_file;
>>> +	unsigned long		nf_time;
>>> +#define NFSD_FILE_HASHED	(0)
>>
>> Why not using hlist_unhashed()? 
>>
> 
> These entries are removed from the list using hlist_del_rcu(), and
> hlist_unhashed will not return true after that.

As I understand, NFSD_FILE_HASHED means the file cache is added to 
nfsd_file_hashtbl, and increased the global file count.

With calling hlist_del_rcu, file cache has be deleted from the hashtbl,
and clear the NFSD_FILE_HASHED bit. 

As using in the codes, the bit and hlist_unhashed have the same meaning.
Any mistake of my understand?

+static void
+nfsd_file_unhash(struct nfsd_file *nf)
+{
+	if (test_and_clear_bit(NFSD_FILE_HASHED, &nf->nf_flags)) {
+		hlist_del_rcu(&nf->nf_node);
+		nfsd_file_count_dec();
+	}
+}

thanks,
Kinglong Mee

> 
> 
>>> +#define NFSD_FILE_PENDING	(1)
>>> +	unsigned long		nf_flags;
>>> +	struct knfsd_fh		nf_handle;
>>> +	unsigned int		nf_hashval;
>>> +	atomic_t		nf_ref;
>>> +	unsigned char		nf_may;
>>> +};
>>> +
>>> +int nfsd_file_cache_init(void);
>>> +void nfsd_file_cache_shutdown(void);
>>> +void nfsd_file_put(struct nfsd_file *nf);
>>> +__be32 nfsd_file_acquire(struct svc_rqst *rqstp, struct svc_fh *fhp,
>>> +		  unsigned int may_flags, struct nfsd_file **nfp);
>>>  #endif /* _FS_NFSD_FILECACHE_H */
>>> diff --git a/fs/nfsd/nfssvc.c b/fs/nfsd/nfssvc.c
>>> index ced9944201a0..0572441e23ec 100644
>>> --- a/fs/nfsd/nfssvc.c
>>> +++ b/fs/nfsd/nfssvc.c
>>> @@ -23,6 +23,7 @@
>>>  #include "cache.h"
>>>  #include "vfs.h"
>>>  #include "netns.h"
>>> +#include "filecache.h"
>>>  
>>>  #define NFSDDBG_FACILITY	NFSDDBG_SVC
>>>  
>>> @@ -233,11 +234,17 @@ static int nfsd_startup_generic(int nrservs)
>>>  	if (!nfsd_laundry_wq)
>>>  		goto out_racache;
>>>  
>>> -	ret = nfs4_state_start();
>>> +	ret = nfsd_file_cache_init();
>>>  	if (ret)
>>>  		goto out_wq;
>>> +
>>> +	ret = nfs4_state_start();
>>> +	if (ret)
>>> +		goto out_nfsd_file;
>>>  	return 0;
>>>  
>>> +out_nfsd_file:
>>> +	nfsd_file_cache_shutdown();
>>>  out_wq:
>>>  	destroy_workqueue(nfsd_laundry_wq);
>>>  	nfsd_laundry_wq = NULL;
>>> @@ -254,6 +261,7 @@ static void nfsd_shutdown_generic(void)
>>>  		return;
>>>  
>>>  	nfs4_state_shutdown();
>>> +	nfsd_file_cache_shutdown();
>>>  	nfsd_racache_shutdown();
>>>  }
>>>  
>>>
> 
> 
