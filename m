Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ua0-f178.google.com ([209.85.217.178]:38971 "EHLO
        mail-ua0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S2387942AbeGTSPh (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 20 Jul 2018 14:15:37 -0400
Received: by mail-ua0-f178.google.com with SMTP id g18-v6so7929619uam.6
        for <linux-nfs@vger.kernel.org>; Fri, 20 Jul 2018 10:26:22 -0700 (PDT)
MIME-Version: 1.0
From: Olga Kornievskaia <aglo@umich.edu>
Date: Fri, 20 Jul 2018 13:26:21 -0400
Message-ID: <CAN-5tyH75NZyiZ43_--oGOcugYiyQk=soBs5XwMq91uRX4+2hA@mail.gmail.com>
Subject: sending duplicate GETATTRs
To: Trond Myklebust <trondmy@hammerspace.com>
Cc: linux-nfs <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Trond,

I would some help understanding attributes management.

Right now, any time a directory inode that was marked with
INVALID_ACCESS (say to a change_attribute changed) ends up triggering
sending a duplicate GETATTR. I don't think that's correct.

In nfs_execute_ok() we check if (nfs_check_cache_invalid(inode,
NFS_INO_INVALID_ACCESS)) and the call __nfs_revalidate_inode() which
will trigger GETATTR. I don't understand why after calling this
function the INVALID_ACCESS doesn't get cleared? Because that's what
causes the double GETATTR to be sent.

On the open path, the first time the getattr is sent is in

Jul 19 15:39:52 ipa18 kernel: dump_stack+0x5a/0x73
Jul 19 15:39:52 ipa18 kernel: nfs4_proc_getattr+0x65/0x110 [nfsv4]
Jul 19 15:39:52 ipa18 kernel: __nfs_revalidate_inode+0xe1/0x370 [nfs]
Jul 19 15:39:52 ipa18 kernel: nfs_permission+0x16b/0x1f0 [nfs]
Jul 19 15:39:52 ipa18 kernel: inode_permission+0xab/0x130
Jul 19 15:39:52 ipa18 kernel: link_path_walk+0x29d/0x520
Jul 19 15:39:52 ipa18 kernel: path_openat+0xf6/0x1230
Jul 19 15:39:52 ipa18 kernel: do_filp_open+0x91/0x100
Jul 19 15:39:52 ipa18 kernel: do_sys_open+0x126/0x210
Jul 19 15:39:52 ipa18 kernel: do_syscall_64+0x55/0x180
Jul 19 15:39:52 ipa18 kernel: entry_SYSCALL_64_after_hwframe+0x44/0xa9

And then again during the open

Jul 19 15:39:52 ipa18 kernel: dump_stack+0x5a/0x73
Jul 19 15:39:52 ipa18 kernel: nfs4_proc_getattr+0x65/0x110 [nfsv4]
Jul 19 15:39:52 ipa18 kernel: __nfs_revalidate_inode+0xe1/0x370 [nfs]
Jul 19 15:39:52 ipa18 kernel: nfs_permission+0x16b/0x1f0 [nfs]
Jul 19 15:39:52 ipa18 kernel: inode_permission+0xab/0x130
Jul 19 15:39:52 ipa18 kernel: path_openat+0x942/0x1230
Jul 19 15:39:52 ipa18 kernel: do_filp_open+0x91/0x100
Jul 19 15:39:52 ipa18 kernel: do_sys_open+0x126/0x210
Jul 19 15:39:52 ipa18 kernel: do_syscall_64+0x55/0x180
Jul 19 15:39:52 ipa18 kernel: entry_SYSCALL_64_after_hwframe+0x44/0xa9

Can't we remove INVALID_ACCESS after we revalidated the inode? This
removes the duplicated GETATTRs. Is this a valid way of fixing this
issue?

diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
index 8f8e9e9..2b55a45 100644
--- a/fs/nfs/dir.c
+++ b/fs/nfs/dir.c
@@ -2504,6 +2504,8 @@ static int nfs_execute_ok(struct inode *inode, int mask)
                if (mask & MAY_NOT_BLOCK)
                        return -ECHILD;
                ret = __nfs_revalidate_inode(server, inode);
+               if (!ret)
+                       NFS_I(inode)->cache_validity &= ~NFS_INO_INVALID_ACCESS;
        }
        if (ret == 0 && !execute_ok(inode))
                ret = -EACCES;
