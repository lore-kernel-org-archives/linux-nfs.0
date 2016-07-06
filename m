Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-oi0-f48.google.com ([209.85.218.48]:36715 "EHLO
	mail-oi0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754490AbcGFRq6 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 6 Jul 2016 13:46:58 -0400
Received: by mail-oi0-f48.google.com with SMTP id f189so280982928oig.3
        for <linux-nfs@vger.kernel.org>; Wed, 06 Jul 2016 10:46:58 -0700 (PDT)
Date: Wed, 6 Jul 2016 12:46:55 -0500
From: Seth Forshee <seth.forshee@canonical.com>
To: Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>
Cc: linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org,
        Tycho Andersen <tycho.andersen@canonical.com>
Subject: Hang due to nfs letting tasks freeze with locked inodes
Message-ID: <20160706174655.GD45215@ubuntu-hedt>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

We're seeing a hang when freezing a container with an nfs bind mount while
running iozone. Two iozone processes were hung with this stack trace.

 [<ffffffff81821b15>] schedule+0x35/0x80
 [<ffffffff81821dbe>] schedule_preempt_disabled+0xe/0x10
 [<ffffffff818239f9>] __mutex_lock_slowpath+0xb9/0x130
 [<ffffffff81823a8f>] mutex_lock+0x1f/0x30
 [<ffffffff8121d00b>] do_unlinkat+0x12b/0x2d0
 [<ffffffff8121dc16>] SyS_unlink+0x16/0x20
 [<ffffffff81825bf2>] entry_SYSCALL_64_fastpath+0x16/0x71

This seems to be due to another iozone thread frozen during unlink with
this stack trace:

 [<ffffffff810e9cfa>] __refrigerator+0x7a/0x140
 [<ffffffffc08e80b8>] nfs4_handle_exception+0x118/0x130 [nfsv4]
 [<ffffffffc08e9efd>] nfs4_proc_remove+0x7d/0xf0 [nfsv4]
 [<ffffffffc088a329>] nfs_unlink+0x149/0x350 [nfs]
 [<ffffffff81219bd1>] vfs_unlink+0xf1/0x1a0
 [<ffffffff8121d159>] do_unlinkat+0x279/0x2d0
 [<ffffffff8121dc16>] SyS_unlink+0x16/0x20
 [<ffffffff81825bf2>] entry_SYSCALL_64_fastpath+0x16/0x71

Since nfs is allowing the thread to be frozen with the inode locked it's
preventing other threads trying to lock the same inode from freezing. It
seems like a bad idea for nfs to be doing this.

Can nfs do something different here to prevent this? Maybe use a
non-freezable sleep and let the operation complete, or else abort the
operation and return ERESTARTSYS?

Thanks,
Seth

