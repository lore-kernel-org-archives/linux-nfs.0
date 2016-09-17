Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from us-smtp-delivery-194.mimecast.com ([63.128.21.194]:45214 "EHLO
        us-smtp-delivery-194.mimecast.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1753271AbcIQSSP (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sat, 17 Sep 2016 14:18:15 -0400
From: Trond Myklebust <trondmy@primarydata.com>
To: Oleg Drokin <green@linuxhacker.ru>
CC: Schumaker Anna <anna.schumaker@netapp.com>,
        List Linux NFS Mailing <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH v5 00/25] Fix delegation behaviour when server revokes
 some state
Date: Sat, 17 Sep 2016 18:18:08 +0000
Message-ID: <CCA85800-84C2-4B80-A44D-966F79EC5892@primarydata.com>
References: <1474089213-104014-1-git-send-email-trond.myklebust@primarydata.com>
 <838E325D-2DA1-4229-A046-76316302F813@linuxhacker.ru>
In-Reply-To: <838E325D-2DA1-4229-A046-76316302F813@linuxhacker.ru>
MIME-Version: 1.0
Content-Type: text/plain; charset=WINDOWS-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


> On Sep 17, 2016, at 14:04, Oleg Drokin <green@linuxhacker.ru> wrote:
>=20
>=20
> On Sep 17, 2016, at 1:13 AM, Trond Myklebust wrote:
>=20
>> According to RFC5661, if any of the SEQUENCE status bits
>> SEQ4_STATUS_EXPIRED_ALL_STATE_REVOKED,
>> SEQ4_STATUS_EXPIRED_SOME_STATE_REVOKED, SEQ4_STATUS_ADMIN_STATE_REVOKED,
>> or SEQ4_STATUS_RECALLABLE_STATE_REVOKED are set, then we need to use
>> TEST_STATEID to figure out which stateids have been revoked, so we
>> can acknowledge the loss of state using FREE_STATEID.
>>=20
>> While we already do this for open and lock state, we have not been doing
>> so for all the delegations.
>>=20
>> v2: nfs_v4_2_minor_ops needs to set .test_and_free_expired too
>> v3: Now with added lock revoke fixes and close/delegreturn/locku fixes
>> v4: Close a bunch of corner cases
>> v5: Report revoked delegations as invalid in nfs_have_delegation()
>>   Fix an infinite loop in nfs_reap_expired_delegations.
>>   Fixes for other looping behaviour
>=20
> This time around the loop seems to be more tight,
> in userspace process:
>=20
> [ 9197.256571] --> nfs41_call_sync_prepare data->seq_server ffff8800a73ce=
000
> [ 9197.256572] --> nfs41_setup_sequence
> [ 9197.256573] --> nfs4_alloc_slot used_slots=3D0000 highest_used=3D42949=
67295 max_slots=3D31
> [ 9197.256574] <-- nfs4_alloc_slot used_slots=3D0001 highest_used=3D0 slo=
tid=3D0
> [ 9197.256574] <-- nfs41_setup_sequence slotid=3D0 seqid=3D14013800
> [ 9197.256582] encode_sequence: sessionid=3D1474126170:1:2:0 seqid=3D1401=
3800 slotid=3D0 max_slotid=3D0 cache_this=3D1
> [ 9197.256755] --> nfs4_alloc_slot used_slots=3D0001 highest_used=3D0 max=
_slots=3D31
> [ 9197.256756] <-- nfs4_alloc_slot used_slots=3D0003 highest_used=3D1 slo=
tid=3D1
> [ 9197.256757] nfs4_free_slot: slotid 1 highest_used_slotid 0
> [ 9197.256758] nfs41_sequence_process: Error 0 free the slot=20
> [ 9197.256760] nfs4_free_slot: slotid 0 highest_used_slotid 4294967295
> [ 9197.256779] --> nfs_put_client({2})

What operation is the userspace process hanging on? Do you have a stack tra=
ce for it?

