Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp.gentoo.org ([140.211.166.183]:40464 "EHLO smtp.gentoo.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752470AbdKMWsl (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 13 Nov 2017 17:48:41 -0500
Subject: Re: [nfsd4] potentially hardware breaking regression in 4.14-rc and
 4.13.11
To: Linus Torvalds <torvalds@linux-foundation.org>,
        Kees Cook <keescook@chromium.org>
Cc: Emese Revfy <re.emese@gmail.com>,
        Al Viro <viro@zeniv.linux.org.uk>,
        Bruce Fields <bfields@redhat.com>,
        "Darrick J. Wong" <darrick.wong@oracle.com>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        stable <stable@vger.kernel.org>,
        Thorsten Leemhuis <regressions@leemhuis.info>,
        "kernel-hardening@lists.openwall.com"
        <kernel-hardening@lists.openwall.com>
References: <a17842c3-aae7-da98-424e-4441dd727e6d@gentoo.org>
 <CA+55aFzGDyeJctD5Y3paBnysWXbA0cMF1_7mvvzG3n2OAnNhHw@mail.gmail.com>
 <20171109193715.GB21978@ZenIV.linux.org.uk>
 <40ad7c6e-f0d7-959a-bf29-d3e3843f5d31@gentoo.org>
 <CA+55aFwqUbd5xVno7tH+yYD=yeu4nBdY=mpZQ+3fA0OEPS_WtQ@mail.gmail.com>
 <23f7da04-95f7-24e7-ee70-ce40c5b8fee3@gentoo.org>
 <CA+55aFx63wq=qN0+P+S-aahq7HzvYLi1tSxhPT9x78E8BrMNGQ@mail.gmail.com>
 <67939ef3-29c6-762c-7afe-46cc69630d95@gentoo.org>
 <ab1a286f-73dc-01aa-d797-0fef82534911@gentoo.org>
 <CA+55aFxw-ycca8+9ywckyXxH4dTggLJi5hXGdJtCQocjM86f5g@mail.gmail.com>
 <CAGXu5jL83V7hSpVLT69UTfgh3XkOsJw-S7Wc9_PQP7zGc8__rg@mail.gmail.com>
 <CA+55aFytWtipkgGtkZgzRTQqLPxG+QzJ2K9+oFdo9NVNXxB69g@mail.gmail.com>
From: Patrick McLean <chutzpah@gentoo.org>
Message-ID: <3d948180-6bd7-c4e9-5ac8-5baef9cc15a7@gentoo.org>
Date: Mon, 13 Nov 2017 14:48:38 -0800
MIME-Version: 1.0
In-Reply-To: <CA+55aFytWtipkgGtkZgzRTQqLPxG+QzJ2K9+oFdo9NVNXxB69g@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 2017-11-11 09:31 AM, Linus Torvalds wrote:
> Boris Lukashev points out that Patrick should probably check a newer
> version of gcc.
> 
> I looked around, and in one of the emails, Patrick said:
> 
>   "No changes, both the working and broken kernels were built with
>    distro-provided gcc 5.4.0 and binutils 2.28.1"
> 
> and gcc-5.4.0 is certainly not very recent. It's not _ancient_, but
> it's a bug-fix release to a pretty old branch that is not exactly new.
> 
> It would probably be good to check if the problems persist with gcc
> 6.x or 7.x.. I have no idea which gcc version the randstruct people
> tend to use themselves.

I just tested it with gcc 7.2, and was able to reproduce the NULL
pointer dereference, the backtrace looks slightly different this time.

I will also test with binutils 2.29, though I doubt that will make any
difference.

> [   56.165181] BUG: unable to handle kernel NULL pointer dereference at 0000000000000560
> [   56.166563] IP: vfs_statfs+0x7c/0xc0
> [   56.167249] PGD 0 P4D 0
> [   56.167860] Oops: 0000 [#1] SMP
> [   56.176478] Modules linked in: ipt_MASQUERADE nf_nat_masquerade_ipv4 xt_multiport xt_addrtype iptable_mangle iptable>
> [   56.180227] CPU: 0 PID: 3985 Comm: nfsd Tainted: G           O    4.14.0-git-kratos-1 #1
> [   56.181728] Hardware name: TYAN S5510/S5510, BIOS V2.02 03/12/2013
> [   56.182729] task: ffff88040c412a00 task.stack: ffffc90002c18000
> [   56.183629] RIP: 0010:vfs_statfs+0x7c/0xc0
> [   56.184341] RSP: 0018:ffffc90002c1bb28 EFLAGS: 00010202
> [   56.185143] RAX: 0000000000000000 RBX: ffffc90002c1bbf0 RCX: 0000000000000020
> [   56.186085] RDX: 0000000000001801 RSI: 0000000000001801 RDI: 0000000000000000
> [   56.187066] RBP: ffffc90002c1bbc0 R08: ffffffffffffff00 R09: 00000000000000ff
> [   56.188268] R10: 000000000038be3a R11: ffff880408b18258 R12: 0000000000000000
> [   56.189336] R13: ffff88040c23ad00 R14: ffff88040b874000 R15: ffffc90002c1bbf0
> [   56.190444] FS:  0000000000000000(0000) GS:ffff88041fc00000(0000) knlGS:0000000000000000
> [   56.191876] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> [   56.192843] CR2: 0000000000000560 CR3: 0000000001e0a002 CR4: 00000000001606f0
> [   56.193898] Call Trace:
> [   56.194510]  nfsd4_encode_fattr+0x201/0x1f90
> [   56.195267]  ? generic_permission+0x12c/0x1a0
> [   56.196025]  nfsd4_encode_getattr+0x25/0x30
> [   56.196753]  nfsd4_encode_operation+0x98/0x1b0
> [   56.197526]  nfsd4_proc_compound+0x2a0/0x5e0
> [   56.198268]  nfsd_dispatch+0xe8/0x220
> [   56.198968]  svc_process_common+0x475/0x640
> [   56.199696]  ? nfsd_destroy+0x60/0x60
> [   56.200404]  svc_process+0xf2/0x1a0
> [   56.201079]  nfsd+0xe3/0x150
> [   56.201706]  kthread+0x117/0x130
> [   56.202354]  ? kthread_create_on_node+0x40/0x40
> [   56.203100]  ret_from_fork+0x25/0x30
> [   56.203774] Code: d6 89 d6 81 ce 00 04 00 00 f6 c1 08 0f 45 d6 89 d6 81 ce 00 08 00 00 f6 c1 10 0f 45 d6 89 d6 81 ce>
> [   56.206289] RIP: vfs_statfs+0x7c/0xc0 RSP: ffffc90002c1bb28
> [   56.207110] CR2: 0000000000000560
> [   56.207763] ---[ end trace d452986a80f64aaa ]---

> On Sat, Nov 11, 2017 at 8:13 AM, Kees Cook <keescook@chromium.org> wrote:
>>
>> I'll take a closer look at this and see if I can provide something to
>> narrow it down.
