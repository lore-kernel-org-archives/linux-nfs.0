From: Rob Gardner <rob.gardner@hp.com>
Subject: Potential lockd bug can cause orphaned locks
Date: Sun, 15 Nov 2009 15:49:50 -0700
Message-ID: <4B00858E.7090400@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1; format=flowed
To: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from g5t0008.atlanta.hp.com ([15.192.0.45]:7687 "EHLO
	g5t0008.atlanta.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752025AbZKOWtr (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 15 Nov 2009 17:49:47 -0500
Received: from g5t0012.atlanta.hp.com (unknown [15.192.0.16])
	(using TLSv1 with cipher ADH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by g5t0008.atlanta.hp.com (Postfix) with ESMTPS id 35A25240F8
	for <linux-nfs@vger.kernel.org>; Sun, 15 Nov 2009 22:49:53 +0000 (UTC)
Received: from [192.168.4.77] (unknown [76.76.65.16])
	by g5t0012.atlanta.hp.com (Postfix) with ESMTPSA id 627E710004
	for <linux-nfs@vger.kernel.org>; Sun, 15 Nov 2009 22:49:52 +0000 (UTC)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


I've discovered some behavior in lockd that I think is questionable. In
conjunction with file systems that provide their own locking functions
(ie, file->f_op->lock()), lockd seems to handle cancel requests
inconsistently, with the result that a file may be left with a byte
range lock on it but with no owner.

There are several scenarios in which lockd would like to cancel a lock
request:
1. Client sends explicit unlock or cancel request
2. A non-blocking lock request times out
3. A 'cleanup' type request, ie, client reboot and subsequent SM_NOTIFY
which attempts to clear all locks and requests for that client

In all scenarios, lockd believes that the locks and lock requests for
the file have been cleaned up, and it closes the file and releases
references to the file.

In the first scenario, lockd calls vfs_cancel_lock to alert the file
system that it would like to cancel the lock request; Then,
nlmsvc_unlink_block() calls posix_unblock_lock() which cancels any
outstanding posix lock request.

But in the other two scenarios, vfs_cancel_lock() is never called, only
posix_unblock_lock(). So there may still be an outstanding lock request
in the file system after lockd thinks everything has been cleaned up. If
this request is granted some time later, the file system will call
nlmsvc_grant_deferred(), who will not find any record of the lock, and
report "grant for unknown block." At this point it's not clear exactly
what the file system should do. The large comment before vfs_lock_file()
in fs/locks.c is a bit vague, but says that "if the request timed out
the callback routine will return a nonzero return code and the file
system should release the lock." But it doesn't say what the file system
should do if the request didn't time out. Either way, I think the
comment is advising what to do in case of a race; After all, if the
caller could cancel the file system request, why wouldn't it do so?

It seems to me that scenarios 2 and 3 are perfectly good "cancel lock"
situations and lockd should call vfs_cancel_lock() in both cases to
reduce the possibility of a future grant for a file no longer opened by
lockd. Depending on the vague and ambiguous advice in the locks.c
comment seems very dangerous; Releasing a lock may not result in the
same state as canceling the lock request that caused the grant so it
should always be preferable to cancel a lock if possible, rather than
waiting for a grant then unlocking it.

I have observed this problem by power cycling a client while it was
blocked waiting on a lock request. It booted back up, and after it sent
the SM_NOTIFY to the server, I unlocked the file that it had been
blocked on. At this point, the "grant for unknown block" message
appears, and the file now has a lock on it that nobody owns, and it
cannot be unlocked except via drastic measures, ie, rebooting server,
unplugging file system.

I am thinking about a change in lockd in which vfs_cancel_lock would be
called before nlmsvc_unlink_block in two places:
1. in nlmsvc_lock() in the B_TIMED_OUT case, to handle a non-blocking 
lock that "times out", ie, doesn't get a response from the file system 
within NLM_TIMEOUT.
2. in nlmsvc_traverse_blocks(), to handle SM_NOTIFY, lockd shutdown , etc.

Possible code change (not tested):

--- svclock.c.linux-2.6.32-rc6    2009-11-15 13:54:03.000000000 -0700
+++ svclock.c    2009-11-15 13:57:15.000000000 -0700
@@ -288,8 +288,9 @@
        if (list_empty(&block->b_list))
            continue;
        kref_get(&block->b_count);
        mutex_unlock(&file->f_mutex);
+        vfs_cancel_lock(block->b_file->f_file,
+              &block->b_call->a_args.lock.fl);
        nlmsvc_unlink_block(block);
        nlmsvc_release_block(block);
        goto restart;
    }
@@ -399,8 +400,9 @@
            ret = nlm_granted;
            goto out;
        }
        if (block->b_flags & B_TIMED_OUT) {
+            vfs_cancel_lock(block->b_file->f_file,
+                  &block->b_call->a_args.lock.fl);
            nlmsvc_unlink_block(block);
            ret = nlm_lck_denied;
            goto out;
        }


Another possibility is to change nlmsvc_unlink_block() to make the call to
vfs_cancel_lock() and then remove the call to vfs_cancel_lock in
nlmsvc_cancel_blocked(). But I don't really like this as most other
calls to nlmsvc_unlink_block() do not require a call to vfs_cancel_lock().

I am interested in hearing opinions on this... is there a better 
solution? Or is it not really a problem because of something else?


Rob Gardner






