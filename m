Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-vc0-f177.google.com ([209.85.220.177]:41013 "EHLO
	mail-vc0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752507AbaJBNqA convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 2 Oct 2014 09:46:00 -0400
Received: by mail-vc0-f177.google.com with SMTP id hq11so1366341vcb.8
        for <linux-nfs@vger.kernel.org>; Thu, 02 Oct 2014 06:45:59 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <242225503.126017.1412240463629.JavaMail.zimbra@opinsys.fi>
References: <1508157147.125995.1412239112248.JavaMail.zimbra@opinsys.fi>
	<242225503.126017.1412240463629.JavaMail.zimbra@opinsys.fi>
Date: Thu, 2 Oct 2014 09:45:59 -0400
Message-ID: <CAHQdGtQPwzEcmWsZs3isrCEEJbB6n3sk0ZsPJ7k1E==e5-VE5g@mail.gmail.com>
Subject: Re: [RFC]: make nfs_wait_on_request() KILLABLE
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: =?UTF-8?B?VHVvbWFzIFLDpHPDpG5lbg==?= <tuomasjjrasanen@opinsys.fi>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Oct 2, 2014 at 5:01 AM, Tuomas Räsänen
<tuomasjjrasanen@opinsys.fi> wrote:
> Hi
>
> Before David Jefferey's commit:
>
>   92a5655 nfs: Don't busy-wait on SIGKILL in __nfs_iocounter_wait
>
> we often experienced softlockups in our systems due to busy-looping
> after SIGKILL.
>
> With that patch applied, the frequency of softlockups has decreased
> but they are not completely gone. Now softlockups happen with
> following kind of call traces:
>
>  [<c1045c27>] ? kvm_clock_get_cycles+0x17/0x20
>  [<c10b2028>] ? ktime_get_ts+0x48/0x140
>  [<f8b77be0>] ? nfs_free_request+0x90/0x90 [nfs]
>  [<c1656fb6>] io_schedule+0x86/0x100
>  [<f8b77bed>] nfs_wait_bit_uninterruptible+0xd/0x20 [nfs]
>  [<c16572d1>] __wait_on_bit+0x51/0x70
>  [<f8b77be0>] ? nfs_free_request+0x90/0x90 [nfs]
>  [<f8b77be0>] ? nfs_free_request+0x90/0x90 [nfs]
>  [<c165734b>] out_of_line_wait_on_bit+0x5b/0x70
>  [<c1091470>] ? autoremove_wake_function+0x40/0x40
>  [<f8b77f3e>] nfs_wait_on_request+0x2e/0x30 [nfs]
>  [<f8b7c5ae>] nfs_updatepage+0x11e/0x7d0 [nfs]
>  [<f8b7b15b>] ? nfs_page_find_request+0x3b/0x50 [nfs]
>  [<f8b7c41d>] ? nfs_flush_incompatible+0x6d/0xe0 [nfs]
>  [<f8b6f1a0>] nfs_write_end+0x110/0x280 [nfs]
>  [<c10503f2>] ? kmap_atomic_prot+0xe2/0x100
>  [<c1050283>] ? __kunmap_atomic+0x63/0x80
>  [<c1121e52>] generic_file_buffered_write+0x132/0x210
>  [<c112362d>] __generic_file_aio_write+0x25d/0x460
>  [<f8b71df2>] ? __nfs_revalidate_inode+0x102/0x2e0 [nfs]
>  [<c1123883>] generic_file_aio_write+0x53/0x90
>  [<f8b6e267>] nfs_file_write+0xa7/0x1d0 [nfs]
>  [<c12a78eb>] ? common_file_perm+0x4b/0xe0
>  [<c11794f7>] do_sync_write+0x57/0x90
>  [<c11794a0>] ? do_sync_readv_writev+0x80/0x80
>  [<c1179975>] vfs_write+0x95/0x1b0
>  [<c117a019>] SyS_write+0x49/0x90
>  [<c165a297>] syscall_call+0x7/0x7
>  [<c1650000>] ? balance_dirty_pages.isra.18+0x390/0x4c3
>
> As I understand it, there are some outstanding requests going on which
> nfs_wait_on_request() is waiting for. For some reason, they are not
> finished in timely manner and the process is eventually killed with

Why are those outstanding requests not completing, and why would
killing the tasks that are waiting for that completion help?

> SIGKILL by admin. However, nfs_wait_on_request() has set the task
> state TASK_UNINTERRUPTIBLE and it does not get killed.
>
> Why nfs_wait_on_request() is UNINTERRUPTIBLE instead of KILLABLE?

Please see the changelog entry in
https://git.kernel.org/cgit/linux/kernel/git/torvalds/linux.git/commit/?id=9f557cd80731

Cheers
  Trond

-- 
Trond Myklebust

Linux NFS client maintainer, PrimaryData

trond.myklebust@primarydata.com
