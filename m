Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f170.google.com ([209.85.223.170]:47708 "EHLO
        mail-io0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754604AbdKJWhd (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 10 Nov 2017 17:37:33 -0500
Received: by mail-io0-f170.google.com with SMTP id h70so15094001ioi.4
        for <linux-nfs@vger.kernel.org>; Fri, 10 Nov 2017 14:37:32 -0800 (PST)
From: Joshua Watt <jpewhacker@gmail.com>
To: NeilBrown <neilb@suse.com>, Jeff Layton <jlayton@redhat.com>,
        Trond Myklebust <trond.myklebust@primarydata.com>
Cc: linux-nfs@vger.kernel.org, Al Viro <viro@zeniv.linux.org.uk>,
        "J . Bruce Fields" <bfields@fieldses.org>,
        David Howells <dhowells@redhat.com>,
        Joshua Watt <JPEWhacker@gmail.com>
Subject: [RFC v2 0/7] NFS Force Unmounting
Date: Fri, 10 Nov 2017 16:37:00 -0600
Message-Id: <20171110223707.17098-1-JPEWhacker@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Reworked patch set in response to Neil's comments. This patchset
requires his patch as a prerequisite:
    http://www.spinics.net/lists/linux-nfs/msg66341.html

These patches implements behavior that allows a failed server to be "cut
off" (e.g. all RPC tasks fail with -EIO) with the following sequence of
operations:

 mount -o remount,serverfailed
 umount -f

In the event you want to try and recover the server, you can remount to
remove the serverfailed status:
 
 mount -o remount,noserverfailed

Although, I'm not sure what implications that might have for data loss.

For the most part I think it is pretty straight forward, the only thing
I am unsure about is the last two patches. This behavior is really
useful in my use case (where the server disappears) as it prevents the
umount -f from blocking while trying to send some DESTROY_SESSION
messages to the client (as long as you mounted with nosharecache).

Version 1 can be found at:
    http://www.spinics.net/lists/linux-nfs/msg66348.html

Thanks in advance for the reviews and comments

Joshua Watt (7):
  SUNRPC: Add flag to kill new tasks
  SUNRPC: Expose kill_new_tasks in debugfs
  SUNRPC: Simplify client shutdown
  NFS: Add mount flags mask
  NFS: Add serverfailed mount option
  NFS: Propagate NFS_MOUNT_UNSHARED to clients
  NFS: Propagate operations to unshared clients

 fs/nfs/client.c                |  9 +++-
 fs/nfs/inode.c                 |  6 +++
 fs/nfs/internal.h              |  1 +
 fs/nfs/nfs3client.c            |  2 +
 fs/nfs/nfs4client.c            |  4 ++
 fs/nfs/super.c                 | 98 ++++++++++++++++++++++++++----------------
 include/linux/nfs_fs_sb.h      |  1 +
 include/linux/sunrpc/clnt.h    |  1 +
 include/uapi/linux/nfs_mount.h |  1 +
 net/sunrpc/clnt.c              | 11 ++---
 net/sunrpc/debugfs.c           |  4 ++
 net/sunrpc/sched.c             |  3 ++
 12 files changed, 95 insertions(+), 46 deletions(-)

-- 
2.13.6

