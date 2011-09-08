Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-vx0-f174.google.com ([209.85.220.174]:62150 "EHLO
	mail-vx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752834Ab1IHPKG convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 8 Sep 2011 11:10:06 -0400
Received: by vxi9 with SMTP id 9so270657vxi.19
        for <linux-nfs@vger.kernel.org>; Thu, 08 Sep 2011 08:10:05 -0700 (PDT)
In-Reply-To: <4E68BCD4.9030202@nexenta.com>
References: <1314512558-16912-1-git-send-email-gusev.vitaliy@nexenta.com>
 <1315337382.16274.7.camel@lade.trondhjem.org> <4E669B21.30006@nexenta.com>
 <F19688880B763E40B28B2B462677FBF805C3299C9C@MX09A.corp.emc.com> <4E68BCD4.9030202@nexenta.com>
From: Peng Tao <bergwolf@gmail.com>
Date: Thu, 8 Sep 2011 23:09:45 +0800
Message-ID: <CA+a=Yy69oQeuSagh_o-32U-rgmwz0BpeZawhMurFK8h6vD2Org@mail.gmail.com>
Subject: Re: [PATCH] nfs: fix inifinite loop at nfs4_layoutcommit_release
To: Vitaliy Gusev <gusev.vitaliy@nexenta.com>
Cc: tao.peng@emc.com, Trond.Myklebust@netapp.com, gusev.vitaliy@gmail.com,
        linux-nfs@vger.kernel.org
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Hi, Gusev,
On Thu, Sep 8, 2011 at 9:02 PM, Vitaliy Gusev <gusev.vitaliy@nexenta.com> wrote:
> On 09/08/2011 02:00 PM, tao.peng@emc.com wrote:
>>
>> Hi, Gusev,
>
> Hello Tao!
>
>> Yes, you are right. How about following patch?
>>
>>  From 14c6da67565fb31c2d2775ccefd93251f348910d Mon Sep 17 00:00:00 2001
>> From: Peng Tao<bergwolf@gmail.com>
>> Date: Thu, 8 Sep 2011 00:57:02 -0400
>> Subject: [PATCH] nfsv4: fix race in layoutcommit lseg list create/free
>>
>> Since there can be more than one layoutcommit proc happen the same time,
>> lseg list create/free should be protected. Otherwise lseg list
>> may get corrupted.
>>
>> Reported-by: Vitaliy Gusev<gusev.vitaliy@nexenta.com>
>> Signed-off-by: Peng Tao<peng_tao@emc.com>
>> ---
>>  fs/nfs/nfs4proc.c |    2 ++
>>  1 files changed, 2 insertions(+), 0 deletions(-)
>>
>> diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
>> index 8c77039..da7c20c 100644
>> --- a/fs/nfs/nfs4proc.c
>> +++ b/fs/nfs/nfs4proc.c
>> @@ -5964,6 +5964,7 @@ static void nfs4_layoutcommit_release(void
>> *calldata)
>>        struct pnfs_layout_segment *lseg, *tmp;
>>
>>        pnfs_cleanup_layoutcommit(data);
>> +       spin_lock(&data->args.inode->i_lock);
>
> I think lock over list_del_init(&lseg->pls_lc_list) is enough, because
I put the spinlock outside of the loop because the critical section is
short enough and it should be faster than grabbing/dropping the inode
lock for every entry in the list, agree?

Thanks,
Tao

>
> 1. here lseg is deleted from unique (placed in stack) data and there is no
> any race during deletion.
>
>
> 2. Only one thing must be protected - list_empty status at
> pnfs_list_write_lseg (after my patch).
>
>   The problem is that list_del_init is placed before test_and_clear_bit and
> spinlock can be some kind of barrier for protection against adding lseg to
> new data->lseg_list at
> pnfs_list_write_lseg.
>
>   Do reordering list_del_init with test_and_clear_bit is not good, because
> lseg can be invalid after put_lseg.
>
>
>>        /* Matched by references in pnfs_set_layoutcommit */
>>        list_for_each_entry_safe(lseg, tmp,&data->lseg_list, pls_lc_list) {
>>                list_del_init(&lseg->pls_lc_list);
>> @@ -5971,6 +5972,7 @@ static void nfs4_layoutcommit_release(void
>> *calldata)
>>                                &lseg->pls_flags))
>>                        put_lseg(lseg);
>>        }
>> +       spin_unlock(&data->args.inode->i_lock);
>>        put_rpccred(data->cred);
>>        kfree(data);
>>  }
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>



-- 
Thanks,
-Bergwolf
