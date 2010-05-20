From: Andy Adamson <andros@netapp.com>
Subject: Re: [PATCH] pnfs: call layoutcommit after flushing inode's data to  disk.
Date: Thu, 20 May 2010 10:17:47 -0400
Message-ID: <1BDB1C4A-A169-4BAF-8E8A-A7B7705A2E57@netapp.com>
References: <20100520032759.GA26892@vmware> <AANLkTikc6JXz1ubKJHxs0UJq-x80Mafsz4SKgkBPZgnf@mail.gmail.com>
Mime-Version: 1.0 (Apple Message framework v936)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Cc: linux-nfs@vger.kernel.org, Benny Halevy <bhalevy@panasas.com>,
	"J. Bruce Fields" <bfields@fieldses.org>
To: Tao Guo <glorioustao@gmail.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:31600 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751934Ab0ETOSI (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 20 May 2010 10:18:08 -0400
In-Reply-To: <AANLkTikc6JXz1ubKJHxs0UJq-x80Mafsz4SKgkBPZgnf-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On May 20, 2010, at 12:42 AM, Tao Guo wrote:

> This is for a bug introduced to 2.6.34. In 2.6.32 and 2.6.33 we call
> layoutcommit in
> nfs_sync_mapping_wait(), but in 2.6.34 we use sync_inode() to sync
> inode's data, so
> the layoutcommit code is gone.
>
> BTW: In current code, layoutcommit_ctx will increase refcount of
> nfs_inode's ctx, so if
> layoutcommit_ctx is not NULL, we could not reach nfs4_close_context
> ... --> __nfs_close().
> So pnfs_layoutcommit_inode() in __nfs_close() will not be called in
> whatever situation.
> Why we have to use nfs_inode's ctx as layoutcommit_ctx, since we only
> need its rpc_creds
> actually?


I have a patch to be submitted today that replaces the  
nfs_open_context with an rpc_cred.

-->Andy

>
> On Thu, May 20, 2010 at 11:28 AM, Tao Guo <guotao-U4AKAne5IzAR5TUyvShJeg@public.gmane.org> wrote:
>> Signed-off-by: Tao Guo <guotao-U4AKAne5IzAR5TUyvShJeg@public.gmane.org>
>> ---
>>  fs/nfs/write.c |    8 +++++++-
>>  1 files changed, 7 insertions(+), 1 deletions(-)
>>
>> diff --git a/fs/nfs/write.c b/fs/nfs/write.c
>> index d3e1645..b4f48b2 100644
>> --- a/fs/nfs/write.c
>> +++ b/fs/nfs/write.c
>> @@ -1558,6 +1558,7 @@ int nfs_write_inode(struct inode *inode,  
>> struct writeback_control *wbc)
>>  */
>>  int nfs_wb_all(struct inode *inode)
>>  {
>> +       int ret;
>>        struct writeback_control wbc = {
>>                .sync_mode = WB_SYNC_ALL,
>>                .nr_to_write = LONG_MAX,
>> @@ -1565,7 +1566,12 @@ int nfs_wb_all(struct inode *inode)
>>                .range_end = LLONG_MAX,
>>        };
>>
>> -       return sync_inode(inode, &wbc);
>> +       ret = sync_inode(inode, &wbc);
>> +#ifdef CONFIG_NFS_V4_1
>> +       if (!ret && NFS_I(inode)->layoutcommit_ctx)
>> +               ret = pnfs_layoutcommit_inode(inode, 1);
>> +#endif
>> +       return ret;
>>  }
>>
>>  int nfs_wb_page_cancel(struct inode *inode, struct page *page)
>> --
>> 1.6.3.3
>>
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux- 
>> nfs" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>>
>
>
>
> -- 
> tao.
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs"  
> in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

