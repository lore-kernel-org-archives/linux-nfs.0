Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qc0-f177.google.com ([209.85.216.177]:64132 "EHLO
	mail-qc0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754485AbaKEOZR (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 5 Nov 2014 09:25:17 -0500
Received: by mail-qc0-f177.google.com with SMTP id l6so587755qcy.22
        for <linux-nfs@vger.kernel.org>; Wed, 05 Nov 2014 06:25:17 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <CAABAsM4UjXP9UP4JHbTcBfrYn3O8O+20rV5SELm8JmLZU3cWXw@mail.gmail.com>
References: <1415178014-17893-1-git-send-email-tao.peng@primarydata.com> <CAABAsM4UjXP9UP4JHbTcBfrYn3O8O+20rV5SELm8JmLZU3cWXw@mail.gmail.com>
From: Peng Tao <tao.peng@primarydata.com>
Date: Wed, 5 Nov 2014 22:24:56 +0800
Message-ID: <CAKVebiUZwZUgN8=mc88x8f4AEV7GKsv=1SVTb8pOqRzjaCn53w@mail.gmail.com>
Subject: Re: [PATCH] nfs: fix pnfs direct write memory leak
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Nov 5, 2014 at 8:49 PM, Trond Myklebust
<trond.myklebust@primarydata.com> wrote:
> On Wed, Nov 5, 2014 at 4:00 AM, Peng Tao <tao.peng@primarydata.com> wrote:
>> For pNFS direct writes, layout driver may dynamically allocate ds_cinfo.buckets.
>> So we need to take care to free them when freeing dreq.
>>
>> Ideally this needs to be done inside layout driver where ds_cinfo.buckets
>> are allocated. But buckets are attached to dreq and reused across LD IO iterations.
>> So I feel it's OK to free them in the generic layer.
>>
>> Cc: stable@vger.kernel.org [v3.4+]
>> Signed-off-by: Peng Tao <tao.peng@primarydata.com>
>> ---
>>  fs/nfs/direct.c | 2 ++
>>  1 file changed, 2 insertions(+)
>>
>> diff --git a/fs/nfs/direct.c b/fs/nfs/direct.c
>> index 20cffc8..61f1904 100644
>> --- a/fs/nfs/direct.c
>> +++ b/fs/nfs/direct.c
>> @@ -266,6 +266,8 @@ static void nfs_direct_req_free(struct kref *kref)
>>  {
>>         struct nfs_direct_req *dreq = container_of(kref, struct nfs_direct_req, kref);
>>
>> +       if (dreq->ds_cinfo.nbuckets)
>> +               kfree(dreq->ds_cinfo.buckets);
>>         if (dreq->l_ctx != NULL)
>>                 nfs_put_lock_context(dreq->l_ctx);
>>         if (dreq->ctx != NULL)
>> --
>>
>
> Well spotted!
> However doesn't the above need to be limited with an #ifdef
> CONFIG_NFS_V4_1? Perhaps you can add a helper in
> include/linux/nfs_xdr.h that takes a struct pnfs_ds_commit_info and
> then frees the nbuckets.
> Note also that kfree() is happy to take a NULL argument.
>
You are right! I'll send v2.

Thanks,
Tao
