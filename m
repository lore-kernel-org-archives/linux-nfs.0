Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-vw0-f46.google.com ([209.85.212.46]:57849 "EHLO
	mail-vw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752834Ab0EKRXE (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 11 May 2010 13:23:04 -0400
Received: by vws17 with SMTP id 17so1282844vws.19
        for <linux-nfs@vger.kernel.org>; Tue, 11 May 2010 10:23:03 -0700 (PDT)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 0/6] Update NFSROOT to use text-based mounts
To: linux-nfs@vger.kernel.org
Date: Tue, 11 May 2010 13:15:44 -0400
Message-ID: <20100511170754.2167.72681.stgit@matisse.1015granger.net>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Here is a small patch set proposed for 2.6.35.

Now that the kernel NFS client does text-based mount option pro-
cessing and has its own MNT client, much of the code in nfsroot.c is
redundant.  This series converts nfsroot.c to use mainline NFS client
mount option processing, and removes the redundant code.

Note that the default mount option settings for NFSROOT change with
this series.  The defaults are now vers=3 and tcp.  There is no
longer a default mntport setting of 627 (used if the server does not
have a running portmapper).

Some additional clean-ups are included, such as updating the in-kernel
documentation for NFSROOT, and adding a new kernel command-line
parameter that enables debugging messages during NFSROOT processing.

It would be good if others who use NFSROOT on a regular basis could
review and test these changes.

---

Chuck Lever (6):
      SUNRPC: Remove rpcb_getport_sync()
      NFS: Allow NFSROOT debugging messages to be enabled dynamically
      NFS: Clean up nfsroot.c
      NFS: Use super.c for NFSROOT mount option parsing
      NFS: Clean up NFSROOT command line parsing
      NFS: Remove \t from mount debugging message


 Documentation/filesystems/nfs/nfsroot.txt |   22 +
 Documentation/kernel-parameters.txt       |    5 
 fs/nfs/mount_clnt.c                       |    2 
 fs/nfs/nfsroot.c                          |  566 +++++++++--------------------
 include/linux/nfs_fs.h                    |   10 -
 include/linux/sunrpc/clnt.h               |    1 
 init/do_mounts.c                          |   12 -
 net/sunrpc/rpcb_clnt.c                    |   51 ---
 8 files changed, 209 insertions(+), 460 deletions(-)

-- 
Chuck Lever
