Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from linuxhacker.ru ([217.76.32.60]:58552 "EHLO fiona.linuxhacker.ru"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751027AbcIQTQx (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Sat, 17 Sep 2016 15:16:53 -0400
Subject: Re: [PATCH v5 00/25] Fix delegation behaviour when server revokes some state
Mime-Version: 1.0 (Apple Message framework v1283)
Content-Type: text/plain; charset=windows-1252
From: Oleg Drokin <green@linuxhacker.ru>
In-Reply-To: <CCA85800-84C2-4B80-A44D-966F79EC5892@primarydata.com>
Date: Sat, 17 Sep 2016 15:16:39 -0400
Cc: Schumaker Anna <anna.schumaker@netapp.com>,
        List Linux NFS Mailing <linux-nfs@vger.kernel.org>
Message-Id: <E84E083B-293E-4990-921A-FF37C282FA15@linuxhacker.ru>
References: <1474089213-104014-1-git-send-email-trond.myklebust@primarydata.com> <838E325D-2DA1-4229-A046-76316302F813@linuxhacker.ru> <CCA85800-84C2-4B80-A44D-966F79EC5892@primarydata.com>
To: Trond Myklebust <trondmy@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Sep 17, 2016, at 2:18 PM, Trond Myklebust wrote:

> 
>> On Sep 17, 2016, at 14:04, Oleg Drokin <green@linuxhacker.ru> wrote:
>> 
>> 
>> On Sep 17, 2016, at 1:13 AM, Trond Myklebust wrote:
>> 
>>> According to RFC5661, if any of the SEQUENCE status bits
>>> SEQ4_STATUS_EXPIRED_ALL_STATE_REVOKED,
>>> SEQ4_STATUS_EXPIRED_SOME_STATE_REVOKED, SEQ4_STATUS_ADMIN_STATE_REVOKED,
>>> or SEQ4_STATUS_RECALLABLE_STATE_REVOKED are set, then we need to use
>>> TEST_STATEID to figure out which stateids have been revoked, so we
>>> can acknowledge the loss of state using FREE_STATEID.
>>> 
>>> While we already do this for open and lock state, we have not been doing
>>> so for all the delegations.
>>> 
>>> v2: nfs_v4_2_minor_ops needs to set .test_and_free_expired too
>>> v3: Now with added lock revoke fixes and close/delegreturn/locku fixes
>>> v4: Close a bunch of corner cases
>>> v5: Report revoked delegations as invalid in nfs_have_delegation()
>>>  Fix an infinite loop in nfs_reap_expired_delegations.
>>>  Fixes for other looping behaviour
>> 
>> This time around the loop seems to be more tight,
>> in userspace process:
>> 
>> [ 9197.256571] --> nfs41_call_sync_prepare data->seq_server ffff8800a73ce000
>> [ 9197.256572] --> nfs41_setup_sequence
>> [ 9197.256573] --> nfs4_alloc_slot used_slots=0000 highest_used=4294967295 max_slots=31
>> [ 9197.256574] <-- nfs4_alloc_slot used_slots=0001 highest_used=0 slotid=0
>> [ 9197.256574] <-- nfs41_setup_sequence slotid=0 seqid=14013800
>> [ 9197.256582] encode_sequence: sessionid=1474126170:1:2:0 seqid=14013800 slotid=0 max_slotid=0 cache_this=1
>> [ 9197.256755] --> nfs4_alloc_slot used_slots=0001 highest_used=0 max_slots=31
>> [ 9197.256756] <-- nfs4_alloc_slot used_slots=0003 highest_used=1 slotid=1
>> [ 9197.256757] nfs4_free_slot: slotid 1 highest_used_slotid 0
>> [ 9197.256758] nfs41_sequence_process: Error 0 free the slot 
>> [ 9197.256760] nfs4_free_slot: slotid 0 highest_used_slotid 4294967295
>> [ 9197.256779] --> nfs_put_client({2})
> 
> What operation is the userspace process hanging on? Do you have a stack trace for it?

seems to be open_create->truncate->ssetattr coming from:
cp /bin/sleep /mnt/nfs2/racer/12

(gdb) bt
#0  nfs41_setup_sequence (session=0xffff88005a853800, args=0xffff8800a7253b80, 
    res=0xffff8800a7253b48, task=0xffff8800b0eb0f00)
    at /home/green/bk/linux-test/fs/nfs/nfs4proc.c:876
#1  0xffffffff813a751c in nfs41_call_sync_prepare (task=<optimized out>, 
    calldata=0xffff8800a7253b80)
    at /home/green/bk/linux-test/fs/nfs/nfs4proc.c:966
#2  0xffffffff8185c639 in rpc_prepare_task (task=<optimized out>)
    at /home/green/bk/linux-test/net/sunrpc/sched.c:683
#3  0xffffffff8185f12b in __rpc_execute (task=0xffff88005a853800)
    at /home/green/bk/linux-test/net/sunrpc/sched.c:775
#4  0xffffffff818617b4 in rpc_execute (task=0xffff88005a853800)
    at /home/green/bk/linux-test/net/sunrpc/sched.c:843
#5  0xffffffff818539b9 in rpc_run_task (task_setup_data=0xffff8800a7253a50)
    at /home/green/bk/linux-test/net/sunrpc/clnt.c:1052
#6  0xffffffff813a75e3 in nfs4_call_sync_sequence (clnt=<optimized out>, 
    server=<optimized out>, msg=<optimized out>, args=<optimized out>, 
    res=<optimized out>) at /home/green/bk/linux-test/fs/nfs/nfs4proc.c:1051
#7  0xffffffff813b4645 in nfs4_call_sync (cache_reply=<optimized out>, 
    res=<optimized out>, args=<optimized out>, msg=<optimized out>, 
    server=<optimized out>, clnt=<optimized out>)
    at /home/green/bk/linux-test/fs/nfs/nfs4proc.c:1069
#8  _nfs4_do_setattr (state=<optimized out>, cred=<optimized out>, 
    res=<optimized out>, arg=<optimized out>, inode=<optimized out>)
---Type <return> to continue, or q <return> to quit---
    at /home/green/bk/linux-test/fs/nfs/nfs4proc.c:2916
#9  nfs4_do_setattr (inode=0xffff880079b152a8, cred=<optimized out>, 
    fattr=<optimized out>, sattr=<optimized out>, state=0xffff880060588e00, 
    ilabel=<optimized out>, olabel=0x0 <irq_stack_union>)
    at /home/green/bk/linux-test/fs/nfs/nfs4proc.c:2955
#10 0xffffffff813b4a16 in nfs4_proc_setattr (dentry=<optimized out>, 
    fattr=0xffff8800a7253b80, sattr=0xffff8800a7253b48)
    at /home/green/bk/linux-test/fs/nfs/nfs4proc.c:3684
#11 0xffffffff8138f1cb in nfs_setattr (dentry=0xffff8800740c1000, 
    attr=0xffff8800a7253ce8) at /home/green/bk/linux-test/fs/nfs/inode.c:556
#12 0xffffffff81298d6b in notify_change (dentry=0xffff8800740c1000, 
    attr=0xffff8800a7253ce8, delegated_inode=<optimized out>)
    at /home/green/bk/linux-test/fs/attr.c:285
#13 0xffffffff812734e3 in do_truncate (dentry=0xffff88005a853800, 
    length=<optimized out>, time_attrs=<optimized out>, filp=<optimized out>)
    at /home/green/bk/linux-test/fs/open.c:63
#14 0xffffffff81287459 in handle_truncate (filp=<optimized out>)
    at /home/green/bk/linux-test/fs/namei.c:2960
#15 do_last (opened=<optimized out>, op=<optimized out>, file=<optimized out>, 
    nd=<optimized out>) at /home/green/bk/linux-test/fs/namei.c:3383
#16 path_openat (nd=0xffff8800a7253de0, op=<optimized out>, 
    flags=<optimized out>) at /home/green/bk/linux-test/fs/namei.c:3497
#17 0xffffffff81288b01 in do_filp_open (dfd=<optimized out>, 
---Type <return> to continue, or q <return> to quit---
    pathname=<optimized out>, op=0xffff8800a7253ef4)
    at /home/green/bk/linux-test/fs/namei.c:3532
#18 0xffffffff81274ab0 in do_sys_open (dfd=-100, filename=<optimized out>, 
    flags=<optimized out>, mode=<optimized out>)
    at /home/green/bk/linux-test/fs/open.c:1036
#19 0xffffffff81274bbe in SYSC_open (mode=<optimized out>, 
    flags=<optimized out>, filename=<optimized out>)
    at /home/green/bk/linux-test/fs/open.c:1054
#20 SyS_open (filename=<optimized out>, flags=<optimized out>, 
    mode=<optimized out>) at /home/green/bk/linux-test/fs/open.c:1049
#21 0xffffffff8189f03c in entry_SYSCALL_64_fastpath ()
    at /home/green/bk/linux-test/arch/x86/entry/entry_64.S:207


