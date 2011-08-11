Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-vx0-f174.google.com ([209.85.220.174]:59300 "EHLO
	mail-vx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752135Ab1HKAEE convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 10 Aug 2011 20:04:04 -0400
Received: by vxi9 with SMTP id 9so1253343vxi.19
        for <linux-nfs@vger.kernel.org>; Wed, 10 Aug 2011 17:04:04 -0700 (PDT)
In-Reply-To: <4E42C564.7070504@panasas.com>
References: <1312685635-1593-1-git-send-email-bergwolf@gmail.com> <4E42C564.7070504@panasas.com>
From: Peng Tao <bergwolf@gmail.com>
Date: Thu, 11 Aug 2011 08:03:44 +0800
Message-ID: <CA+a=Yy4WXD64A3anw7f-wSWcs4A4-6W18QQs=YyYC0285_W_qg@mail.gmail.com>
Subject: Re: [PATCH 1/5] pNFS: recoalesce when ld write pagelist fails
To: Boaz Harrosh <bharrosh@panasas.com>
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>,
        Benny Halevy <benny@tonian.com>, linux-nfs@vger.kernel.org,
        Peng Tao <peng_tao@emc.com>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Thu, Aug 11, 2011 at 1:52 AM, Boaz Harrosh <bharrosh@panasas.com> wrote:
> On 08/06/2011 07:53 PM, Peng Tao wrote:
>> For pnfs pagelist write failure, we need to pg_recoalesce and resend
>> IO to mds.
>>
>
> I have not given this subject any thought or investigation, so I don't
> know what we should do, but the gut feeling is that I have seen all this
> code else where and we could be having a bigger re-use of existing code.
>
> What if we dig into:
>        data->mds_ops->rpc_call_done(&data->task, data);
>        data->mds_ops->rpc_release(data);
>
> And do all the pages tear-down and unlocks but if there is an error
> not set them as clean. That is keep them dirty. Then mark the layout
> as error and let the normal code choose an MDS write_out. (Just a wild
> thought)
This may work only for write failures. But for read, we will have to
recoalesce and send to MDS. So I prefer to let read and write have
similar retry code path like this.

>
> Trond please look in here, can't it be made simpler?
>
>
>> Signed-off-by: Peng Tao <peng_tao@emc.com>
>> ---
>>  fs/nfs/internal.h |    4 ++++
>>  fs/nfs/pnfs.c     |   35 ++++++++++++++++++++++++++++++++---
>>  fs/nfs/write.c    |   21 ++++++++++++++-------
>>  3 files changed, 50 insertions(+), 10 deletions(-)
>>
>> diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
>> index ab12913..62f183d 100644
>> --- a/fs/nfs/internal.h
>> +++ b/fs/nfs/internal.h
>> @@ -305,6 +305,10 @@ extern void nfs_readdata_release(struct nfs_read_data *rdata);
>>  /* write.c */
>>  extern int nfs_generic_flush(struct nfs_pageio_descriptor *desc,
>>               struct list_head *head);
>> +extern int do_nfs_writepage(struct page *page, struct writeback_control *wbc,
>> +             struct nfs_pageio_descriptor *pgio);
>> +extern void nfs_pageio_init_write_mds(struct nfs_pageio_descriptor *pgio,
>> +             struct inode *inode, int ioflags);
>>  extern void nfs_pageio_reset_write_mds(struct nfs_pageio_descriptor *pgio);
>>  extern void nfs_writedata_release(struct nfs_write_data *wdata);
>>  extern void nfs_commit_free(struct nfs_write_data *p);
>> diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
>> index e550e88..08aba45 100644
>> --- a/fs/nfs/pnfs.c
>> +++ b/fs/nfs/pnfs.c
>> @@ -1172,6 +1172,13 @@ int
>>  pnfs_ld_write_done(struct nfs_write_data *data)
>>  {
>>       int status;
>> +     struct nfs_pageio_descriptor pgio;
>> +     struct writeback_control wbc = {
>> +             .sync_mode = WB_SYNC_ALL,
>> +             .range_start = data->mds_offset,
>> +             .nr_to_write = data->npages,
>> +             .range_end = LLONG_MAX,
>> +     };
>>
>>       if (!data->pnfs_error) {
>>               pnfs_set_layoutcommit(data);
>> @@ -1180,11 +1187,33 @@ pnfs_ld_write_done(struct nfs_write_data *data)
>>               return 0;
>>       }
>>
>> +     put_lseg(data->lseg);
>> +     data->lseg = NULL;
>>       dprintk("%s: pnfs_error=%d, retry via MDS\n", __func__,
>>               data->pnfs_error);
>> -     status = nfs_initiate_write(data, NFS_CLIENT(data->inode),
>> -                                 data->mds_ops, NFS_FILE_SYNC);
>> -     return status ? : -EAGAIN;
>> +     nfs_pageio_init_write_mds(&pgio, data->inode, FLUSH_STABLE);
>> +     pgio.pg_recoalesce = 1;
>> +     while (!list_empty(&data->pages)) {
>> +             struct nfs_page *req = nfs_list_entry(data->pages.next);
>> +             struct page *page = req->wb_page;
>> +
>> +             nfs_list_remove_request(req);
>> +             nfs_clear_page_tag_locked(req);
>> +
>> +             end_page_writeback(page);
>> +
>> +             lock_page(page);
>> +             status = do_nfs_writepage(page, &wbc, &pgio);
>> +             if (status) {
>> +                     /* FIXME: is this enough?? */
>> +                     set_page_dirty(page);
>> +             }
>> +             unlock_page(page);
>> +     }
>> +     nfs_pageio_complete(&pgio);
>> +     nfs_writedata_release(data);
>> +
>> +     return 0;
>>  }
>>  EXPORT_SYMBOL_GPL(pnfs_ld_write_done);
>>
>> diff --git a/fs/nfs/write.c b/fs/nfs/write.c
>> index b39b37f..0ccdf98 100644
>> --- a/fs/nfs/write.c
>> +++ b/fs/nfs/write.c
>> @@ -285,14 +285,9 @@ out:
>>       return ret;
>>  }
>>
>> -static int nfs_do_writepage(struct page *page, struct writeback_control *wbc, struct nfs_pageio_descriptor *pgio)
>> +int do_nfs_writepage(struct page *page, struct writeback_control *wbc, struct nfs_pageio_descriptor *pgio)
>>  {
>> -     struct inode *inode = page->mapping->host;
>>       int ret;
>> -
>> -     nfs_inc_stats(inode, NFSIOS_VFSWRITEPAGE);
>> -     nfs_add_stats(inode, NFSIOS_WRITEPAGES, 1);
>> -
>>       nfs_pageio_cond_complete(pgio, page->index);
>>       ret = nfs_page_async_flush(pgio, page, wbc->sync_mode == WB_SYNC_NONE);
>>       if (ret == -EAGAIN) {
>> @@ -301,6 +296,17 @@ static int nfs_do_writepage(struct page *page, struct writeback_control *wbc, st
>>       }
>>       return ret;
>>  }
>> +EXPORT_SYMBOL_GPL(do_nfs_writepage);
>> +
>> +static int nfs_do_writepage(struct page *page, struct writeback_control *wbc, struct nfs_pageio_descriptor *pgio)
>
> This is a terrible name please invent something more appropriate. You can't have an
> nfs_do_writepage call a do_nfs_writepage it's the same name. Please use a different name
> that describes what is the point of this function. (nfs_writepage_stats ???)
Agreed. Will change it.

>
>> +{
>> +     struct inode *inode = page->mapping->host;
>> +
>> +     nfs_inc_stats(inode, NFSIOS_VFSWRITEPAGE);
>> +     nfs_add_stats(inode, NFSIOS_WRITEPAGES, 1);
>> +
>> +     return do_nfs_writepage(page, wbc, pgio);
>> +}
>>
>>  /*
>>   * Write an mmapped page to the server.
>> @@ -1051,12 +1057,13 @@ static const struct nfs_pageio_ops nfs_pageio_write_ops = {
>>       .pg_doio = nfs_generic_pg_writepages,
>>  };
>>
>> -static void nfs_pageio_init_write_mds(struct nfs_pageio_descriptor *pgio,
>> +void nfs_pageio_init_write_mds(struct nfs_pageio_descriptor *pgio,
>>                                 struct inode *inode, int ioflags)
>>  {
>>       nfs_pageio_init(pgio, inode, &nfs_pageio_write_ops,
>>                               NFS_SERVER(inode)->wsize, ioflags);
>>  }
>> +EXPORT_SYMBOL_GPL(nfs_pageio_init_write_mds);
>
> Why is this EXPORT? if you are going to use it from LD driver later
> in a patch that we did not yet see, please only make it export in the
> patch that has a user for it. (You don't need EXPORT_X if it is used
> by a different file inside nfs.ko, just only remove the static)
Will change it. Thanks.

>
>>
>>  void nfs_pageio_reset_write_mds(struct nfs_pageio_descriptor *pgio)
>>  {
>
> Thanks for looking into this issue. Actually looking back we always had
> a problem here. I never was able to pass my error injection tests.
Thanks for reviewing. I will wait for Trond's comments before sending
the next version.

-- 
Thanks,
-Bergwolf
