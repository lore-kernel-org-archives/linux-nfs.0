Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from us-smtp-delivery-194.mimecast.com ([63.128.21.194]:21881 "EHLO
        us-smtp-delivery-194.mimecast.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1754914AbcIRWiQ (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sun, 18 Sep 2016 18:38:16 -0400
From: Trond Myklebust <trondmy@primarydata.com>
To: Oleg Drokin <green@linuxhacker.ru>
CC: Schumaker Anna <anna.schumaker@netapp.com>,
        List Linux NFS Mailing <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH v5 00/25] Fix delegation behaviour when server revokes
 some state
Date: Sun, 18 Sep 2016 22:38:07 +0000
Message-ID: <2FBB0CA9-F6B4-4D80-B9C5-387DE4D267DD@primarydata.com>
References: <1474089213-104014-1-git-send-email-trond.myklebust@primarydata.com>
 <838E325D-2DA1-4229-A046-76316302F813@linuxhacker.ru>
 <CCA85800-84C2-4B80-A44D-966F79EC5892@primarydata.com>
 <E84E083B-293E-4990-921A-FF37C282FA15@linuxhacker.ru>
 <1474140727.7526.1.camel@primarydata.com>
 <1474148731.7526.3.camel@primarydata.com>
 <96CBC4AF-B0EA-4AFA-8068-E93CBACD1B0B@linuxhacker.ru>
 <C2E081FE-712D-4B99-AE18-A2BBC33739FA@primarydata.com>
 <E7C7924A-9C31-4D95-A2AF-63D4806D27B2@linuxhacker.ru>
 <8E0CD004-8BAE-4EC0-BAA2-ED7B83F85610@linuxhacker.ru>
In-Reply-To: <8E0CD004-8BAE-4EC0-BAA2-ED7B83F85610@linuxhacker.ru>
MIME-Version: 1.0
Content-Type: text/plain; charset=WINDOWS-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


> On Sep 18, 2016, at 12:23, Oleg Drokin <green@linuxhacker.ru> wrote:
>=20
>=20
> On Sep 17, 2016, at 9:19 PM, Oleg Drokin wrote:
>=20
>>=20
>> On Sep 17, 2016, at 5:59 PM, Trond Myklebust wrote:
>>=20
>>>=20
>>>> On Sep 17, 2016, at 17:55, Oleg Drokin <green@linuxhacker.ru> wrote:
>>>>=20
>>>>=20
>>>> On Sep 17, 2016, at 5:45 PM, Trond Myklebust wrote:
>>>>=20
>>>>> On Sat, 2016-09-17 at 15:32 -0400, Trond Myklebust wrote:
>>>>>> On Sat, 2016-09-17 at 15:16 -0400, Oleg Drokin wrote:
>>>>>>>=20
>>>>>>> On Sep 17, 2016, at 2:18 PM, Trond Myklebust wrote:
>>>>>>>=20
>>>>>>>>=20
>>>>>>>>=20
>>>>>>>>=20
>>>>>>>>>=20
>>>>>>>>>=20
>>>>>>>>> On Sep 17, 2016, at 14:04, Oleg Drokin <green@linuxhacker.ru>
>>>>>>>>> wrote:
>>>>>>>>>=20
>>>>>>>>>=20
>>>>>>>>> On Sep 17, 2016, at 1:13 AM, Trond Myklebust wrote:
>>>>>>>>>=20
>>>>>>>>>>=20
>>>>>>>>>>=20
>>>>>>>>>> According to RFC5661, if any of the SEQUENCE status bits
>>>>>>>>>> SEQ4_STATUS_EXPIRED_ALL_STATE_REVOKED,
>>>>>>>>>> SEQ4_STATUS_EXPIRED_SOME_STATE_REVOKED,
>>>>>>>>>> SEQ4_STATUS_ADMIN_STATE_REVOKED,
>>>>>>>>>> or SEQ4_STATUS_RECALLABLE_STATE_REVOKED are set, then we need
>>>>>>>>>> to use
>>>>>>>>>> TEST_STATEID to figure out which stateids have been revoked,
>>>>>>>>>> so
>>>>>>>>>> we
>>>>>>>>>> can acknowledge the loss of state using FREE_STATEID.
>>>>>>>>>>=20
>>>>>>>>>> While we already do this for open and lock state, we have not
>>>>>>>>>> been doing
>>>>>>>>>> so for all the delegations.
>>>>>>>>>>=20
>>>>>>>>>> v2: nfs_v4_2_minor_ops needs to set .test_and_free_expired
>>>>>>>>>> too
>>>>>>>>>> v3: Now with added lock revoke fixes and
>>>>>>>>>> close/delegreturn/locku fixes
>>>>>>>>>> v4: Close a bunch of corner cases
>>>>>>>>>> v5: Report revoked delegations as invalid in
>>>>>>>>>> nfs_have_delegation()
>>>>>>>>>> Fix an infinite loop in nfs_reap_expired_delegations.
>>>>>>>>>> Fixes for other looping behaviour
>>>>>>>>>=20
>>>>>>>>> This time around the loop seems to be more tight,
>>>>>>>>> in userspace process:
>>>>>>>>>=20
>>>>>>>>> [ 9197.256571] --> nfs41_call_sync_prepare data->seq_server
>>>>>>>>> ffff8800a73ce000
>>>>>>>>> [ 9197.256572] --> nfs41_setup_sequence
>>>>>>>>> [ 9197.256573] --> nfs4_alloc_slot used_slots=3D0000
>>>>>>>>> highest_used=3D4294967295 max_slots=3D31
>>>>>>>>> [ 9197.256574] <-- nfs4_alloc_slot used_slots=3D0001
>>>>>>>>> highest_used=3D0
>>>>>>>>> slotid=3D0
>>>>>>>>> [ 9197.256574] <-- nfs41_setup_sequence slotid=3D0 seqid=3D140138=
00
>>>>>>>>> [ 9197.256582] encode_sequence: sessionid=3D1474126170:1:2:0
>>>>>>>>> seqid=3D14013800 slotid=3D0 max_slotid=3D0 cache_this=3D1
>>>>>>>>> [ 9197.256755] --> nfs4_alloc_slot used_slots=3D0001
>>>>>>>>> highest_used=3D0
>>>>>>>>> max_slots=3D31
>>>>>>>>> [ 9197.256756] <-- nfs4_alloc_slot used_slots=3D0003
>>>>>>>>> highest_used=3D1
>>>>>>>>> slotid=3D1
>>>>>>>>> [ 9197.256757] nfs4_free_slot: slotid 1 highest_used_slotid 0
>>>>>>>>> [ 9197.256758] nfs41_sequence_process: Error 0 free the slot=20
>>>>>>>>> [ 9197.256760] nfs4_free_slot: slotid 0 highest_used_slotid
>>>>>>>>> 4294967295
>>>>>>>>> [ 9197.256779] --> nfs_put_client({2})
>>>>>>>>=20
>>>>>>>> What operation is the userspace process hanging on? Do you have a
>>>>>>>> stack trace for it?
>>>>>>>=20
>>>>>>> seems to be open_create->truncate->ssetattr coming from:
>>>>>>> cp /bin/sleep /mnt/nfs2/racer/12
>>>>>>>=20
>>>>>>> (gdb) bt
>>>>>>> #0  nfs41_setup_sequence (session=3D0xffff88005a853800,
>>>>>>> args=3D0xffff8800a7253b80,=20
>>>>>>> res=3D0xffff8800a7253b48, task=3D0xffff8800b0eb0f00)
>>>>>>> at /home/green/bk/linux-test/fs/nfs/nfs4proc.c:876
>>>>>>> #1  0xffffffff813a751c in nfs41_call_sync_prepare (task=3D<optimize=
d
>>>>>>> out>,=20
>>>>>>> calldata=3D0xffff8800a7253b80)
>>>>>>> at /home/green/bk/linux-test/fs/nfs/nfs4proc.c:966
>>>>>>> #2  0xffffffff8185c639 in rpc_prepare_task (task=3D<optimized out>)
>>>>>>> at /home/green/bk/linux-test/net/sunrpc/sched.c:683
>>>>>>> #3  0xffffffff8185f12b in __rpc_execute (task=3D0xffff88005a853800)
>>>>>>> at /home/green/bk/linux-test/net/sunrpc/sched.c:775
>>>>>>> #4  0xffffffff818617b4 in rpc_execute (task=3D0xffff88005a853800)
>>>>>>> at /home/green/bk/linux-test/net/sunrpc/sched.c:843
>>>>>>> #5  0xffffffff818539b9 in rpc_run_task
>>>>>>> (task_setup_data=3D0xffff8800a7253a50)
>>>>>>> at /home/green/bk/linux-test/net/sunrpc/clnt.c:1052
>>>>>>> #6  0xffffffff813a75e3 in nfs4_call_sync_sequence (clnt=3D<optimize=
d
>>>>>>> out>,=20
>>>>>>> server=3D<optimized out>, msg=3D<optimized out>, args=3D<optimized
>>>>>>> out>,=20
>>>>>>> res=3D<optimized out>) at /home/green/bk/linux-
>>>>>>> test/fs/nfs/nfs4proc.c:1051
>>>>>>> #7  0xffffffff813b4645 in nfs4_call_sync (cache_reply=3D<optimized
>>>>>>> out>,=20
>>>>>>> res=3D<optimized out>, args=3D<optimized out>, msg=3D<optimized
>>>>>>> out>,=20
>>>>>>> server=3D<optimized out>, clnt=3D<optimized out>)
>>>>>>> at /home/green/bk/linux-test/fs/nfs/nfs4proc.c:1069
>>>>>>> #8  _nfs4_do_setattr (state=3D<optimized out>, cred=3D<optimized ou=
t>,=20
>>>>>>> res=3D<optimized out>, arg=3D<optimized out>, inode=3D<optimized
>>>>>>> out>)
>>>>>>> ---Type <return> to continue, or q <return> to quit---
>>>>>>> at /home/green/bk/linux-test/fs/nfs/nfs4proc.c:2916
>>>>>>> #9  nfs4_do_setattr (inode=3D0xffff880079b152a8, cred=3D<optimized
>>>>>>> out>,=20
>>>>>>> fattr=3D<optimized out>, sattr=3D<optimized out>,
>>>>>>> state=3D0xffff880060588e00,=20
>>>>>>> ilabel=3D<optimized out>, olabel=3D0x0 <irq_stack_union>)
>>>>>>> at /home/green/bk/linux-test/fs/nfs/nfs4proc.c:2955
>>>>>>> #10 0xffffffff813b4a16 in nfs4_proc_setattr (dentry=3D<optimized
>>>>>>> out>,=20
>>>>>>> fattr=3D0xffff8800a7253b80, sattr=3D0xffff8800a7253b48)
>>>>>>> at /home/green/bk/linux-test/fs/nfs/nfs4proc.c:3684
>>>>>>> #11 0xffffffff8138f1cb in nfs_setattr (dentry=3D0xffff8800740c1000,=
=20
>>>>>>>=20
>>>>>>=20
>>>>>> Cool! Does the following help?
>>>>>=20
>>>>> Grrr... There is another bug there=85
>>>>=20
>>>> Is this in addition to the previous patch or instead of?
>>>=20
>>> It can apply on top of it. The two patches fix different bugs.
>>=20
>> Ok, it does not seem to have helped:
>=20
> Of the 10 nodes where I run this, I had some more failures overnight,
> some of them different.
>=20
> The other one I got was (I have 3 nodes in this state,
> only one in the one reported yesterday.):


I=92ve been trying desperately to reproduce the issue, but I can=92t make k=
nfsd return or revoke the delegations with the =93racer=94 script that you =
pointed me to (I=92m using the stock knfsd from Linux 4.7.3). Is there anyt=
hing else special about your setup that I should know about?


