From: Terry Loftin <terry.loftin@hp.com>
Subject: [PATCH 0/1] nfs: Panic when commit fails
Date: Tue, 20 Oct 2009 11:44:36 -0600
Message-ID: <4ADDF704.9080109@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: SteveD@redhat.com, linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from g5t0007.atlanta.hp.com ([15.192.0.44]:40458 "EHLO
	g5t0007.atlanta.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751980AbZJTRop (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 20 Oct 2009 13:44:45 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


Steve,

Please consider the following patch.  Thanks in advance!

Summary:
At the end of an nfs write, if the nfs commit fails, all the writes
will be rescheduled.  They are supposed to be rescheduled as NFS_FILE_SYNC
writes, but the rpc_task structure is not completely intialized and so
the option is not passed.  When the rescheduled writes complete, the
return indicates that they are NFS_UNSTABLE and we try to do another
commit.  This leads to a Panic because the commit data structure pointer
was set to null in the initial (failed) commit attempt.


Long-Winded Description:
This panic is pretty rare - it requires all writes to complete
succesfully, and the commit to fail.

We had an NFS clilent panic with this stack trace:
    PID: 5981   TASK: ffff8801a51c86c0  CPU: 6   COMMAND: "nfsiod"
     #0 [ffff88019f1ab800] crash_kexec at ffffffff8026eb22
     #1 [ffff88019f1ab8e0] oops_end at ffffffff804c7099
     #2 [ffff88019f1ab910] do_page_fault at ffffffff804c8d2a
     #3 [ffff88019f1abc90] page_fault at ffffffff804c65d5
     #4 [ffff88019f1abd18] nfs_direct_write_complete at ffffffffa0345bf7
     #5 [ffff88019f1abdf8] nfs_direct_write_release at ffffffffa0346030
     #6 [ffff88019f1abe28] rpc_release_calldata at ffffffffa02ec427
     #7 [ffff88019f1abe38] rpc_free_task at ffffffffa02ec4ce
     #8 [ffff88019f1abe68] rpc_async_release at ffffffffa02ec58b
     #9 [ffff88019f1abe78] run_workqueue at ffffffff80252b17
    #10 [ffff88019f1abec8] worker_thread at ffffffff80252c91
    #11 [ffff88019f1abf28] kthread at ffffffff8025623d
    #12 [ffff88019f1abf48] kernel_thread at ffffffff8021241a

Just prior to this, our nfs server crashed due to hw problems.
The Panic happens in nfs_direct_commit_schedule(), at line ~568 in
fs/nfs/direct.c:

        data->inode = dreq->inode;

Here, data is NULL and is the cause of the Panic.  This means that
dreq->commit_data is NULL.  By inspection, this pointer is only set
to NULL in nfs_direct_commit_schedule(), so we must have called this
function twice.

This panic happens when a commit fails.  In nfs_direct_commit_release(),
when a commit fails, we set dreq->flags to NFS_ODIRECT_RESCHED_WRITES
to reschedule all the associated writes.  When these writes complete,
we try to do another commit, but, the commit_data pointer has already
been set to NULL during previous commit attempt.

The problem is that we shouldn't be doing a second commit attempt.
In nfs_direct_write_reschedule() we request a sync write by setting
the args->stable pointer to NFS_FILE_SYNC, but the server does not
see this, because the rpc_task structure isn't fully initialized.
Thus the response from the server for these rescheduled writes always
returns NFS_UNSTABLE, which causes us to do a second commit  (See:
nfs_direct_write_release()) and causes a Panic.

I added code to nfs_direct_release() to fail every 8th commit.  The
panic was reproduced on the 8th commit every time.  I then added a
line to initialize the rpc_task structure in nfs_direct_write_reschedule().
I quit testing after logging over 64K commits (with 8K commit failures)
and no Panics, and no write errors detected.

This is pretty much a typo.  Every other rpc_task struct appears to
be fully initialized.

-T
