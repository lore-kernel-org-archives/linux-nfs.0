Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-oi0-f68.google.com ([209.85.218.68]:35264 "EHLO
        mail-oi0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1161551AbdAEOUo (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 5 Jan 2017 09:20:44 -0500
Received: by mail-oi0-f68.google.com with SMTP id v84so78882384oie.2
        for <linux-nfs@vger.kernel.org>; Thu, 05 Jan 2017 06:20:44 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20170104172906.GC17649@fieldses.org>
References: <960d206f-3cb5-b60e-5245-d7282dabf664@gmail.com> <20170104172906.GC17649@fieldses.org>
From: Kinglong Mee <kinglongmee@gmail.com>
Date: Thu, 5 Jan 2017 22:20:43 +0800
Message-ID: <CAB6yy34YC_OL0ws9GdvAJBOLiQa_3sgKpo=N5025rJa-1xmQaA@mail.gmail.com>
Subject: Re: [PATCH] NFSD: only support readonly export for !fsync and
 readonly filesystem
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Christoph Hellwig <hch@infradead.org>,
        Steve Dickson <SteveD@redhat.com>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Jan 5, 2017 at 1:29 AM, J. Bruce Fields <bfields@fieldses.org> wrote:
> On Sat, Dec 31, 2016 at 09:18:08PM +0800, Kinglong Mee wrote:
>> Commit fae5096ad217
>> "nfsd: assume writeable exportabled filesystems have f_sync"
>> have remove the checking of f_sync.
>>
>> Christoph Hellwig suggests,
>> "Warn and refuse the writable export."
>>
>> I think just covert to a readonly export for !fsync filesystem,
>> also, for a readonly filesystem is reasonable.
>
> Hmmm.  It's not something we've done before.  Off hand, I can't see why
> it would cause a problem, but I'm not convinced yet.
>
> Could you add to the changelog a description of the use case you gave
> Christoph in your defense of this idea?

Okay, I will give more description about the patch include that.

>
> Also:
>
>> Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>
>> ---
>>  fs/nfsd/export.c | 12 ++++++++++++
>>  1 file changed, 12 insertions(+)
>>
>> diff --git a/fs/nfsd/export.c b/fs/nfsd/export.c
>> index 43e109c..3ec3b6b 100644
>> --- a/fs/nfsd/export.c
>> +++ b/fs/nfsd/export.c
>> @@ -358,6 +358,18 @@ static int check_export(struct inode *inode, int *flags, unsigned char *uuid)
>>       if (*flags & NFSEXP_V4ROOT)
>>               *flags |= NFSEXP_READONLY;
>>
>> +     /*
>> +      * Convert to a readonly export for that,
>> +      * 1. not supported fsync filesystem,
>> +      * 2. readonly filesystem.
>> +      */
>> +     if ((!inode->i_fop->fsync || IS_RDONLY(inode))
>> +         && !(*flags & NFSEXP_READONLY)) {
>> +             dprintk("exp_export: Only support readonly export "
>> +                     "for fsync unsupported or readonly filesystem.\n");
>
> Something like this might be more helpful:
>
>         "Filesystem %s: exporting read-only\n", IS_RDONLY(inode) ?
>                         "is read-only" : "has no fsync method"
>
> Also if we passed the dentry to check_export, could we do something
> like:
>
>         "%s %s: exporting read-only\n", d_path(dentry,...), IS_RDONLY...
>
> here and in the other warnings?

A kstrdup from svc_export_parse() 's string path parsing is simplify,
also, I will show in the next patch.

thanks,
Kinglong Mee

>
> --b.
>
>> +             *flags |= NFSEXP_READONLY;
>> +     }
>> +
>>       /* There are two requirements on a filesystem to be exportable.
>>        * 1:  We must be able to identify the filesystem from a number.
>>        *       either a device number (so FS_REQUIRES_DEV needed)
>> --
>> 2.9.3
