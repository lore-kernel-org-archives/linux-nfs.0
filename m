Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:52350 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932761AbcLGWzz (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 7 Dec 2016 17:55:55 -0500
From: "Benjamin Coddington" <bcodding@redhat.com>
To: "Trond Myklebust" <trondmy@primarydata.com>
Cc: "Linux NFS Mailing List" <linux-nfs@vger.kernel.org>
Subject: Re: Concurrent `ls` takes out the thrash
Date: Wed, 07 Dec 2016 17:55:53 -0500
Message-ID: <EC88DF6D-5A78-499C-A6A8-A5D74083876F@redhat.com>
In-Reply-To: <6C5DA8AC-9A42-45FA-892C-E9597A7F7AC9@primarydata.com>
References: <C2A81CDB-ED8F-4D41-919F-3F92CBFF751B@redhat.com>
 <CEE29C1D-BB8F-4504-940D-43DE1FE63385@primarydata.com>
 <7DA8E9BE-7353-44D5-B982-B477CF7B0A57@redhat.com>
 <934FC075-4393-42AD-92A3-3BC3BE580699@redhat.com>
 <6C5DA8AC-9A42-45FA-892C-E9597A7F7AC9@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 7 Dec 2016, at 17:41, Trond Myklebust wrote:

>> On Dec 7, 2016, at 17:34, Benjamin Coddington <bcodding@redhat.com> 
>> wrote:
>> static
>> @@ -921,7 +930,7 @@ static int nfs_readdir(struct file *file, struct 
>> dir_context *ctx)
>> 	desc->ctx = ctx;
>> 	desc->dir_cookie = &dir_ctx->dir_cookie;
>> 	desc->decode = NFS_PROTO(inode)->decode_dirent;
>> -	desc->plus = nfs_use_readdirplus(inode, ctx) ? 1 : 0;
>> +	desc->plus = nfs_use_readdirplus(inode, ctx, dir_ctx) ? 1 : 0;
>
> This fixes desc->plus at the beginning of the readdir() call. Perhaps 
> we
> should instead check the value of ctx->use_readdir_plus in the call to
> nfs_readdir_xdr_filler(), and just resetting cts->use_readdir_plus at 
> the
> very end of nfs_readdir()?

I don't understand the functional difference.  Is this just a 
preference?

There must be something else happening.. dcache is getting under 
pressure
pruned maybe, that causes a miss and then the process starts over?

Ben
