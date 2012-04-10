Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mailhub.sw.ru ([195.214.232.25]:27661 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755883Ab2DJMSw (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 10 Apr 2012 08:18:52 -0400
Message-ID: <4F84250F.8050301@parallels.com>
Date: Tue, 10 Apr 2012 16:18:23 +0400
From: Stanislav Kinsbursky <skinsbursky@parallels.com>
MIME-Version: 1.0
To: Jeff Layton <jlayton@redhat.com>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH][RFC] nfsd/lockd: have locks_in_grace take a sb arg
References: <1333455279-11200-1-git-send-email-jlayton@redhat.com>	<4F841D2A.9020504@parallels.com> <20120410080508.2c82225d@tlielax.poochiereds.net>
In-Reply-To: <20120410080508.2c82225d@tlielax.poochiereds.net>
Content-Type: text/plain; charset=UTF-8; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

10.04.2012 16:05, Jeff Layton пишет:
> On Tue, 10 Apr 2012 15:44:42 +0400
> Stanislav Kinsbursky<skinsbursky@parallels.com>  wrote:
>
>> 03.04.2012 16:14, Jeff Layton пишет:
>>> The main reason for the grace period is to prevent the server from
>>> allowing an operation that might otherwise be denied once the client has
>>> reclaimed all of its stateful objects.
>>>
>>> Currently, the grace period handling in the nfsd/lockd server code is
>>> very simple. When the lock managers start, they stick an entry on a list
>>> and set a timer. When the timers pop, then they remove the entry from
>>> the list. The locks_in_grace check just looks to see if the list is
>>> empty. If it is, then the grace period is considered to be over.
>>>
>>> This is insufficient for a clustered filesystem that is being served
>>> from multiple nodes at the same time. In such a configuration, the grace
>>> period must be coordinated in some fashion, or else one node might hand
>>> out stateful objects that conflict with those that have not yet been
>>> reclaimed.
>>>
>>> This patch paves the way for fixing this by adding a new export
>>> operation called locks_in_grace that takes a superblock argument. The
>>> existing locks_in_grace function is renamed to generic_locks_in_grace,
>>> and a new locks_in_grace function that takes a superblock arg is added.
>>> If a filesystem does not have a locks_in_grace export operation then the
>>> generic version will be used.
>>>
>>> Care has also been taken to reorder calls such that locks_in_grace is
>>> called last in compound conditional statements. Handling this for
>>> clustered filesystems may involve upcalls, so we don't want to call it
>>> unnecessarily.
>>>
>>> For now, this patch is just an RFC as I do not yet have any code that
>>> overrides this function and am still specing out what that code should
>>> look like.
>>>
>>
>> Oops, I've noticed your patch after I replied in "Grace period" thread.
>> This patch looks good, but doesn't explain, how this per-filesystem logic will
>> work in case of sharing non-nested subdirectories with the same superblock.
>> This is a valid situation. But how to handle grace period in this case?
>
>
> It's a valid situation but one that's discouraged.

But it looks like common case. In future we are going to get rid of using one 
mounted file system for more than one virtual environment, but currently in 
OpenVZ we do exactly this.
And it looks like LXC uses chroot for containers as well...

-- 
Best regards,
Stanislav Kinsbursky
