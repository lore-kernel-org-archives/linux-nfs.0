Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx3-rdu2.redhat.com ([66.187.233.73]:58172 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1030678AbeBNOB0 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 14 Feb 2018 09:01:26 -0500
Date: Wed, 14 Feb 2018 09:01:25 -0500
From: Scott Mayhew <smayhew@redhat.com>
To: trondmy@primarydata.com
Cc: linux-nfs@vger.kernel.org
Subject: Question about the removal of __nfs_revalidate_inode() from
 do_setlk()
Message-ID: <20180214140125.kkpoz4cgouuk5lvx@tonberry.usersys.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Trond,

Commit ca0daa2 ("NFS: Cache aggressively when file is open for writing")
removed the inode revalidation from do_setlk().  Why was that necessary?
If just that part of the commit is added back in, the client still seems
to be able to cope with out-of-order write replies.

Currently the client invalidates the data cache whenever it takes a lock
and that causes performance problems for some workloads... if a client
wants to re-read portions of a file, and no other client has modified 
that file, then why should the reads go out on the wire just because
locking is being used?

-Scott
