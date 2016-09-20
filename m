Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from szxga01-in.huawei.com ([58.251.152.64]:7240 "EHLO
        szxga01-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752293AbcITAeX (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 19 Sep 2016 20:34:23 -0400
Subject: Re: [PATCH] nfs: add missing CONFIG_MIGRATION for nfs_migrate_page
To: Anna Schumaker <Anna.Schumaker@netapp.com>,
        <trond.myklebust@primarydata.com>
References: <20160919120917.29844-1-yuchao0@huawei.com>
 <fb5f4957-7d01-4c69-aca2-0e704104d921@Netapp.com>
CC: <linux-nfs@vger.kernel.org>, <linux-kernel@vger.kernel.org>
From: Chao Yu <yuchao0@huawei.com>
Message-ID: <f4556003-919a-0ecf-5c33-9c6f69a8d8bc@huawei.com>
Date: Tue, 20 Sep 2016 08:34:04 +0800
MIME-Version: 1.0
In-Reply-To: <fb5f4957-7d01-4c69-aca2-0e704104d921@Netapp.com>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Anna,

On 2016/9/20 1:38, Anna Schumaker wrote:
> Hi Chao,
> 
> On 09/19/2016 08:09 AM, Chao Yu wrote:
>> We'd better to use CONFIG_MIGRATION to cover nfs_migrate_page, otherwise
>> when CONFIG_MIGRATION is not defined, unused nfs_migrate_page will still
>> be compiled into kernel.
> 
> I don't think that nfs_migrate_page is still compiled into the kernel when CONFIG_MIGRATION=n.  The file fs/nfs/internal.h has:
> 
>   #ifdef CONFIG_MIGRATION
>   extern int nfs_migrate_page(struct address_space *,
>                   struct page *, struct page *, enum migrate_mode);
>   #else
>   #define nfs_migrate_page NULL
>   #endif
> 
> So it looks like we're just setting the variable to a NULL pointer in this case.  

Oh, thank you for correcting me, I think I'm missing that part.

> I'm not opposed to your change, since it better matches how we've done things in other parts of the client, but can you please clean up internal.h while you're at it?

OK, let me change commit log and do more cleanup like you suggested above.

Thanks,

> 
> Thanks,
> Anna
> 
>>
>> Signed-off-by: Chao Yu <yuchao0@huawei.com>
>> ---
>>  fs/nfs/file.c | 2 ++
>>  1 file changed, 2 insertions(+)
>>
>> diff --git a/fs/nfs/file.c b/fs/nfs/file.c
>> index 7d62097..6cfb83e 100644
>> --- a/fs/nfs/file.c
>> +++ b/fs/nfs/file.c
>> @@ -543,7 +543,9 @@ const struct address_space_operations nfs_file_aops = {
>>  	.invalidatepage = nfs_invalidate_page,
>>  	.releasepage = nfs_release_page,
>>  	.direct_IO = nfs_direct_IO,
>> +#ifdef CONFIG_MIGRATION
>>  	.migratepage = nfs_migrate_page,
>> +#endif
>>  	.launder_page = nfs_launder_page,
>>  	.is_dirty_writeback = nfs_check_dirty_writeback,
>>  	.error_remove_page = generic_error_remove_page,
>>
> 
> 
> .
> 

