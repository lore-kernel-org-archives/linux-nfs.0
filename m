Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-vc0-f171.google.com ([209.85.220.171]:36699 "EHLO
	mail-vc0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753305AbaH2TCT (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 29 Aug 2014 15:02:19 -0400
Received: by mail-vc0-f171.google.com with SMTP id id10so2961721vcb.16
        for <linux-nfs@vger.kernel.org>; Fri, 29 Aug 2014 12:02:18 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <alpine.LRH.2.11.1408291213280.26449@bcodding-csb.redhat.com>
References: <1438879608.14503585.1407251825405.JavaMail.zimbra@redhat.com>
	<1408580933.4029.2.camel@leira.trondhjem.org>
	<53F612DC.60006@redhat.com>
	<CAHQdGtRw0V=mAuXs=UL7aJxxvKo26xqVoyOwR7r+9PrGPNmn_g@mail.gmail.com>
	<53F63758.70306@redhat.com>
	<CAHQdGtQT9-YJ=L1jLKc53e7nzdNU0GaUie0RwEdF3EpsJEvPsg@mail.gmail.com>
	<alpine.LRH.2.11.1408291128050.26449@bcodding-csb.redhat.com>
	<CAHQdGtTYzn2LoE+pSEDEk2pRUgn8=KSUDW0T-OdJVg4+QUfnhA@mail.gmail.com>
	<alpine.LRH.2.11.1408291213280.26449@bcodding-csb.redhat.com>
Date: Fri, 29 Aug 2014 15:02:17 -0400
Message-ID: <CAHQdGtTrHX-AHSpoHQC5Xv2kEyJP8ULUOwqhtHt0kYqpNQMzXg@mail.gmail.com>
Subject: Re: [PATCH] nfs: Always try and release an NFS file lock, even after
 receiving a SIGKILL
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Benjamin Coddington <bcodding@redhat.com>
Cc: David Jeffery <djeffery@redhat.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Aug 29, 2014 at 12:31 PM, Benjamin Coddington
<bcodding@redhat.com> wrote:
> On Fri, 29 Aug 2014, Trond Myklebust wrote:
>
>> On Fri, Aug 29, 2014 at 11:34 AM, Benjamin Coddington
>> <bcodding@redhat.com> wrote:
>>>
>>>
>>> On Thu, 21 Aug 2014, Trond Myklebust wrote:
>>>>
>>>>
>>>> On Thu, Aug 21, 2014 at 2:15 PM, David Jeffery <djeffery@redhat.com>
>>>> wrote:
>>>>>
>>>>>
>>>>> On 08/21/2014 11:50 AM, Trond Myklebust wrote:
>>>>>>
>>>>>>
>>>>>> On Thu, Aug 21, 2014 at 11:40 AM, David Jeffery <djeffery@redhat.com>
>>>>>> wrote:
>>>>>>>
>>>>>>>
>>>>>>> On 08/20/2014 08:28 PM, Trond Myklebust wrote:
>>>>>>>>
>>>>>>>>
>>>>>>>>
>>>>>>>> What guarantees that this does not lead to silent corruption of the
>>>>>>>> file
>>>>>>>> if there are outstanding write requests?
>>>>>>>>
>>>>>>>
>>>>>>> Do you have a particular scenario in mind you are concerned about?
>>>>>>>
>>>>>>> Right before the code the patch modifies, nfs_sync_mapping() is
>>>>>>> called.
>>>>>>>  Any writes started before the unlock operation began have already
>>>>>>> been
>>>>>>> flushed, so we shouldn't have a corruption case of writes from before
>>>>>>> the unlock began being sent after the unlock is complete.
>>>>>>>
>>>>>>> Are you concerned about some other nfs4 writes being started while we
>>>>>>> initially waited on the counter?  Such a write racing with the unlock
>>>>>>
>>>>>>
>>>>>>
>>>>>> No. I'm worried about the writes that have been started, but which are
>>>>>> now completing in the background while the lock is being freed.
>>>>>>
>>>>>>> going ahead instead of erroring out could initially fail from a wrong
>>>>>>> state ID, but should retry with the new state.  Is there something
>>>>>>> I've
>>>>>>> overlooked?
>>>>>>
>>>>>>
>>>>>>
>>>>>> Loss of lock atomicity due to the fact that the writes are completing
>>>>>> after the lock was released.
>>>>>>
>>>>>
>>>>> I don't think my patches break lock atomicity, unless I've completely
>>>>> misunderstood nfs_sync_mapping()'s behavior.
>>>>>
>>>>> The background writes should have already been waited for by
>>>>> nfs_sync_mapping() at the beginning of do_unlk().  nfs_sync_mapping()
>>>>> would call nfs_wb_all() which calls sync_inode() with WB_SYNC_ALL, so
>>>>> it's going to push out any dirty data and wait for any writes to
>>>>> complete.  Only after the writes are complete do we go on to call
>>>>> nfs_iocounter_wait().
>>>>
>>>>
>>>>
>>>> What if nfs_wb_all() is interrupted? Currently, that doesn't matter
>>>> precisely because of the call to nfs_iocounter_wait.
>>>
>>>
>>>
>>> Hi Trond, it looks like the intent of:
>>>
>>> 577b423 NFS: Add functionality to allow waiting on all outstanding
>>> reads..
>>> 7a8203d NFS: Ensure that NFS file unlock waits for readahead to
>>> complete..
>>>
>>> was to wait for readahead, not to avoid releasing the lock if
>>> nfs_wb_all()
>>> is interrupted.  What was the underlying reason for waiting for readahead
>>> to
>>> complete?  I know there was one issue where the NFS server would release
>>> the
>>> lockowner before processing the reads - was that what these were trying
>>> to
>>> avoid?  I ask because if we're only worried about outstanding writes we
>>> could just wait on the writes, not the reads.
>>>
>>> Would it be better to use TASK_UNINTERRUPTIBLE instead of TASK_KILLABLE
>>> in
>>> __nfs_iocounter_wait?
>>>
>>> Ben
>>
>>
>> Hi Ben,
>>
>> The main intent of the two patches was to ensure that all I/O that
>> uses the lock stateid should have completed before we attempt to
>> release the lock. The main reason is to avoid an unnecessary
>> "recovery" situation where the server asks us to resend the I/O
>> because the lock stateid is no longer valid.
>>
>> Concerning writes; if there are any outstanding then we must ensure
>> those complete before we unlock the file. This rule should be
>> unaffected by the above 2 patches (although it is just a bonus if they
>> help to enforce it).
>
>
> If so, then David's patch shouldn't risk corruption any more than before
> 577b423 and 7a8203d were applied.
>
> He's trying to avoid the problem (I think) where very aggressive readahead
> behavior blocks the unlocking thread and a sysadmin decides to kill the
> process, which results in the abandoned lock.  That can make a big mess.
> Instead, his change would result in the "recovery" scenario at worst when
> the impatient sysadmin goes on a rampage.
>

The patch is trying to force the lock to be cleared before the I/O is
done. That's wrong, whether or not the code was broken before. I'm not
applying.

Cheers
  Trond
-- 
Trond Myklebust

Linux NFS client maintainer, PrimaryData

trond.myklebust@primarydata.com
