Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qc0-f179.google.com ([209.85.216.179]:54884 "EHLO
	mail-qc0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934700AbaKNERO (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 13 Nov 2014 23:17:14 -0500
Received: by mail-qc0-f179.google.com with SMTP id c9so1673915qcz.24
        for <linux-nfs@vger.kernel.org>; Thu, 13 Nov 2014 20:17:13 -0800 (PST)
MIME-Version: 1.0
From: Steve French <smfrench@gmail.com>
Date: Thu, 13 Nov 2014 20:16:53 -0800
Message-ID: <CAH2r5mthrYxw_fD3TVwCKcxdpcgkT=MT5AmddyKDB5-c7DXwfg@mail.gmail.com>
Subject: xfstests and 3.18-rc3 nfs
To: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

I was experimenting to see how many new tests the updated xfstests
enabled and when trying it over nfs ran into a strange problem with
3.18-rc3 on nfs v3 mount

after the usual generic/035 (nlink count is 1 when should be zero)
test failure with v3
xfstest generic/036 hung with the following

[22918.651195] INFO: task aio-dio-fcntl-r:63057 blocked for more than
120 seconds.
[22918.651197]       Not tainted 3.18.0-031800rc3-generic #201411022335
[22918.651198] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs"
disables this message.
[22918.651199] aio-dio-fcntl-r D 0000000000000000     0 63057  63056 0x00000000
[22918.651202]  ffff880111c8bd08 0000000000000046 ffff88009d099648
ffffea0002742600
[22918.651205]  ffff880111c8bfd8 0000000000014640 ffff88009165bf00
0000000000014640
[22918.651207]  ffffffff81c1d4e0 ffff8800ba110a00 ffff880111c8bcf8
ffff8800808f7c50
[22918.651209] Call Trace:
[22918.651213]  [<ffffffff817a4dd9>] schedule+0x29/0x70
[22918.651216]  [<ffffffff817a50fe>] schedule_preempt_disabled+0xe/0x10
[22918.651219]  [<ffffffff817a6db5>] __mutex_lock_slowpath+0x95/0x100
[22918.651222]  [<ffffffff817a6e43>] mutex_lock+0x23/0x37
[22918.651239]  [<ffffffffc08b086b>] nfs4_file_fsync+0x6b/0xa0 [nfsv4]
[22918.651243]  [<ffffffff81216089>] vfs_fsync+0x29/0x40
[22918.651250]  [<ffffffffc07e8cea>] nfs_file_flush+0x8a/0xd0 [nfs]
[22918.651255]  [<ffffffff811e378a>] filp_close+0x3a/0x90
[22918.651261]  [<ffffffff8120303a>] put_files_struct.part.12+0x7a/0xd0
[22918.651264]  [<ffffffff812033e5>] put_files_struct+0x15/0x20
[22918.651266]  [<ffffffff812034b2>] exit_files+0x52/0x60
[22918.651269]  [<ffffffff81071811>] do_exit+0x171/0x470
[22918.651272]  [<ffffffff81071ba4>] do_group_exit+0x44/0xa0
[22918.651274]  [<ffffffff81071c17>] SyS_exit_group+0x17/0x20
[22918.651276]  [<ffffffff817a8fed>] system_call_fastpath+0x16/0x1b

Is this something recently fixed (or regressed)?  I don't see much in
the changelog in the last two weeks in fs/nfs that looks plausibly
related.

Tomorrow I will update to current (rc4) mainline and see if it goes
away - but curious if others had seen this ... (e.g. with test 036)

-- 
Thanks,

Steve
