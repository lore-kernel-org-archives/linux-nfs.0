From: Benny Halevy <bhalevy@panasas.com>
Subject: Re: [PATCH] pnfs: call layoutcommit after flushing inode's data to
 disk.
Date: Tue, 25 May 2010 09:55:41 +0300
Message-ID: <4BFB746D.3050507@panasas.com>
References: <4BFACDB9.7030008@panasas.com> <4BFACE47.3050604@panasas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Andy Adamson <andros@netapp.com>,
	NFS list <linux-nfs@vger.kernel.org>
To: Boaz Harrosh <bharrosh@panasas.com>,
	Tao Guo <glorioustao@gmail.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:31421 "EHLO
	daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752034Ab0EYGzo (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 25 May 2010 02:55:44 -0400
In-Reply-To: <4BFACE47.3050604@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On May. 24, 2010, 22:06 +0300, Boaz Harrosh <bharrosh@panasas.com> wrote:
> On 05/24/2010 10:04 PM, Boaz Harrosh wrote:
>> From: Tao Guo <guotao-U4AKAne5IzAR5TUyvShJeg@public.gmane.org>
>>
>> This is for a bug introduced to 2.6.34. In 2.6.32 and 2.6.33 we call
>> layoutcommit in nfs_sync_mapping_wait(), but in 2.6.34 we use
>> sync_inode() to sync inode's data, so the layoutcommit code is gone.
>>
>> BTW: In current code, layoutcommit_ctx will increase refcount of
>> nfs_inode's ctx, so if layoutcommit_ctx is not NULL, we could not
>> reach nfs4_close_context ... --> __nfs_close().
>> So pnfs_layoutcommit_inode() in __nfs_close() will not be called in
>> whatever situation.
>> Why we have to use nfs_inode's ctx as layoutcommit_ctx, since we
>> only need its rpc_creds actually?
>>
>> Boaz:
>>   Without this patch none-files layouts which return NFS_FILE_SYNC
>>   from writes, will eventually hang on uncommitted inodes.
>>
>>   This patch reveals a bad design pattern from the pnfs-client. On
>>   none-files layouts nfs_post_op_update_inode_force_wcc or friends
>>   are never called and i_size_write() is never preformed on client.
>>   What happens is that the layoutcommit eventually updates the server.
>>   In Linux the sever would update i_size_attr and mtime. It would then
>>   be detected by the client and i_size is fetched from server. This is
>>   not nice client behaviour, and is not done so for files and none-pnfs
>>   IO. Sigh! 
>>   I think also files-lo might suffer from this in some cases, which means
>>   if commit is not preformed (It's just an hint) then writeout will have
> 
> commit => layout_commit, oops
> 
>>   i_size  corruption.
>>
>> Signed-off-by: Tao Guo <guotao-U4AKAne5IzAR5TUyvShJeg@public.gmane.org>
>> Signed-off-by: Boaz Harrosh <bharrosh@panasas.com>

Committed at pnfs-all-2.6.34-2010-05-25

Thanks!

Benny

>> ---
>>  fs/nfs/write.c |    8 +++++++-
>>  1 files changed, 7 insertions(+), 1 deletions(-)
>>
>> diff --git a/fs/nfs/write.c b/fs/nfs/write.c
>> index dad8da3..9424203 100644
>> --- a/fs/nfs/write.c
>> +++ b/fs/nfs/write.c
>> @@ -1558,6 +1558,7 @@ int nfs_write_inode(struct inode *inode, struct writeback_control *wbc)
>>   */
>>  int nfs_wb_all(struct inode *inode)
>>  {
>> +	int ret;
>>  	struct writeback_control wbc = {
>>  		.sync_mode = WB_SYNC_ALL,
>>  		.nr_to_write = LONG_MAX,
>> @@ -1565,7 +1566,12 @@ int nfs_wb_all(struct inode *inode)
>>  		.range_end = LLONG_MAX,
>>  	};
>>  
>> -	return sync_inode(inode, &wbc);
>> +	ret = sync_inode(inode, &wbc);
>> +#ifdef CONFIG_NFS_V4_1
>> +	if (!ret && do_layoutcommit(NFS_I(inode)))
>> +		ret = pnfs_layoutcommit_inode(inode, 1);
>> +#endif
>> +	return ret;
>>  }
>>  
>>  int nfs_wb_page_cancel(struct inode *inode, struct page *page)
> 
