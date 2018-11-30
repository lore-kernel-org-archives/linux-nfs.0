Return-Path: <SRS0=T1LL=OJ=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 436BCC64EB4
	for <linux-nfs@archiver.kernel.org>; Fri, 30 Nov 2018 14:44:06 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 0B69220863
	for <linux-nfs@archiver.kernel.org>; Fri, 30 Nov 2018 14:44:06 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0B69220863
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726615AbeLABxh (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Fri, 30 Nov 2018 20:53:37 -0500
Received: from mx1.redhat.com ([209.132.183.28]:59838 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1726685AbeLABxh (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 30 Nov 2018 20:53:37 -0500
Received: from smtp.corp.redhat.com (int-mx01.intmail.prod.int.phx2.redhat.com [10.5.11.11])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by mx1.redhat.com (Postfix) with ESMTPS id 317E9394D3F;
        Fri, 30 Nov 2018 14:44:04 +0000 (UTC)
Received: from coeurl.usersys.redhat.com (ovpn-120-28.rdu2.redhat.com [10.10.120.28])
        by smtp.corp.redhat.com (Postfix) with ESMTP id AF030649DC;
        Fri, 30 Nov 2018 14:44:03 +0000 (UTC)
Received: by coeurl.usersys.redhat.com (Postfix, from userid 1000)
        id 313702078D; Fri, 30 Nov 2018 09:44:03 -0500 (EST)
From:   Scott Mayhew <smayhew@redhat.com>
To:     trond.myklebust@hammerspace.com, anna.schumaker@netapp.com
Cc:     linux-nfs@vger.kernel.org
Subject: [PATCH 0/1] NFSv4: fix "Lock reclaim failed" false positives
Date:   Fri, 30 Nov 2018 09:44:02 -0500
Message-Id: <20181130144403.31621-1-smayhew@redhat.com>
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.11
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.38]); Fri, 30 Nov 2018 14:44:04 +0000 (UTC)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

I've been doing a lot of server restarts in my testing lately, and I
typically see "Lock reclaim failed" warnings logged on the client after
a server restart.  For example, restarting the server while running the 
locking tests from cthon will usually trigger the warning.  But the test
runs to completion and there's no indication of any failures in a
tcpdump.

I modified the warning to add some more data and added a BUG() so I
could poke around.  It looks like the warnings stem from the fact that
an nfs4_lock_state has a longer lifetime than the file_lock that it
corresponds to.  Here are two examples.

In the first vmcore, there was a task that was in the process of acquiring a
lock when the recovery started.

crash> log | grep JSM
[  211.483875] JSM: nfs4_reclaim_open_state: owner: ffff940adfd43c00 state: ffff940aed5cc9c0 lock: ffff940ae5eaca00

crash> px &((struct nfs4_state *)0xffff940aed5cc9c0)->lock_states
$5 = (struct list_head *) 0xffff940aed5cc9e0

crash> list -H 0xffff940aed5cc9e0 -o nfs4_lock_state.ls_locks -s nfs4_lock_state.ls_flags,ls_stateid
ffff940ae5eaca00
  ls_flags = 0 <----- NFS_LOCK_INITIALIZED bit is clear
  ls_stateid = {
    {
      data = "\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000", 
      {
        seqid = 0, 
        other = "\000\000\000\000\000\000\000\000\000\000\000"
      }
    }, 
    type = NFS4_INVALID_STATEID_TYPE
  }
ffff940adfd40000
  ls_flags = 1
  ls_stateid = {
    {
      data = "\000\000\000\001\257\330\355[(\300\226\251\001\000\000", 
      {
        seqid = 16777216, 
        other = "\257\330\355[(\300\226\251\001\000\000"
      }
    }, 
    type = NFS4_LOCK_STATEID_TYPE
  }

crash> nfs4_state.inode ffff940aed5cc9c0
  inode = 0xffff940adfb7fd20
crash> inode.i_flctx 0xffff940adfb7fd20
  i_flctx = 0xffff940af85a4460
crash> px &((struct file_lock_context *)0xffff940af85a4460)->flc_posix
$6 = (struct list_head *) 0xffff940af85a4478
crash> list -H 0xffff940af85a4478 -o file_lock.fl_list
ffff940af3f8a640
crash> px &((struct file_lock_context *)0xffff940af85a4460)->flc_flock
$7 = (struct list_head *) 0xffff940af85a4468
crash> list -H 0xffff940af85a4468 -o file_lock.fl_list
(empty)

crash> px ((struct file_lock *)0xffff940af3f8a640)->fl_u.nfs4_fl.owner
$8 = (struct nfs4_lock_state *) 0xffff940adfd40000

So the inode's file_lock_context has a single posix lock, whose owner
corresponds to the nfs4_lock_state with type NFS4_LOCK_STATEID_TYPE and
NFS_LOCK_INITIALIZED set in the ls_flags.

What about the other nfs4_lock_state?

Here's a task that was in the process of acquiring a lock:

crash> bt
PID: 7477   TASK: ffff940ae196dd00  CPU: 1   COMMAND: "tlocklfs"
 #0 [ffffb6e8c2c1bb68] __schedule at ffffffff8190c273
 #1 [ffffb6e8c2c1bbf8] schedule at ffffffff8190c8a8
 #2 [ffffb6e8c2c1bc00] locks_lock_inode_wait at ffffffff8130a201
 #3 [ffffb6e8c2c1bc50] nfs4_proc_setlk at ffffffffc08b4e50 [nfsv4]
 #4 [ffffb6e8c2c1bcc0] nfs4_retry_setlk at ffffffffc08b4fc7 [nfsv4]
 #5 [ffffb6e8c2c1bd70] nfs4_proc_lock at ffffffffc08b80c2 [nfsv4]
 #6 [ffffb6e8c2c1bde0] do_setlk at ffffffffc07bbb90 [nfs]
 #7 [ffffb6e8c2c1be18] do_lock_file_wait at ffffffff81309f28
 #8 [ffffb6e8c2c1be70] fcntl_setlk at ffffffff8130afd8
 #9 [ffffb6e8c2c1beb0] do_fcntl at ffffffff812bc172
#10 [ffffb6e8c2c1bf00] __x64_sys_fcntl at ffffffff812bc78b
#11 [ffffb6e8c2c1bf38] do_syscall_64 at ffffffff8100416b
#12 [ffffb6e8c2c1bf50] entry_SYSCALL_64_after_hwframe at ffffffff81a00088
    RIP: 00007f55c4b3c414  RSP: 00007ffd5e540890  RFLAGS: 00000246
    RAX: ffffffffffffffda  RBX: 0000000000000000  RCX: 00007f55c4b3c414
    RDX: 00007ffd5e540930  RSI: 0000000000000007  RDI: 0000000000000009
    RBP: 00007ffd5e540960   R8: 0000000000000009   R9: 0000000000000000
    R10: 00000000000001b6  R11: 0000000000000246  R12: 0000000000400f30
    R13: 00007ffd5e540b70  R14: 0000000000000000  R15: 0000000000000000
    ORIG_RAX: 0000000000000048  CS: 0033  SS: 002b

Find the file_lock:

crash> dis -lr ffffffff8130afd8
...
/usr/src/debug/kernel-4.18.fc28/linux-4.18.18-200.fc28.x86_64/fs/locks.c: 2215
0xffffffff8130afc2 <fcntl_setlk+146>:   test   %eax,%eax
0xffffffff8130afc4 <fcntl_setlk+148>:   jne    0xffffffff8130b092 <fcntl_setlk+354>
0xffffffff8130afca <fcntl_setlk+154>:   mov    %rbx,%rdx <-----file_lock
0xffffffff8130afcd <fcntl_setlk+157>:   mov    %r12d,%esi
0xffffffff8130afd0 <fcntl_setlk+160>:   mov    %rbp,%rdi
0xffffffff8130afd3 <fcntl_setlk+163>:   callq  0xffffffff81309ef0 <do_lock_file_wait>
0xffffffff8130afd8 <fcntl_setlk+168>:   mov    %eax,%r15d

crash> dis -l do_lock_file_wait
/usr/src/debug/kernel-4.18.fc28/linux-4.18.18-200.fc28.x86_64/fs/locks.c: 2209
0xffffffff81309ef0 <do_lock_file_wait>: nopl   0x0(%rax,%rax,1) [FTRACE NOP]
0xffffffff81309ef5 <do_lock_file_wait+5>:       push   %r13
0xffffffff81309ef7 <do_lock_file_wait+7>:       mov    %rdi,%r13
0xffffffff81309efa <do_lock_file_wait+10>:      push   %r12
0xffffffff81309efc <do_lock_file_wait+12>:      mov    %esi,%r12d
0xffffffff81309eff <do_lock_file_wait+15>:      push   %rbp
0xffffffff81309f00 <do_lock_file_wait+16>:      push   %rbx <-----file_lock

crash> bt -f
...
 #7 [ffffb6e8c2c1be18] do_lock_file_wait at ffffffff81309f28
    ffffb6e8c2c1be20: ffffffff8190caf5 00a3da2d34adeb00 
    ffffb6e8c2c1be30: ffffffff822c3148 0000000000000001 
    ffffb6e8c2c1be40: ffff940ada22e300 00a3da2d34adeb00 
    ffffb6e8c2c1be50: ffff940af3f8aa28 ffff940ada22e300
                      ^^^file_lock 
    ffffb6e8c2c1be60: 0000000000000007 ffffb6e8c2c1beb8 
    ffffb6e8c2c1be70: ffffffff8130afd8 
 #8 [ffffb6e8c2c1be70] fcntl_setlk at ffffffff8130afd8
...

crash> px &((struct file_lock *)0xffff940af3f8aa28)->fl_list
$9 = (struct list_head *) 0xffff940af3f8aa30
crash> list -H 0xffff940af3f8aa30 -o file_lock.fl_list
(empty)

The fl_list is empty, so this file_lock is not on any file_lock_context's
lists.

crash> px ((struct file_lock *)0xffff940af3f8aa28)->fl_u.nfs4_fl.owner
$10 = (struct nfs4_lock_state *) 0xffff940ae5eaca00

This owner matches the nfs4_lock_state with type NFS4_INVALID_STATEID_TYPE
and with the NFS_LOCK_INITIALIZED bit clear in ls_flags.

--------------------

In the second vmcore, there was a task that was in the process of releasing a
lock when the recovery started.

crash> log | grep JSM
[ 7866.014210] JSM: nfs4_reclaim_open_state: owner: ffff8b7b767f5e00 state: ffff8b7b41220900 lock: ffff8b7b767f6400

crash> px &((struct nfs4_state *)0xffff8b7b41220900)->lock_states
$11 = (struct list_head *) 0xffff8b7b41220920

crash> list -H 0xffff8b7b41220920 -o nfs4_lock_state.ls_locks -s nfs4_lock_state.ls_flags,ls_stateid,ls_owner
ffff8b7b767f6400
  ls_flags = 0x0 <---- NFS_LOCK_INITIALIZED bit is clear
  ls_stateid = {
    {
      data = "\000\000\000\001n\367\355[\316_\177\203\006\003\000", 
      {
        seqid = 0x1000000, 
        other = "n\367\355[\316_\177\203\006\003\000"
      }
    }, 
    type = NFS4_LOCK_STATEID_TYPE
  }
  ls_owner = 0xffff8b7b74855d80

crash> nfs4_state.inode ffff8b7b41220900
  inode = 0xffff8b7b6d75f4a0

crash> inode.i_flctx 0xffff8b7b6d75f4a0
  i_flctx = 0xffff8b7b769a4ce8

Both the posix and the flock lists on the inode's file_lock_context were empty:

crash> px &((struct file_lock_context *)0xffff8b7b769a4ce8)->flc_posix
$12 = (struct list_head *) 0xffff8b7b769a4d00

crash> list -H 0xffff8b7b769a4d00 -o file_lock.fl_list
(empty)

crash> px &((struct file_lock_context *)0xffff8b7b769a4ce8)->flc_flock
$13 = (struct list_head *) 0xffff8b7b769a4cf0

crash> list -H 0xffff8b7b769a4cf0 -o file_lock.fl_list
(empty)

This was the task that was releasing a lock.

crash> bt
PID: 6133   TASK: ffff8b7b3ea19f00  CPU: 1   COMMAND: "tlock64"
 #0 [ffff9a0682c8ba20] __schedule at ffffffff8190c273
 #1 [ffff9a0682c8bab0] schedule at ffffffff8190c8a8
 #2 [ffff9a0682c8bab8] rpc_wait_bit_killable at ffffffffc04e8bbe [sunrpc]
 #3 [ffff9a0682c8bad0] __wait_on_bit at ffffffff8190ccdc
 #4 [ffff9a0682c8bb08] out_of_line_wait_on_bit at ffffffff8190cd81
 #5 [ffff9a0682c8bb58] nfs4_proc_lock at ffffffffc070d1c9 [nfsv4]
 #6 [ffff9a0682c8bbc8] locks_remove_posix at ffffffff8130a065
 #7 [ffff9a0682c8bcb8] filp_close at ffffffff812a3f00
 #8 [ffff9a0682c8bcd8] put_files_struct at ffffffff812c8b3c
 #9 [ffff9a0682c8bd10] do_exit at ffffffff810b3284
#10 [ffff9a0682c8bd90] do_group_exit at ffffffff810b3b9a
#11 [ffff9a0682c8bdb8] get_signal at ffffffff810bfed6
#12 [ffff9a0682c8be10] do_signal at ffffffff810254e6
#13 [ffff9a0682c8bf20] exit_to_usermode_loop at ffffffff81003e11
#14 [ffff9a0682c8bf38] do_syscall_64 at ffffffff8100425d
#15 [ffff9a0682c8bf50] entry_SYSCALL_64_after_hwframe at ffffffff81a00088
    RIP: 00007f0af7b7d704  RSP: 00007ffdb021b2c8  RFLAGS: 00000246
    RAX: fffffffffffffdfc  RBX: ffffffffffffff80  RCX: 00007f0af7b7d704
    RDX: 0000000000000000  RSI: 00007ffdb021b2d0  RDI: 00007ffdb021b2d0
    RBP: 0000000000000016   R8: 00007f0af7e728c0   R9: 00007f0af841c740
    R10: 00007f0af82261c0  R11: 0000000000000246  R12: 0000000000400f40
    R13: 00007ffdb021b560  R14: 0000000000000000  R15: 0000000000000000
    ORIG_RAX: 0000000000000023  CS: 0033  SS: 002b

The file_lock is on the stack in locks_remove_posix, but I'm more interested
in the fl_owner_t since I can compare that to the nfs4_lock_state->ls_owner,
so let's find that.

crash> dis -lr ffffffff812a3f00
...
/usr/src/debug/kernel-4.18.fc28/linux-4.18.18-200.fc28.x86_64/fs/open.c: 1182
0xffffffff812a3ef5 <filp_close+0x45>:   mov    %rbp,%rsi <-----fl_owner_t
0xffffffff812a3ef8 <filp_close+0x48>:   mov    %rbx,%rdi
0xffffffff812a3efb <filp_close+0x4b>:   callq  0xffffffff81309fb0 <locks_remove_posix>
/usr/src/debug/kernel-4.18.fc28/linux-4.18.18-200.fc28.x86_64/fs/open.c: 1184
0xffffffff812a3f00 <filp_close+0x50>:   mov    %rbx,%rdi

crash>  dis -l locks_remove_posix
/usr/src/debug/kernel-4.18.fc28/linux-4.18.18-200.fc28.x86_64/fs/locks.c: 2473
0xffffffff81309fb0 <locks_remove_posix>:        nopl   0x0(%rax,%rax,1) [FTRACE NOP]
0xffffffff81309fb5 <locks_remove_posix+0x5>:    push   %r12
0xffffffff81309fb7 <locks_remove_posix+0x7>:    push   %rbp <-----fl_owner_t
0xffffffff81309fb8 <locks_remove_posix+0x8>:    push   %rbx
0xffffffff81309fb9 <locks_remove_posix+0x9>:    sub    $0xd0,%rsp
0xffffffff81309fc0 <locks_remove_posix+0x10>:   mov    %gs:0x28,%rax
0xffffffff81309fc9 <locks_remove_posix+0x19>:   mov    %rax,0xc8(%rsp)
0xffffffff81309fd1 <locks_remove_posix+0x21>:   xor    %eax,%eax

crash> bt -f
...
 #6 [ffff9a0682c8bbc8] locks_remove_posix at ffffffff8130a065
    ffff9a0682c8bbd0: ffffffff811ffd2b c15433ce12497000 
    ffff9a0682c8bbe0: 0000000000000000 0000000000000000 
    ffff9a0682c8bbf0: 0000000000000000 ffffffffc0620664 
    ffff9a0682c8bc00: ffff8b7b75b4c2f0 ffff8b7b74855d80 
    ffff9a0682c8bc10: ffff9a0200000051 ffff8b7b000017f5 
    ffff9a0682c8bc20: ffff8b7b6d75f3c0 0000000000000000 
    ffff9a0682c8bc30: 0000000000000000 ffff8b7b72879500 
    ffff9a0682c8bc40: 0000000000000000 7fffffffffffffff 
    ffff9a0682c8bc50: ffff8b7b767e5400 ffff8b7b72879500 
    ffff9a0682c8bc60: ffff8b7b6d75f4a0 ffffffffc073c420 
    ffff9a0682c8bc70: 0000000000000000 ffff8b7b767f6400 
    ffff9a0682c8bc80: 0000000082c8bc88 ffff8b7b72879500 
    ffff9a0682c8bc90: ffff8b7b74855d80 c15433ce12497000 
    ffff9a0682c8bca0: ffff8b7b72879500 ffff8b7b74855d80 
                                       ^^^fl_owner_t
    ffff9a0682c8bcb0: 0000000000000000 ffffffff812a3f00 
 #7 [ffff9a0682c8bcb8] filp_close at ffffffff812a3f00
...

The fl_owner is ffff8b7b74855d80 which matches ls_owner of the nfs4_lock_state
that would have triggered the "Lock reclaim failed" error message.


Scott Mayhew (1):
  NFSv4: fix "Lock reclaim failed" false positives

 fs/nfs/nfs4_fs.h   | 1 +
 fs/nfs/nfs4state.c | 7 ++++++-
 2 files changed, 7 insertions(+), 1 deletion(-)

-- 
2.17.1

