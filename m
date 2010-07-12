From: Benny Halevy <bhalevy@panasas.com>
Subject: Re: [PATCH 12/16] SQUASHME pnfs-submit: reference layout across layoutcommit
Date: Mon, 12 Jul 2010 22:54:49 +0300
Message-ID: <4C3B7309.3040305@panasas.com>
References: <1278542063-4009-1-git-send-email-andros@netapp.com>	<1278542063-4009-2-git-send-email-andros@netapp.com>	<1278542063-4009-3-git-send-email-andros@netapp.com>	<1278542063-4009-4-git-send-email-andros@netapp.com>	<1278542063-4009-5-git-send-email-andros@netapp.com>	<1278542063-4009-6-git-send-email-andros@netapp.com>	<1278542063-4009-7-git-send-email-andros@netapp.com>	<1278542063-4009-8-git-send-email-andros@netapp.com>	<1278542063-4009-9-git-send-email-andros@netapp.com>	<1278542063-4009-10-git-send-email-andros@netapp.com>	<1278542063-4009-11-git-send-email-andros@netapp.com>	<1278542063-4009-12-git-send-email-andros@netapp.com>	<1278542063-4009-13-git-send-email-andros@netapp.com>	<4C3B4FFA.2010704@panasas.com>	<AANLkTilWfV86wpO7vFho3FmL9y9Y6Sx9_-knKq7T-snu@mail.gmail.com>	<
 4C3B5E7E.8080108@panasas.com> <AANLkTilrcKirEQLe5mhtYNAnaJBSn6q4edC3TlXJd1rm@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Boaz Harrosh <bharrosh@panasas.com>, linux-nfs@vger.kernel.org
To: "William A. (Andy) Adamson" <androsadamson@gmail.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:64053 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751217Ab0GLTy6 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 12 Jul 2010 15:54:58 -0400
Received: by wyf23 with SMTP id 23so3664622wyf.19
        for <linux-nfs@vger.kernel.org>; Mon, 12 Jul 2010 12:54:56 -0700 (PDT)
In-Reply-To: <AANLkTilrcKirEQLe5mhtYNAnaJBSn6q4edC3TlXJd1rm-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Jul. 12, 2010, 21:28 +0300, "William A. (Andy) Adamson" <androsadamson@gmail.com> wrote:
> On Mon, Jul 12, 2010 at 2:27 PM, Benny Halevy <bhalevy@panasas.com> wrote:
>> On Jul. 12, 2010, 21:09 +0300, "William A. (Andy) Adamson" <androsadamson@gmail.com> wrote:
>>> On Mon, Jul 12, 2010 at 1:25 PM, Boaz Harrosh <bharrosh@panasas.com> wrote:
>>>> On 07/08/2010 01:34 AM, andros@netapp.com wrote:
>>>>> From: Andy Adamson <andros@netapp.com>
>>>>>
>>>>> Signed-off-by: Andy Adamson <andros@netapp.com>
>>>>> ---
>>>>>  fs/nfs/nfs4proc.c |    2 ++
>>>>>  fs/nfs/pnfs.c     |   13 +++++++++++++
>>>>>  fs/nfs/pnfs.h     |    1 +
>>>>>  3 files changed, 16 insertions(+), 0 deletions(-)
>>>>>
>>>>> diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
>>>>> index 6acebc3..f763746 100644
>>>>> --- a/fs/nfs/nfs4proc.c
>>>>> +++ b/fs/nfs/nfs4proc.c
>>>>> @@ -5565,6 +5565,8 @@ static void pnfs_layoutcommit_release(void *lcdata)
>>>>>       struct pnfs_layoutcommit_data *data =
>>>>>               (struct pnfs_layoutcommit_data *)lcdata;
>>>>>
>>>>> +     /* Matched by get_layout in pnfs_layoutcommit_inode */
>>>>> +     put_layout(data->args.inode);
>>>>>       put_rpccred(data->cred);
>>>>>       pnfs_layoutcommit_free(lcdata);
>>>>>  }
>>>>> diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
>>>>> index aa16e5d..d42c5da 100644
>>>>> --- a/fs/nfs/pnfs.c
>>>>> +++ b/fs/nfs/pnfs.c
>>>>> @@ -354,6 +354,15 @@ put_layout_locked(struct pnfs_layout_type *lo)
>>>>>  }
>>>>>
>>>>>  void
>>>>> +put_layout(struct inode *inode)
>>>>> +{
>>>>> +     spin_lock(&inode->i_lock);
>>>>> +     put_layout_locked(NFS_I(inode)->layout);
>>>>> +     spin_unlock(&inode->i_lock);
>>>>> +
>>>>> +}
>>>>> +
>>>>> +void
>>>>>  pnfs_layout_release(struct pnfs_layout_type *lo,
>>>>>                   struct nfs4_pnfs_layout_segment *range)
>>>>>  {
>>>>> @@ -1598,6 +1607,9 @@ pnfs_layoutcommit_inode(struct inode *inode, int sync)
>>>>>       __clear_bit(NFS_INO_LAYOUTCOMMIT, &nfsi->layout->pnfs_layout_state);
>>>>>       pnfs_get_layout_stateid(&data->args.stateid, nfsi->layout);
>>>>>
>>>>> +     /* Reference for layoutcommit matched in pnfs_layoutcommit_release */
>>>>> +     get_layout(NFS_I(inode)->layout);
>>>>> +
>>>>
>>>> Has of your rules this should be now called get_layout_locked
>>>
>>> OK
>>
>> Andy, before you crank another version, I've already merged this patchset
>> with obvious fixes into my tree so it might be better to fix that up.
>>
>> I also fixed a couple other less trivial bugs for which I'm going
>> to send patches soon, and I fixed up the obj and block layout alloc/free
>> methods to agree with the new API.
> 
> OK, Thanks. :)
> 
> I'll grab it and we can move forward together from there.

Super. It's out.
Time for me to call it a day (11 pm here) :-/
Enjoy :)

Benny

> 
> -->Andy
>>
>> Benny
>>
>>>
>>>
>>>>
>>>>>       spin_unlock(&inode->i_lock);
>>>>>
>>>>>       /* Set up layout commit args */
>>>>> @@ -1606,6 +1618,7 @@ pnfs_layoutcommit_inode(struct inode *inode, int sync)
>>>>>       if (status) {
>>>>>               /* The layout driver failed to setup the layoutcommit */
>>>>>               put_rpccred(data->cred);
>>>>> +             put_layout(inode);
>>>>
>>>> And it is really nice that put_layout takes an inode and get_layout takes an
>>>> struct layout_type.
>>>>
>>>>>               goto out_free;
>>>>>       }
>>>>>       status = pnfs4_proc_layoutcommit(data, sync);
>>>>> diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
>>>>> index 9b0fed4..e04b9d4 100644
>>>>> --- a/fs/nfs/pnfs.h
>>>>> +++ b/fs/nfs/pnfs.h
>>>>> @@ -64,6 +64,7 @@ void pnfs_layout_release(struct pnfs_layout_type *, struct nfs4_pnfs_layout_segm
>>>>>  void pnfs_set_layout_stateid(struct pnfs_layout_type *lo,
>>>>>                            const nfs4_stateid *stateid);
>>>>>  void pnfs_destroy_layout(struct nfs_inode *);
>>>>> +void put_layout(struct inode *inode);
>>>>>
>>>>>  #define PNFS_EXISTS_LDIO_OP(srv, opname) ((srv)->pnfs_curr_ld &&     \
>>>>>                                    (srv)->pnfs_curr_ld->ld_io_ops &&  \
>>>>
>>>> I still think they can all go away.
>>>> What is the point of a layout without it's nfsi+inode. And who cares if we free the layout_type structure
>>>> 2 milliseconds before, and in the error case?
>>>>
>>>> Boaz
>>>> --
>>>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>>>> the body of a message to majordomo@vger.kernel.org
>>>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>>>>
>>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

