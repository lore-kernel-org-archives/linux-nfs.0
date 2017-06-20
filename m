Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:37448 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750993AbdFTODp (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 20 Jun 2017 10:03:45 -0400
From: "Benjamin Coddington" <bcodding@redhat.com>
To: "Jeff Layton" <jlayton@poochiereds.net>
Cc: bfields@fieldses.org, "Alexander Viro" <viro@zeniv.linux.org.uk>,
        linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        "open list" <linux-kernel@vger.kernel.org>
Subject: Re: [PATCH 2/2] fs/locks: Remove fl_nspid and use fs-specific l_pid
 for remote locks
Date: Tue, 20 Jun 2017 10:03:42 -0400
Message-ID: <9037C362-D6F7-4545-80C2-08B072005055@redhat.com>
In-Reply-To: <1497893534.4654.11.camel@poochiereds.net>
References: <cover.1497877897.git.bcodding@redhat.com>
 <901367ff4ffd87594a380e3a0a5d20c4e4195b0e.1497877897.git.bcodding@redhat.com>
 <1497893534.4654.11.camel@poochiereds.net>
MIME-Version: 1.0
Content-Type: text/plain; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On 19 Jun 2017, at 13:32, Jeff Layton wrote:

> On Mon, 2017-06-19 at 09:24 -0400, Benjamin Coddington wrote:
>> @@ -2041,16 +2034,46 @@ SYSCALL_DEFINE2(flock, unsigned int, fd, 
>> unsigned int, cmd)
>>   */
>>  int vfs_test_lock(struct file *filp, struct file_lock *fl)
>>  {
>> -	if (filp->f_op->lock && is_remote_lock(filp))
>> +	if (filp->f_op->lock && is_remote_lock(filp)) {
>> +		fl->fl_flags |= FL_PID_PRIV;
>>  		return filp->f_op->lock(filp, F_GETLK, fl);
>> +	}
>>  	posix_test_lock(filp, fl);
>>  	return 0;
>>  }
>>  EXPORT_SYMBOL_GPL(vfs_test_lock);
>>
>
> I think this looks wrong for NFS.

Oh yes, this is completely wrong..  It should be looking for fl_ops, 
which
would set the flag for lock managers.

> There are really two cases we're concerned with here:
>
> 1) the lock is held by a task on the client itself, in which case we
> probably want to report the pid as we would on a local fs.
>
> ...or...
>
> 2) the lock is held by another host entirely in which case the pid
> doesn't have any meaning. We probably ought to return something like 
> '-
> 1' as the pid (like we would for OFD locks).

I don't think we have f_op->lock() users that only set remote locks.  
For
NFS, the remote lock is always matched by a local lock.

> The problem for NFS is that you're setting the flag unconditionally
> there. It may very well be the case that we _want_ to translate the
> fl_pid according to the local namespace (i.e. if the lock is held by a
> task on the same host).
>
> I think what you want to do here is have the fs ->lock operation set
> that flag if the fl_pid should be used "as-is" instead of being
> translated.
>
> Most of the current lock operations can just set it early (to preserve
> the existing behavior), but NFS could be set up to set that flag if 
> the
> lock request goes to the server.

I think this is just a mistake.. I think we want to always translate all
local locks, unless the lock is placed by a lock manager.

I'll send a corrected version.

Ben
