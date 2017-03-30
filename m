Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f196.google.com ([209.85.223.196]:35371 "EHLO
        mail-io0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S934023AbdC3R7w (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 30 Mar 2017 13:59:52 -0400
Received: by mail-io0-f196.google.com with SMTP id f103so3652990ioi.2
        for <linux-nfs@vger.kernel.org>; Thu, 30 Mar 2017 10:59:51 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1c58c56a-3a16-2a5d-b87c-d0019762ec9e@gmail.com>
References: <CAN-5tyG5s1B25WShf5HJ0DkYLpM7oQ1OiZO+zvg892yZ=68NoQ@mail.gmail.com>
 <20170330141055.61977-1-kolga@netapp.com> <1c58c56a-3a16-2a5d-b87c-d0019762ec9e@gmail.com>
From: Olga Kornievskaia <aglo@umich.edu>
Date: Thu, 30 Mar 2017 13:59:49 -0400
Message-ID: <CAN-5tyEYVstq8ALNXQE=bHTPcScOkMLWrYkRr7O1rdNUB73OkQ@mail.gmail.com>
Subject: Re: [PATCH 1/1] PNFS fix fallback to MDS if got error on commit to DS
To: Anna Schumaker <schumaker.anna@gmail.com>
Cc: Olga Kornievskaia <kolga@netapp.com>,
        Trond Myklebust <Trond.Myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        linux-nfs <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Mar 30, 2017 at 1:34 PM, Anna Schumaker
<schumaker.anna@gmail.com> wrote:
> Hi Olga,
>
> On 03/30/2017 10:10 AM, Olga Kornievskaia wrote:
>> Upong receiving some errors (EACCES) on commit to the DS the code
>> doesn't fallback to MDS and intead retrieds to the same DS again.
>
> Just so I know what's going on: do you want this patch instead of the first one in the thread?

Yes I do. I think this might be more correct. The previous patch would
call pnfs_set_lo_fail() twice for the "rpc connection errors from ds"
in file layout_async_handle_error() function. Also I think other
callers of filelayout_async_handle_error() (like read and write) when
they get these unhandled errors (like EACCES) would also benefit from
it caz otherwise they would also resend to the DS instead of MDS (but
I have not tested this case with EACCES and IO).

But what I would have liked a comment on is whether or not
pnfs_error_mark_layout_for_return() needs to be moved lower to?

>
> Thanks,
> Anna
>>
>> Signed-off-by: Olga Kornievskaia <kolga@netapp.com>
>> ---
>>  fs/nfs/filelayout/filelayout.c | 2 +-
>>  1 file changed, 1 insertion(+), 1 deletion(-)
>>
>> diff --git a/fs/nfs/filelayout/filelayout.c b/fs/nfs/filelayout/filelayout.c
>> index a3fc48b..59e1efa 100644
>> --- a/fs/nfs/filelayout/filelayout.c
>> +++ b/fs/nfs/filelayout/filelayout.c
>> @@ -202,10 +202,10 @@ static int filelayout_async_handle_error(struct rpc_task *task,
>>                       task->tk_status);
>>               nfs4_mark_deviceid_unavailable(devid);
>>               pnfs_error_mark_layout_for_return(inode, lseg);
>> -             pnfs_set_lo_fail(lseg);
>>               rpc_wake_up(&tbl->slot_tbl_waitq);
>>               /* fall through */
>>       default:
>> +             pnfs_set_lo_fail(lseg);
>>  reset:
>>               dprintk("%s Retry through MDS. Error %d\n", __func__,
>>                       task->tk_status);
>>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
