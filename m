Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from linuxhacker.ru ([217.76.32.60]:34880 "EHLO fiona.linuxhacker.ru"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751581AbcIRQXZ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Sun, 18 Sep 2016 12:23:25 -0400
Subject: Re: [PATCH v5 00/25] Fix delegation behaviour when server revokes some state
Mime-Version: 1.0 (Apple Message framework v1283)
Content-Type: text/plain; charset=windows-1252
From: Oleg Drokin <green@linuxhacker.ru>
In-Reply-To: <E7C7924A-9C31-4D95-A2AF-63D4806D27B2@linuxhacker.ru>
Date: Sun, 18 Sep 2016 12:23:11 -0400
Cc: Schumaker Anna <anna.schumaker@netapp.com>,
        List Linux NFS Mailing <linux-nfs@vger.kernel.org>
Message-Id: <8E0CD004-8BAE-4EC0-BAA2-ED7B83F85610@linuxhacker.ru>
References: <1474089213-104014-1-git-send-email-trond.myklebust@primarydata.com> <838E325D-2DA1-4229-A046-76316302F813@linuxhacker.ru> <CCA85800-84C2-4B80-A44D-966F79EC5892@primarydata.com> <E84E083B-293E-4990-921A-FF37C282FA15@linuxhacker.ru> <1474140727.7526.1.camel@primarydata.com> <1474148731.7526.3.camel@primarydata.com> <96CBC4AF-B0EA-4AFA-8068-E93CBACD1B0B@linuxhacker.ru> <C2E081FE-712D-4B99-AE18-A2BBC33739FA@primarydata.com> <E7C7924A-9C31-4D95-A2AF-63D4806D27B2@linuxhacker.ru>
To: Trond Myklebust <trondmy@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Sep 17, 2016, at 9:19 PM, Oleg Drokin wrote:

> 
> On Sep 17, 2016, at 5:59 PM, Trond Myklebust wrote:
> 
>> 
>>> On Sep 17, 2016, at 17:55, Oleg Drokin <green@linuxhacker.ru> wrote:
>>> 
>>> 
>>> On Sep 17, 2016, at 5:45 PM, Trond Myklebust wrote:
>>> 
>>>> On Sat, 2016-09-17 at 15:32 -0400, Trond Myklebust wrote:
>>>>> On Sat, 2016-09-17 at 15:16 -0400, Oleg Drokin wrote:
>>>>>> 
>>>>>> On Sep 17, 2016, at 2:18 PM, Trond Myklebust wrote:
>>>>>> 
>>>>>>> 
>>>>>>> 
>>>>>>> 
>>>>>>>> 
>>>>>>>> 
>>>>>>>> On Sep 17, 2016, at 14:04, Oleg Drokin <green@linuxhacker.ru>
>>>>>>>> wrote:
>>>>>>>> 
>>>>>>>> 
>>>>>>>> On Sep 17, 2016, at 1:13 AM, Trond Myklebust wrote:
>>>>>>>> 
>>>>>>>>> 
>>>>>>>>> 
>>>>>>>>> According to RFC5661, if any of the SEQUENCE status bits
>>>>>>>>> SEQ4_STATUS_EXPIRED_ALL_STATE_REVOKED,
>>>>>>>>> SEQ4_STATUS_EXPIRED_SOME_STATE_REVOKED,
>>>>>>>>> SEQ4_STATUS_ADMIN_STATE_REVOKED,
>>>>>>>>> or SEQ4_STATUS_RECALLABLE_STATE_REVOKED are set, then we need
>>>>>>>>> to use
>>>>>>>>> TEST_STATEID to figure out which stateids have been revoked,
>>>>>>>>> so
>>>>>>>>> we
>>>>>>>>> can acknowledge the loss of state using FREE_STATEID.
>>>>>>>>> 
>>>>>>>>> While we already do this for open and lock state, we have not
>>>>>>>>> been doing
>>>>>>>>> so for all the delegations.
>>>>>>>>> 
>>>>>>>>> v2: nfs_v4_2_minor_ops needs to set .test_and_free_expired
>>>>>>>>> too
>>>>>>>>> v3: Now with added lock revoke fixes and
>>>>>>>>> close/delegreturn/locku fixes
>>>>>>>>> v4: Close a bunch of corner cases
>>>>>>>>> v5: Report revoked delegations as invalid in
>>>>>>>>> nfs_have_delegation()
>>>>>>>>> Fix an infinite loop in nfs_reap_expired_delegations.
>>>>>>>>> Fixes for other looping behaviour
>>>>>>>> 
>>>>>>>> This time around the loop seems to be more tight,
>>>>>>>> in userspace process:
>>>>>>>> 
>>>>>>>> [ 9197.256571] --> nfs41_call_sync_prepare data->seq_server
>>>>>>>> ffff8800a73ce000
>>>>>>>> [ 9197.256572] --> nfs41_setup_sequence
>>>>>>>> [ 9197.256573] --> nfs4_alloc_slot used_slots=0000
>>>>>>>> highest_used=4294967295 max_slots=31
>>>>>>>> [ 9197.256574] <-- nfs4_alloc_slot used_slots=0001
>>>>>>>> highest_used=0
>>>>>>>> slotid=0
>>>>>>>> [ 9197.256574] <-- nfs41_setup_sequence slotid=0 seqid=14013800
>>>>>>>> [ 9197.256582] encode_sequence: sessionid=1474126170:1:2:0
>>>>>>>> seqid=14013800 slotid=0 max_slotid=0 cache_this=1
>>>>>>>> [ 9197.256755] --> nfs4_alloc_slot used_slots=0001
>>>>>>>> highest_used=0
>>>>>>>> max_slots=31
>>>>>>>> [ 9197.256756] <-- nfs4_alloc_slot used_slots=0003
>>>>>>>> highest_used=1
>>>>>>>> slotid=1
>>>>>>>> [ 9197.256757] nfs4_free_slot: slotid 1 highest_used_slotid 0
>>>>>>>> [ 9197.256758] nfs41_sequence_process: Error 0 free the slot 
>>>>>>>> [ 9197.256760] nfs4_free_slot: slotid 0 highest_used_slotid
>>>>>>>> 4294967295
>>>>>>>> [ 9197.256779] --> nfs_put_client({2})
>>>>>>> 
>>>>>>> What operation is the userspace process hanging on? Do you have a
>>>>>>> stack trace for it?
>>>>>> 
>>>>>> seems to be open_create->truncate->ssetattr coming from:
>>>>>> cp /bin/sleep /mnt/nfs2/racer/12
>>>>>> 
>>>>>> (gdb) bt
>>>>>> #0  nfs41_setup_sequence (session=0xffff88005a853800,
>>>>>> args=0xffff8800a7253b80, 
>>>>>>  res=0xffff8800a7253b48, task=0xffff8800b0eb0f00)
>>>>>>  at /home/green/bk/linux-test/fs/nfs/nfs4proc.c:876
>>>>>> #1  0xffffffff813a751c in nfs41_call_sync_prepare (task=<optimized
>>>>>> out>, 
>>>>>>  calldata=0xffff8800a7253b80)
>>>>>>  at /home/green/bk/linux-test/fs/nfs/nfs4proc.c:966
>>>>>> #2  0xffffffff8185c639 in rpc_prepare_task (task=<optimized out>)
>>>>>>  at /home/green/bk/linux-test/net/sunrpc/sched.c:683
>>>>>> #3  0xffffffff8185f12b in __rpc_execute (task=0xffff88005a853800)
>>>>>>  at /home/green/bk/linux-test/net/sunrpc/sched.c:775
>>>>>> #4  0xffffffff818617b4 in rpc_execute (task=0xffff88005a853800)
>>>>>>  at /home/green/bk/linux-test/net/sunrpc/sched.c:843
>>>>>> #5  0xffffffff818539b9 in rpc_run_task
>>>>>> (task_setup_data=0xffff8800a7253a50)
>>>>>>  at /home/green/bk/linux-test/net/sunrpc/clnt.c:1052
>>>>>> #6  0xffffffff813a75e3 in nfs4_call_sync_sequence (clnt=<optimized
>>>>>> out>, 
>>>>>>  server=<optimized out>, msg=<optimized out>, args=<optimized
>>>>>> out>, 
>>>>>>  res=<optimized out>) at /home/green/bk/linux-
>>>>>> test/fs/nfs/nfs4proc.c:1051
>>>>>> #7  0xffffffff813b4645 in nfs4_call_sync (cache_reply=<optimized
>>>>>> out>, 
>>>>>>  res=<optimized out>, args=<optimized out>, msg=<optimized
>>>>>> out>, 
>>>>>>  server=<optimized out>, clnt=<optimized out>)
>>>>>>  at /home/green/bk/linux-test/fs/nfs/nfs4proc.c:1069
>>>>>> #8  _nfs4_do_setattr (state=<optimized out>, cred=<optimized out>, 
>>>>>>  res=<optimized out>, arg=<optimized out>, inode=<optimized
>>>>>> out>)
>>>>>> ---Type <return> to continue, or q <return> to quit---
>>>>>>  at /home/green/bk/linux-test/fs/nfs/nfs4proc.c:2916
>>>>>> #9  nfs4_do_setattr (inode=0xffff880079b152a8, cred=<optimized
>>>>>> out>, 
>>>>>>  fattr=<optimized out>, sattr=<optimized out>,
>>>>>> state=0xffff880060588e00, 
>>>>>>  ilabel=<optimized out>, olabel=0x0 <irq_stack_union>)
>>>>>>  at /home/green/bk/linux-test/fs/nfs/nfs4proc.c:2955
>>>>>> #10 0xffffffff813b4a16 in nfs4_proc_setattr (dentry=<optimized
>>>>>> out>, 
>>>>>>  fattr=0xffff8800a7253b80, sattr=0xffff8800a7253b48)
>>>>>>  at /home/green/bk/linux-test/fs/nfs/nfs4proc.c:3684
>>>>>> #11 0xffffffff8138f1cb in nfs_setattr (dentry=0xffff8800740c1000, 
>>>>>> 
>>>>> 
>>>>> Cool! Does the following help?
>>>> 
>>>> Grrr... There is another bug there…
>>> 
>>> Is this in addition to the previous patch or instead of?
>> 
>> It can apply on top of it. The two patches fix different bugs.
> 
> Ok, it does not seem to have helped:

Of the 10 nodes where I run this, I had some more failures overnight,
some of them different.

The other one I got was (I have 3 nodes in this state,
only one in the one reported yesterday.):

[65712.698123] NFS call  test_stateid ffff8800b05b1f24
[65712.698126] --> nfs41_call_sync_prepare data->seq_server ffff8800aeb16000
[65712.698127] --> nfs41_setup_sequence
[65712.698128] --> nfs4_alloc_slot used_slots=0000 highest_used=4294967295 max_slots=31
[65712.698129] <-- nfs4_alloc_slot used_slots=0001 highest_used=0 slotid=0
[65712.698129] <-- nfs41_setup_sequence slotid=0 seqid=27222672
[65712.698136] encode_sequence: sessionid=1474186002:21:22:0 seqid=27222672 slotid=0 max_slotid=0 cache_this=0
[65712.698278] --> nfs4_alloc_slot used_slots=0001 highest_used=0 max_slots=31
[65712.698279] <-- nfs4_alloc_slot used_slots=0003 highest_used=1 slotid=1
[65712.698280] nfs4_free_slot: slotid 1 highest_used_slotid 0
[65712.698281] nfs41_sequence_process: Error 0 free the slot 
[65712.698282] nfs4_free_slot: slotid 0 highest_used_slotid 4294967295
[65712.698295] NFS reply test_stateid: succeeded, 0
[65712.698301] --> nfs_put_client({3})
[65712.698333] --> nfs_put_client({2})
[65712.698337] --> nfs41_call_sync_prepare data->seq_server ffff8800aeb16000
[65712.698338] --> nfs41_setup_sequence
[65712.698339] --> nfs4_alloc_slot used_slots=0000 highest_used=4294967295 max_slots=31
[65712.698339] <-- nfs4_alloc_slot used_slots=0001 highest_used=0 slotid=0
[65712.698340] <-- nfs41_setup_sequence slotid=0 seqid=27222673
[65712.698347] encode_sequence: sessionid=1474186002:21:22:0 seqid=27222673 slotid=0 max_slotid=0 cache_this=1
[65712.698501] --> nfs4_alloc_slot used_slots=0001 highest_used=0 max_slots=31
[65712.698502] <-- nfs4_alloc_slot used_slots=0003 highest_used=1 slotid=1
[65712.698503] nfs4_free_slot: slotid 1 highest_used_slotid 0
[65712.698503] nfs41_sequence_process: Error 0 free the slot 
[65712.698504] nfs4_free_slot: slotid 0 highest_used_slotid 4294967295
[65712.698520] nfs4_schedule_stateid_recovery: scheduling stateid recovery for server localhost
[65712.698636] NFS call  test_stateid ffff8800b05b1f24
[65712.698639] --> nfs41_call_sync_prepare data->seq_server ffff8800aeb16000
[65712.698640] --> nfs41_setup_sequence
[65712.698641] --> nfs4_alloc_slot used_slots=0000 highest_used=4294967295 max_slots=31
[65712.698642] <-- nfs4_alloc_slot used_slots=0001 highest_used=0 slotid=0
[65712.698642] <-- nfs41_setup_sequence slotid=0 seqid=27222674
[65712.698649] encode_sequence: sessionid=1474186002:21:22:0 seqid=27222674 slotid=0 max_slotid=0 cache_this=0
[65712.698800] --> nfs4_alloc_slot used_slots=0001 highest_used=0 max_slots=31
[65712.698801] <-- nfs4_alloc_slot used_slots=0003 highest_used=1 slotid=1
[65712.698802] nfs4_free_slot: slotid 1 highest_used_slotid 0
[65712.698802] nfs41_sequence_process: Error 0 free the slot 
[65712.698803] nfs4_free_slot: slotid 0 highest_used_slotid 4294967295
[65712.698817] NFS reply test_stateid: succeeded, 0
[65712.698822] --> nfs_put_client({3})
[65712.698855] --> nfs_put_client({2})
[65712.698859] --> nfs41_call_sync_prepare data->seq_server ffff8800aeb16000
[65712.698860] --> nfs41_setup_sequence
[65712.698861] --> nfs4_alloc_slot used_slots=0000 highest_used=4294967295 max_slots=31
[65712.698862] <-- nfs4_alloc_slot used_slots=0001 highest_used=0 slotid=0
[65712.698863] <-- nfs41_setup_sequence slotid=0 seqid=27222675
[65712.698869] encode_sequence: sessionid=1474186002:21:22:0 seqid=27222675 slotid=0 max_slotid=0 cache_this=1
[65712.699022] --> nfs4_alloc_slot used_slots=0001 highest_used=0 max_slots=31
[65712.699023] <-- nfs4_alloc_slot used_slots=0003 highest_used=1 slotid=1
[65712.699024] nfs4_free_slot: slotid 1 highest_used_slotid 0
[65712.699025] nfs41_sequence_process: Error 0 free the slot 
[65712.699026] nfs4_free_slot: slotid 0 highest_used_slotid 4294967295
[65712.699042] nfs4_schedule_stateid_recovery: scheduling stateid recovery for server localhost


> [11397.552805] --> nfs41_call_sync_prepare data->seq_server ffff880085b17000
> [11397.552806] --> nfs41_setup_sequence
> [11397.552807] --> nfs4_alloc_slot used_slots=0000 highest_used=4294967295 max_slots=31
> [11397.552808] <-- nfs4_alloc_slot used_slots=0001 highest_used=0 slotid=0
> [11397.552809] <-- nfs41_setup_sequence slotid=0 seqid=8829382
> [11397.552817] encode_sequence: sessionid=1474153431:3:4:0 seqid=8829382 slotid=0 max_slotid=0 cache_this=1
> [11397.553032] --> nfs4_alloc_slot used_slots=0001 highest_used=0 max_slots=31
> [11397.553033] <-- nfs4_alloc_slot used_slots=0003 highest_used=1 slotid=1
> [11397.553034] nfs4_free_slot: slotid 1 highest_used_slotid 0
> [11397.553035] nfs41_sequence_process: Error 0 free the slot 
> [11397.553036] nfs4_free_slot: slotid 0 highest_used_slotid 4294967295
> [11397.553056] --> nfs_put_client({2})
> [11397.553062] --> nfs41_call_sync_prepare data->seq_server ffff880085b17000
> [11397.553063] --> nfs41_setup_sequence
> [11397.553064] --> nfs4_alloc_slot used_slots=0000 highest_used=4294967295 max_slots=31
> [11397.553065] <-- nfs4_alloc_slot used_slots=0001 highest_used=0 slotid=0
> [11397.553066] <-- nfs41_setup_sequence slotid=0 seqid=8829383
> [11397.553074] encode_sequence: sessionid=1474153431:3:4:0 seqid=8829383 slotid=0 max_slotid=0 cache_this=1
> [11397.553290] --> nfs4_alloc_slot used_slots=0001 highest_used=0 max_slots=31
> [11397.553291] <-- nfs4_alloc_slot used_slots=0003 highest_used=1 slotid=1
> [11397.553292] nfs4_free_slot: slotid 1 highest_used_slotid 0
> [11397.553293] nfs41_sequence_process: Error 0 free the slot 
> [11397.553294] nfs4_free_slot: slotid 0 highest_used_slotid 4294967295
> [11397.553316] --> nfs_put_client({2})
> [11397.553322] --> nfs41_call_sync_prepare data->seq_server ffff880085b17000
> [11397.553322] --> nfs41_setup_sequence
> [11397.553324] --> nfs4_alloc_slot used_slots=0000 highest_used=4294967295 max_slots=31
> [11397.553324] <-- nfs4_alloc_slot used_slots=0001 highest_used=0 slotid=0
> [11397.553325] <-- nfs41_setup_sequence slotid=0 seqid=8829384
> [11397.553333] encode_sequence: sessionid=1474153431:3:4:0 seqid=8829384 slotid=0 max_slotid=0 cache_this=1
> [11397.553575] --> nfs4_alloc_slot used_slots=0001 highest_used=0 max_slots=31
> [11397.553576] <-- nfs4_alloc_slot used_slots=0003 highest_used=1 slotid=1
> [11397.553577] nfs4_free_slot: slotid 1 highest_used_slotid 0
> [11397.553578] nfs41_sequence_process: Error 0 free the slot 
> [11397.553580] nfs4_free_slot: slotid 0 highest_used_slotid 4294967295
> [11397.553602] --> nfs_put_client({2})
> [11397.553607] --> nfs41_call_sync_prepare data->seq_server ffff880085b17000
> [11397.553608] --> nfs41_setup_sequence
> [11397.553609] --> nfs4_alloc_slot used_slots=0000 highest_used=4294967295 max_slots=31
> [11397.553610] <-- nfs4_alloc_slot used_slots=0001 highest_used=0 slotid=0
> [11397.553611] <-- nfs41_setup_sequence slotid=0 seqid=8829385
> [11397.553619] encode_sequence: sessionid=1474153431:3:4:0 seqid=8829385 slotid=0 max_slotid=0 cache_this=1
> [11397.560057] --> nfs4_alloc_slot used_slots=0001 highest_used=0 max_slots=31
> [11397.560059] <-- nfs4_alloc_slot used_slots=0003 highest_used=1 slotid=1
> [11397.560061] nfs4_free_slot: slotid 1 highest_used_slotid 0
> [11397.560062] nfs41_sequence_process: Error 0 free the slot 
> [11397.560064] nfs4_free_slot: slotid 0 highest_used_slotid 4294967295
> [11397.560094] --> nfs_put_client({2})
> [11397.560103] --> nfs41_call_sync_prepare data->seq_server ffff880085b17000
> [11397.560103] --> nfs41_setup_sequence
> [11397.560104] --> nfs4_alloc_slot used_slots=0000 highest_used=4294967295 max_slots=31
> [11397.560105] <-- nfs4_alloc_slot used_slots=0001 highest_used=0 slotid=0
> [11397.560106] <-- nfs41_setup_sequence slotid=0 seqid=8829386
> [11397.560120] encode_sequence: sessionid=1474153431:3:4:0 seqid=8829386 slotid=0 max_slotid=0 cache_this=1
> [11397.560388] --> nfs4_alloc_slot used_slots=0001 highest_used=0 max_slots=31
> [11397.560389] <-- nfs4_alloc_slot used_slots=0003 highest_used=1 slotid=1
> [11397.560391] nfs4_free_slot: slotid 1 highest_used_slotid 0
> [11397.560391] nfs41_sequence_process: Error 0 free the slot 
> [11397.560393] nfs4_free_slot: slotid 0 highest_used_slotid 4294967295
> [11397.560415] --> nfs_put_client({2})
> 
> 
> bt looks about the same:
> #0  xprt_get (xprt=0x0 <irq_stack_union>)
>    at /home/green/bk/linux-test/net/sunrpc/xprt.c:1435
> #1  0xffffffff8186196f in rpc_init_task (task_setup_data=<optimized out>, 
>    task=<optimized out>) at /home/green/bk/linux-test/net/sunrpc/sched.c:936
> #2  rpc_new_task (setup_data=0x0 <irq_stack_union>)
>    at /home/green/bk/linux-test/net/sunrpc/sched.c:971
> #3  0xffffffff818538c8 in rpc_run_task (task_setup_data=0xffff88007236ba50)
>    at /home/green/bk/linux-test/net/sunrpc/clnt.c:1041
> #4  0xffffffff813a75e3 in nfs4_call_sync_sequence (clnt=<optimized out>, 
>    server=<optimized out>, msg=<optimized out>, args=<optimized out>, 
>    res=<optimized out>) at /home/green/bk/linux-test/fs/nfs/nfs4proc.c:1055
> #5  0xffffffff813b4675 in nfs4_call_sync (cache_reply=<optimized out>, 
>    res=<optimized out>, args=<optimized out>, msg=<optimized out>, 
>    server=<optimized out>, clnt=<optimized out>)
>    at /home/green/bk/linux-test/fs/nfs/nfs4proc.c:1073
> #6  _nfs4_do_setattr (state=<optimized out>, cred=<optimized out>, 
>    res=<optimized out>, arg=<optimized out>, inode=<optimized out>)
>    at /home/green/bk/linux-test/fs/nfs/nfs4proc.c:2920
> #7  nfs4_do_setattr (inode=0xffff8800640f82a8, cred=<optimized out>, 
>    fattr=<optimized out>, sattr=<optimized out>, state=0xffff88005a95be00, 
>    ilabel=<optimized out>, olabel=0x0 <irq_stack_union>)
>    at /home/green/bk/linux-test/fs/nfs/nfs4proc.c:2959
> #8  0xffffffff813b4a46 in nfs4_proc_setattr (dentry=<optimized out>, 
> ---Type <return> to continue, or q <return> to quit---
>    fattr=0xf8 <irq_stack_union+248>, sattr=0x1 <irq_stack_union+1>)
>    at /home/green/bk/linux-test/fs/nfs/nfs4proc.c:3688
> #9  0xffffffff8138f1cb in nfs_setattr (dentry=0xffff8800119c0000, 
>    attr=0xffff88007236bce8) at /home/green/bk/linux-test/fs/nfs/inode.c:556
> #10 0xffffffff81298d6b in notify_change (dentry=0xffff8800119c0000, 
>    attr=0xffff88007236bce8, delegated_inode=<optimized out>)
>    at /home/green/bk/linux-test/fs/attr.c:285
> #11 0xffffffff812734e3 in do_truncate (dentry=0x0 <irq_stack_union>, 
>    length=<optimized out>, time_attrs=<optimized out>, filp=<optimized out>)
>    at /home/green/bk/linux-test/fs/open.c:63
> #12 0xffffffff81287459 in handle_truncate (filp=<optimized out>)
>    at /home/green/bk/linux-test/fs/namei.c:2960
> #13 do_last (opened=<optimized out>, op=<optimized out>, file=<optimized out>, 
>    nd=<optimized out>) at /home/green/bk/linux-test/fs/namei.c:3383
> #14 path_openat (nd=0xffff88007236bde0, op=<optimized out>, 
>    flags=<optimized out>) at /home/green/bk/linux-test/fs/namei.c:3497
> #15 0xffffffff81288b01 in do_filp_open (dfd=<optimized out>, 
>    pathname=<optimized out>, op=0xffff88007236bef4)
>    at /home/green/bk/linux-test/fs/namei.c:3532
> #16 0xffffffff81274ab0 in do_sys_open (dfd=-100, filename=<optimized out>, 
>    flags=<optimized out>, mode=<optimized out>)
>    at /home/green/bk/linux-test/fs/open.c:1036
> #17 0xffffffff81274bbe in SYSC_open (mode=<optimized out>, 
> ---Type <return> to continue, or q <return> to quit---
>    flags=<optimized out>, filename=<optimized out>)
>    at /home/green/bk/linux-test/fs/open.c:1054
> #18 SyS_open (filename=<optimized out>, flags=<optimized out>, 
>    mode=<optimized out>) at /home/green/bk/linux-test/fs/open.c:1049
> #19 0xffffffff8189f03c in entry_SYSCALL_64_fastpath ()
> 
> 

