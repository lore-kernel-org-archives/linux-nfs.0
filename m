Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-gy0-f174.google.com ([209.85.160.174]:36976 "EHLO
	mail-gy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753939Ab2DCNpV convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 3 Apr 2012 09:45:21 -0400
Received: by ghrr11 with SMTP id r11so1743744ghr.19
        for <linux-nfs@vger.kernel.org>; Tue, 03 Apr 2012 06:45:20 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <4F762AD1.2090306@panasas.com>
References: <4F7625D7.8070801@panasas.com> <4F762AD1.2090306@panasas.com>
From: Benny Halevy <bhalevy@tonian.com>
Date: Tue, 3 Apr 2012 16:45:00 +0300
Message-ID: <CAEMWVhsKLTWLA9Rc_jftgDkZ=WL-5RKoPFsh5ajn-zxw6F=Rbw@mail.gmail.com>
Subject: Re: [osd-dev] [PATCH] pnfs-obj: Remove unused variable from objlayout_get_deviceinfo()
To: Boaz Harrosh <bharrosh@panasas.com>
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>,
        NFS list <linux-nfs@vger.kernel.org>, open-osd <osd-dev@open-osd.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sat, Mar 31, 2012 at 12:51 AM, Boaz Harrosh <bharrosh@panasas.com> wrote:
> On 03/30/2012 02:29 PM, Boaz Harrosh wrote:
>
>> From: Sachin Bhamare <sbhamare@panasas.com>
>>
>> Local variable 'sb' was not being used in objlayout_get_deviceinfo().
>>
>> Signed-off-by: Sachin Bhamare <sbhamare@panasas.com>
>> Signed-off-by: Boaz Harrosh <bharrosh@panasas.com>
>
>
> I was transitioning all my tree's to the 3.4-rc0 Kernel and noticed
> we forgot this patch, Please add it to what ever next-kernel branch you
> have.
>
> Benny could you please make a pnfs-all-3.3 branch? It should be identical
> to the 3.3-rc6, probably, but just for completeness.

I'll do that after rebasing to v3.3 (which I've been chasing my tail to do)

>
> Tell me if you also want to add the autologin patches to it I can help
> out with that. Else the client side went into 3.4-rc0 so I'll send you
> the exofs side for your future 3.4-rc1 tree.

I prefer to apply it for 3.4-rc.

>
> Thanks

Sure :)

Benny

> Boaz
>
>> ---
>>  fs/nfs/objlayout/objlayout.c |    2 --
>>  1 files changed, 0 insertions(+), 2 deletions(-)
>>
>> diff --git a/fs/nfs/objlayout/objlayout.c b/fs/nfs/objlayout/objlayout.c
>> index 1ae53eb..b158d1b 100644
>> --- a/fs/nfs/objlayout/objlayout.c
>> +++ b/fs/nfs/objlayout/objlayout.c
>> @@ -604,7 +604,6 @@ int objlayout_get_deviceinfo(struct pnfs_layout_hdr *pnfslay,
>>  {
>>       struct objlayout_deviceinfo *odi;
>>       struct pnfs_device pd;
>> -     struct super_block *sb;
>>       struct page *page, **pages;
>>       u32 *p;
>>       int err;
>> @@ -623,7 +622,6 @@ int objlayout_get_deviceinfo(struct pnfs_layout_hdr *pnfslay,
>>       pd.pglen = PAGE_SIZE;
>>       pd.mincount = 0;
>>
>> -     sb = pnfslay->plh_inode->i_sb;
>>       err = nfs4_proc_getdeviceinfo(NFS_SERVER(pnfslay->plh_inode), &pd);
>>       dprintk("%s nfs_getdeviceinfo returned %d\n", __func__, err);
>>       if (err)
>
>
