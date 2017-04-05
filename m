Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f180.google.com ([209.85.223.180]:34236 "EHLO
        mail-io0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932603AbdDEP0c (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 5 Apr 2017 11:26:32 -0400
Received: by mail-io0-f180.google.com with SMTP id b140so12027045iof.1
        for <linux-nfs@vger.kernel.org>; Wed, 05 Apr 2017 08:26:32 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <87efx7irru.fsf@notabene.neil.brown.name>
References: <20170405001206.GA58184@beast> <87efx7irru.fsf@notabene.neil.brown.name>
From: Kees Cook <keescook@chromium.org>
Date: Wed, 5 Apr 2017 08:26:30 -0700
Message-ID: <CAGXu5jKR_iL5UsYZcRDNoEvQKX_UJstJ8p6HCxhhQM7HRQgQeA@mail.gmail.com>
Subject: Re: [PATCH] NFS: Avoid cross-structure casting
To: NeilBrown <neilb@suse.com>
Cc: LKML <linux-kernel@vger.kernel.org>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        "open list:NFS, SUNRPC, AND..." <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Apr 4, 2017 at 6:09 PM, NeilBrown <neilb@suse.com> wrote:
> On Tue, Apr 04 2017, Kees Cook wrote:
>
>> When the call to nfs_devname() fails, the error path attempts to retain
>> the error via the mnt variable, but this requires a cast across very
>> different types (char * to struct vfsmount), which the upcoming structure
>> layout randomization plugin flags as being potentially dangerous in the
>> face of randomization. This is a false positive, but what this code
>> actually wants to do is retain the error value, so this patch explicitly
>> sets it, instead of using what seems to be an unexpected cast.
>>
>> Signed-off-by: Kees Cook <keescook@chromium.org>
>> ---
>>  fs/nfs/namespace.c | 5 +++--
>>  1 file changed, 3 insertions(+), 2 deletions(-)
>>
>> diff --git a/fs/nfs/namespace.c b/fs/nfs/namespace.c
>> index 786f17580582..89f50bf12f52 100644
>> --- a/fs/nfs/namespace.c
>> +++ b/fs/nfs/namespace.c
>> @@ -259,9 +259,10 @@ struct vfsmount *nfs_do_submount(struct dentry *dentry, struct nfs_fh *fh,
>>       if (page == NULL)
>>               goto out;
>>       devname = nfs_devname(dentry, page, PAGE_SIZE);
>> -     mnt = (struct vfsmount *)devname;
>> -     if (IS_ERR(devname))
>> +     if (IS_ERR(devname)) {
>> +             mnt = ERR_PTR(PTR_ERR(devname));
>
> Allow me to introduce you to ERR_CAST()

Ah! Thank you, yes, that's precisely what I wanted. And only 10 lines
away from where I was reading in err.h trying to find the right
approach. *sigh*

> /**
>  * ERR_CAST - Explicitly cast an error-valued pointer to another pointer type
>  * @ptr: The pointer to cast.
>  *
>  * Explicitly cast an error-valued pointer to another pointer type in such a
>  * way as to make it clear that's what's going on.
>  */
>
> So:
>  +              mnt = ERR_CAST(devname);

I'll send a v2. :)

-Kees

-- 
Kees Cook
Pixel Security
