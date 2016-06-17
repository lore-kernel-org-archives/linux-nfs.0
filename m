Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from linuxhacker.ru ([217.76.32.60]:45822 "EHLO fiona.linuxhacker.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750877AbcFQEJg convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 17 Jun 2016 00:09:36 -0400
From: Oleg Drokin <green@linuxhacker.ru>
Content-Type: text/plain; charset=us-ascii
Subject: More parallel atomic_open/d_splice_alias fun with NFS and possibly more FSes.
Date: Fri, 17 Jun 2016 00:09:19 -0400
Message-Id: <F861E78B-00C3-4F17-A10D-C9FCB81D43B9@linuxhacker.ru>
Cc: linux-nfs@vger.kernel.org, Mailing List <linux-kernel@vger.kernel.org>,
        "<linux-fsdevel@vger.kernel.org>" <linux-fsdevel@vger.kernel.org>,
        idryomov@gmail.com, sage@redhat.com, zyan@redhat.com
To: Al Viro <viro@ZenIV.linux.org.uk>,
        Trond Myklebust <trond.myklebust@primarydata.com>
Mime-Version: 1.0 (Apple Message framework v1283)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hello!

   So I think I finally kind of understand this other d_splice_alias problem
   I've been having.

   Imagine that we have a negative dentry in the cache.

   Now we have two threads that are trying to open this file in parallel,
   the fs is NFS, so atomic_open is defined, it's not a create, so
   parent is locked in shared mode and they both enter first lookup_open
   and then (because the dentry is negative) into nfs_atomic_open().

   Now in nfs_atomic_open we have two threads that run alongside each other
   trying to open this file and both fail (the code is with Al's earlier patch
   for the other d_splice_alias problem).

        inode = NFS_PROTO(dir)->open_context(dir, ctx, open_flags, &attr, opened);
        if (IS_ERR(inode)) {
                err = PTR_ERR(inode);
                trace_nfs_atomic_open_exit(dir, ctx, open_flags, err);
                put_nfs_open_context(ctx);
                d_drop(dentry);
. . .
                case -ENOTDIR:
                        goto no_open;
. . .
no_open:
        res = nfs_lookup(dir, dentry, lookup_flags);


    So they both do d_drop(), the dentry is now unhashed, and they both
    dive into nfs_lookup().
    There eventually they both call

	res = d_splice_alias(inode, dentry);

   And so the first lucky one continues on it's merry way with a hashed dentry,
   but the other less lucky one ends up calling into d_splice_alias() with
   dentry that's already hashed and hits the very familiar assertion.

   I took a brief look into ceph and it looks like a very similar thing
   might happen there with handle_reply() for two parallel replies calling into
   ceph_fill_trace() and then splice_alias()->d_splice_alias(), since the
   unhashed check it does is not under any locks, it's unsafe, so the problem
   might be more generic than just NFS too.

   So I wonder how to best fix this? Holding some sort of dentry lock across a call
   into atomic_open in VFS? We cannot just make d_splice_alias() callers call with
   inode->i_lock held because dentry might be negative.

   I know this is really happening because I in fact have 3 threads doing the above
   described race, one luckily passing through and two hitting the assertion:
PID: 2689619  TASK: ffff8800ca740540  CPU: 6   COMMAND: "ls"
 #0 [ffff8800c6da3758] machine_kexec at ffffffff81042462
 #1 [ffff8800c6da37b8] __crash_kexec at ffffffff811365ff
 #2 [ffff8800c6da3880] __crash_kexec at ffffffff811366d5
 #3 [ffff8800c6da3898] crash_kexec at ffffffff8113671b
 #4 [ffff8800c6da38b8] oops_end at ffffffff81018cb4
 #5 [ffff8800c6da38e0] die at ffffffff8101917b
 #6 [ffff8800c6da3910] do_trap at ffffffff81015b92
 #7 [ffff8800c6da3960] do_error_trap at ffffffff81015d8b
 #8 [ffff8800c6da3a20] do_invalid_op at ffffffff810166e0
 #9 [ffff8800c6da3a30] invalid_op at ffffffff8188c91e
    [exception RIP: d_splice_alias+478]
    RIP: ffffffff8128784e  RSP: ffff8800c6da3ae8  RFLAGS: 00010286
    RAX: ffff8800d8661ab8  RBX: ffff8800d3b6b178  RCX: ffff8800ca740540
    RDX: ffffffff81382f09  RSI: ffff8800d3b6b178  RDI: ffff8800d8661ab8
    RBP: ffff8800c6da3b20   R8: 0000000000000000   R9: 0000000000000000
    R10: ffff8800ca740540  R11: 0000000000000000  R12: ffff8800d6491600
    R13: 0000000000000102  R14: ffff8800d39063d0  R15: 0000000000000000
    ORIG_RAX: ffffffffffffffff  CS: 0010  SS: 0018
#10 [ffff8800c6da3b28] nfs_lookup at ffffffff8137cd1c
#11 [ffff8800c6da3b80] nfs_atomic_open at ffffffff8137ed61
#12 [ffff8800c6da3c30] lookup_open at ffffffff8127901a
#13 [ffff8800c6da3d50] path_openat at ffffffff8127bf15
#14 [ffff8800c6da3dd8] do_filp_open at ffffffff8127d9b1
#15 [ffff8800c6da3ee0] do_sys_open at ffffffff81269f90
#16 [ffff8800c6da3f40] sys_open at ffffffff8126a09e
#17 [ffff8800c6da3f50] entry_SYSCALL_64_fastpath at ffffffff8188aebc
    RIP: 00007f92a76d4d20  RSP: 00007fff640c1160  RFLAGS: 00000206
    RAX: ffffffffffffffda  RBX: 0000000000000003  RCX: 00007f92a76d4d20
    RDX: 000055c9f5be9f50  RSI: 0000000000090800  RDI: 000055c9f5bea1d0
    RBP: 0000000000000000   R8: 000055c9f5bea340   R9: 0000000000000000
    R10: 000055c9f5bea300  R11: 0000000000000206  R12: 00007f92a800d6b0
    R13: 000055c9f5bf3000  R14: 000055c9f5bea3e0  R15: 0000000000000000
    ORIG_RAX: 0000000000000002  CS: 0033  SS: 002b

PID: 2689597  TASK: ffff880109b40bc0  CPU: 7   COMMAND: "ls"
 #0 [ffff8800c07178e0] die at ffffffff8101914e
 #1 [ffff8800c0717910] do_trap at ffffffff81015b92
 #2 [ffff8800c0717960] do_error_trap at ffffffff81015d8b
 #3 [ffff8800c0717a20] do_invalid_op at ffffffff810166e0
 #4 [ffff8800c0717a30] invalid_op at ffffffff8188c91e
    [exception RIP: d_splice_alias+478]
    RIP: ffffffff8128784e  RSP: ffff8800c0717ae8  RFLAGS: 00010286
    RAX: ffff8800d8661ab8  RBX: ffff8800d3b6b178  RCX: ffff880109b40bc0
    RDX: ffffffff81382f09  RSI: ffff8800d3b6b178  RDI: ffff8800d8661ab8
    RBP: ffff8800c0717b20   R8: 0000000000000000   R9: 0000000000000000
    R10: ffff880109b40bc0  R11: 0000000000000000  R12: ffff8800d6a29e40
    R13: 0000000000000102  R14: ffff8800d39063d0  R15: 0000000000000000
    ORIG_RAX: ffffffffffffffff  CS: 0010  SS: 0018
 #5 [ffff8800c0717b28] nfs_lookup at ffffffff8137cd1c
 #6 [ffff8800c0717b80] nfs_atomic_open at ffffffff8137ed61
 #7 [ffff8800c0717c30] lookup_open at ffffffff8127901a
 #8 [ffff8800c0717d50] path_openat at ffffffff8127bf15
 #9 [ffff8800c0717dd8] do_filp_open at ffffffff8127d9b1
#10 [ffff8800c0717ee0] do_sys_open at ffffffff81269f90
#11 [ffff8800c0717f40] sys_open at ffffffff8126a09e
#12 [ffff8800c0717f50] entry_SYSCALL_64_fastpath at ffffffff8188aebc
    RIP: 00007f5cef6f8d20  RSP: 00007ffcc98f87b0  RFLAGS: 00000202
    RAX: ffffffffffffffda  RBX: 0000000000000003  RCX: 00007f5cef6f8d20
    RDX: 000055de64230f50  RSI: 0000000000090800  RDI: 000055de642311d0
    RBP: 0000000000000000   R8: 000055de64231320   R9: 0000000000000000
    R10: 000055de64231300  R11: 0000000000000202  R12: 00007f5cf00316b0
    R13: 000055de6423a000  R14: 000055de642313c0  R15: 0000000000000000
    ORIG_RAX: 0000000000000002  CS: 0033  SS: 002b

The dentry is 0xffff8800d3b6b178 in both cases.


