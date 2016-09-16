Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from linuxhacker.ru ([217.76.32.60]:60242 "EHLO fiona.linuxhacker.ru"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751296AbcIPVVh (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 16 Sep 2016 17:21:37 -0400
Subject: Re: [PATCH v4 00/20] Fix delegation behaviour when server revokes some state
Mime-Version: 1.0 (Apple Message framework v1283)
Content-Type: text/plain; charset=us-ascii
From: Oleg Drokin <green@linuxhacker.ru>
In-Reply-To: <FC6D8393-2C79-47FC-98CB-67213BA2D27C@linuxhacker.ru>
Date: Fri, 16 Sep 2016 17:21:22 -0400
Cc: "anna.schumaker@netapp.com Schumaker" <anna.schumaker@netapp.com>,
        "linux-nfs@vger.kernel.org NFS Mailing" <linux-nfs@vger.kernel.org>
Message-Id: <3C143DE1-43AF-4E73-82D2-FE97A8EFFE3A@linuxhacker.ru>
References: <1473957960-10001-1-git-send-email-trond.myklebust@primarydata.com> <F3BA1CBE-EADB-4B0A-8DE6-A3B5FB2E2156@linuxhacker.ru> <1474040207.75849.1.camel@primarydata.com> <FC6D8393-2C79-47FC-98CB-67213BA2D27C@linuxhacker.ru>
To: Trond Myklebust <trondmy@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Sep 16, 2016, at 5:15 PM, Oleg Drokin wrote:

> 
> On Sep 16, 2016, at 11:36 AM, Trond Myklebust wrote:
> 
>> On Fri, 2016-09-16 at 00:38 -0400, Oleg Drokin wrote:
>>> On Sep 15, 2016, at 12:45 PM, Trond Myklebust wrote:
>>> 
>>>> 
>>>> According to RFC5661, if any of the SEQUENCE status bits
>>>> SEQ4_STATUS_EXPIRED_ALL_STATE_REVOKED,
>>>> SEQ4_STATUS_EXPIRED_SOME_STATE_REVOKED,
>>>> SEQ4_STATUS_ADMIN_STATE_REVOKED,
>>>> or SEQ4_STATUS_RECALLABLE_STATE_REVOKED are set, then we need to
>>>> use
>>>> TEST_STATEID to figure out which stateids have been revoked, so we
>>>> can acknowledge the loss of state using FREE_STATEID.
>>>> 
>>>> While we already do this for open and lock state, we have not been
>>>> doing
>>>> so for all the delegations.
>>>> 
>>>> v2: nfs_v4_2_minor_ops needs to set .test_and_free_expired too
>>>> v3: Now with added lock revoke fixes and close/delegreturn/locku
>>>> fixes
>>>> v4: Close a bunch of corner cases
>>> 
>>> This one seems to be looping on the client in a way very similar
>>> to the first failure in that it's the serverip-named process that's
>>> using the cpu, but the debug log is very similar to the second
>>> failure
>>> in test stateid, except this time it's not "success 0", but "success
>>> -10025":
>>> 
>> Ah... I think I see what the issue is... Does the following help?
> 
> Well, it changed the output back to what I had with the first patch set, I think:
> I.e. now it's nfsid test succeded, 0, and the process using the cpu is again
> a userspace one:

Ah, I did not realize you probably meant not to apply this on top of the previous
batch, but replace patch #14 with this one.
So I am trying it now.

> 
> [14231.187643] NFS call  test_stateid ffff88005e979f24
> [14231.187648] --> nfs41_call_sync_prepare data->seq_server ffff8800aadcb000
> [14231.187648] --> nfs41_setup_sequence
> [14231.187650] --> nfs4_alloc_slot used_slots=0000 highest_used=4294967295 max_slots=31
> [14231.187651] <-- nfs4_alloc_slot used_slots=0001 highest_used=0 slotid=0
> [14231.187651] <-- nfs41_setup_sequence slotid=0 seqid=3355909
> [14231.187660] encode_sequence: sessionid=1474050426:3:4:0 seqid=3355909 slotid=0 max_slotid=0 cache_this=0
> [14231.187879] --> nfs4_alloc_slot used_slots=0001 highest_used=0 max_slots=31
> [14231.187880] <-- nfs4_alloc_slot used_slots=0003 highest_used=1 slotid=1
> [14231.187882] nfs4_free_slot: slotid 1 highest_used_slotid 0
> [14231.187882] nfs41_sequence_process: Error 0 free the slot 
> [14231.187884] nfs4_free_slot: slotid 0 highest_used_slotid 4294967295
> [14231.187903] NFS reply test_stateid: succeeded, 0
> [14231.187911] --> nfs_put_client({3})
> [14231.187969] --> nfs_put_client({2})
> [14231.187976] --> nfs41_call_sync_prepare data->seq_server ffff8800aadcb000
> [14231.187977] --> nfs41_setup_sequence
> [14231.187978] --> nfs4_alloc_slot used_slots=0000 highest_used=4294967295 max_slots=31
> [14231.187979] <-- nfs4_alloc_slot used_slots=0001 highest_used=0 slotid=0
> [14231.187980] <-- nfs41_setup_sequence slotid=0 seqid=3355910
> [14231.187989] encode_sequence: sessionid=1474050426:3:4:0 seqid=3355910 slotid=0 max_slotid=0 cache_this=1
> [14231.188151] --> nfs4_alloc_slot used_slots=0001 highest_used=0 max_slots=31
> [14231.188152] <-- nfs4_alloc_slot used_slots=0003 highest_used=1 slotid=1
> [14231.188154] nfs4_free_slot: slotid 1 highest_used_slotid 0
> [14231.188155] nfs41_sequence_process: Error 0 free the slot 
> [14231.188156] nfs4_free_slot: slotid 0 highest_used_slotid 4294967295
> [14231.188178] nfs4_schedule_stateid_recovery: scheduling stateid recovery for server localhost
> [14231.188355] NFS call  test_stateid ffff88005e979f24
> [14231.188360] --> nfs41_call_sync_prepare data->seq_server ffff8800aadcb000
> [14231.188361] --> nfs41_setup_sequence
> [14231.188362] --> nfs4_alloc_slot used_slots=0000 highest_used=4294967295 max_slots=31
> [14231.188363] <-- nfs4_alloc_slot used_slots=0001 highest_used=0 slotid=0
> [14231.188364] <-- nfs41_setup_sequence slotid=0 seqid=3355911
> [14231.188373] encode_sequence: sessionid=1474050426:3:4:0 seqid=3355911 slotid=0 max_slotid=0 cache_this=0
> [14231.188584] --> nfs4_alloc_slot used_slots=0001 highest_used=0 max_slots=31
> [14231.188586] <-- nfs4_alloc_slot used_slots=0003 highest_used=1 slotid=1
> [14231.188587] nfs4_free_slot: slotid 1 highest_used_slotid 0
> [14231.188588] nfs41_sequence_process: Error 0 free the slot 
> [14231.188589] nfs4_free_slot: slotid 0 highest_used_slotid 4294967295
> [14231.188608] NFS reply test_stateid: succeeded, 0
> [14231.188617] --> nfs_put_client({3})
> [14231.188672] --> nfs_put_client({2})
> [14231.188679] --> nfs41_call_sync_prepare data->seq_server ffff8800aadcb000
> [14231.188680] --> nfs41_setup_sequence
> [14231.188681] --> nfs4_alloc_slot used_slots=0000 highest_used=4294967295 max_slots=31
> [14231.188682] <-- nfs4_alloc_slot used_slots=0001 highest_used=0 slotid=0
> [14231.188683] <-- nfs41_setup_sequence slotid=0 seqid=3355912
> [14231.188692] encode_sequence: sessionid=1474050426:3:4:0 seqid=3355912 slotid=0 max_slotid=0 cache_this=1
> [14231.188848] --> nfs4_alloc_slot used_slots=0001 highest_used=0 max_slots=31
> [14231.188849] <-- nfs4_alloc_slot used_slots=0003 highest_used=1 slotid=1
> [14231.188851] nfs4_free_slot: slotid 1 highest_used_slotid 0
> [14231.188855] nfs41_sequence_process: Error 0 free the slot 
> [14231.188871] nfs4_free_slot: slotid 0 highest_used_slotid 4294967295
> [14231.188891] nfs4_schedule_stateid_recovery: scheduling stateid recovery for server localhost
> [14231.189059] NFS call  test_stateid ffff88005e979f24
> [14231.189064] --> nfs41_call_sync_prepare data->seq_server ffff8800aadcb000
> [14231.189065] --> nfs41_setup_sequence
> [14231.189066] --> nfs4_alloc_slot used_slots=0000 highest_used=4294967295 max_slots=31
> [14231.189067] <-- nfs4_alloc_slot used_slots=0001 highest_used=0 slotid=0
> [14231.189068] <-- nfs41_setup_sequence slotid=0 seqid=3355913
> [14231.189077] encode_sequence: sessionid=1474050426:3:4:0 seqid=3355913 slotid=0 max_slotid=0 cache_this=0
> [14231.189289] --> nfs4_alloc_slot used_slots=0001 highest_used=0 max_slots=31
> [14231.189290] <-- nfs4_alloc_slot used_slots=0003 highest_used=1 slotid=1
> [14231.189291] nfs4_free_slot: slotid 1 highest_used_slotid 0
> [14231.189292] nfs41_sequence_process: Error 0 free the slot 
> [14231.189294] nfs4_free_slot: slotid 0 highest_used_slotid 4294967295
> [14231.189311] NFS reply test_stateid: succeeded, 0
> [14231.189320] --> nfs_put_client({3})
> [14231.189373] --> nfs_put_client({2})
> [14231.189380] --> nfs41_call_sync_prepare data->seq_server ffff8800aadcb000
> [14231.189381] --> nfs41_setup_sequence
> [14231.189382] --> nfs4_alloc_slot used_slots=0000 highest_used=4294967295 max_slots=31
> [14231.189383] <-- nfs4_alloc_slot used_slots=0001 highest_used=0 slotid=0
> [14231.189384] <-- nfs41_setup_sequence slotid=0 seqid=3355914
> [14231.189393] encode_sequence: sessionid=1474050426:3:4:0 seqid=3355914 slotid=0 max_slotid=0 cache_this=1
> [14231.193709] --> nfs4_alloc_slot used_slots=0001 highest_used=0 max_slots=31
> [14231.193710] <-- nfs4_alloc_slot used_slots=0003 highest_used=1 slotid=1
> [14231.193712] nfs4_free_slot: slotid 1 highest_used_slotid 0
> [14231.193713] nfs41_sequence_process: Error 0 free the slot 
> [14231.193715] nfs4_free_slot: slotid 0 highest_used_slotid 4294967295
> [14231.193742] nfs4_schedule_stateid_recovery: scheduling stateid recovery for server localhost
> 
> 

