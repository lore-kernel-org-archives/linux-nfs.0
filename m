Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-iw0-f174.google.com ([209.85.214.174]:39623 "EHLO
	mail-iw0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752353Ab0JGT25 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 7 Oct 2010 15:28:57 -0400
Received: by iwn9 with SMTP id 9so204613iwn.19
        for <linux-nfs@vger.kernel.org>; Thu, 07 Oct 2010 12:28:56 -0700 (PDT)
In-Reply-To: <4CAE16FA.9040606@panasas.com>
References: <1286480230-9418-1-git-send-email-andros@netapp.com>
	<4CAE16FA.9040606@panasas.com>
Date: Thu, 7 Oct 2010 15:28:53 -0400
Message-ID: <AANLkTi==KuNTW0yPsupb4p20+qTaD3vpOux9wF4Ekd8g@mail.gmail.com>
Subject: Re: [PATCH 1/3] pnfs_submit: move layout segment valid test
From: "William A. (Andy) Adamson" <androsadamson@gmail.com>
To: Benny Halevy <bhalevy@panasas.com>
Cc: linux-nfs@vger.kernel.org
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Thu, Oct 7, 2010 at 2:52 PM, Benny Halevy <bhalevy@panasas.com> wrote:
> On 2010-10-07 15:37, andros@netapp.com wrote:
>> From: Andy Adamson <andros@rhel6-1.androsmac.org>
>>
>> Do not get_lseg for a non-valid lseg.
>> Prepare for calling put_lseg outside of inode i_lock.
>>
>> Signed-off-by: Andy Adamson <andros@netapp.com>
>> ---
>>  fs/nfs/pnfs.c |    4 ++--
>>  1 files changed, 2 insertions(+), 2 deletions(-)
>>
>> diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
>> index 6b2a95d..24620cf 100644
>> --- a/fs/nfs/pnfs.c
>> +++ b/fs/nfs/pnfs.c
>> @@ -845,7 +845,8 @@ pnfs_has_layout(struct pnfs_layout_hdr *lo,
>>       list_for_each_entry(lseg, &lo->segs, fi_list) {
>>               if (is_matching_lseg(lseg, range)) {
>>                       ret = lseg;
>> -                     get_lseg(ret);
>> +                     if (lseg->valid)
>> +                             get_lseg(ret);
>
> We shouldn't be hiding this inside pnfs_has_layout
> and have different side effects in the different cases.

Sorry - I just looked at the pnfs-submit branch. I should have looked
at the pnfs-all branch and seen the other callers of pnfs_has_layout.

> Since we're called under the lock, pnfs_has_layout
> can just return the lseg and never get a reference and its
> caller can take it if necessary before releasing the lock.
>
> Also, it doesn't need to be EXPORT_SYMBOL_GPLed as it's
> not used outside of the nfs client module.

Right - Fred just removed the call in the file layout driver.

I'll fix this.

-->Andy

>
> Benny
>
>>                       break;
>>               }
>>               if (cmp_layout(range, &lseg->range) > 0)
>> @@ -889,7 +890,6 @@ pnfs_update_layout(struct inode *ino,
>>       /* Check to see if the layout for the given range already exists */
>>       lseg = pnfs_has_layout(lo, &arg);
>>       if (lseg && !lseg->valid) {
>> -             put_lseg_locked(lseg);
>>               /* someone is cleaning the layout */
>>               lseg = NULL;
>>               goto out_unlock;
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
