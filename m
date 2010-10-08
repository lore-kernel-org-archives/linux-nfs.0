Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:55350 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752417Ab0JHON4 convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 8 Oct 2010 10:13:56 -0400
Received: by bwz15 with SMTP id 15so267139bwz.19
        for <linux-nfs@vger.kernel.org>; Fri, 08 Oct 2010 07:13:55 -0700 (PDT)
In-Reply-To: <4CADD3E9.7040307@panasas.com>
References: <1286397317-17881-1-git-send-email-iisaman@netapp.com>
 <1286397317-17881-3-git-send-email-iisaman@netapp.com> <4CADCC48.4030908@panasas.com>
 <AANLkTimnVJYW-ndu_rhk71JXkh3zW-0hLfMTYkRc8VpK@mail.gmail.com> <4CADD3E9.7040307@panasas.com>
From: "P.B.Shelley" <shelleypt@gmail.com>
Date: Fri, 8 Oct 2010 22:13:33 +0800
Message-ID: <AANLkTimUeQGrFXzZfgkkiE834MvMYz3uxobHHAdzE79p@mail.gmail.com>
Subject: Re: [PATCH 2/4] pnfs_submit: Only update stateid if it is more recent
 than current
To: Benny Halevy <bhalevy@panasas.com>
Cc: Fred Isaman <iisaman@netapp.com>, linux-nfs@vger.kernel.org
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Thu, Oct 7, 2010 at 10:06 PM, Benny Halevy <bhalevy@panasas.com> wrote:
> On 2010-10-07 10:01, Fred Isaman wrote:
>> On Thu, Oct 7, 2010 at 9:34 AM, Benny Halevy <bhalevy@panasas.com> wrote:
>>> On 2010-10-06 16:35, Fred Isaman wrote:
>>>> Right now, when we set the stateid, we blindly overwrite the current
>>>> one, allowing the seqid to incorrectly roll backward.
>>>>
>>>> Signed-off-by: Fred Isaman <iisaman@netapp.com>
>>>> ---
>>>>  fs/nfs/pnfs.c |   38 ++++++++++++++++++++++++++++++++------
>>>>  1 files changed, 32 insertions(+), 6 deletions(-)
>>>>
>>>> diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
>>>> index 39bce9b..555955b 100644
>>>> --- a/fs/nfs/pnfs.c
>>>> +++ b/fs/nfs/pnfs.c
>>>> @@ -459,16 +459,42 @@ pnfs_destroy_all_layouts(struct nfs_client *clp)
>>>>       }
>>>>  }
>>>>
>>>> +/* update lo->stateid with new if is more recent
>>>> + *
>>>> + * lo->stateid could be the open stateid, in which case we just use what given.
>>>> + */
>>>>  static void
>>>>  pnfs_set_layout_stateid(struct pnfs_layout_hdr *lo,
>>>> -                     const nfs4_stateid *stateid)
>>>> +                     const nfs4_stateid *new)
>>>>  {
>>>> -     /* TODO - should enforce that embedded seqid, in the case
>>>> -      * that the two stateid.others are equal,  only increases.
>>>> -      * Complicated by wrap-around.
>>>> -      */
>>>> +     nfs4_stateid *old = &lo->stateid;
>>>> +     bool overwrite = false;
>>>> +
>>>>       write_seqlock(&lo->seqlock);
>>>> -     memcpy(lo->stateid.data, stateid->data, sizeof(lo->stateid.data));
>>>> +     if (!test_bit(NFS_LAYOUT_STATEID_SET, &lo->state) ||
>>>> +         memcmp(old->stateid.other, new->stateid.other, sizeof(new->stateid.other)))
>>>> +             overwrite = true;
>>>> +     else {
>>>> +             u32 oldseq, newseq, limit;
>>>> +
>>>> +             oldseq = be32_to_cpu(old->stateid.seqid);
>>>> +             newseq = be32_to_cpu(new->stateid.seqid);
>>>> +             /* There are no good bounds on window size, so just
>>>> +              * use a ridiculously large window of 2^31.
>>>> +              */
>>>> +             limit = oldseq + (1 << 31);
>>>> +             if (oldseq < limit) {
>>>> +                     /* The easy, non-wraparound case */
>>>> +                     if (oldseq < newseq && newseq < limit)
>>>> +                             overwrite = true;
>>>> +             } else {
>>>> +                     /* Near wraparound edge */
>>>> +                     if (oldseq < newseq || newseq < limit)
>>>> +                             overwrite = true;
>>>> +             }
>>>
>>> Wouldn't it be simpler to just look at (int32_t)(newseq - oldseq)?
>>>
>>
>> Why yes it would.  I'll send a new version of this patch shortly.
>>
>
> No need :)
> I'll just change this as follows:
>
> +       else {
> +               u32 oldseq, newseq, limit;
> +
> +               oldseq = be32_to_cpu(old->stateid.seqid);
> +               newseq = be32_to_cpu(new->stateid.seqid);
> +               if ((int)(newseq - oldseq) > 0)
> +                       overwrite = true;
Do we also need to verify the other field of the stateid? Will there
be situations that server change the other field and reset the seqid?

Thanks,
Shelley
