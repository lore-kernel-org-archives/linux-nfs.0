From: Steven Whitehouse <swhiteho@redhat.com>
Subject: lockd and lock cancellation
Date: Thu, 01 Apr 2010 13:16:42 +0100
Message-ID: <1270124202.3354.40.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: eshel@almaden.ibm.com
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:14979 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755781Ab0DAMMu (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 1 Apr 2010 08:12:50 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi,

I'm trying to find my way around the lockd code and I'm currently a bit
stumped by the code relating to lock cancellation. There is only one
call to vfs_cancel_lock() in lockd/svclock.c and its return value isn't
checked.

It is used in combination with nlmsvc_unlink_block() which
unconditionally calls posix_unblock_lock(). There are also other places
where the code also calls nlmsvc_unlink_block() without first canceling
the lock. The way in which vfs_cancel_lock() is used suggests that
canceling a lock is a synchronous operation, and that it must succeed
before returning.

I'd have expected to see (pseudo code) something more like the
following:

ret = vfs_cancel_lock();
if (ret == -ENOENT) /* never had the lock in the first place */
    do_something_appropriate();
else if (ret == -EINVAL) /* we raced with a grant */
    unlock_lock();
else /* lock successfully canceled */
    nlmsvc_unlink_block();

Is there a reason why that is not required? and indeed, is there a
reason why its safe to call nlmsvc_unlink_block() in the cases where the
lock isn't canceled first? I'm trying to work out how the underlying fs
can tell that a lock has gone away in those particular cases,

Steve.


