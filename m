Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-pb0-f46.google.com ([209.85.160.46]:45108 "EHLO
	mail-pb0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753760Ab2HDVSB (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 4 Aug 2012 17:18:01 -0400
Received: by pbbrr13 with SMTP id rr13so333387pbb.19
        for <linux-nfs@vger.kernel.org>; Sat, 04 Aug 2012 14:18:01 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <501D3B12.5040105@netapp.com>
References: <CAJ75kXa9PRJMHXfTHGLxnXUAMwnA9RD5G+cjHnOdk8SE_hbsZQ@mail.gmail.com>
 <866.1343987269@warthog.procyon.org.uk> <CAJ75kXaYgxiRZnFzZLXSj61EXOEVNsPcy70etkLRhEpy9AWDnA@mail.gmail.com>
 <CAJ75kXbFTm3+v9OJTcKsO+nmn6q0CbSZniT0MkP+oUh7f_sZ0Q@mail.gmail.com> <501D3B12.5040105@netapp.com>
From: William Dauchy <wdauchy@gmail.com>
Date: Sat, 4 Aug 2012 23:17:40 +0200
Message-ID: <CAJ75kXYpw5ZWzkDDw2pHDwgSETWoXfcYn4XftawaknK+oqc25Q@mail.gmail.com>
Subject: Re: nfs_idmap_legacy_upcall
To: Bryan Schumaker <bjschuma@netapp.com>
Cc: David Howells <dhowells@redhat.com>,
        Trond Myklebust <Trond.Myklebust@netapp.com>,
        linux-nfs@vger.kernel.org,
        "Schumaker, Bryan" <Bryan.Schumaker@netapp.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Bryan,

On Sat, Aug 4, 2012 at 5:09 PM, Bryan Schumaker <bjschuma@netapp.com> wrote:
> What are you doing to reproduce this?  I'm having bash run mount / unmount in a loop, but so far I haven't seen the oops.  Also, are you using kerberos?

That's what I'm trying to understand because I'm note able to
reproduce it when I want (wait_for_key_construction oops).
About 300 nfs mount, each one doing I/O, after a while some
mount/umount produces the oops; but I don't know yet exactly when.
I'm not using kerberos.
I was thinking about a remaining race on the old idmaper. I'm putting
the null deference trace back in this thread as a reminder.

BUG: unable to handle kernel NULL pointer dereference at 0000000000000070
IP: [<ffffffff811a4a18>] wait_for_key_construction+0x28/0x70
PGD 2bf8de000
Oops: 0000 [#1] PREEMPT SMP
CPU 23
Pid: 25735, comm: kworker/23:2 Tainted: G        W    3.4.4 #1 Dell
Inc.  C6100           /0D61XP
RIP: 0010:[<ffffffff811a4a18>]  [<ffffffff811a4a18>]
wait_for_key_construction+0x28/0x70
RSP: 0018:ffff880b99a15a80  EFLAGS: 00010246
RAX: ffffffff811a4a70 RBX: 0000000000000000 RCX: 0000000000000002
RDX: ffffffff811a4a60 RSI: 0000000000000000 RDI: 0000000000000070
RBP: ffff8803c915e420 R08: ffff88061c877bc1 R09: 0000000000000000
R10: 0000000050159fb7 R11: 0000000000000000 R12: ffffffff816b5e49
R13: ffff880ba944ca48 R14: 0000000000000013 R15: ffff8803c915e423
FS:  0000000000000000(0000) GS:ffff880c3fd60000(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
CR2: 0000000000000070 CR3: 00000000014aa000 CR4: 00000000000007f0
DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
Process kworker/23:2 (pid: 25735, threadinfo ffff880b154a0ba0, task
ffff880b154a0750)
Stack:
0000000000000000 ffffffff811a512f 0000000000000000 ffffffff810df09d
0000000000000000 000000000000000e ffff880841b54cc0 ffffffff816c88f8
ffff8803c915e420 ffffffff81184fbb 0000000000000013 ffffffff81935c40
Call Trace:
[<ffffffff811a512f>] ? request_key+0x5f/0xa0
[<ffffffff810df09d>] ? __kmalloc+0x2d/0x120
[<ffffffff81184fbb>] ? nfs_idmap_request_key+0x1ab/0x1c0
[<ffffffff81185027>] ? nfs_idmap_get_key+0x57/0xd0
[<ffffffff811852ae>] ? nfs_map_string_to_numeric+0x3e/0xc0
[<ffffffff8118535f>] ? nfs_idmap_lookup_id+0x2f/0x80
[<ffffffff81185479>] ? nfs_map_name_to_uid+0x39/0x90
[<ffffffff8117dedb>] ? decode_getfattr_attrs+0x94b/0xa10
[<ffffffff8117f776>] ? T.1607+0x96/0xe0
[<ffffffff8117f852>] ? nfs4_xdr_dec_delegreturn+0x72/0x80
[<ffffffff8117f7e0>] ? decode_getfattr+0x20/0x20
[<ffffffff8144db39>] ? rpcauth_unwrap_resp+0x79/0x80
[<ffffffff8117f7e0>] ? decode_getfattr+0x20/0x20
[<ffffffff81445a33>] ? call_decode+0x2a3/0x400
[<ffffffff8144cf26>] ? __rpc_execute+0x46/0x1b0
[<ffffffff81050338>] ? process_one_work+0x108/0x3a0
[<ffffffff8144d0c0>] ? rpc_execute+0x30/0x30
[<ffffffff81050a21>] ? worker_thread+0x151/0x420
[<ffffffff810508d0>] ? rescuer_thread+0x300/0x300
[<ffffffff810508d0>] ? rescuer_thread+0x300/0x300
[<ffffffff81054e3e>] ? kthread+0x9e/0xb0
[<ffffffff81484774>] ? kernel_thread_helper+0x4/0x10
[<ffffffff81482a38>] ? retint_restore_args+0x6/0x6
[<ffffffff81054da0>] ? kthread_freezable_should_stop+0x60/0x60
[<ffffffff81484770>] ? gs_change+0xb/0xb
Code: 00 00 00 40 80 fe 01 53 19 c9 48 89 fb 48 c7 c0 70 4a 1a 81 f7
d1 48 c7 c2 60 4a 1a 81 83 c1 02 48 8d 7f 70 40 84 f6 48 0f 45 d0 <48>
8b 43 70 a8 10 75 20 48 8b 43 70 a8 20 74 08 8b 83 80 00 00
RIP  [<ffffffff811a4a18>] wait_for_key_construction+0x28/0x70
RSP <ffff880b99a15a80>
CR2: 0000000000000070

-- 
William
