From: "Mike Snitzer" <snitzer@gmail.com>
Subject: constrained lockd error handling semantics when lock request processing is deferred?
Date: Tue, 18 Dec 2007 23:03:01 -0500
Message-ID: <170fa0d20712182003n6819645cwc1560b35da210895@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from nz-out-0506.google.com ([64.233.162.238]:64817 "EHLO
	nz-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753710AbXLSEDD (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 18 Dec 2007 23:03:03 -0500
Received: by nz-out-0506.google.com with SMTP id s18so1470075nze.1
        for <linux-nfs@vger.kernel.org>; Tue, 18 Dec 2007 20:03:02 -0800 (PST)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

I could be missing something blatantly obvious so please be kind...

I would like to understand how one _should_ implement ->lock() for a
filesystem that can't immediately determine that the request would
result in -EDEADLK or -ENOLCK.  Particularly for deferred SETLKW
requests.

That is, the filesystem's ->lock() initially responds with
-EINPROGRESS but later goes on to fail the request with -EDEADLK or
-ENOLCK.  The filesystem's call to ->fl_grant() will be made with an
unsupported 'result'.

Having reviewed the code in fs/lockd/svclock.c it would seem that it
was never designed to allow EDEADLK or ENOLCK _after_ nlmsvc_lock()'s
initial call to vfs_lock_file().

nlmsvc_grant_deferred() properly handles deferred SETLKW processing
IFF the result is 0 (aka granted).
nlmsvc_grant_deferred()'s SETLK processing will at least return
failures (but they are assumed to be B_TIMED_OUT).
In the end the real 'result' gets dropped on the floor.

Why must ->lock() immediately return error (e.g. EDEADLK), otherwise
it is assumed the request will complete successfully (or timeout in
the B_QUEUED/SETLK case)?  Seems overly constrained (painfully so for
SETLKW) when you consider that the whole point of deferred processing
(via EINPROGRESS and ->fl_grant) is to accomodate filesystems that
can't respond to a lock request immediately.

regards,
Mike
