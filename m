Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp.gentoo.org ([140.211.166.183]:39984 "EHLO smtp.gentoo.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1757009AbdKQTDZ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 17 Nov 2017 14:03:25 -0500
From: Patrick McLean <chutzpah@gentoo.org>
Subject: Re: [nfsd4] potentially hardware breaking regression in 4.14-rc and
 4.13.11
To: Kees Cook <keescook@chromium.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
        Emese Revfy <re.emese@gmail.com>,
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
 <3d948180-6bd7-c4e9-5ac8-5baef9cc15a7@gentoo.org>
 <CAGXu5jJBnJEPoUMQJTxxHXtHEUhpvq75xqzVdXsY5cKuHoe5Mg@mail.gmail.com>
Message-ID: <09f2480f-e8e8-645b-6d94-b6ae4ca47806@gentoo.org>
Date: Fri, 17 Nov 2017 11:03:22 -0800
MIME-Version: 1.0
In-Reply-To: <CAGXu5jJBnJEPoUMQJTxxHXtHEUhpvq75xqzVdXsY5cKuHoe5Mg@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 2017-11-16 04:54 PM, Kees Cook wrote:
> On Mon, Nov 13, 2017 at 2:48 PM, Patrick McLean <chutzpah@gentoo.org> wrote:
>> On 2017-11-11 09:31 AM, Linus Torvalds wrote:
>>> Boris Lukashev points out that Patrick should probably check a newer
>>> version of gcc.
>>>
>>> I looked around, and in one of the emails, Patrick said:
>>>
>>>   "No changes, both the working and broken kernels were built with
>>>    distro-provided gcc 5.4.0 and binutils 2.28.1"
>>>
>>> and gcc-5.4.0 is certainly not very recent. It's not _ancient_, but
>>> it's a bug-fix release to a pretty old branch that is not exactly new.
>>>
>>> It would probably be good to check if the problems persist with gcc
>>> 6.x or 7.x.. I have no idea which gcc version the randstruct people
>>> tend to use themselves.
>>
>> I just tested it with gcc 7.2, and was able to reproduce the NULL
>> pointer dereference, the backtrace looks slightly different this time.
>>
>> I will also test with binutils 2.29, though I doubt that will make any
>> difference.
>>
>>> [   56.165181] BUG: unable to handle kernel NULL pointer dereference at 0000000000000560
>>> [   56.166563] IP: vfs_statfs+0x7c/0xc0
>>> [   56.167249] PGD 0 P4D 0
>>> [   56.167860] Oops: 0000 [#1] SMP
>>> [   56.176478] Modules linked in: ipt_MASQUERADE nf_nat_masquerade_ipv4 xt_multiport xt_addrtype iptable_mangle iptable>
>>> [   56.180227] CPU: 0 PID: 3985 Comm: nfsd Tainted: G           O    4.14.0-git-kratos-1 #1
>>> [   56.181728] Hardware name: TYAN S5510/S5510, BIOS V2.02 03/12/2013
>>> [   56.182729] task: ffff88040c412a00 task.stack: ffffc90002c18000
>>> [   56.183629] RIP: 0010:vfs_statfs+0x7c/0xc0
>>> [   56.184341] RSP: 0018:ffffc90002c1bb28 EFLAGS: 00010202
>>> [   56.185143] RAX: 0000000000000000 RBX: ffffc90002c1bbf0 RCX: 0000000000000020
>>> [   56.186085] RDX: 0000000000001801 RSI: 0000000000001801 RDI: 0000000000000000
>>> [   56.187066] RBP: ffffc90002c1bbc0 R08: ffffffffffffff00 R09: 00000000000000ff
>>> [   56.188268] R10: 000000000038be3a R11: ffff880408b18258 R12: 0000000000000000
>>> [   56.189336] R13: ffff88040c23ad00 R14: ffff88040b874000 R15: ffffc90002c1bbf0
>>> [   56.190444] FS:  0000000000000000(0000) GS:ffff88041fc00000(0000) knlGS:0000000000000000
>>> [   56.191876] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
>>> [   56.192843] CR2: 0000000000000560 CR3: 0000000001e0a002 CR4: 00000000001606f0
>>> [   56.193898] Call Trace:
>>> [   56.194510]  nfsd4_encode_fattr+0x201/0x1f90
>>> [   56.195267]  ? generic_permission+0x12c/0x1a0
>>> [   56.196025]  nfsd4_encode_getattr+0x25/0x30
>>> [   56.196753]  nfsd4_encode_operation+0x98/0x1b0
>>> [   56.197526]  nfsd4_proc_compound+0x2a0/0x5e0
>>> [   56.198268]  nfsd_dispatch+0xe8/0x220
>>> [   56.198968]  svc_process_common+0x475/0x640
>>> [   56.199696]  ? nfsd_destroy+0x60/0x60
>>> [   56.200404]  svc_process+0xf2/0x1a0
>>> [   56.201079]  nfsd+0xe3/0x150
>>> [   56.201706]  kthread+0x117/0x130
>>> [   56.202354]  ? kthread_create_on_node+0x40/0x40
>>> [   56.203100]  ret_from_fork+0x25/0x30
>>> [   56.203774] Code: d6 89 d6 81 ce 00 04 00 00 f6 c1 08 0f 45 d6 89 d6 81 ce 00 08 00 00 f6 c1 10 0f 45 d6 89 d6 81 ce>
>>> [   56.206289] RIP: vfs_statfs+0x7c/0xc0 RSP: ffffc90002c1bb28
>>> [   56.207110] CR2: 0000000000000560
>>> [   56.207763] ---[ end trace d452986a80f64aaa ]---
>>
>>> On Sat, Nov 11, 2017 at 8:13 AM, Kees Cook <keescook@chromium.org> wrote:
>>>>
>>>> I'll take a closer look at this and see if I can provide something to
>>>> narrow it down.
> 
> How reliable is this crash? The best idea I have to isolate it would
> be to bisect the additions of the __randomize_layout markings on
> various structures. I would start with the ones Al is most upset to
> see randomized. ;)

It's pretty reliable, once I get a bad seed I can reproduce the crash
pretty quickly.

> 
> All that said, I'd like to better understand the BIOS side of this a
> little better. In the first email in this thread, you showed two BUGs
> separated by a little time, which implies to me that the NULL deref
> and the BIOS no longer POSTing are separate (though seemingly related)
> issues. Have you had machines survive the BUG without blowing up the
> BIOS?

We had 3 machines die due to the BIOS issue (all of them pretty quickly
with the bad-seed kernel). All the dead machines had the same
motherboard model. I have not managed to reproduce the issue again on
the machine I restored via the IPMI interface, I suspect that it may be
a bug in the BIOS that was fixed in a more recent version.

> 
> I'm still trying to wrap my head around how the BIOS could be blowing
> up. I assume there's some magic memory address that is getting poked
> as a result of some struct randomization bug, so tracking that down
> should be possible assuming you can stand reflashing your BIOS across
> the bisects.

That is our theory, some magic memory address that caused an overwrite
of the flash where the BIOS code is stored. We are working under the
assumption that it was fixed in a more recent BIOS update, since I have
not managed to reproduce the issue on the resurrected machine.

> For the first step, I'd try a revert of
> 9225331b310821760f39ba55b00b8973602adbb5, which enables a large
> portion of struct randomization. If that doesn't change things, I can
> provide a series that reverts 3859a271a003aba01e45b85c9d8b355eb7bf25f9
> and then re-applies __randomize_layout one structure per patch, and
> you could bisect that?

Sure, I can bisect that.

