Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ob0-f174.google.com ([209.85.214.174]:34329 "EHLO
	mail-ob0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751622AbbI0SWJ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 27 Sep 2015 14:22:09 -0400
Received: by obbda8 with SMTP id da8so113579515obb.1
        for <linux-nfs@vger.kernel.org>; Sun, 27 Sep 2015 11:22:08 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <9143.1443358024@jrobl>
References: <9143.1443358024@jrobl>
Date: Sun, 27 Sep 2015 14:22:07 -0400
Message-ID: <CAHQdGtRjsqdHGpdFJc7AGm=gFXBdKBSPyQpvUPWJZtmwx0FypA@mail.gmail.com>
Subject: Re: v4.3-rc2, fault in sock_release via nfs_put_client
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: "J. R. Okajima" <hooanon05g@gmail.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        Linux FS-devel Mailing List <linux-fsdevel@vger.kernel.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sun, Sep 27, 2015 at 8:47 AM, J. R. Okajima <hooanon05g@gmail.com> wrote:
>
>
> Hello NFS folks,
>
> I don't know whether this is a known issue or not (since I was off from
> development for a few months), but I've got a "general protection fault:
> 0000" message from linux-4.3-rc2.
> Here are the reproducible script and the log.
> Would you check them please?
>
> Notes:
> - The script cannot reproduce the problem perfectly. Not always. But if
>   you try several times, you will able to see. On my test system, I had
>   to try a few times.
> - As far as I know, if bind-mount did not happen, then the problem did
>   not happen either. But I am not sure whether bind-mount is really the
>   trigger of this issue.
>
>
> J. R. Okajima
>
> ----------------------------------------------------------------------
> #!/bin/sh
>
> set -eu
>
> Stat() # path
> {
>         stat -f --printf="%n %T\n" $1
> }
>
> uname -a
> s=/dev/shm
> Stat $s
> c=/tmp/c
> mkdir -p $c
> showmount -e > /tmp/e
> sudo exportfs -i -o rw,async,no_subtree_check,no_root_squash,fsid=99 localhost:$s
> showmount -e | diff /tmp/e - || :
> sudo mount -t nfs localhost:$s $c
> Stat $c
> b=/tmp/b
> mkdir -p $b
> sudo mount -o bind $c $b
> Stat $b
> > $b/f
> cat /proc/mounts > /tmp/m
> sudo umount -l $b
> diff /tmp/m /proc/mounts || :
> sync
> sleep 1
> cat /proc/mounts > /tmp/m
> sudo umount -l $c
> diff /tmp/m /proc/mounts
> sudo exportfs -u localhost:$s
> showmount -e | diff /tmp/e -
> ----------------------------------------------------------------------
>
> $ sh -x ./nfs-4.3-rc2.sh
> + set -eu
> + s=/dev/shm
> + Stat /dev/shm
> + stat -f --printf=%n %T\n /dev/shm
> /dev/shm tmpfs
> + c=/tmp/c
> + mkdir -p /tmp/c
> + showmount -e
> + sudo exportfs -i -o rw,async,no_subtree_check,no_root_squash,fsid=99 localhost:/dev/shm
> + showmount -e
> + diff /tmp/e -
> 3a4
> > /dev/shm     localhost
> + :
> + sudo mount -t nfs localhost:/dev/shm /tmp/c
> + Stat /tmp/c
> + stat -f --printf=%n %T\n /tmp/c
> /tmp/c nfs
> + b=/tmp/b
> + mkdir -p /tmp/b
> + sudo mount -o bind /tmp/c /tmp/b
> + Stat /tmp/b
> + stat -f --printf=%n %T\n /tmp/b
> /tmp/b nfs
> +
> + cat /proc/mounts
> + sudo umount -l /tmp/b
> + diff /tmp/m /proc/mounts
> 26d25
> < localhost:/dev/shm /tmp/b nfs4 rw,relatime,vers=4.0,rsize=65536,wsize=65536,namlen=255,hard,proto=tcp,port=0,timeo=600,retrans=2,clientaddr=127.0.0.1,local_lock=none,addr=127.0.0.1 0 0
> + :
> + sync
> + sleep 1
> + cat /proc/mounts
> + sudo umount -l /tmp/c
> general protection fault: 0000 [#7] PREEMPT SMP
> Modules linked in: oprofile configs autofs4 nfsd [last unloaded: brd]
> CPU: 0 PID: 4325 Comm: umount.nfs Tainted: G      D         4.3.0-rc2aufsD+ #67
> Hardware name: Pegatron Pegatron/IPM41, BIOS 0001 02/05/2009
> task: ffff88002d69ea00 ti: ffff88002ca00000 task.ti: ffff88002ca00000
> RIP: 0010:[<ffffffff81643be1>]  [<ffffffff81643be1>] sock_release+0x21/0x90
> RSP: 0018:ffff88002ca03bd8  EFLAGS: 00010202
> RAX: 6b6b6b6b6b6b6b6b RBX: ffff88002812f7c0 RCX: 0000000000000000
> RDX: 0000000000000000 RSI: 0000000000000000 RDI: ffff88002812f7c0
> RBP: ffff88002ca03be8 R08: 0000000000000000 R09: 0000000000000000
> R10: 0000000000000000 R11: 0000000000000001 R12: 0000000000000000
> R13: ffff88002812f7c0 R14: ffff88002b8eeea0 R15: 0000000000000001
> FS:  00007f763d4f57e0(0000) GS:ffff88002fc00000(0000) knlGS:0000000000000000
> CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
> CR2: 0000000001176db8 CR3: 000000002d76c000 CR4: 00000000000406f0
> Stack:
>  ffff88002b870000 0000000000000000 ffff88002ca03c18 ffffffff81715afc
>  ffff88002b870000 0000000000000000 ffff88002b870000 ffff88002ca03d08
>  ffff88002ca03c38 ffffffff81715bd6 0000000000000000 ffff88002b870000
> Call Trace:
>  [<ffffffff81715afc>] xs_reset_transport+0x18c/0x250
>  [<ffffffff81715bd6>] xs_close+0x16/0x30
>  [<ffffffff81715c06>] xs_destroy+0x16/0x30
>  [<ffffffff8170fb4f>] xprt_destroy+0x6f/0x80
>  [<ffffffff81712364>] xprt_put+0x14/0x20
>  [<ffffffff8170dda4>] rpc_free_client+0x84/0xc0
>  [<ffffffff8170de3a>] rpc_release_client+0x5a/0x90
>  [<ffffffff8170df61>] rpc_shutdown_client+0xf1/0x100
>  [<ffffffff812cb4c7>] nfs_free_client+0x97/0xa0
>  [<ffffffff81312c84>] nfs4_free_client+0xa4/0xc0
>  [<ffffffff812c97e5>] nfs_put_client+0x295/0x430
>  [<ffffffff81312be0>] ? nfs4_alloc_client+0x380/0x380
>  [<ffffffff812ca80c>] nfs_free_server+0x7c/0xd0
>  [<ffffffff812d732c>] nfs_kill_super+0x2c/0x40
>  [<ffffffff811ad5f1>] deactivate_locked_super+0x51/0x90
>  [<ffffffff811ae4b4>] deactivate_super+0x84/0x90
>  [<ffffffff811d28e7>] cleanup_mnt+0x97/0xe0
>  [<ffffffff811d2982>] __cleanup_mnt+0x12/0x20
>  [<ffffffff8107e9f2>] task_work_run+0x72/0xa0
>  [<ffffffff81001d0b>] prepare_exit_to_usermode+0x10b/0x150
>  [<ffffffff811d3d95>] ? mntput_no_expire+0x5/0x2c0
>  [<ffffffff81001de6>] syscall_return_slowpath+0x96/0x2f0
>  [<ffffffff81751a71>] int_ret_from_sys_call+0x25/0x9f
> Code: 5b 5d c3 0f 1f 80 00 00 00 00 66 66 66 66 90 55 48 89 e5 48 83 ec 10 48 89 5d f0 48 89 fb 4c 89 65 f8 48 8b 47 28 48 85 c0 74 17 <4c> 8b 60 08 ff 50 10 48 c7 43 28 00 00 00 00 4c 89 e7 e8 b8 7d
> RIP  [<ffffffff81643be1>] sock_release+0x21/0x90
>  RSP <ffff88002ca03bd8>
> ---[ end trace 1bcdd4036690d082 ]---
> umount.nfs: /tmp/c: not mounted
> umount.nfs: /tmp/c: not mounted
> umount.nfs: /tmp/c: not mounted
> umount.nfs: /tmp/c: not mounted
> umount.nfs: /tmp/c: not mounted
> umount.nfs: /tmp/c: not mounted
> umount.nfs: /tmp/c: not mounted


There is a fix for this issue in v4.3-rc3. Please see
https://git.kernel.org/cgit/linux/kernel/git/torvalds/linux.git/commit/?id=79234c3db6842a3de03817211d891e0c2878f756

Cheers
  Trond
