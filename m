From: "William A. (Andy) Adamson" <androsadamson@gmail.com>
Subject: Re: [PATCH 03/16] SQUASHME pnfs-submit embed pnfs_layout_type
Date: Mon, 12 Jul 2010 14:33:51 -0400
Message-ID: <AANLkTikxD0k3SrPN-JThqX_jaT7uOpQBG96pFTm_88h6@mail.gmail.com>
References: <1278542063-4009-1-git-send-email-andros@netapp.com>
	<1278542063-4009-2-git-send-email-andros@netapp.com>
	<1278542063-4009-3-git-send-email-andros@netapp.com>
	<1278542063-4009-4-git-send-email-andros@netapp.com>
	<4C3B42FD.1070809@panasas.com>
	<AANLkTikTMLQJwj1PeW2Y0dfmRcVFdNr6sasxJtaAiMg4@mail.gmail.com>
	<4C3B5432.8030206@panasas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: bhalevy@panasas.com, linux-nfs@vger.kernel.org
To: Boaz Harrosh <bharrosh@panasas.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-px0-f174.google.com ([209.85.212.174]:41503 "EHLO
	mail-px0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756409Ab0GLSdx (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 12 Jul 2010 14:33:53 -0400
Received: by pxi14 with SMTP id 14so1945903pxi.19
        for <linux-nfs@vger.kernel.org>; Mon, 12 Jul 2010 11:33:53 -0700 (PDT)
In-Reply-To: <4C3B5432.8030206@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Jul 12, 2010 at 1:43 PM, Boaz Harrosh <bharrosh@panasas.com> wrote:
> On 07/12/2010 08:34 PM, William A. (Andy) Adamson wrote:
>> On Mon, Jul 12, 2010 at 12:29 PM, Boaz Harrosh <bharrosh@panasas.com> wrote:
>>>>  static inline bool
>>>>  layoutcommit_needed(struct nfs_inode *nfsi)
>>>>  {
>>>> -     return test_bit(NFS_INO_LAYOUTCOMMIT, &nfsi->layout.pnfs_layout_state);
>>>> +     return has_layout(nfsi) &&
>>>> +            test_bit(NFS_INO_LAYOUTCOMMIT, &nfsi->layout->pnfs_layout_state);
>>>
>>> What is the purpose of patch[1/1] ?
>>
>> To not segfault when the nfs_inode->layout field is NULL.
>>
>
> Yes that is this patch [3/16].
>
> I was asking about [PATCH 01/16] that changed it to a state_bit from lo_cred
> why do we need that one. Now that you proved that has_layout(nfsi) cannot become
> negative on us while asking?

Hmm. Looks like you're right, it's not needed. We do need to document
that the existance of the lo_cred is what signals the need for layout
commit.....

Thanks

-->Andy

>
>>>
>>> you are unlocked and asking about a layout pointer. Which according to you might
>>> go away mid-flight?
>>
>> No, it simply has not been allocated. The pnfs_layout_type reference
>> counting will be done under the inode->i_lock and all in-flight RPC's
>> will hold a reference, so there is no reason to hold a lock to call
>> has_layout().
>>
>
> I agree it is safe.
>
> Boaz
>
>> -->Andy
>>
>
