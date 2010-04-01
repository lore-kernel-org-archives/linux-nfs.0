Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qy0-f173.google.com ([209.85.221.173]:62450 "EHLO
	mail-qy0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756645Ab0DATCV (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 1 Apr 2010 15:02:21 -0400
Received: by qyk4 with SMTP id 4so1698690qyk.24
        for <linux-nfs@vger.kernel.org>; Thu, 01 Apr 2010 12:02:19 -0700 (PDT)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 00/11] [RFC] possible NFSv2/v3 lock recovery enhancements
To: linux-nfs@vger.kernel.org
Date: Thu, 01 Apr 2010 15:02:16 -0400
Message-ID: <20100401183724.6395.60353.stgit@localhost.localdomain>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

For the purpose of discussion, here are 11 WIP patches.  These have
seen very little testing, and are presented here as a proof of concept
only.

There are three main goals of this work:

1)  Provide an API for an NFSv2/v3 server administrator to release
    stale locks

2)  Provide an alternate API that doesn't depend on the existance of
    a particular network loopback interface to allow statd to perform
    NLM callbacks (ie statd won't have to care whether to use IPv4
    or IPv6 loopback to make NLM downcalls)

3)  Allow clients to send correct caller_name strings in
    NLMPROC_LOCK requests.

1 and 2 are met by implementing a set of directories under /sys that
expose the kernel's nlm_host and nsm_handle cache.  Each entry in the
nsm_handle cache has a reboot attribute that would allow a user space
process to trigger reboot recovery on the remote peer represented by
that entry.

3 is met by adding a new NFSv2/v3 mount option, similar to clientaddr=
for NFSv4 mounts, that allows the mount command to specify the
caller_name string to use for lock requests on this mount point.

There is still a chicken-and-egg type problem for statd.  These new
/sys files are owned and readable by only root.  The reboot attribute
is owned and writable by only root.  statd runs as "rpcuser" usually,
so unless something special is done, it wouldn't be able to use a /sys
file to trigger reboot recovery.

A possible way to address this is to add support for AF_LOCAL to the
kernel.  The kernel can create an RPC socket that statd can use to
perform downcalls.  AF_LOCAL can also be used in other cases, like
when the kernel has to contact rpcbind, so kernel AF_LOCAL support
wouldn't be a single-use type of thing.

---

Chuck Lever (11):
      lockd: Allow mount option to specify caller_name
      lockd: use sm_my_name for nsm_handle lookups
      lockd: Keep my_name in nsm_handle
      lockd: Add "reboot" attribute to nsm_handles
      lockd: Refactor nlm_host_rebooted()
      lockd: Add /sys/fs/lockd/nsm_handle/*
      lockd: Add /sys/fs/lockd/mon
      lockd: Add attributes to /sys/fs/lockd/hosts/*/
      lockd: Add /sys/fs/lockd/hosts/*
      lockd: Add /sys/fs/lockd/hosts/
      lockd: Add /sys/fs/lockd


 fs/lockd/clntlock.c         |    3 
 fs/lockd/clntproc.c         |    6 -
 fs/lockd/host.c             |  319 +++++++++++++++++++++++++++++++++++++++++--
 fs/lockd/mon.c              |  253 ++++++++++++++++++++++++++++++++--
 fs/lockd/svc.c              |   31 ++++
 fs/lockd/svclock.c          |    2 
 fs/nfs/client.c             |   11 +
 fs/nfs/internal.h           |    1 
 fs/nfs/super.c              |    9 +
 include/linux/lockd/bind.h  |    1 
 include/linux/lockd/lockd.h |   19 ++-
 include/linux/nfs_fs_sb.h   |    5 +
 12 files changed, 620 insertions(+), 40 deletions(-)

-- 
Chuck Lever
