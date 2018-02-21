Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qt0-f174.google.com ([209.85.216.174]:35011 "EHLO
        mail-qt0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751401AbeBUToO (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 21 Feb 2018 14:44:14 -0500
Received: by mail-qt0-f174.google.com with SMTP id g14so3433846qti.2
        for <linux-nfs@vger.kernel.org>; Wed, 21 Feb 2018 11:44:13 -0800 (PST)
Message-ID: <1519242250.3719.9.camel@redhat.com>
Subject: Re: question on kernel stack trace
From: David Wysochanski <dwysocha@redhat.com>
To: "Mkrtchyan, Tigran" <tigran.mkrtchyan@desy.de>,
        linux-nfs <linux-nfs@vger.kernel.org>
Date: Wed, 21 Feb 2018 14:44:10 -0500
In-Reply-To: <1894283666.7881272.1519209992729.JavaMail.zimbra@desy.de>
References: <1894283666.7881272.1519209992729.JavaMail.zimbra@desy.de>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, 2018-02-21 at 11:46 +0100, Mkrtchyan, Tigran wrote:
> On one of our nodes we got the following stack trace:
> 
> 
> Feb 19 16:55:53 nafhh kernel: updatedb      D 000000000000000f     0
> 32087  32081 0x00000080
> Feb 19 16:55:53 nafhh kernel: ffff880852d13a88 0000000000000082
> 0000000000000000 ffffffffa00bfe13
> Feb 19 16:55:53 nafhh kernel: 0000000000000050 0000000300000001
> 000d5a7576495a7a 0000000000000286
> Feb 19 16:55:53 nafhh kernel: 0000000000000286 00000001dfd51213
> ffff8810207c5068 ffff880852d13fd8
> Feb 19 16:55:53 nafhh kernel: Call Trace:
> Feb 19 16:55:53 nafhh kernel: [<ffffffffa00bfe13>] ?
> ext4_mark_inode_dirty+0x83/0x1d0 [ext4]
> Feb 19 16:55:53 nafhh kernel: [<ffffffffa029b1e4>] ?
> __rpc_sleep_on_priority+0xf4/0x330 [sunrpc]
> Feb 19 16:55:53 nafhh kernel: [<ffffffffa029a5b0>] ?
> rpc_wait_bit_killable+0x0/0xa0 [sunrpc]
> Feb 19 16:55:53 nafhh kernel: [<ffffffffa029a5f2>]
> rpc_wait_bit_killable+0x42/0xa0 [sunrpc]
> Feb 19 16:55:53 nafhh kernel: [<ffffffff8154ca7f>]
> __wait_on_bit+0x5f/0x90
> Feb 19 16:55:53 nafhh kernel: [<ffffffffa0294217>] ?
> xprt_reserve_xprt+0x87/0x110 [sunrpc]
> Feb 19 16:55:53 nafhh kernel: [<ffffffffa029a5b0>] ?
> rpc_wait_bit_killable+0x0/0xa0 [sunrpc]
> Feb 19 16:55:53 nafhh kernel: [<ffffffff8154cb28>]
> out_of_line_wait_on_bit+0x78/0x90
> Feb 19 16:55:53 nafhh kernel: [<ffffffff810a7220>] ?
> wake_bit_function+0x0/0x50
> Feb 19 16:55:53 nafhh kernel: [<ffffffffa029ab35>]
> __rpc_execute+0xf5/0x350 [sunrpc]
> Feb 19 16:55:53 nafhh kernel: [<ffffffff810a7027>] ?
> bit_waitqueue+0x17/0xd0
> Feb 19 16:55:53 nafhh kernel: [<ffffffffa029adf1>]
> rpc_execute+0x61/0xa0 [sunrpc]
> Feb 19 16:55:53 nafhh kernel: [<ffffffffa0291475>]
> rpc_run_task+0x75/0x90 [sunrpc]
> Feb 19 16:55:53 nafhh kernel: [<ffffffffa0291592>]
> rpc_call_sync+0x42/0x70 [sunrpc]
> Feb 19 16:55:53 nafhh kernel: [<ffffffffa035cf2e>]
> _nfs4_call_sync+0x3e/0x40 [nfs]
> Feb 19 16:55:53 nafhh kernel: [<ffffffffa035574c>]
> _nfs4_proc_getattr+0xac/0xc0 [nfs]
> Feb 19 16:55:53 nafhh kernel: [<ffffffffa0358796>]
> nfs4_proc_getattr+0x56/0x80 [nfs]
> Feb 19 16:55:53 nafhh kernel: [<ffffffffa033e293>]
> __nfs_revalidate_inode+0xe3/0x220 [nfs]
> Feb 19 16:55:53 nafhh kernel: [<ffffffffa033f12e>]
> nfs_getattr+0xde/0x210 [nfs]
> Feb 19 16:55:53 nafhh kernel: [<ffffffff811a0391>]
> vfs_getattr+0x51/0x80
> Feb 19 16:55:53 nafhh kernel: [<ffffffff811a01d4>] ?
> cp_new_stat+0xe4/0x100
> Feb 19 16:55:53 nafhh kernel: [<ffffffff811a0424>]
> vfs_fstatat+0x64/0xa0
> Feb 19 16:55:53 nafhh kernel: [<ffffffff811a04ce>]
> vfs_lstat+0x1e/0x20
> Feb 19 16:55:53 nafhh kernel: [<ffffffff811a04f4>]
> sys_newlstat+0x24/0x50
> Feb 19 16:55:53 nafhh kernel: [<ffffffff81556627>] ?
> system_call_after_swapgs+0x187/0x220
> Feb 19 16:55:53 nafhh kernel: [<ffffffff81556620>] ?
> system_call_after_swapgs+0x180/0x220
> Feb 19 16:55:53 nafhh kernel: [<ffffffff810eeef7>] ?
> audit_syscall_entry+0x1d7/0x200
> Feb 19 16:55:53 nafhh kernel: [<ffffffff8155660b>] ?
> system_call_after_swapgs+0x16b/0x220
> Feb 19 16:55:53 nafhh kernel: [<ffffffff81556604>] ?
> system_call_after_swapgs+0x164/0x220
> Feb 19 16:55:53 nafhh kernel: [<ffffffff815565fd>] ?
> system_call_after_swapgs+0x15d/0x220
> Feb 19 16:55:53 nafhh kernel: [<ffffffff815565f6>] ?
> system_call_after_swapgs+0x156/0x220
> Feb 19 16:55:53 nafhh kernel: [<ffffffff815565ef>] ?
> system_call_after_swapgs+0x14f/0x220
> Feb 19 16:55:53 nafhh kernel: [<ffffffff815566d6>]
> system_call_fastpath+0x16/0x1b
> Feb 19 16:55:53 nafhh kernel: [<ffffffff8155656a>] ?
> system_call_after_swapgs+0xca/0x220
> 
> 
> I am surprised, that top of the stack trace is in ext4 module. Can
> some one put a light on it?
> 

Ignore the symbols with '?' next to them as they are not reliable.

If you want to map this to code use something like 'eu-addr2line' and
see if the symbols make sense in terms of source code lines.

This looks like the process is just blocked for a long time waiting on
an NFS4 GETATTR to complete, and does not look unusual to me.

