Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f181.google.com ([209.85.223.181]:48861 "EHLO
        mail-io0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753449AbdKNXGg (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 14 Nov 2017 18:06:36 -0500
Received: by mail-io0-f181.google.com with SMTP id d66so26220041ioe.5
        for <linux-nfs@vger.kernel.org>; Tue, 14 Nov 2017 15:06:35 -0800 (PST)
From: Joshua Watt <jpewhacker@gmail.com>
To: NeilBrown <neilb@suse.com>, Jeff Layton <jlayton@redhat.com>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        "J . Bruce Fields" <bfields@fieldses.org>
Cc: linux-nfs@vger.kernel.org, Al Viro <viro@zeniv.linux.org.uk>,
        David Howells <dhowells@redhat.com>,
        Joshua Watt <JPEWhacker@gmail.com>
Subject: [RFC v3 0/7] NFS Force Unmounting
Date: Tue, 14 Nov 2017 17:06:24 -0600
Message-Id: <20171114230631.14682-1-JPEWhacker@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

After some additional testing on version 2, I realized that 1) my test
setup was bad (Doh!) and 2) using remount isn't really an ideal method
for setting the "serverfailed" mount flag. The reason being that any
userspace remount is going to touch the file system and probably invoke
some RPCs for inode validation as such. If the server is truly dead,
these RPCs will have to time out before the flag could actually be set.
This not only takes a long time, but will probably also fail, causing
the remount to fail and not set the flag, defeating the purpose.

This patch set works around this by exposing the failed server flag in
debugfs. In addition, the flag now applies at the nfs_client level
(instead of the nfs_server). Setting the flag will cancel all RPCs in
the client, as well as all nfs_servers attached to it. This ensures that
you get all the mounts, even when dealing with submounts that cross
remote device boundaries. This is also where the nosharecache option
applying to nfs_clients becomes useful... it will prevent sharing
between other explicit mount calls, but submounts will all still share a
nfs_client (and fail together).

Obviously, debugfs is not a permanent solution for this, so some
discussion needs to be had on how this will be administered "in the real
world" (I think "remount" is off the table).

Joshua Watt (7):
  SUNRPC: Add flag to kill new tasks
  SUNRPC: Expose kill_new_tasks in debugfs
  SUNRPC: Simplify client shutdown
  NFS: Add debugfs for nfs_server and nfs_client
  NFS: Propagate NFS_MOUNT_UNSHARED to clients
  NFS: Add API to fail client
  NFS: Control failed clients through debugfs

 fs/nfs/Makefile             |   2 +-
 fs/nfs/client.c             | 121 ++++++++++++++++++++++++--
 fs/nfs/debugfs.c            | 202 ++++++++++++++++++++++++++++++++++++++++++++
 fs/nfs/inode.c              |   5 ++
 fs/nfs/internal.h           |  11 +++
 fs/nfs/nfs3client.c         |   2 +
 fs/nfs/nfs4client.c         |   5 ++
 include/linux/nfs_fs_sb.h   |   8 ++
 include/linux/sunrpc/clnt.h |   1 +
 net/sunrpc/clnt.c           |  12 +--
 net/sunrpc/debugfs.c        |   4 +
 net/sunrpc/sched.c          |   3 +
 12 files changed, 360 insertions(+), 16 deletions(-)
 create mode 100644 fs/nfs/debugfs.c

-- 
2.13.6

