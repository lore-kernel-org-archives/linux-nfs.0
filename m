Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:63182 "EHLO
	daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752410Ab0INNZk (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 14 Sep 2010 09:25:40 -0400
Message-ID: <4C8F77D5.8060903@panasas.com>
Date: Tue, 14 Sep 2010 15:25:41 +0200
From: Benny Halevy <bhalevy@panasas.com>
To: Fred Isaman <iisaman@umich.edu>
CC: linux-nfs@vger.kernel.org
Subject: Re: [PATCH 1/1] SQUASHME: pnfs: clean up layoutcommit_mempool
References: <1284461087-4498-1-git-send-email-bhalevy@panasas.com> <AANLkTimsoKRwx+_-LOk6ZPZtTzfa+jaovD5Ru82gY-nv@mail.gmail.com>
In-Reply-To: <AANLkTimsoKRwx+_-LOk6ZPZtTzfa+jaovD5Ru82gY-nv@mail.gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 2010-09-14 13:37, Fred Isaman wrote:
> Note that in an internal review, Trond suggested that we can get rid
> of the mempool entirely, relying instead on kmalloc.  This has the
> advantage that it basically makes pnfs_init/uninit no-ops that can be
> removed.  This idea was integrated into the submission patches.  I
> also have a rebase (that still needs some cleanup) that carries the
> removal up to your pnfs-submit branch.

OK, makes sense.

Benny

> 
> Fred
> 
> 
> On Tue, Sep 14, 2010 at 3:44 AM, Benny Halevy <bhalevy@panasas.com> wrote:
>> Signed-off-by: Benny Halevy <bhalevy@panasas.com>
>> ---
>>  fs/nfs/pnfs.c |   16 +++++++---------
>>  1 files changed, 7 insertions(+), 9 deletions(-)
>>
>> diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
>> index 61dbc0a..b576470 100644
>> --- a/fs/nfs/pnfs.c
>> +++ b/fs/nfs/pnfs.c
>> @@ -71,7 +71,7 @@ static spinlock_t pnfs_spinlock = __SPIN_LOCK_UNLOCKED(pnfs_spinlock);
>>  * pnfs_modules_tbl holds all pnfs modules
>>  */
>>  static struct list_head        pnfs_modules_tbl;
>> -static struct kmem_cache *pnfs_cachep;
>> +static struct kmem_cache *pnfs_layoutcommit_cachep;
>>  static mempool_t *pnfs_layoutcommit_mempool;
>>
>>  static inline struct nfs4_layoutcommit_data *pnfs_layoutcommit_alloc(void)
>> @@ -102,18 +102,16 @@ pnfs_initialize(void)
>>  {
>>        INIT_LIST_HEAD(&pnfs_modules_tbl);
>>
>> -       pnfs_cachep = kmem_cache_create("nfs4_layoutcommit_data",
>> +       pnfs_layoutcommit_cachep = kmem_cache_create("nfs4_layoutcommit_data",
>>                                        sizeof(struct nfs4_layoutcommit_data),
>>                                        0, SLAB_HWCACHE_ALIGN, NULL);
>> -       if (pnfs_cachep == NULL)
>> +       if (pnfs_layoutcommit_cachep == NULL)
>>                return -ENOMEM;
>>
>> -       pnfs_layoutcommit_mempool = mempool_create(MIN_POOL_LC,
>> -                                                  mempool_alloc_slab,
>> -                                                  mempool_free_slab,
>> -                                                  pnfs_cachep);
>> +       pnfs_layoutcommit_mempool = mempool_create_slab_pool(MIN_POOL_LC,
>> +                                               pnfs_layoutcommit_cachep);
>>        if (pnfs_layoutcommit_mempool == NULL) {
>> -               kmem_cache_destroy(pnfs_cachep);
>> +               kmem_cache_destroy(pnfs_layoutcommit_cachep);
>>                return -ENOMEM;
>>        }
>>
>> @@ -124,7 +122,7 @@ pnfs_initialize(void)
>>  void pnfs_uninitialize(void)
>>  {
>>        mempool_destroy(pnfs_layoutcommit_mempool);
>> -       kmem_cache_destroy(pnfs_cachep);
>> +       kmem_cache_destroy(pnfs_layoutcommit_cachep);
>>  }
>>
>>  /* search pnfs_modules_tbl for right pnfs module */
>> --
>> 1.7.2.2
>>
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>>
