Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:24295 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755834AbbHFQ4m convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 6 Aug 2015 12:56:42 -0400
Content-Type: text/plain; charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 7.3 \(1878.6\))
Subject: Re: [PATCH] NFS: Add OTW write barrier before may-open test
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <CAHQdGtTB3uxbGsN1WXVJh3vdLabW5pOr5wuyS59a-WK2dM-yPw@mail.gmail.com>
Date: Thu, 6 Aug 2015 12:56:33 -0400
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <913A1219-4719-4E0E-ACF5-A6F7C79215C8@oracle.com>
References: <20150805182305.11796.75476.stgit@manet.1015granger.net> <359CCE70-6056-418F-B627-688BE27C7EA8@oracle.com> <CAHQdGtQz1EqZLt-i=uAhFONpnyfUBSFyWHnjWdjgU8kOmnrR6Q@mail.gmail.com> <8F6C1893-11A1-485C-A9EA-0ABBCC4D4286@oracle.com> <CAHQdGtTB3uxbGsN1WXVJh3vdLabW5pOr5wuyS59a-WK2dM-yPw@mail.gmail.com>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Aug 5, 2015, at 10:50 PM, Trond Myklebust <trond.myklebust@primarydata.com> wrote:

> On Wed, Aug 5, 2015 at 8:15 PM, Chuck Lever <chuck.lever@oracle.com> wrote:
>> 
>> On Aug 5, 2015, at 6:27 PM, Trond Myklebust <trond.myklebust@primarydata.com> wrote:
>> 
>>> On Wed, Aug 5, 2015 at 2:44 PM, Chuck Lever <chuck.lever@oracle.com> wrote:
>>>> 
>>>> On Aug 5, 2015, at 2:34 PM, Chuck Lever <chuck.lever@oracle.com> wrote:
>>>> 
>>>>> Commit 14546c337588 ("NFS: Don't do a full flush to disk on close()
>>>>> if we hold a delegation") added an optimization. When an NFSv4 write
>>>>> delegation is present, close(2) does not wait while a file's dirty
>>>>> data is flushed to the NFS server.
>>>>> 
>>>>> However, if the application workload immediately re-opens that file,
>>>>> nfs_may_open() can perform an ACCESS and GETATTR which runs
>>>>> concurrently with the flushing WRITE. If the flushing WRITE and
>>>>> GETATTR complete out of order on the server, the file size cached on
>>>>> the client will go backwards, possibly resulting in new writes going
>>>>> to the wrong file offset.
>>>>> 
>>>>> Add a write barrier before the access check to ensure the server's
>>>>> idea of the file's size is properly up to date.
>>>>> 
>>>>> The downside of this approach is that each fresh open(2) of a dirty
>>>>> file results in an extra flush. It seems to me that _any_ open(2)
>>>>> done while there is dirty data waiting on the client could result in
>>>>> a file size roll back. However, I see bad behavior only when the
>>>>> client holds a write delegation.
>>>>> 
>>>>> Fixes: 14546c337588 ("NFS: Don't do a full flush to disk on . . .")
>>>>> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
>>>>> ---
>>>>> fs/nfs/dir.c |    9 +++++++++
>>>>> 1 file changed, 9 insertions(+)
>>>>> 
>>>>> I'm not certain this is a good long term fix. Some other possible
>>>>> solutions include:
>>>>> 
>>>>> - Not performing the access check if the client holds a delegation
>>>>> - Not performing a GETATTR as part of the ACCESS check
>>>>> - Simply marking the file attributes stale instead of using the
>>>>> returned file size
>>>>> - Reverting commit 14546c337588
>>>> 
>>>> OK. If the client holds a write delegation, then it shouldn't care
>>>> about the server's file size at all until it has flushed all dirty
>>>> data and returned the delegation. So flushing here is probably wrong.
>>>> 
>>>> But the incoming file size in the GETATTR is definitely screwing up
>>>> the cached file size.
>>>> 
>>> 
>>> In which kernels are you seeing the race? For recent kernels (v4.0+)
>>> the write code should be calling nfs_fattr_set_barrier() in order to
>>> prevent the result from the ACCESS from overwriting the new file size.
>> 
>> I'm testing on 4.2-rc4.
>> 
> 
> OK. Does turning off the check for nfs_ctime_need_update() in
> nfs_inode_attrs_need_update() fix the problem?

I am not able to reproduce the issue when I remove
nfs_ctime_need_update().

The test I'm running does this: unpack git onto an NFSv4.0
mount point, build it, then run "make -j8 test".

Doing "make -j1 test" always works. The test always works
against Linux NFS servers.

With Solaris, which aggressively offers write delegations,
the test fails reliably after -j3, at random points during
the "make test" step.

A network trace was captured during a failure, which
happened to occur during t6030-bisect-porcelain.sh this
time through.

Here's an excerpt which shows the problem. The failing
script seems to be:

 98         echo "  master" > branch.expect &&
 99         echo "* other" >> branch.expect &&

Frame 29091: SETATTR call set size to 0
Frame 29095: SETATTR reply

Frame 29097: WRITE call offset 0, "  master\n"
Frame 29097: ACCESS/GETATTR call

[NB: the ACCESS call appears after the WRITE call in the
same TCP frame]

Frame 29101: ACCESS/GETATTR reply size 0 <<<<
Frame 29102: WRITE reply 9 bytes written

Frame 29112: WRITE call offset 0, "* other\n"
Frame 29115: WRITE reply 8 bytes written

The successful case shows the ACCESS and first WRITE replies
in the reverse order; the ACCESS reply shows the file size
is 9; the second WRITE then sends the correct data, which is
"  master\n* other\n" .

Since nfs_may_open() is called only if the client is holding
a delegation, I wonder if that GETATTR is needed? The only
thing may_open is checking is whether the caller is allowed
to use the existing delegation. Shouldn't the GETATTR results
be ignored in every case?

--
Chuck Lever



