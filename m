Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f173.google.com ([209.85.223.173]:50172 "EHLO
        mail-io0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752603AbdKHPAJ (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 8 Nov 2017 10:00:09 -0500
Received: by mail-io0-f173.google.com with SMTP id n137so6225150iod.6
        for <linux-nfs@vger.kernel.org>; Wed, 08 Nov 2017 07:00:09 -0800 (PST)
From: Joshua Watt <jpewhacker@gmail.com>
To: NeilBrown <neilb@suse.com>, Jeff Layton <jlayton@redhat.com>,
        Trond Myklebust <trond.myklebust@primarydata.com>
Cc: linux-nfs@vger.kernel.org, Al Viro <viro@zeniv.linux.org.uk>,
        "J . Bruce Fields" <bfields@fieldses.org>,
        David Howells <dhowells@redhat.com>,
        Joshua Watt <JPEWhacker@gmail.com>
Subject: [RFC 0/4] Re: NFS Force Unmounting
Date: Wed,  8 Nov 2017 08:59:38 -0600
Message-Id: <20171108145942.5127-1-JPEWhacker@gmail.com>
In-Reply-To: <CAJdd5GZ-EMj8f3RaV_WUdeZs6aWbEAeC6xX8BadMD-aOFL3_jA@mail.gmail.com>
References: <CAJdd5GZ-EMj8f3RaV_WUdeZs6aWbEAeC6xX8BadMD-aOFL3_jA@mail.gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This was my attempt at solving the force unmounting problem, which I
though I would post for discussion (as sort of a alternate to Neil's
patch).

I think there are a few advantages to this approach:
 1) "umount -f" pretty much always does what you want if you have
    "forcekill" in your mount options
 2) It is easy to separate out at an administrative level what mounts
    will be affected by "umount -f", because the "forcekill" mount
    option affects the decision as to whether the NFS superblock can be
    shared (e.g. only mounts to the same client with the same state of
    the forcekill flag are shared, and thus affected by umount -f)
 3) I think this will catch all the different types of RPCs
    (asynchronous, etc.) for a given client?

And a few disadvantages:
 1) It requires a new mount option (maybe there is another way? A mount
    option was all I could figure to prevent superblock sharing).
 2) It doesn't currently affect the behavior of the DESTROY_SESSION RPC
    call made by the nfs_client when the last superblock reference is
    removed. This means that this call must go through the normal
    recovery and timeout process. I am OK with this behavior (for my use
    case at least) because that is *only* going to block the umount
    caller for a (bounded) amount of time.
 3) Probably more I haven't though of...

I don't claim to be a Linux Kernel NFS or filesystem expert, so I will
leave the decisions to those who have a better understanding.

Also, this is my first (non-trivial) Linux kernel patch, so any sort of
review and comments are greatly appreciated.

Thanks!

Joshua Watt (4):
  SUNRPC: Add flag to kill new tasks
  SUNRPC: Kill client tasks from debugfs
  SUNRPC: Simplify client shutdown
  NFS: Add forcekill mount option

 fs/nfs/super.c                 | 17 ++++++++++++---
 include/linux/sunrpc/clnt.h    |  1 +
 include/linux/sunrpc/sched.h   |  2 +-
 include/uapi/linux/nfs_mount.h |  1 +
 net/sunrpc/clnt.c              | 13 +++++++++---
 net/sunrpc/debugfs.c           | 48 ++++++++++++++++++++++++++++++++++++++++++
 net/sunrpc/sched.c             |  7 ++++++
 7 files changed, 82 insertions(+), 7 deletions(-)

-- 
2.13.6

