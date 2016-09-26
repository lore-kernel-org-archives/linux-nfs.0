Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from linuxhacker.ru ([217.76.32.60]:44354 "EHLO fiona.linuxhacker.ru"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932345AbcIZVEO (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 26 Sep 2016 17:04:14 -0400
Subject: Re: [PATCH v7 00/31] Fix delegation behaviour when server revokes some state
Mime-Version: 1.0 (Apple Message framework v1283)
Content-Type: text/plain; charset=utf-8
From: Oleg Drokin <green@linuxhacker.ru>
In-Reply-To: <A84EB639-97C3-4517-A92F-3A4176A7F916@primarydata.com>
Date: Mon, 26 Sep 2016 17:03:55 -0400
Cc: Schumaker Anna <anna.schumaker@netapp.com>,
        List Linux NFS Mailing <linux-nfs@vger.kernel.org>
Message-Id: <D1BF19E9-6B7E-49A3-8B48-43D4C80B1C72@linuxhacker.ru>
References: <1474565961-21303-1-git-send-email-trond.myklebust@primarydata.com> <F177D682-4193-4538-8B79-06EC504F13B5@linuxhacker.ru> <A84EB639-97C3-4517-A92F-3A4176A7F916@primarydata.com>
To: Trond Myklebust <trondmy@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Sep 26, 2016, at 4:46 PM, Trond Myklebust wrote:

> 
>> On Sep 26, 2016, at 13:23, Oleg Drokin <green@linuxhacker.ru> wrote:
>> 
>> 
>> On Sep 22, 2016, at 1:38 PM, Trond Myklebust wrote:
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
>>>   Fix an infinite loop in nfs_reap_expired_delegations.
>>>       Fixes for other looping behaviour
>>> v6: Fix nfs4_do_handle_exception to handle all stateids, not just delegations
>>>   Stable fix for nfs4_copy_delegation_stateid
>>>   Marked fix "NFSv4: Don't report revoked delegations as valid in
>>>       nfs_have_delegation" for stable.
>>>   Stable fix for the inode mode/fileid corruption
>>> v7: Fix handling of NFS4ERR_OPENMODE
>>>   Handle matching stateids that have set seqid==0
>> 
>> 
>> 
>> Well, it took 2.5 days this time around, but it seems some narrow
>> races remain.
>> I got the system stuck in that state again:
>> [257275.514588] NFS call  test_stateid ffff880005304f24
>> [257275.514591] --> nfs41_call_sync_prepare data->seq_server ffff88005cb2e000
>> [257275.514591] --> nfs41_setup_sequence
>> [257275.514592] --> nfs4_alloc_slot used_slots=0003 highest_used=1 max_slots=31
>> [257275.514593] <-- nfs4_alloc_slot used_slots=0007 highest_used=2 slotid=2
>> [257275.514594] <-- nfs41_setup_sequence slotid=2 seqid=65520554
>> [257275.514612] encode_sequence: sessionid=1474859578:109:110:0 seqid=65520554 slotid=2 max_slotid=2 cache_this=0
>> [257275.514707] --> nfs4_alloc_slot used_slots=0007 highest_used=2 max_slots=31
>> [257275.514708] <-- nfs4_alloc_slot used_slots=000f highest_used=3 slotid=3
>> [257275.514709] nfs4_free_slot: slotid 3 highest_used_slotid 2
>> [257275.514710] nfs41_sequence_process: Error 0 free the slot 
>> [257275.514711] nfs4_free_slot: slotid 2 highest_used_slotid 1
>> [257275.514733] NFS reply test_stateid: succeeded, 0
>> [257275.514738] --> nfs_put_client({2})
>> [257275.514751] --> nfs4_setup_sequence clp ffff88005b2e4800 session ffff880029aa8800 sr_slot 4294967295
>> [257275.514751] --> nfs41_setup_sequence
>> [257275.514752] --> nfs4_alloc_slot used_slots=0003 highest_used=1 max_slots=31
>> [257275.514753] <-- nfs4_alloc_slot used_slots=0007 highest_used=2 slotid=2
>> [257275.514754] <-- nfs41_setup_sequence slotid=2 seqid=65520555
>> [257275.514754] <-- nfs4_setup_sequence status=0
>> [257275.514761] encode_sequence: sessionid=1474859578:109:110:0 seqid=65520555 slotid=2 max_slotid=2 cache_this=1
>> [257275.515115] NFS: nfs_pgio_result: 17130, (status -10038)
>> [257275.515116] --> nfs4_alloc_slot used_slots=0007 highest_used=2 max_slots=31
>> [257275.515117] <-- nfs4_alloc_slot used_slots=000f highest_used=3 slotid=3
>> [257275.515117] nfs4_free_slot: slotid 3 highest_used_slotid 2
>> [257275.515118] nfs41_sequence_process: Error 0 free the slot 
>> [257275.515118] nfs4_free_slot: slotid 2 highest_used_slotid 1
>> [257275.515119] nfs4_schedule_stateid_recovery: scheduling stateid recovery for server localhost
>> [257275.515193] NFS call  test_stateid ffff880005304f24
>> [257275.515196] --> nfs41_call_sync_prepare data->seq_server ffff88005cb2e000
>> [257275.515196] --> nfs41_setup_sequence
>> [257275.515198] --> nfs4_alloc_slot used_slots=0003 highest_used=1 max_slots=31
>> [257275.515199] <-- nfs4_alloc_slot used_slots=0007 highest_used=2 slotid=2
>> [257275.515199] <-- nfs41_setup_sequence slotid=2 seqid=65520556
>> [257275.515206] encode_sequence: sessionid=1474859578:109:110:0 seqid=65520556 slotid=2 max_slotid=2 cache_this=0
>> [257275.515297] --> nfs4_alloc_slot used_slots=0007 highest_used=2 max_slots=31
>> [257275.515298] <-- nfs4_alloc_slot used_slots=000f highest_used=3 slotid=3
>> [257275.515299] nfs4_free_slot: slotid 3 highest_used_slotid 2
>> [257275.515300] nfs41_sequence_process: Error 0 free the slot 
>> [257275.515301] nfs4_free_slot: slotid 2 highest_used_slotid 1
>> [257275.515319] NFS reply test_stateid: succeeded, 0
>> [257275.515323] --> nfs_put_client({2})
>> [257275.515326] --> nfs4_setup_sequence clp ffff88005b2e4800 session ffff880029aa8800 sr_slot 4294967295
>> [257275.515326] --> nfs41_setup_sequence
>> [257275.515327] --> nfs4_alloc_slot used_slots=0003 highest_used=1 max_slots=31
>> [257275.515328] <-- nfs4_alloc_slot used_slots=0007 highest_used=2 slotid=2
>> [257275.515329] <-- nfs41_setup_sequence slotid=2 seqid=65520557
>> [257275.515329] <-- nfs4_setup_sequence status=0
>> [257275.515336] encode_sequence: sessionid=1474859578:109:110:0 seqid=65520557 slotid=2 max_slotid=2 cache_this=1
>> [257275.515687] NFS: nfs_pgio_result: 17130, (status -10038)
>> [257275.515689] --> nfs4_alloc_slot used_slots=0007 highest_used=2 max_slots=31
>> [257275.515690] <-- nfs4_alloc_slot used_slots=000f highest_used=3 slotid=3
>> [257275.515690] nfs4_free_slot: slotid 3 highest_used_slotid 2
>> [257275.515691] nfs41_sequence_process: Error 0 free the slot 
>> [257275.515692] nfs4_free_slot: slotid 2 highest_used_slotid 1
>> [257275.515703] nfs4_schedule_stateid_recovery: scheduling stateid recovery for server localhost
>> [257275.515793] NFS call  test_stateid ffff880005304f24
>> [257275.515796] --> nfs41_call_sync_prepare data->seq_server ffff88005cb2e000
>> [257275.515797] --> nfs41_setup_sequence
>> [257275.515798] --> nfs4_alloc_slot used_slots=0003 highest_used=1 max_slots=31
>> [257275.515799] <-- nfs4_alloc_slot used_slots=0007 highest_used=2 slotid=2
>> [257275.515799] <-- nfs41_setup_sequence slotid=2 seqid=65520558
>> [257275.515806] encode_sequence: sessionid=1474859578:109:110:0 seqid=65520558 slotid=2 max_slotid=2 cache_this=0
>> [257275.515889] --> nfs4_alloc_slot used_slots=0007 highest_used=2 max_slots=31
>> [257275.515890] <-- nfs4_alloc_slot used_slots=000f highest_used=3 slotid=3
>> [257275.515891] nfs4_free_slot: slotid 3 highest_used_slotid 2
>> [257275.515891] nfs41_sequence_process: Error 0 free the slot 
>> [257275.515892] nfs4_free_slot: slotid 2 highest_used_slotid 1
>> [257275.515910] NFS reply test_stateid: succeeded, 0
>> [257275.515914] --> nfs_put_client({2})
>> [257275.515917] --> nfs4_setup_sequence clp ffff88005b2e4800 session ffff880029aa8800 sr_slot 4294967295
>> [257275.515918] --> nfs41_setup_sequence
>> [257275.515919] --> nfs4_alloc_slot used_slots=0003 highest_used=1 max_slots=31
>> [257275.515920] <-- nfs4_alloc_slot used_slots=0007 highest_used=2 slotid=2
>> [257275.515920] <-- nfs41_setup_sequence slotid=2 seqid=65520559
>> [257275.515921] <-- nfs4_setup_sequence status=0
>> [257275.515928] encode_sequence: sessionid=1474859578:109:110:0 seqid=65520559 slotid=2 max_slotid=2 cache_this=1
>> [257275.516312] NFS: nfs_pgio_result: 17130, (status -10038)
> 
> Hmm… It looks as if one of the pgio calls is stuck in an NFS4ERR_OPENMODE loop.
> 
>> [257275.516313] --> nfs4_alloc_slot used_slots=0007 highest_used=2 max_slots=31
>> [257275.516314] <-- nfs4_alloc_slot used_slots=000f highest_used=3 slotid=3
>> [257275.516315] nfs4_free_slot: slotid 3 highest_used_slotid 2
>> [257275.516315] nfs41_sequence_process: Error 0 free the slot 
>> [257275.516316] nfs4_free_slot: slotid 2 highest_used_slotid 1
>> [257275.516317] nfs4_schedule_stateid_recovery: scheduling stateid recovery for server localhost
> 
> …but it looks as if it is successfully scheduling stateid recovery.
> 
>> 
>> Please let me know if you need anything else extracted from a system in this state.
> 
> Do you have the ability to extract the ‘struct state’ info? I suspect the problem may be a bug tracking the open mode. Also, can you tell if this is a read or a write that is failing?

I think it's a write because:
#3  rpcauth_wrap_req (task=0xffff88005bbb8cd8, 
    encode=0xffffffff813bf250 <nfs4_xdr_enc_write>, rqstp=0xffff880006d9de00, 
    data=0xffff880065be6060, obj=<optimized out>)


There's no "struct state" anywhere in the fs/nfs/*.c, can you please elaborate
on what did you mean by that?

In nfs41_test_stateid:
$1 = {{data = "\000\000\000\b:\222ХWm\000\000\000©\226\001", {
      seqid = 134217728, other = ":\222ХWm\000\000\000©\226\001"}}, 
  type = NFS4_OPEN_STATEID_TYPE}

In that same callpath if I go up to nfs4_reclaim_open_state:

(gdb) p *state
$3 = {open_states = {next = 0xffff88000c6d6c98, prev = 0xffff88005ed3ee00}, 
  inode_states = {next = 0xffff88008447c1d8, prev = 0xffff88008447c1d8}, 
  lock_states = {next = 0xffff880005304e20, prev = 0xffff880005304e20}, 
  owner = 0xffff88000c6d6c00, inode = 0xffff88008447c2a8, flags = 284, 
  state_lock = {{rlock = {raw_lock = {val = {counter = 0}}, 
        magic = 3735899821, owner_cpu = 4294967295, 
        owner = 0xffffffffffffffff, dep_map = {
          key = 0xffffffff833ff7f0 <__key.66122>, class_cache = {
            0x0 <irq_stack_union>, 0x0 <irq_stack_union>}, 
          name = 0xffffffff81c89ce6 "&(&state->state_lock)->rlock", cpu = 3, 
          ip = 0}}, {
        __padding = "\000\000\000\000╜N╜чЪЪЪЪ\000\000\000\000ЪЪЪЪЪЪЪЪ", 
        dep_map = {key = 0xffffffff833ff7f0 <__key.66122>, class_cache = {
            0x0 <irq_stack_union>, 0x0 <irq_stack_union>}, 
          name = 0xffffffff81c89ce6 "&(&state->state_lock)->rlock", cpu = 3, 
          ip = 0}}}}, seqlock = {seqcount = {sequence = 16, dep_map = {
        key = 0xffffffff833ff7e8 <__key.66123>, class_cache = {
          0x0 <irq_stack_union>, 0x0 <irq_stack_union>}, 
        name = 0xffffffff81c89d03 "&(&state->seqlock)->seqcount", cpu = 3, 
        ip = 0}}, lock = {{rlock = {raw_lock = {val = {counter = 0}}, 
          magic = 3735899821, owner_cpu = 4294967295, 
          owner = 0xffffffffffffffff, dep_map = {
            key = 0xffffffff833ff7e0 <__key.66124>, class_cache = {
              0x0 <irq_stack_union>, 0x0 <irq_stack_union>}, 
            name = 0xffffffff81c7c978 "&(&(&state->seqlock)->lock)->rlock", 
            cpu = 3, ip = 0}}, {
          __padding = "\000\000\000\000╜N╜чЪЪЪЪ\000\000\000\000ЪЪЪЪЪЪЪЪ", 
          dep_map = {key = 0xffffffff833ff7e0 <__key.66124>, class_cache = {
              0x0 <irq_stack_union>, 0x0 <irq_stack_union>}, 
            name = 0xffffffff81c7c978 "&(&(&state->seqlock)->lock)->rlock", 
            cpu = 3, ip = 0}}}}}, stateid = {{
      data = "\000\000\000\b:\222ХWm\000\000\000©\226\001", {
        seqid = 134217728, other = ":\222ХWm\000\000\000©\226\001"}}, 
    type = NFS4_OPEN_STATEID_TYPE}, open_stateid = {{
      data = "\000\000\000\b:\222ХWm\000\000\000©\226\001", {
        seqid = 134217728, other = ":\222ХWm\000\000\000©\226\001"}}, 
    type = NFS4_OPEN_STATEID_TYPE}, n_rdonly = 2, n_wronly = 2, n_rdwr = 0, 
  state = 3, count = {counter = 5}}



