Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-vc0-f178.google.com ([209.85.220.178]:60278 "EHLO
	mail-vc0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753060AbaJMPZa (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 13 Oct 2014 11:25:30 -0400
Received: by mail-vc0-f178.google.com with SMTP id hq12so6133383vcb.9
        for <linux-nfs@vger.kernel.org>; Mon, 13 Oct 2014 08:25:29 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CAHQdGtT12WC896sZwHQkgXgiPx0ODckX2dhNZb0O+XHBUN2E-A@mail.gmail.com>
References: <1413209295-13509-1-git-send-email-andros@netapp.com>
	<CAHQdGtT12WC896sZwHQkgXgiPx0ODckX2dhNZb0O+XHBUN2E-A@mail.gmail.com>
Date: Mon, 13 Oct 2014 11:25:29 -0400
Message-ID: <CAHQdGtRpmS6EXCb2cj48BAeT3uHYC5kjJp8YGaRAt5CR4M_7Jw@mail.gmail.com>
Subject: Re: [PATCH 1/1] NFSv4: open context can be NULL in nfs_put_open_context
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Resending to list... Apologies for the duplicate...

On Mon, Oct 13, 2014 at 11:24 AM, Trond Myklebust
<trond.myklebust@primarydata.com> wrote:
> Hi Andy,
>
>
> On Mon, Oct 13, 2014 at 10:08 AM, <andros@netapp.com> wrote:
>>
>> From: Andy Adamson <andros@netapp.com>
>>
>> If a pgio error is caught before the nfs_pgio_header args->context is set
>> with get_nfs_open_context, the context can be NULL.
>>
>> Signed-off-by: Andy Adamson <andros@netapp.com>
>> ---
>>  fs/nfs/inode.c | 3 +++
>>  1 file changed, 3 insertions(+)
>>
>> diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
>> index 141c9f4..a2b148e 100644
>> --- a/fs/nfs/inode.c
>> +++ b/fs/nfs/inode.c
>> @@ -798,6 +798,9 @@ static void __put_nfs_open_context(struct
>> nfs_open_context *ctx, int is_sync)
>>         struct inode *inode = ctx->dentry->d_inode;
>>         struct super_block *sb = ctx->dentry->d_sb;
>>
>> +       if (ctx == NULL)
>> +               return;
>> +
>>         if (!list_empty(&ctx->list)) {
>>                 if (!atomic_dec_and_lock(&ctx->lock_context.count,
>> &inode->i_lock))
>>                         return;
>> --
>> 1.8.3.1
>>
>
> AFAICS, there is only one callsite where we need to check the context, so we
> can avoid the check on all calls to put_nfs_open_context. Please see PATCH
> 1/2 that I just posted in response to an off-list bug report from Steve
> Dickson.
>
> Cheers
>   Trond
> --
>
> Trond Myklebust
>
> Linux NFS client maintainer, PrimaryData
>
> trond.myklebust@primarydata.com



-- 
Trond Myklebust

Linux NFS client maintainer, PrimaryData

trond.myklebust@primarydata.com
