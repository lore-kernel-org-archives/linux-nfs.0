From: "William A. (Andy) Adamson" <androsadamson@gmail.com>
Subject: Re: [PATCH 1/1] nfs4 use mandatory attribute file type in
	nfs4_get_root
Date: Tue, 15 Jun 2010 09:30:54 -0400
Message-ID: <AANLkTilKwdBqGoujSBEKhk2OHioPAnjv8mCEAotvUIR4@mail.gmail.com>
References: <1276203143-2118-1-git-send-email-andros@netapp.com>
	<1276552926.3953.8.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: linux-nfs@vger.kernel.org
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-gw0-f46.google.com ([74.125.83.46]:37806 "EHLO
	mail-gw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752959Ab0FONa4 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 15 Jun 2010 09:30:56 -0400
Received: by mail-gw0-f46.google.com with SMTP id 15so3148420gwj.19
        for <linux-nfs@vger.kernel.org>; Tue, 15 Jun 2010 06:30:56 -0700 (PDT)
In-Reply-To: <1276552926.3953.8.camel-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Jun 14, 2010 at 6:02 PM, Trond Myklebust
<Trond.Myklebust@netapp.com> wrote:
> On Thu, 2010-06-10 at 16:52 -0400, andros@netapp.com wrote:
>> From: Andy Adamson <andros@netapp.com>
>>
>> decode_attr_type sets fattr->mode.
>
> Well, yes... It sets part of fattr->mode. More specifically, though, it
> sets the file type part, so your patch is correct.
>
> I'll fix up the above changelog entry so that it is a bit more
> descriptive. How about the following?
>
>        S_ISDIR(fsinfo.fattr->mode) checks the file type rather than the
>        mode bits, so we should be checking for the NFS_ATTR_FATTR_TYPE
>        fattr property.

Looks good.

-->Andy

>
>>
>> Signed-off-by: Andy Adamson <andros@netapp.com>
>> ---
>>  fs/nfs/getroot.c |    2 +-
>>  1 files changed, 1 insertions(+), 1 deletions(-)
>>
>> diff --git a/fs/nfs/getroot.c b/fs/nfs/getroot.c
>> index 7428f7d..a70e446 100644
>> --- a/fs/nfs/getroot.c
>> +++ b/fs/nfs/getroot.c
>> @@ -146,7 +146,7 @@ int nfs4_get_rootfh(struct nfs_server *server, struct nfs_fh *mntfh)
>>               goto out;
>>       }
>>
>> -     if (!(fsinfo.fattr->valid & NFS_ATTR_FATTR_MODE)
>> +     if (!(fsinfo.fattr->valid & NFS_ATTR_FATTR_TYPE)
>>                       || !S_ISDIR(fsinfo.fattr->mode)) {
>>               printk(KERN_ERR "nfs4_get_rootfh:"
>>                      " getroot encountered non-directory\n");
>
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
