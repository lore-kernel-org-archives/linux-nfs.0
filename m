From: Benny Halevy <bhalevy@panasas.com>
Subject: Re: [PATCH 14/24] pnfs_submit: use fsdata to pass lseg
Date: Thu, 10 Jun 2010 15:48:30 +0300
Message-ID: <4C10DF1E.6060608@panasas.com>
References: <1275970761-31806-1-git-send-email-iisaman@netapp.com> <1275970761-31806-3-git-send-email-iisaman@netapp.com> <1275970761-31806-4-git-send-email-iisaman@netapp.com> <1275970761-31806-5-git-send-email-iisaman@netapp.com> <1275970761-31806-6-git-send-email-iisaman@netapp.com> <1275970761-31806-7-git-send-email-iisaman@netapp.com> <1275970761-31806-8-git-send-email-iisaman@netapp.com> <1275970761-31806-9-git-send-email-iisaman@netapp.com> <1275970761-31806-10-git-send-email-iisaman@netapp.com> <1275970761-31806-11-git-send-email-iisaman@netapp.com> <1275970761-31806-12-git-send-email-iisaman@netapp.com> <1275970761-31806-13-git-send-email-iisaman@netapp.com> <1275970761-31806-14-git-send-email-iisaman@netapp.com> <1275970761-31806-15-git-send-email-iisaman@netapp.com> <4C0F6F11.70
 50602@panasas.com> <AANLkTillGAndgQoohtCV36csBH6CzxkZ3792H16nRV-S@mail.gmail.com> <D0754698-130E-40CA-B28A-3A6926E7D25C@netapp.com> <4C10DE61.7010706@panasas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: linux-nfs@vger.kernel.org
To: Fred Isaman <iisaman@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:46949 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753751Ab0FJMsj (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 10 Jun 2010 08:48:39 -0400
Received: by wyb40 with SMTP id 40so939959wyb.19
        for <linux-nfs@vger.kernel.org>; Thu, 10 Jun 2010 05:48:37 -0700 (PDT)
In-Reply-To: <4C10DE61.7010706@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Jun. 10, 2010, 15:45 +0300, Benny Halevy <bhalevy@panasas.com> wrote:
> On 06/10/2010 01:33 PM, Fred Isaman wrote:
>>
>> On Jun 9, 2010, at 8:08 AM, Fred Isaman wrote:
>>
>>> On Wed, Jun 9, 2010 at 6:38 AM, Benny Halevy <bhalevy@panasas.com> wrote:
>>>> Fred, how does that patch interact with
>>>> 285052f pnfs_post_submit: Restore "pnfs: pnfs_do_flush"
>>>> and the latter patches that depend on it?
>>>>
>>>> Benny
>>>>
>>>
>>> They will have to be modified.  I'll look at that today.
>>>
>>> Fred
>>
>> OK, this is a general git question.  How in the world do I send in these modifications?
>>
>> Basically, because of the way we have pnfs-submit in the middle of our tree, I have a branch that looks like:
>>
>> A->B->C->D
>>
>> I've inserted my new patch F between And B, which requires a rebase of the subsequent patches:
>>
>> A->F->B'->C'->D'
>>
>> But that rebase is non-trivial, in particular for patch C (a block-layout patch), and I want to communicate the modifications I made.
>>
>> The best I have been able to come up with is to do the minimal obvious rebase, just sufficient to remove all the conflict markers,
>> then add a following modification patch, so I would have something like:
>>
>> A->F->B'->C'->C''->D'
>>
>> and I could send in C''.  But this seems less than ideal, especially when you consider I have ~10 patches which would require this handling.
>>
> 
> You can either send your a patchset based on C and I can
> rebase parts of it onto A and B or just send the clean rebased
> patches from B and C and we can review the diff (B vs. B' and
> C vs. C')

Oh and I apologize for having set a moving target for you.
I'm about to release a tree with merged patches from Alexandros,
Andy, and Boaz (merge conflicts should be minimal though)

> 
> Benny
> 
>> Fred
>>
>>
>>>
>>>> On Jun. 08, 2010, 7:19 +0300, Fred Isaman <iisaman@netapp.com> wrote:
>>>>> Preparing for LAYUTGET invocation in nfs_write_begin to be the
>>>>> only invocation in the write path.
>>>>>
>>>>> It isn't used at all yet, but it should be properly referenced/dereferenced
>>>>>
>>>>> Signed-off-by: Fred Isaman <iisaman@netapp.com>
>>>>> ---
>>>>>  fs/nfs/file.c |   16 +++++++++++++---
>>>>>  1 files changed, 13 insertions(+), 3 deletions(-)
>>>>>
>>>>> diff --git a/fs/nfs/file.c b/fs/nfs/file.c
>>>>> index 03601d2..fde6cb5 100644
>>>>> --- a/fs/nfs/file.c
>>>>> +++ b/fs/nfs/file.c
>>>>> @@ -420,6 +420,8 @@ static int nfs_write_begin(struct file *file, struct address_space *mapping,
>>>>>               file->f_path.dentry->d_name.name,
>>>>>               mapping->host->i_ino, len, (long long) pos);
>>>>>
>>>>> +     pnfs_update_layout(mapping->host, NULL, NFS4_MAX_UINT64, 0, IOMODE_RW,
>>>>> +                        (struct pnfs_layout_segment **) fsdata);
>>>>>  start:
>>>>>       /*
>>>>>        * Prevent starvation issues if someone is doing a consistency
>>>>> @@ -428,11 +430,13 @@ start:
>>>>>       ret = wait_on_bit(&NFS_I(mapping->host)->flags, NFS_INO_FLUSHING,
>>>>>                       nfs_wait_bit_killable, TASK_KILLABLE);
>>>>>       if (ret)
>>>>> -             return ret;
>>>>> +             goto out;
>>>>>
>>>>>       page = grab_cache_page_write_begin(mapping, index, flags);
>>>>> -     if (!page)
>>>>> -             return -ENOMEM;
>>>>> +     if (!page) {
>>>>> +             ret = -ENOMEM;
>>>>> +             goto out;
>>>>> +     }
>>>>>       *pagep = page;
>>>>>
>>>>>       ret = nfs_flush_incompatible(file, page);
>>>>> @@ -447,6 +451,11 @@ start:
>>>>>               if (!ret)
>>>>>                       goto start;
>>>>>       }
>>>>> + out:
>>>>> +     if (ret) {
>>>>> +             put_lseg(*fsdata);
>>>>> +             *fsdata = NULL;
>>>>> +     }
>>>>>       return ret;
>>>>>  }
>>>>>
>>>>> @@ -486,6 +495,7 @@ static int nfs_write_end(struct file *file, struct address_space *mapping,
>>>>>
>>>>>       unlock_page(page);
>>>>>       page_cache_release(page);
>>>>> +     put_lseg(fsdata);
>>>>>
>>>>>       if (status < 0)
>>>>>               return status;
>>>>
>>>> --
>>>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>>>> the body of a message to majordomo@vger.kernel.org
>>>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>>>>
>>
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

