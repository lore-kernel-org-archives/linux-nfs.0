Return-Path: linux-nfs-owner@vger.kernel.org
Received: from api.opinsys.fi ([217.112.254.4]:49551 "EHLO mail.opinsys.fi"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751158AbaJQIie convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 17 Oct 2014 04:38:34 -0400
Date: Fri, 17 Oct 2014 08:38:30 +0000 (UTC)
From: Tuomas =?utf-8?B?UsOkc8OkbmVu?= <tuomasjjrasanen@opinsys.fi>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-ID: <566943989.27100.1413535110583.JavaMail.zimbra@opinsys.fi>
In-Reply-To: <CAHQdGtQPwzEcmWsZs3isrCEEJbB6n3sk0ZsPJ7k1E==e5-VE5g@mail.gmail.com>
References: <1508157147.125995.1412239112248.JavaMail.zimbra@opinsys.fi> <242225503.126017.1412240463629.JavaMail.zimbra@opinsys.fi> <CAHQdGtQPwzEcmWsZs3isrCEEJbB6n3sk0ZsPJ7k1E==e5-VE5g@mail.gmail.com>
Subject: Re: [RFC]: make nfs_wait_on_request() KILLABLE
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

----- Original Message -----
> From: "Trond Myklebust" <trond.myklebust@primarydata.com>
> On Thu, Oct 2, 2014 at 5:01 AM, Tuomas Räsänen
> <tuomasjjrasanen@opinsys.fi> wrote:
> > Hi
> >
> > Before David Jefferey's commit:
> >
> >   92a5655 nfs: Don't busy-wait on SIGKILL in __nfs_iocounter_wait
> >
> > we often experienced softlockups in our systems due to busy-looping
> > after SIGKILL.
> >
> > With that patch applied, the frequency of softlockups has decreased
> > but they are not completely gone. Now softlockups happen with
> > following kind of call traces:
> >
> >  [<c1045c27>] ? kvm_clock_get_cycles+0x17/0x20
> >  [<c10b2028>] ? ktime_get_ts+0x48/0x140
> >  [<f8b77be0>] ? nfs_free_request+0x90/0x90 [nfs]
> >  [<c1656fb6>] io_schedule+0x86/0x100
> >  [<f8b77bed>] nfs_wait_bit_uninterruptible+0xd/0x20 [nfs]
> >  [<c16572d1>] __wait_on_bit+0x51/0x70
> >  [<f8b77be0>] ? nfs_free_request+0x90/0x90 [nfs]
> >  [<f8b77be0>] ? nfs_free_request+0x90/0x90 [nfs]
> >  [<c165734b>] out_of_line_wait_on_bit+0x5b/0x70
> >  [<c1091470>] ? autoremove_wake_function+0x40/0x40
> >  [<f8b77f3e>] nfs_wait_on_request+0x2e/0x30 [nfs]
> >  [<f8b7c5ae>] nfs_updatepage+0x11e/0x7d0 [nfs]
> >  [<f8b7b15b>] ? nfs_page_find_request+0x3b/0x50 [nfs]
> >  [<f8b7c41d>] ? nfs_flush_incompatible+0x6d/0xe0 [nfs]
> >  [<f8b6f1a0>] nfs_write_end+0x110/0x280 [nfs]
> >  [<c10503f2>] ? kmap_atomic_prot+0xe2/0x100
> >  [<c1050283>] ? __kunmap_atomic+0x63/0x80
> >  [<c1121e52>] generic_file_buffered_write+0x132/0x210
> >  [<c112362d>] __generic_file_aio_write+0x25d/0x460
> >  [<f8b71df2>] ? __nfs_revalidate_inode+0x102/0x2e0 [nfs]
> >  [<c1123883>] generic_file_aio_write+0x53/0x90
> >  [<f8b6e267>] nfs_file_write+0xa7/0x1d0 [nfs]
> >  [<c12a78eb>] ? common_file_perm+0x4b/0xe0
> >  [<c11794f7>] do_sync_write+0x57/0x90
> >  [<c11794a0>] ? do_sync_readv_writev+0x80/0x80
> >  [<c1179975>] vfs_write+0x95/0x1b0
> >  [<c117a019>] SyS_write+0x49/0x90
> >  [<c165a297>] syscall_call+0x7/0x7
> >  [<c1650000>] ? balance_dirty_pages.isra.18+0x390/0x4c3
> >
> > As I understand it, there are some outstanding requests going on which
> > nfs_wait_on_request() is waiting for. For some reason, they are not
> > finished in timely manner and the process is eventually killed with
> 
> Why are those outstanding requests not completing, and why would
> killing the tasks that are waiting for that completion help?

I, quite naively, assumed that, if the process just gets killed, all the
bad would magically go away.. (I'm in the middle of replacing
assumptions with knowledge, that is, learning).

The scenario in which we are experiencing the problem is as follows:

 - Client kernels from series 3.10, 3.12 and 3.13
 - Server kernel from series 3.10
 - NFS4.0 mounted /home, sec=krb5, lots of desktop users

Increasing IO-load on /home seems to increase the likelihood of
lockups. Unfortunately the problem is relatively rare, it might take
several days of continuous automated desktop usage. But that's obviously
way too frequent for a good production quality.

Would you have any ideas where I should look at and what could be the
potential causes of traces like that? How the problem could be
reproduced more effectively?

I'd really appreciate any help.

-- 
Tuomas
