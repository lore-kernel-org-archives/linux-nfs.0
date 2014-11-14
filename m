Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qc0-f169.google.com ([209.85.216.169]:58028 "EHLO
	mail-qc0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752730AbaKNU23 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 14 Nov 2014 15:28:29 -0500
MIME-Version: 1.0
In-Reply-To: <CAH2r5mthrYxw_fD3TVwCKcxdpcgkT=MT5AmddyKDB5-c7DXwfg@mail.gmail.com>
References: <CAH2r5mthrYxw_fD3TVwCKcxdpcgkT=MT5AmddyKDB5-c7DXwfg@mail.gmail.com>
From: Steve French <smfrench@gmail.com>
Date: Fri, 14 Nov 2014 14:28:08 -0600
Message-ID: <CAH2r5muA=e+rw_mtfT-mwUZ2_=Zt-ByxEF5R9joRkXRRSTawGg@mail.gmail.com>
Subject: Re: xfstests and 3.18-rc3 nfs
To: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Cc: linux-fsdevel <linux-fsdevel@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Reran xfstests today on rc4 on nfsv4.1 (to unmodified Fedora 20
server) mount - still get hung testcase and dmesg entries logged
repeatedly

[ 1081.138806] INFO: task aio-dio-fcntl-r:14913 blocked for more than
120 seconds.
[ 1081.138808]       Not tainted 3.18.0-031800rc3-generic #201411022335
[ 1081.138809] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs"
disables this message.
[ 1081.138810] aio-dio-fcntl-r D 0000000000000000     0 14913  14911 0x00000000
[ 1081.138812]  ffff88005a5fbac8 0000000000000082 0000000000000000
ffff88015f5cb200
[ 1081.138814]  ffff88005a5fbfd8 0000000000014640 ffff88014ee39180
0000000000014640
[ 1081.138817]  ffff880174ed8a00 ffff88015f5cb200 ffff88005a5fbae8
ffff88006225ab10
[ 1081.138819] Call Trace:
[ 1081.138822]  [<ffffffff817a4dd9>] schedule+0x29/0x70
[ 1081.138825]  [<ffffffff817a50fe>] schedule_preempt_disabled+0xe/0x10
[ 1081.138829]  [<ffffffff817a6db5>] __mutex_lock_slowpath+0x95/0x100
[ 1081.138832]  [<ffffffff817a6e43>] mutex_lock+0x23/0x37
[ 1081.138843]  [<ffffffffc01a47e6>] nfs_file_direct_write+0xd6/0x360 [nfs]
[ 1081.138852]  [<ffffffffc01a4a8e>] nfs_direct_IO+0x1e/0x30 [nfs]
[ 1081.138855]  [<ffffffff811704bb>] generic_file_direct_write+0xbb/0x180
[ 1081.138858]  [<ffffffff81170827>] __generic_file_write_iter+0x2a7/0x350
[ 1081.138861]  [<ffffffff8117091b>] generic_file_write_iter+0x4b/0xc0
[ 1081.138868]  [<ffffffffc019aabb>] nfs_file_write+0xab/0x1c0 [nfs]
[ 1081.138877]  [<ffffffffc019aa10>] ?
nfs_revalidate_file_size.isra.20+0xa0/0xa0 [nfs]
[ 1081.138879]  [<ffffffff8122f2d6>] aio_run_iocb+0x226/0x3e0
[ 1081.138883]  [<ffffffff817a6e36>] ? mutex_lock+0x16/0x37
[ 1081.138885]  [<ffffffff8122d971>] ? aio_read_events_ring+0x1e1/0x250
[ 1081.138888]  [<ffffffff8122f583>] io_submit_one+0xf3/0x320
[ 1081.138890]  [<ffffffff8122fd14>] do_io_submit+0x104/0x1d0
[ 1081.138893]  [<ffffffff8122fdf0>] SyS_io_submit+0x10/0x20
[ 1081.138895]  [<ffffffff817a8fed>] system_call_fastpath+0x16/0x1b

On Thu, Nov 13, 2014 at 10:16 PM, Steve French <smfrench@gmail.com> wrote:
> I was experimenting to see how many new tests the updated xfstests
> enabled and when trying it over nfs ran into a strange problem with
> 3.18-rc3 on nfs v3 mount
>
> after the usual generic/035 (nlink count is 1 when should be zero)
> test failure with v3
> xfstest generic/036 hung with the following
>
> [22918.651195] INFO: task aio-dio-fcntl-r:63057 blocked for more than
> 120 seconds.
> [22918.651197]       Not tainted 3.18.0-031800rc3-generic #201411022335
> [22918.651198] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs"
> disables this message.
> [22918.651199] aio-dio-fcntl-r D 0000000000000000     0 63057  63056 0x00000000
> [22918.651202]  ffff880111c8bd08 0000000000000046 ffff88009d099648
> ffffea0002742600
> [22918.651205]  ffff880111c8bfd8 0000000000014640 ffff88009165bf00
> 0000000000014640
> [22918.651207]  ffffffff81c1d4e0 ffff8800ba110a00 ffff880111c8bcf8
> ffff8800808f7c50
> [22918.651209] Call Trace:
> [22918.651213]  [<ffffffff817a4dd9>] schedule+0x29/0x70
> [22918.651216]  [<ffffffff817a50fe>] schedule_preempt_disabled+0xe/0x10
> [22918.651219]  [<ffffffff817a6db5>] __mutex_lock_slowpath+0x95/0x100
> [22918.651222]  [<ffffffff817a6e43>] mutex_lock+0x23/0x37
> [22918.651239]  [<ffffffffc08b086b>] nfs4_file_fsync+0x6b/0xa0 [nfsv4]
> [22918.651243]  [<ffffffff81216089>] vfs_fsync+0x29/0x40
> [22918.651250]  [<ffffffffc07e8cea>] nfs_file_flush+0x8a/0xd0 [nfs]
> [22918.651255]  [<ffffffff811e378a>] filp_close+0x3a/0x90
> [22918.651261]  [<ffffffff8120303a>] put_files_struct.part.12+0x7a/0xd0
> [22918.651264]  [<ffffffff812033e5>] put_files_struct+0x15/0x20
> [22918.651266]  [<ffffffff812034b2>] exit_files+0x52/0x60
> [22918.651269]  [<ffffffff81071811>] do_exit+0x171/0x470
> [22918.651272]  [<ffffffff81071ba4>] do_group_exit+0x44/0xa0
> [22918.651274]  [<ffffffff81071c17>] SyS_exit_group+0x17/0x20
> [22918.651276]  [<ffffffff817a8fed>] system_call_fastpath+0x16/0x1b
>
> Is this something recently fixed (or regressed)?  I don't see much in
> the changelog in the last two weeks in fs/nfs that looks plausibly
> related.
>
> Tomorrow I will update to current (rc4) mainline and see if it goes
> away - but curious if others had seen this ... (e.g. with test 036)
>
> --
> Thanks,
>
> Steve



-- 
Thanks,

Steve
