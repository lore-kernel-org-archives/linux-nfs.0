Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-vc0-f182.google.com ([209.85.220.182]:55175 "EHLO
	mail-vc0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753784AbaHUSlE (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 21 Aug 2014 14:41:04 -0400
Received: by mail-vc0-f182.google.com with SMTP id hy4so11299848vcb.13
        for <linux-nfs@vger.kernel.org>; Thu, 21 Aug 2014 11:41:02 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <53F63758.70306@redhat.com>
References: <1438879608.14503585.1407251825405.JavaMail.zimbra@redhat.com>
	<1408580933.4029.2.camel@leira.trondhjem.org>
	<53F612DC.60006@redhat.com>
	<CAHQdGtRw0V=mAuXs=UL7aJxxvKo26xqVoyOwR7r+9PrGPNmn_g@mail.gmail.com>
	<53F63758.70306@redhat.com>
Date: Thu, 21 Aug 2014 14:41:02 -0400
Message-ID: <CAHQdGtQT9-YJ=L1jLKc53e7nzdNU0GaUie0RwEdF3EpsJEvPsg@mail.gmail.com>
Subject: Re: [PATCH] nfs: Always try and release an NFS file lock, even after
 receiving a SIGKILL
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: David Jeffery <djeffery@redhat.com>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Aug 21, 2014 at 2:15 PM, David Jeffery <djeffery@redhat.com> wrote:
> On 08/21/2014 11:50 AM, Trond Myklebust wrote:
>> On Thu, Aug 21, 2014 at 11:40 AM, David Jeffery <djeffery@redhat.com> wrote:
>>> On 08/20/2014 08:28 PM, Trond Myklebust wrote:
>>>>
>>>> What guarantees that this does not lead to silent corruption of the file
>>>> if there are outstanding write requests?
>>>>
>>>
>>> Do you have a particular scenario in mind you are concerned about?
>>>
>>> Right before the code the patch modifies, nfs_sync_mapping() is called.
>>>  Any writes started before the unlock operation began have already been
>>> flushed, so we shouldn't have a corruption case of writes from before
>>> the unlock began being sent after the unlock is complete.
>>>
>>> Are you concerned about some other nfs4 writes being started while we
>>> initially waited on the counter?  Such a write racing with the unlock
>>
>> No. I'm worried about the writes that have been started, but which are
>> now completing in the background while the lock is being freed.
>>
>>> going ahead instead of erroring out could initially fail from a wrong
>>> state ID, but should retry with the new state.  Is there something I've
>>> overlooked?
>>
>> Loss of lock atomicity due to the fact that the writes are completing
>> after the lock was released.
>>
>
> I don't think my patches break lock atomicity, unless I've completely
> misunderstood nfs_sync_mapping()'s behavior.
>
> The background writes should have already been waited for by
> nfs_sync_mapping() at the beginning of do_unlk().  nfs_sync_mapping()
> would call nfs_wb_all() which calls sync_inode() with WB_SYNC_ALL, so
> it's going to push out any dirty data and wait for any writes to
> complete.  Only after the writes are complete do we go on to call
> nfs_iocounter_wait().

What if nfs_wb_all() is interrupted? Currently, that doesn't matter
precisely because of the call to nfs_iocounter_wait.

> If there is a write causing us to want to wait in nfs_iocounter_wait()
> and which my patches no longer wait for, the write was done after
> nfs_sync_mapping() started, which means the write occurred after the
> unlock-initiating call began.  Such a write should have no atomicity
> guarantee with holding the lock, and may complete before or after the
> lock is released.  The writes which require atomicity are already
> completed before getting to the call of nfs_iocounter_wait() and the
> code my patch changes.

See above.

-- 
Trond Myklebust

Linux NFS client maintainer, PrimaryData

trond.myklebust@primarydata.com
