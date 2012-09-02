Return-Path: linux-nfs-owner@vger.kernel.org
Received: from intranet.asianux.com ([58.214.24.6]:44849 "EHLO
	intranet.asianux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750923Ab2IBFkq (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 2 Sep 2012 01:40:46 -0400
Message-ID: <5042F1A2.6090407@asianux.com>
Date: Sun, 02 Sep 2012 13:41:54 +0800
From: gchen <gang.chen@asianux.com>
MIME-Version: 1.0
To: Jeff Layton <jlayton@redhat.com>
CC: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Subject: Re: [QUESTION] about NFS sub system between Public Kernel and Red
 Hat Kernel.
References: <50404E40.3070702@asianux.com> <20120831070213.6e350dd1@corrin.poochiereds.net>
In-Reply-To: <20120831070213.6e350dd1@corrin.poochiereds.net>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

于 2012年08月31日 22:02, Jeff Layton 写道:
> On Fri, 31 Aug 2012 13:40:16 +0800
> gchen <gang.chen@asianux.com> wrote:
>
>> Hi linux-nfs@vger.kernel.org
>>
>> I have 1 question, and also 2 conclusions which need confirm.
>>
>>
>> 1) Question:
>>
>> Jeff Layton said in Red Hat Bugzilla (bug 848706):
>> "Have configuration where the same host is acting as both NFS client
>> and server. That's a configuration known to cause deadlocks."
>>
>> Does it mean that the public Linux kernel (not Red Hat) also can cause
>> deadlocks if NFS client and server are under the same machine ?
>>
> Yes.

I will communicate with LTP (Linux Test Project) to confirm it, too.

And, it will be better if other members in linux-nfs@vger.kernel.org
also confirm it.

>> 2) Confirm 1: (better by Jeff Layton)
>>
>> For function nfs_commit_set_lock in ./fs/nfs/write.c
>>
>> for latest public kernel version:
>> the parameters of out_of_line_wait_on_bit_lock() are
>> (&nfsi->flags, NFS_INO_COMMIT, nfs_wait_killable, TASK_KILLABLE)
>> for Red Hat kernel version: kernel-2.6.18-308.4.1.el5
>> the parameters of out_of_line_wait_on_bit_lock() are
>> (&nfsi->flags, NFS_INO_COMMIT,
>> nfs_wait_bit_uninterruptible, TASK_UNINTERRUPTIBLE)
>>
>> It means for red hat version:
>> when deadlock occurs, we can not boot machine in normal way
>> (it is true for my test machine, the deadlock task can not be killed)
>> It means for public kernel version:
>> "Assume deadlock occurs", we can still boot machine in normal way,
>> because the task can be killed.
>>
>> Is what I said above correct ?
>>
> Not sure I understand your question. RHEL5 doesn't have support for
> TASK_KILLABLE, and I didn't backport it, hence the difference in that
> function.

I agree with what you said above.

Thanks for your confirmation.

>> 3) Confirm 2:
>>
>> Is LTP (Linux Test Project) still a suitable test tools for public kernel ?
>> (for ltp-full-20100331.gz stress test, it mounts NFS on local machine,
>> and the latest LTP ltp-full-20120401.bz2 also seems the same).
>>
> That I'm not sure of. All I can tell you is that mounts over loopback
> (or similar configurations) are easily deadlockable under load.
>

I will communicate with LTP (Linux Test Project) about these informations.


Thanks.

gchen.

Asianux Corporation.

