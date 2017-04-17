Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-lf0-f47.google.com ([209.85.215.47]:35208 "EHLO
        mail-lf0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753258AbdDQOdV (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 17 Apr 2017 10:33:21 -0400
Received: by mail-lf0-f47.google.com with SMTP id 75so66074361lfs.2
        for <linux-nfs@vger.kernel.org>; Mon, 17 Apr 2017 07:33:21 -0700 (PDT)
MIME-Version: 1.0
From: Daniel Hilst <daniel@versatushpc.com.br>
Date: Mon, 17 Apr 2017 11:33:19 -0300
Message-ID: <CAMGgfevu8LqcHgSLJD+rXfoSW1=rwbnkzeEWYstRA7u9R171-g@mail.gmail.com>
Subject: nfsometer NFS client not idle (check /proc/fs/nfsfs/servers)
To: linux-nfs@vger.kernel.org
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi,

I left a nfsometer running last weekend. Today I tried to get the
results but for my sadness the nfsometer can't complete the tests. It
stopped on filebench_fileserver workload. The dmesg
has some interesting messages like about the filebench tasking hanging
for more than 120 seconds. And if I try to run it again I get "NFS
client not idle" error. How can I handle this error? I don't want to
reboot before understanting what is happening.

There is some key points here. The server is a freebsd11 and the
client a centos7 (kernel 3.10). Also the server is besides an
infiniband card by using ipoib. The MTU is setted to 65K because of
ipoib.

[ 4800.645708] INFO: task filebench:4790 blocked for more than 120 seconds.
[ 4800.645758] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs"
disables this message.
[ 4800.645816] filebench       D ffff8820214e5870     0  4790   4756 0x00000080
[ 4800.645819]  ffff882030b2bc70 0000000000000082 ffff88203da40fb0
ffff882030b2bfd8
[ 4800.645823]  ffff882030b2bfd8 ffff882030b2bfd8 ffff88203da40fb0
ffff8820214e5868
[ 4800.645826]  ffff8820214e586c ffff88203da40fb0 00000000ffffffff
ffff8820214e5870
[ 4800.645830] Call Trace:
[ 4800.645835]  [<ffffffff8168cca9>] schedule_preempt_disabled+0x29/0x70
[ 4800.645839]  [<ffffffff8168a905>] __mutex_lock_slowpath+0xc5/0x1c0
[ 4800.645844]  [<ffffffff81689d6f>] mutex_lock+0x1f/0x2f
[ 4800.645847]  [<ffffffff8120cd9f>] do_last+0x28f/0x12a0
[ 4800.645852]  [<ffffffff811de4f6>] ? kmem_cache_alloc_trace+0x1d6/0x200
[ 4800.645856]  [<ffffffff8120de72>] path_openat+0xc2/0x490
[ 4800.645866]  [<ffffffffa09ac60d>] ?
nfs_attribute_cache_expired+0x2d/0x70 [nfs]
[ 4800.645869]  [<ffffffff8120ffeb>] do_filp_open+0x4b/0xb0
[ 4800.645873]  [<ffffffff8121cc67>] ? __alloc_fd+0xa7/0x130
[ 4800.645878]  [<ffffffff811fd4f3>] do_sys_open+0xf3/0x1f0
[ 4800.645882]  [<ffffffff811fd60e>] SyS_open+0x1e/0x20
[ 4800.645887]  [<ffffffff81696b09>] system_call_fastpath+0x16/0x1b


[root@centos7 ~]# nfsometer 1.2.3.4:/tank/nfsshare filebench_fileserver
> No options specified. Using default: -o v3 -o v4 -o v4.1
> Using results directory: /root/nfsometer_results
NFS client not idle (check /proc/fs/nfsfs/servers)

run "nfsometer --help" and "nfsometer examples" for more info
[root@centos7 ~]#

Best regards,
