Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ie0-f175.google.com ([209.85.223.175]:47619 "EHLO
	mail-ie0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753759AbaLVCHS (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 21 Dec 2014 21:07:18 -0500
Received: by mail-ie0-f175.google.com with SMTP id x19so3624053ier.20
        for <linux-nfs@vger.kernel.org>; Sun, 21 Dec 2014 18:07:17 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <54909E1B.4000005@Netapp.com>
References: <1418756513-95187-1-git-send-email-loghyr@primarydata.com>
 <1418756513-95187-39-git-send-email-loghyr@primarydata.com> <54909E1B.4000005@Netapp.com>
From: Peng Tao <bergwolf@gmail.com>
Date: Mon, 22 Dec 2014 10:06:57 +0800
Message-ID: <CA+a=Yy44H40uk6RdHyRrftEZs0X=io2p7tVqRpLMqjvDFmZkLw@mail.gmail.com>
Subject: Re: [PATCH 38/50] nfs41: add a debug warning if we destroy an unempty layout
To: Anna Schumaker <Anna.Schumaker@netapp.com>
Cc: Tom Haynes <thomas.haynes@primarydata.com>,
        Trond Myklebust <Trond.Myklebust@primarydata.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Dec 17, 2014 at 5:03 AM, Anna Schumaker
<Anna.Schumaker@netapp.com> wrote:
> On 12/16/2014 02:01 PM, Tom Haynes wrote:
>> From: Peng Tao <tao.peng@primarydata.com>
>>
>> So that we can detect the case if some layout segments are still
>> pinned which is surely a bug that we need to fix.
>
> How often is this hit?  A patch fixing the bug would be better than a patch just to detect it :).
>
Never yet :)

I was suspecting a bug in segment reference counting and thus added
the patch. That bug turns out to be somewhere else but I thought the
WARN makes sense in general sense because without it we silently
ignores unfreed reference counts.

Cheers,
Tao

> Anna
>
>>
>> Signed-off-by: Peng Tao <tao.peng@primarydata.com>
>> ---
>>  fs/nfs/pnfs.c | 2 ++
>>  1 file changed, 2 insertions(+)
>>
>> diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
>> index 5f7c422..e123cfc 100644
>> --- a/fs/nfs/pnfs.c
>> +++ b/fs/nfs/pnfs.c
>> @@ -242,6 +242,8 @@ pnfs_put_layout_hdr(struct pnfs_layout_hdr *lo)
>>       struct inode *inode = lo->plh_inode;
>>
>>       if (atomic_dec_and_lock(&lo->plh_refcount, &inode->i_lock)) {
>> +             if (!list_empty(&lo->plh_segs))
>> +                     WARN_ONCE(1, "NFS: BUG unfreed layout segments.\n");
>>               pnfs_detach_layout_hdr(lo);
>>               spin_unlock(&inode->i_lock);
>>               pnfs_free_layout_hdr(lo);
>>
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
