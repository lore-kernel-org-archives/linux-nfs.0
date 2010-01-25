Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-out1.uio.no ([129.240.10.57]:35271 "EHLO mail-out1.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751368Ab0AYSp5 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 25 Jan 2010 13:45:57 -0500
Subject: Re: [2.6.32.3] potentially uninitialised field in
 nfs_atomic_lookup...
From: Trond Myklebust <trond.myklebust@fys.uio.no>
To: Daniel J Blueman <daniel.blueman@gmail.com>
Cc: linux-nfs@vger.kernel.org
In-Reply-To: <6278d2221001250910i41f43a27y4db92f9ef17439cc@mail.gmail.com>
References: <6278d2221001250910i41f43a27y4db92f9ef17439cc@mail.gmail.com>
Content-Type: text/plain; charset="UTF-8"
Date: Mon, 25 Jan 2010 13:45:52 -0500
Message-ID: <1264445152.3615.18.camel@localhost>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Mon, 2010-01-25 at 17:10 +0000, Daniel J Blueman wrote: 
> When booting with 2.6.32.3 x86-64 with a debug configuration including
> kmemcheck activated, I'm seeing bytes reported as uninitialised [1]
> (here with value 0x33).
> 
> This is with automount and NFS4 [2] and reproduces consistently; it
> appears to not be structure padding.
> 
> What additional information would help on this?
> 
> Daniel
> 
> --- [1]
> 
> WARNING: kmemcheck: Caught 64-bit read from uninitialized memory
> (ffff88016cc180c8)
> 
> 07000000000000003333333333333333808d7e6d0188ffff988d7e6d0188ffff
> 
>  i i i i i i i i u u u u u u u u i i i i i i i i i i i i i i i i
> 
> 
> 
> Modules linked in: nfs lockd nfs_acl auth_rpcgss netconsole configfs
> autofs4 sunrpc af_packet ipv6 msr binfmt_misc dm_mod nvram evdev
> psmouse rtc_cmos rtc_core rtc_lib e1000e piix pata_acpi
> ide_pci_generic ata_generic rng_core ext3 jbd mbcache uhci_hcd
> ohci_hcd ehci_hcd usbcore [last unloaded: microcode]
> 
>  [<ffffffffa0236d2e>] nfs_atomic_lookup+0xce/0x110 [nfs]
> 
>  [<ffffffff8113e13a>] do_lookup+0x1da/0x220
> 
>  [<ffffffff8113e5c0>] __link_path_walk+0x440/0x760
> 
>  [<ffffffff8113e937>] path_walk+0x57/0xb0
> 
>  [<ffffffff8113e9fa>] vfs_path_lookup+0x6a/0xe0
> 
>  [<ffffffffa023f370>] nfs_follow_remote_path+0x50/0x150 [nfs]
> 
>  [<ffffffffa023fe97>] nfs4_try_mount+0x77/0xd0 [nfs]
> 
>  [<ffffffffa024107b>] nfs4_get_sb+0x13b/0x320 [nfs]
> 
>  [<ffffffff81134e18>] vfs_kern_mount+0x58/0xe0
> 
>  [<ffffffff81134f0e>] do_kern_mount+0x4e/0x110
> 
>  [<ffffffff8114dd06>] do_mount+0x546/0x7c0
> 
>  [<ffffffff8114e00a>] sys_mount+0x8a/0xd0
> 
>  [<ffffffff8100be2b>] system_call_fastpath+0x16/0x1b
> 
>  [<ffffffffffffffff>] 0xffffffffffffffff
> 
> 
> --- [2]
> 
> auto.direct /net/home autofs
> rw,relatime,fd=5,pgrp=4013,timeout=300,minproto=5,maxproto=5,direct 0
> 0
> filer:/home /net/home nfs4
> rw,relatime,vers=4,rsize=1048576,wsize=1048576,namlen=255,hard,proto=tcp,port=65535,timeo=600,retrans=3,sec=sys,clientaddr=172.16.0.130,addr=172.16.0.110
> 0 0
> 
> --- [3]
> 
> /net/cluster/daniel/kernel/linux-2.6.32.3/fs/nfs/dir.c:1044
>     3cf1:       48 8b 5d e8             mov    -0x18(%rbp),%rbx
>     3cf5:       4c 8b 65 f0             mov    -0x10(%rbp),%r12
>     3cf9:       48 89 c8                mov    %rcx,%rax
>     3cfc:       4c 8b 6d f8             mov    -0x8(%rbp),%r13
>     3d00:       c9                      leaveq
>     3d01:       c3                      retq
> /net/cluster/daniel/kernel/linux-2.6.32.3/fs/nfs/dir.c:1022
>     3d02:       83 f8 ec                cmp    $0xffffffffffffffec,%eax
>     3d05:       74 19                   je     3d20 <nfs_atomic_lookup+0xc0>
>     3d07:       83 f8 fe                cmp    $0xfffffffffffffffe,%eax
>     3d0a:       74 5e                   je     3d6a <nfs_atomic_lookup+0x10a>
>     3d0c:       83 f8 d8                cmp    $0xffffffffffffffd8,%eax
>     3d0f:       90                      nop
>     3d10:       75 df                   jne    3cf1 <nfs_atomic_lookup+0x91>
> /net/cluster/daniel/kernel/linux-2.6.32.3/fs/nfs/dir.c:1031
>     3d12:       f6 83 8a 00 00 00 02    testb  $0x2,0x8a(%rbx)
>     3d19:       75 d6                   jne    3cf1 <nfs_atomic_lookup+0x91>
>     3d1b:       0f 1f 44 00 00          nopl   0x0(%rax,%rax,1)
> /net/cluster/daniel/kernel/linux-2.6.32.3/fs/nfs/dir.c:1043
>     3d20:       48 89 da                mov    %rbx,%rdx
>     3d23:       4c 89 e6                mov    %r12,%rsi
>     3d26:       4c 89 ef                mov    %r13,%rdi
>     3d29:       e8 22 fd ff ff          callq  3a50 <nfs_lookup>
>     3d2e:       48 89 c1                mov    %rax,%rcx <----
>     3d31:       eb be                   jmp    3cf1 <nfs_atomic_lookup+0x91>
> /net/cluster/daniel/kernel/linux-2.6.32.3/fs/nfs/dir.c:1014
>     3d33:       31 f6                   xor    %esi,%esi
>     3d35:       4c 89 e7                mov    %r12,%rdi
>     3d38:       e8 00 00 00 00          callq  3d3d <nfs_atomic_lookup+0xdd>
>     3d3d:       31 c9                   xor    %ecx,%ecx
>     3d3f:       eb b0                   jmp    3cf1 <nfs_atomic_lookup+0x91>
> 
> static struct dentry *nfs_atomic_lookup(struct inode *dir, struct dentry *dentr
> {
> ...
>          } else if (res != NULL)
>                 dentry = res;
> out:
>         return res;
> no_open:
>         return nfs_lookup(dir, dentry, nd);  <---
> }

I'm not sure I understand. You're saying that kmemcheck is reporting the
nfs_lookup() return value as being uninitialised?

The only place I can see such a value coming from, would be from the
calls to NFS_PROTO(dir)->lookup(), nfs_fhget() and
d_materialise_unique(). Since the return values from those calls are
tested, why isn't kmemcheck pouncing on the uninitialised fields in
those tests?

Were you also running with stack overflow checking?

Cheers
  Trond

