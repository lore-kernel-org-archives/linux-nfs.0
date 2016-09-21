Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from linuxhacker.ru ([217.76.32.60]:48094 "EHLO fiona.linuxhacker.ru"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754593AbcIUBHS (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 20 Sep 2016 21:07:18 -0400
Subject: Re: [PATCH v6 00/29] Fix delegation behaviour when server revokes some state
Mime-Version: 1.0 (Apple Message framework v1283)
Content-Type: text/plain; charset=windows-1252
From: Oleg Drokin <green@linuxhacker.ru>
In-Reply-To: <104E1824-0235-41DF-AA9D-5C3F5560CA57@primarydata.com>
Date: Tue, 20 Sep 2016 21:07:05 -0400
Cc: Schumaker Anna <anna.schumaker@netapp.com>,
        List Linux NFS Mailing <linux-nfs@vger.kernel.org>
Message-Id: <85905FB8-E30A-4CD3-BB1D-4103316D0C06@linuxhacker.ru>
References: <1474390571-17106-1-git-send-email-trond.myklebust@primarydata.com> <C5E6E9A2-24B0-4D4B-A82A-706A89E23D24@linuxhacker.ru> <104E1824-0235-41DF-AA9D-5C3F5560CA57@primarydata.com>
To: Trond Myklebust <trondmy@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Sep 20, 2016, at 8:57 PM, Trond Myklebust wrote:

> 
>> On Sep 20, 2016, at 18:06, Oleg Drokin <green@linuxhacker.ru> wrote:
>> 
>> 
>> On Sep 20, 2016, at 12:55 PM, Trond Myklebust wrote:
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
>>> 
>>> Trond Myklebust (29):
>>> NFSv4.1: Don't deadlock the state manager on the SEQUENCE status flags
>>> NFS: Fix inode corruption in nfs_prime_dcache()
>>> NFSv4: Don't report revoked delegations as valid in
>>>   nfs_have_delegation()
>>> NFSv4: nfs4_copy_delegation_stateid() must fail if the delegation is
>>>   invalid
>>> NFSv4.1: Don't check delegations that are already marked as revoked
>>> NFSv4.1: Allow test_stateid to handle session errors without waiting
>>> NFSv4.1: Add a helper function to deal with expired stateids
>>> NFSv4.x: Allow callers of nfs_remove_bad_delegation() to specify a
>>>   stateid
>>> NFSv4.1: Test delegation stateids when server declares "some state
>>>   revoked"
>>> NFSv4.1: Deal with server reboots during delegation expiration
>>>   recovery
>>> NFSv4.1: Don't recheck delegations that have already been checked
>>> NFSv4.1: Allow revoked stateids to skip the call to TEST_STATEID
>>> NFSv4.1: Ensure we always run TEST/FREE_STATEID on locks
>>> NFSv4.1: FREE_STATEID can be asynchronous
>>> NFSv4.1: Ensure we call FREE_STATEID if needed on
>>>   close/delegreturn/locku
>>> NFSv4: Ensure we don't re-test revoked and freed stateids
>>> NFSv4: nfs_inode_find_delegation_state_and_recover() should check all
>>>   stateids
>>> NFSv4: nfs4_handle_delegation_recall_error() handle expiration as
>>>   revoke case
>>> NFSv4: nfs4_handle_setlk_error() handle expiration as revoke case
>>> NFSv4.1: nfs4_layoutget_handle_exception handle revoked state
>>> NFSv4: Pass the stateid to the exception handler in
>>>   nfs4_read/write_done_cb
>>> NFSv4: Fix a race in nfs_inode_reclaim_delegation()
>>> NFSv4: Fix a race when updating an open_stateid
>>> NFS: Always call nfs_inode_find_state_and_recover() when revoking a
>>>   delegation
>>> NFSv4: nfs4_do_handle_exception() handle revoke/expiry of a single
>>>   stateid
>>> NFSv4: Don't test open_stateid unless it is set
>>> NFSv4: Mark the lock and open stateids as invalid after freeing them
>>> NFSv4: Open state recovery must account for file permission changes
>>> NFSv4: Fix retry issues with nfs41_test/free_stateid
>> 
>> This one seems to fail in multiple ways.
>> This is applied on top of Linus' tree commit d2ffb0103aaefa9b169da042cf39ce27bfb6cdbb
>> One is similar to what we saw before:
>> 
>> [12374.572987] --> nfs41_call_sync_prepare data->seq_server ffff8800af6e3000
>> [12374.572988] --> nfs41_setup_sequence
>> [12374.572989] --> nfs4_alloc_slot used_slots=0000 highest_used=4294967295 max_slots=31
>> [12374.572990] <-- nfs4_alloc_slot used_slots=0001 highest_used=0 slotid=0
>> [12374.572991] <-- nfs41_setup_sequence slotid=0 seqid=3873200
>> [12374.572998] encode_sequence: sessionid=1474402413:3:4:0 seqid=3873200 slotid=0 max_slotid=0 cache_this=1
>> [12374.573228] --> nfs4_alloc_slot used_slots=0001 highest_used=0 max_slots=31
>> [12374.573229] <-- nfs4_alloc_slot used_slots=0003 highest_used=1 slotid=1
>> [12374.573230] nfs4_free_slot: slotid 1 highest_used_slotid 0
>> [12374.573231] nfs41_sequence_process: Error 0 free the slot 
>> [12374.573232] nfs4_free_slot: slotid 0 highest_used_slotid 4294967295
>> [12374.573252] --> nfs_put_client({2})
>> [12374.573257] --> nfs41_call_sync_prepare data->seq_server ffff8800af6e3000
>> [12374.573258] --> nfs41_setup_sequence
>> [12374.573259] --> nfs4_alloc_slot used_slots=0000 highest_used=4294967295 max_slots=31
>> [12374.573260] <-- nfs4_alloc_slot used_slots=0001 highest_used=0 slotid=0
>> [12374.573261] <-- nfs41_setup_sequence slotid=0 seqid=3873201
>> [12374.573268] encode_sequence: sessionid=1474402413:3:4:0 seqid=3873201 slotid=0 max_slotid=0 cache_this=1
>> [12374.573525] --> nfs4_alloc_slot used_slots=0001 highest_used=0 max_slots=31
>> [12374.573526] <-- nfs4_alloc_slot used_slots=0003 highest_used=1 slotid=1
>> [12374.573527] nfs4_free_slot: slotid 1 highest_used_slotid 0
>> [12374.573527] nfs41_sequence_process: Error 0 free the slot 
>> [12374.573529] nfs4_free_slot: slotid 0 highest_used_slotid 4294967295
>> [12374.573548] --> nfs_put_client({2})
>> [12374.573554] --> nfs41_call_sync_prepare data->seq_server ffff8800af6e3000
>> [12374.573555] --> nfs41_setup_sequence
>> [12374.573556] --> nfs4_alloc_slot used_slots=0000 highest_used=4294967295 max_slots=31
>> [12374.573557] <-- nfs4_alloc_slot used_slots=0001 highest_used=0 slotid=0
>> [12374.573558] <-- nfs41_setup_sequence slotid=0 seqid=3873202
>> [12374.573565] encode_sequence: sessionid=1474402413:3:4:0 seqid=3873202 slotid=0 max_slotid=0 cache_this=1
>> [12374.573794] --> nfs4_alloc_slot used_slots=0001 highest_used=0 max_slots=31
>> [12374.573795] <-- nfs4_alloc_slot used_slots=0003 highest_used=1 slotid=1
>> [12374.573796] nfs4_free_slot: slotid 1 highest_used_slotid 0
>> [12374.573797] nfs41_sequence_process: Error 0 free the slot 
>> [12374.573798] nfs4_free_slot: slotid 0 highest_used_slotid 4294967295
>> [12374.573818] --> nfs_put_client({2})
>> [12374.573823] --> nfs41_call_sync_prepare data->seq_server ffff8800af6e3000
>> [12374.573824] --> nfs41_setup_sequence
>> [12374.573825] --> nfs4_alloc_slot used_slots=0000 highest_used=4294967295 max_slots=31
>> [12374.573826] <-- nfs4_alloc_slot used_slots=0001 highest_used=0 slotid=0
>> [12374.573827] <-- nfs41_setup_sequence slotid=0 seqid=3873203
>> [12374.573835] encode_sequence: sessionid=1474402413:3:4:0 seqid=3873203 slotid=0 max_slotid=0 cache_this=1
>> [12374.574103] --> nfs4_alloc_slot used_slots=0001 highest_used=0 max_slots=31
>> [12374.574104] <-- nfs4_alloc_slot used_slots=0003 highest_used=1 slotid=1
>> [12374.574105] nfs4_free_slot: slotid 1 highest_used_slotid 0
>> [12374.574106] nfs41_sequence_process: Error 0 free the slot 
>> [12374.574108] nfs4_free_slot: slotid 0 highest_used_slotid 4294967295
>> [12374.574128] --> nfs_put_client({2})
> 
> Still not reproducing this. I’ve been trying for days… :-/

Well, I think I shared all my instructions.
I can show you around the system virtually if you want to explore it in case I missed
something.
I guess I can also fetch whatever data you think you might need with a debugger,
since all of that happens in a VM.
Come think of it, I can also force a crashdump and you can sift through it yourself
if you think this would work better for you.

