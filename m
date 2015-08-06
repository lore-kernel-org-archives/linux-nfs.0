Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ob0-f177.google.com ([209.85.214.177]:33774 "EHLO
	mail-ob0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752269AbbHFCuW (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 5 Aug 2015 22:50:22 -0400
Received: by obdeg2 with SMTP id eg2so46287457obd.0
        for <linux-nfs@vger.kernel.org>; Wed, 05 Aug 2015 19:50:21 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <8F6C1893-11A1-485C-A9EA-0ABBCC4D4286@oracle.com>
References: <20150805182305.11796.75476.stgit@manet.1015granger.net>
	<359CCE70-6056-418F-B627-688BE27C7EA8@oracle.com>
	<CAHQdGtQz1EqZLt-i=uAhFONpnyfUBSFyWHnjWdjgU8kOmnrR6Q@mail.gmail.com>
	<8F6C1893-11A1-485C-A9EA-0ABBCC4D4286@oracle.com>
Date: Wed, 5 Aug 2015 22:50:21 -0400
Message-ID: <CAHQdGtTB3uxbGsN1WXVJh3vdLabW5pOr5wuyS59a-WK2dM-yPw@mail.gmail.com>
Subject: Re: [PATCH] NFS: Add OTW write barrier before may-open test
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Aug 5, 2015 at 8:15 PM, Chuck Lever <chuck.lever@oracle.com> wrote:
>
> On Aug 5, 2015, at 6:27 PM, Trond Myklebust <trond.myklebust@primarydata.com> wrote:
>
>> On Wed, Aug 5, 2015 at 2:44 PM, Chuck Lever <chuck.lever@oracle.com> wrote:
>>>
>>> On Aug 5, 2015, at 2:34 PM, Chuck Lever <chuck.lever@oracle.com> wrote:
>>>
>>>> Commit 14546c337588 ("NFS: Don't do a full flush to disk on close()
>>>> if we hold a delegation") added an optimization. When an NFSv4 write
>>>> delegation is present, close(2) does not wait while a file's dirty
>>>> data is flushed to the NFS server.
>>>>
>>>> However, if the application workload immediately re-opens that file,
>>>> nfs_may_open() can perform an ACCESS and GETATTR which runs
>>>> concurrently with the flushing WRITE. If the flushing WRITE and
>>>> GETATTR complete out of order on the server, the file size cached on
>>>> the client will go backwards, possibly resulting in new writes going
>>>> to the wrong file offset.
>>>>
>>>> Add a write barrier before the access check to ensure the server's
>>>> idea of the file's size is properly up to date.
>>>>
>>>> The downside of this approach is that each fresh open(2) of a dirty
>>>> file results in an extra flush. It seems to me that _any_ open(2)
>>>> done while there is dirty data waiting on the client could result in
>>>> a file size roll back. However, I see bad behavior only when the
>>>> client holds a write delegation.
>>>>
>>>> Fixes: 14546c337588 ("NFS: Don't do a full flush to disk on . . .")
>>>> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
>>>> ---
>>>> fs/nfs/dir.c |    9 +++++++++
>>>> 1 file changed, 9 insertions(+)
>>>>
>>>> I'm not certain this is a good long term fix. Some other possible
>>>> solutions include:
>>>>
>>>> - Not performing the access check if the client holds a delegation
>>>> - Not performing a GETATTR as part of the ACCESS check
>>>> - Simply marking the file attributes stale instead of using the
>>>>  returned file size
>>>> - Reverting commit 14546c337588
>>>
>>> OK. If the client holds a write delegation, then it shouldn't care
>>> about the server's file size at all until it has flushed all dirty
>>> data and returned the delegation. So flushing here is probably wrong.
>>>
>>> But the incoming file size in the GETATTR is definitely screwing up
>>> the cached file size.
>>>
>>
>> In which kernels are you seeing the race? For recent kernels (v4.0+)
>> the write code should be calling nfs_fattr_set_barrier() in order to
>> prevent the result from the ACCESS from overwriting the new file size.
>
> I'm testing on 4.2-rc4.
>

OK. Does turning off the check for nfs_ctime_need_update() in
nfs_inode_attrs_need_update() fix the problem?
