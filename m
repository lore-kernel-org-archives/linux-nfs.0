From: Boaz Harrosh <bharrosh@panasas.com>
Subject: Re: [PATCH 03/16] SQUASHME pnfs-submit embed pnfs_layout_type
Date: Mon, 12 Jul 2010 20:43:14 +0300
Message-ID: <4C3B5432.8030206@panasas.com>
References: <1278542063-4009-1-git-send-email-andros@netapp.com>	<1278542063-4009-2-git-send-email-andros@netapp.com>	<1278542063-4009-3-git-send-email-andros@netapp.com>	<1278542063-4009-4-git-send-email-andros@netapp.com>	<4C3B42FD.1070809@panasas.com> <AANLkTikTMLQJwj1PeW2Y0dfmRcVFdNr6sasxJtaAiMg4@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: bhalevy@panasas.com, linux-nfs@vger.kernel.org
To: "William A. (Andy) Adamson" <androsadamson@gmail.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:15355 "EHLO
	daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1756402Ab0GLRnV (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 12 Jul 2010 13:43:21 -0400
In-Reply-To: <AANLkTikTMLQJwj1PeW2Y0dfmRcVFdNr6sasxJtaAiMg4-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 07/12/2010 08:34 PM, William A. (Andy) Adamson wrote:
> On Mon, Jul 12, 2010 at 12:29 PM, Boaz Harrosh <bharrosh@panasas.com> wrote:
>>>  static inline bool
>>>  layoutcommit_needed(struct nfs_inode *nfsi)
>>>  {
>>> -     return test_bit(NFS_INO_LAYOUTCOMMIT, &nfsi->layout.pnfs_layout_state);
>>> +     return has_layout(nfsi) &&
>>> +            test_bit(NFS_INO_LAYOUTCOMMIT, &nfsi->layout->pnfs_layout_state);
>>
>> What is the purpose of patch[1/1] ?
> 
> To not segfault when the nfs_inode->layout field is NULL.
> 

Yes that is this patch [3/16]. 

I was asking about [PATCH 01/16] that changed it to a state_bit from lo_cred
why do we need that one. Now that you proved that has_layout(nfsi) cannot become
negative on us while asking?

>>
>> you are unlocked and asking about a layout pointer. Which according to you might
>> go away mid-flight?
> 
> No, it simply has not been allocated. The pnfs_layout_type reference
> counting will be done under the inode->i_lock and all in-flight RPC's
> will hold a reference, so there is no reason to hold a lock to call
> has_layout().
> 

I agree it is safe.

Boaz

> -->Andy
> 
