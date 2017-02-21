Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:15844 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752621AbdBUN4a (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 21 Feb 2017 08:56:30 -0500
From: "Benjamin Coddington" <bcodding@redhat.com>
To: "Trond Myklebust" <trondmy@primarydata.com>
Cc: "anna.schumaker@netapp.com" <anna.schumaker@netapp.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 4/4] NFS: Always wait for I/O completion before unlock
Date: Tue, 21 Feb 2017 08:56:27 -0500
Message-ID: <75865610-7BBA-46BA-832D-084E039EF0C8@redhat.com>
In-Reply-To: <1487359849.23558.1.camel@primarydata.com>
References: <cover.1487356965.git.bcodding@redhat.com>
 <d81a853ea1ee4ba1294c85bbed7aa7298852b180.1487356965.git.bcodding@redhat.com>
 <1487358041.11929.7.camel@primarydata.com>
 <46DADA84-BE1F-43A6-8196-2A097435829A@redhat.com>
 <1487359849.23558.1.camel@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 17 Feb 2017, at 14:30, Trond Myklebust wrote:

> On Fri, 2017-02-17 at 14:15 -0500, Benjamin Coddington wrote:
>> On 17 Feb 2017, at 14:00, Trond Myklebust wrote:
>>
>>> On Fri, 2017-02-17 at 13:46 -0500, Benjamin Coddington wrote:
>>>> NFS attempts to wait for read and write completion before
>>>> unlocking
>>>> in
>>>> order to ensure that the data returned was protected by the
>>>> lock.  When
>>>> this waiting is interrupted by a signal, the unlock may never be
>>>> sent, and
>>>> messages similar to the following are seen in the kernel ring
>>>> buffer:
>>>>
>>>> [20.167876] Leaked locks on dev=0x0:0x2b ino=0x8dd4c3:
>>>> [20.168286] POSIX: fl_owner=ffff880078b06940 fl_flags=0x1
>>>> fl_type=0x0
>>>> fl_pid=20183
>>>> [20.168727] POSIX: fl_owner=ffff880078b06680 fl_flags=0x1
>>>> fl_type=0x0
>>>> fl_pid=20185
>>>>
>>>> For NFSv3, the missing unlock will cause the server to refuse
>>>> conflicting
>>>> locks indefinitely.  For NFSv4, the leftover lock will be removed
>>>> by
>>>> the
>>>> server after the lease timeout.
>>>>
>>>> This patch fixes this for NFSv3 by skipping the wait in order to
>>>> immediately send the unlock if the FL_CLOSE flag is set when
>>>> signaled.  For
>>>> NFSv4, this approach may cause the server to see the I/O as
>>>> arriving
>>>> with
>>>> an old stateid, so, for the v4 case the fix is different: the
>>>> wait on
>>>> I/O
>>>> completion is moved into nfs4_locku_ops'
>>>> rpc_call_prepare().  This
>>>> will
>>>> cause the sleep to happen in rpciod context, and a signal to the
>>>> originally
>>>> waiting process will not cause the unlock to be skipped.
>>>
>>> NACK. I/O waits in rpciod contexts are NOT acceptable. rpciod is
>>> part
>>> of the memory reclaim chain, so having it sleep on I/O is deadlock
>>> prone.
>>>
>>> Why is there a need to wait for I/O completion in the first place
>>> if
>>> the user has killed the task that held the lock? 'kill -9' will
>>> cause
>>> corruption; that's a fact that no amount of paper will cover over.
>>
>> To avoid an unnecessary recovery situation where the server asks us
>> to resend
>> I/O due to an invalid stateid.
>>
>
> I agree we shouldn't recover in this situation. It would be better to
> jettison the failed write, and invalidate the page. Can we make use of
> nfs_wb_page_cancel() together with generic_error_remove_page()?

Probably we can piggy-back on NFS_LOCK_LOST, then -EIO would get passed up
and the page would make it into generic_error_remove_page().  Any
outstanding writes are likely already transmitted or scheduled to be
tranmitted by now, and the error recovery path for incorrect stateids
doesn't intersect with nfs_wb_page_cancel(), rather it re-schedules the RPC.

But, after looking at this further, I'm not sure how much work should be
done here.  It's a fairly unlikely situation already, and if we assert that
a fatal signal means writes don't have to complete at all, I don't see the
harm in having them complete outside the lock.  Adding extra complexity to
bypass recovery for this specific situation would be optimal, but
unnecessary.

Ben
