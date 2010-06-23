From: Andy Adamson <andros@netapp.com>
Subject: Re: [PATCH 3/8] SQUASHME pnfs-submit: tell commit to use the MDS
Date: Wed, 23 Jun 2010 10:24:46 -0400
Message-ID: <FB284E7B-7A63-4E6B-99F1-F205D6496614@netapp.com>
References: <1277243798-8181-1-git-send-email-andros@netapp.com> <1277243798-8181-2-git-send-email-andros@netapp.com> <1277243798-8181-3-git-send-email-andros@netapp.com> <1277243798-8181-4-git-send-email-andros@netapp.com> <AANLkTimh37nfPbw5CZmBJv1XhIqrlogV_0nUVSDaxZJ3@mail.gmail.com> <F3672AD5-CEF8-477F-8E52-E1FDA3624744@netapp.com> <AANLkTikzfFVMd76tevedVeQ4Q6ot5wxXZ8fxKFNz_zyK@mail.gmail.com>
Mime-Version: 1.0 (Apple Message framework v936)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Cc: bhalevy@panasas.com, linux-nfs@vger.kernel.org
To: Fred Isaman <iisaman@umich.edu>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:41000 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752503Ab0FWOYs (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 23 Jun 2010 10:24:48 -0400
In-Reply-To: <AANLkTikzfFVMd76tevedVeQ4Q6ot5wxXZ8fxKFNz_zyK-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Jun 23, 2010, at 10:11 AM, Fred Isaman wrote:

> On Wed, Jun 23, 2010 at 9:53 AM, Andy Adamson <andros@netapp.com>  
> wrote:
>>
>> On Jun 23, 2010, at 9:34 AM, Fred Isaman wrote:
>>
>>> On Tue, Jun 22, 2010 at 5:56 PM,  <andros@netapp.com> wrote:
>>>>
>>>> From: Andy Adamson <andros@netapp.com>
>>>>
>>>> Signed-off-by: Andy Adamson <andros@netapp.com>
>>>> ---
>>>>  fs/nfs/pnfs.c |    1 +
>>>>  1 files changed, 1 insertions(+), 0 deletions(-)
>>>>
>>>> diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
>>>> index 9a295cf..c1a8066 100644
>>>> --- a/fs/nfs/pnfs.c
>>>> +++ b/fs/nfs/pnfs.c
>>>> @@ -1454,6 +1454,7 @@ pnfs_writepages(struct nfs_write_data  
>>>> *wdata, int
>>>> how)
>>>>                                                       wdata);
>>>>
>>>>       if (trypnfs == PNFS_NOT_ATTEMPTED) {
>>>> +               wdata->req->wb_lseg = NULL;
>>>
>>> This is wrong.  It will be taken care of by
>>> _pnfs_clear_lseg_from_pages called by pnfs_try_to_write_data.
>>
>> A partial write, e.g. one that uses nfs_write_partial_ops, does not  
>> set
>> nfs_write_data->pages, so _pnfs_clear_lseg_from_pages does not take  
>> care of
>> clearing the req->wb_lseg.
>>
>
> Hmmm, you are right.
>
>> Perhaps it would be cleaner to add this case to  
>> _pnfs_clear_lseg_from_pages.
>>
>
> I'll look into this, but for now your patch does the correct thing.

I can resend with it moved to _pnfs_clear_lseg_from_pages.

-->Andy

>
> Fred
>
>> -->Andy
>>
>>>
>>> Fred
>>>
>>>>               wdata->pdata.lseg = NULL;
>>>>               put_lseg(lseg);
>>>>       }
>>>> --
>>>> 1.6.6
>>>>
>>>> --
>>>> To unsubscribe from this list: send the line "unsubscribe linux- 
>>>> nfs" in
>>>> the body of a message to majordomo@vger.kernel.org
>>>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>>>>
>>
>>

