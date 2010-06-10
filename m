Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:59065 "EHLO
	daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753051Ab0FJNJP (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 10 Jun 2010 09:09:15 -0400
Message-ID: <4C10E3F8.2040603@panasas.com>
Date: Thu, 10 Jun 2010 16:09:12 +0300
From: Boaz Harrosh <bharrosh@panasas.com>
To: Benny Halevy <bhalevy@panasas.com>
CC: Fred Isaman <iisaman@netapp.com>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH 14/24] pnfs_submit: use fsdata to pass lseg
References: <1275970761-31806-1-git-send-email-iisaman@netapp.com> <1275970761-31806-3-git-send-email-iisaman@netapp.com> <1275970761-31806-4-git-send-email-iisaman@netapp.com> <1275970761-31806-5-git-send-email-iisaman@netapp.com> <1275970761-31806-6-git-send-email-iisaman@netapp.com> <1275970761-31806-7-git-send-email-iisaman@netapp.com> <1275970761-31806-8-git-send-email-iisaman@netapp.com> <1275970761-31806-9-git-send-email-iisaman@netapp.com> <1275970761-31806-10-git-send-email-iisaman@netapp.com> <1275970761-31806-11-git-send-email-iisaman@netapp.com> <1275970761-31806-12-git-send-email-iisaman@netapp.com> <1275970761-31806-13-git-send-email-iisaman@netapp.com> <1275970761-31806-14-git-send-email-iisaman@netapp.com> <1275970761-31806-15-git-send-email-iisaman@netapp.com> <4C0F6F11.7050602@panasas.com> <AANLkTillGAndgQoohtCV36csBH6CzxkZ3792H16nRV-S@mail.gmail.com> <D0754698-130E-40CA-B28A-3A6926E7D25C@netapp.com> <4C10DE61.7010706@panasas.com> <4C10DF1E.6060608@panasas.!
 com>
In-Reply-To: <4C10DF1E.6060608@panasas.com>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 06/10/2010 03:48 PM, Benny Halevy wrote:
> On Jun. 10, 2010, 15:45 +0300, Benny Halevy <bhalevy@panasas.com> wrote:
>> On 06/10/2010 01:33 PM, Fred Isaman wrote:
>>>
>>> On Jun 9, 2010, at 8:08 AM, Fred Isaman wrote:
>>>
>>>> On Wed, Jun 9, 2010 at 6:38 AM, Benny Halevy <bhalevy@panasas.com> wrote:
>>>>> Fred, how does that patch interact with
>>>>> 285052f pnfs_post_submit: Restore "pnfs: pnfs_do_flush"
>>>>> and the latter patches that depend on it?
>>>>>
>>>>> Benny
>>>>>
>>>>
>>>> They will have to be modified.  I'll look at that today.
>>>>
>>>> Fred
>>>
>>> OK, this is a general git question.  How in the world do I send in these modifications?
>>>
>>> Basically, because of the way we have pnfs-submit in the middle of our tree, I have a branch that looks like:
>>>
>>> A->B->C->D
>>>
>>> I've inserted my new patch F between And B, which requires a rebase of the subsequent patches:
>>>
>>> A->F->B'->C'->D'
>>>
>>> But that rebase is non-trivial, in particular for patch C (a block-layout patch), and I want to communicate the modifications I made.
>>>
>>> The best I have been able to come up with is to do the minimal obvious rebase, just sufficient to remove all the conflict markers,
>>> then add a following modification patch, so I would have something like:
>>>
>>> A->F->B'->C'->C''->D'
>>>
>>> and I could send in C''.  But this seems less than ideal, especially when you consider I have ~10 patches which would require this handling.
>>>
>>
>> You can either send your a patchset based on C and I can
>> rebase parts of it onto A and B or just send the clean rebased
>> patches from B and C and we can review the diff (B vs. B' and
>> C vs. C')
> 
> Oh and I apologize for having set a moving target for you.
> I'm about to release a tree with merged patches from Alexandros,
> Andy, and Boaz (merge conflicts should be minimal though)
> 
>>
>> Benny
>>

Fred do you have a git tree on the linux-nfs.org/ or at Netapp that's open on the net?
If so you could just publish your cleanup tree, Benny will "git remote add" your branch
and can then cherry-pick / rebase very easily. It's how we did it a few times.
(We still need patches for review though)

Boaz
