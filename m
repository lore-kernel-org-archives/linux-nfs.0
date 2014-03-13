Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ig0-f172.google.com ([209.85.213.172]:61220 "EHLO
	mail-ig0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752135AbaCMVgp convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 13 Mar 2014 17:36:45 -0400
Received: by mail-ig0-f172.google.com with SMTP id uq10so18338345igb.5
        for <linux-nfs@vger.kernel.org>; Thu, 13 Mar 2014 14:36:44 -0700 (PDT)
Content-Type: text/plain; charset=windows-1252
Mime-Version: 1.0 (Mac OS X Mail 7.2 \(1874\))
Subject: Re: [PATCH] nfs: emit a fsnotify_nameremove call in sillyrename codepath
From: Trond Myklebust <trond.myklebust@primarydata.com>
In-Reply-To: <1394745983.5656.4.camel@leira.trondhjem.org>
Date: Thu, 13 Mar 2014 17:36:42 -0400
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <26D6D5FE-EAF3-45A9-9138-F2B89C7C3728@primarydata.com>
References: <1394738651-26783-1-git-send-email-jlayton@redhat.com> <35EEB018-FD2D-4C52-AA6B-24B66B11D6B6@primarydata.com> <20140313162218.570e0819@tlielax.poochiereds.net> <96492A5A-C738-4E20-88B9-D01995217981@primarydata.com> <20140313172119.232397a5@tlielax.poochiereds.net> <1394745983.5656.4.camel@leira.trondhjem.org>
To: Layton Jeff <jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Mar 13, 2014, at 17:26, Trond Myklebust <trond.myklebust@primarydata.com> wrote:

> On Thu, 2014-03-13 at 17:21 -0400, Jeff Layton wrote:
>> On Thu, 13 Mar 2014 16:47:49 -0400
>> Trond Myklebust <trond.myklebust@primarydata.com> wrote:
>> 
>>> 
>>> On Mar 13, 2014, at 16:22, Jeff Layton <jlayton@redhat.com> wrote:
>>> 
>>>> On Thu, 13 Mar 2014 16:08:01 -0400
>>>> Trond Myklebust <trond.myklebust@primarydata.com> wrote:
>>>> 
>>>>> 
>>>>> On Mar 13, 2014, at 15:24, Jeff Layton <jlayton@redhat.com> wrote:
>>>>> 
>>>>>> If a file is sillyrenamed, then the generic vfs_unlink code will skip
>>>>>> emitting fsnotify events for it.
>>>>>> 
>>>>>> This patch has the sillyrename code do that instead.
>>>>>> 
>>>>>> In truth this is a little bit odd since we aren't actually removing the
>>>>>> dentry per-se, but renaming it. Still, this is probably the right thing
>>>>>> to do since it's what userland apps expect to see when an unlink()
>>>>>> occurs or some file is renamed on top of the dentry.
>>>>>> 
>>>>>> Signed-off-by: Jeff Layton <jlayton@redhat.com>
>>>>>> ---
>>>>>> fs/nfs/dir.c    | 1 +
>>>>>> fs/nfs/unlink.c | 2 ++
>>>>>> 2 files changed, 3 insertions(+)
>>>>>> 
>>>>>> diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
>>>>>> index 4a48fe4b84b6..591aec9b1719 100644
>>>>>> --- a/fs/nfs/dir.c
>>>>>> +++ b/fs/nfs/dir.c
>>>>>> @@ -37,6 +37,7 @@
>>>>>> #include <linux/sched.h>
>>>>>> #include <linux/kmemleak.h>
>>>>>> #include <linux/xattr.h>
>>>>>> +#include <linux/fsnotify.h>
>>>>>> 
>>>>>> #include "delegation.h"
>>>>>> #include "iostat.h"
>>>>>> diff --git a/fs/nfs/unlink.c b/fs/nfs/unlink.c
>>>>>> index 11d78944de79..547ed0cd59db 100644
>>>>>> --- a/fs/nfs/unlink.c
>>>>>> +++ b/fs/nfs/unlink.c
>>>>>> @@ -355,6 +355,8 @@ static void nfs_async_rename_done(struct rpc_task *task, void *calldata)
>>>>>> 
>>>>>> 	if (task->tk_status != 0)
>>>>>> 		nfs_cancel_async_unlink(old_dentry);
>>>>>> +	else if (old_dentry->d_flags & DCACHE_NFSFS_RENAMED)
>>>>>> +		fsnotify_nameremove(old_dentry, S_ISDIR(old_dentry->d_inode->i_mode));
>>>>>> }
>>>>> 
>>>>> Any reason why we shouldn’t just do this in nfs_sillyrename() itself?
>>>>> 
>>>> 
>>>> We certainly could, but then you'd probably never get the event if the
>>>> process waiting on the async sillyrename got killed while waiting on
>>>> the reply.
>>> 
>>> Just send it anyway. The dentry will have been scheduled to be unlinked no matter whether or not the process is killed.
>>> 
>> 
>> Hrm, I dunno...
>> 
>> If we do that then we may end up sending the event before it has
>> actually occurred. I'm not sure if that's a problem or not, but it
>> seems iffy.
>> 
>> I don't get it though -- why not do this in the rpc_call_done handler?
>> If we do it there then we know we'll only send the event if the rename
>> succeeded.
> 
> While nfs_async_rename() may currently reside in fs/nfs/unlink.c, the
> function itself is completely independent of sillyrename. It doesn't
> even share any common structures. Why should we start adding stuff which
> has absolutely nothing to do with rename to it when we don't have to?

Put differently: if anyone out there is looking for something to do, then reuniting nfs_async_rename() with its long lost synchronous cousins would be a nice little cleanup.
_________________________________
Trond Myklebust
Linux NFS client maintainer, PrimaryData
trond.myklebust@primarydata.com

