Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ey0-f174.google.com ([209.85.215.174]:57861 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752793Ab0H0TBO (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 27 Aug 2010 15:01:14 -0400
Received: by eyg5 with SMTP id 5so2339496eyg.19
        for <linux-nfs@vger.kernel.org>; Fri, 27 Aug 2010 12:01:12 -0700 (PDT)
In-Reply-To: <AANLkTi=gj901aF_84+40j9MhvAwNJSNB8qRnpY8o0gBZ@mail.gmail.com>
References: <AANLkTikWR_YSnx=4=KAodATpX+xO9+hj-cf7_e158f4d@mail.gmail.com>
	<AANLkTi=gj901aF_84+40j9MhvAwNJSNB8qRnpY8o0gBZ@mail.gmail.com>
Date: Fri, 27 Aug 2010 12:01:12 -0700
Message-ID: <AANLkTinEoMgXLvN4MvfnCHjHtHCwV1HDP67BoKQ3ZbQx@mail.gmail.com>
Subject: Re: fsync/wb deadlocks in 2.6.32
From: Kian Mohageri <kian.mohageri@gmail.com>
To: davidr@ressman.org
Cc: linux-nfs@vger.kernel.org, cl@linux-foundation.com
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Fri, Aug 27, 2010 at 7:16 AM,  <davidr@ressman.org> wrote:
> Hi all,
>
> I'm guessing this is uncommon and nobody here has seen it. One of my
> friends looked through the list archives and discovered commit
> 0702099bd86c33c2dcdbd3963433a61f3f503901, which looked relevant. I
> backported it to 2.6.32.18 (if you can call anything involving a one
> line patch "backporting" :) ), and the problem has not yet returned.
>

Hi David,

Just happened upon this message.  My symptoms are a little different,
however, and I'm still investigating the possibility of a faulty drive
on the NFS server.... but thought I'd chime in anyway:

[141720.614673] INFO: task apache2:21298 blocked for more than 120 seconds.
[141720.614704] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs"
disables this message.
[141720.614749] apache2       D 0000000000000000     0 21298   1697 0x00000000
[141720.614752]  ffffffff8145b1f0 0000000000000046 0000000000000000
0000000000000000
[141720.614755]  ffff88007c80fc98 0000000000000000 000000000000f8a0
ffff88007c80ffd8
[141720.614758]  0000000000015640 0000000000015640 ffff880029b69530
ffff880029b69828
[141720.614761] Call Trace:
[141720.614764]  [<ffffffff810bb72a>] ? pagevec_lookup_tag+0x1a/0x21
[141720.614771]  [<ffffffffa03f0d54>] ?
nfs_wait_bit_uninterruptible+0x0/0xd [nfs]
[141720.614773]  [<ffffffff812f9549>] ? io_schedule+0x73/0xb7
[141720.614780]  [<ffffffffa03f0d5d>] ?
nfs_wait_bit_uninterruptible+0x9/0xd [nfs]
[141720.614783]  [<ffffffff812f9a56>] ? __wait_on_bit+0x41/0x70
[141720.614785]  [<ffffffff81190848>] ? __lookup_tag+0xad/0x11b
[141720.614792]  [<ffffffffa03f0d54>] ?
nfs_wait_bit_uninterruptible+0x0/0xd [nfs]
[141720.614795]  [<ffffffff812f9af0>] ? out_of_line_wait_on_bit+0x6b/0x77
[141720.614797]  [<ffffffff81064b28>] ? wake_bit_function+0x0/0x23
[141720.614805]  [<ffffffffa03f4cff>] ? nfs_sync_mapping_wait+0xfa/0x227 [nfs]
[141720.614812]  [<ffffffffa03f54e6>] ? nfs_write_mapping+0x69/0x8e [nfs]
[141720.614815]  [<ffffffff810cf8f5>] ? remove_vma+0x6b/0x72
[141720.614821]  [<ffffffffa03e83af>] ? nfs_do_fsync+0x1c/0x3c [nfs]
[141720.614823]  [<ffffffff810ec3ae>] ? filp_close+0x37/0x62
[141720.614826]  [<ffffffff8104f768>] ? put_files_struct+0x64/0xc1
[141720.614828]  [<ffffffff81051016>] ? do_exit+0x225/0x6b5
[141720.614831]  [<ffffffff8105151c>] ? do_group_exit+0x76/0x9d
[141720.614833]  [<ffffffff81051555>] ? sys_exit_group+0x12/0x16
[141720.614836]  [<ffffffff81010b42>] ? system_call_fastpath+0x16/0x1b
[141758.556016] nfs: server 10.20.153.68 not responding, still trying
[141758.556790] nfs: server 10.20.153.68 OK


2 clients + 1 server, all are Debian Squeeze (2.6.32-5-amd64).

Client mount options:
10.20.153.68:/ on /mnt/data type nfs4
(rw,sync,noatime,lookupcache=none,noac,addr=10.20.153.68,clientaddr=10.20.153.70)

Server:
/srv/nfs4
10.20.153.70/26(rw,sync,fsid=0,no_subtree_check,no_root_squash)


ii  nfs-common                          1:1.2.2-1
NFS support files common to client and serve
ii  nfs-kernel-server                   1:1.2.2-1
support for NFS kernel server

Seeing the same thing you are with iowait but of course, if it's the
server at fault, I might expect that.

-Kian
