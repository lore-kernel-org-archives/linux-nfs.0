Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:50622 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1728003AbeJESpp (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 5 Oct 2018 14:45:45 -0400
From: "Benjamin Coddington" <bcodding@redhat.com>
To: "Stan Hu" <stanhu@gmail.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: High network traffic from repeated TEST_STATEID messages
Date: Fri, 05 Oct 2018 07:47:20 -0400
Message-ID: <4AEBA335-FFA9-4124-8FE7-5A8C28134E2C@redhat.com>
In-Reply-To: <CAMBWrQnS4MyrgyGUqr5rhOTm+ss2AYy-vNXjj4+fzqY+cuE=tw@mail.gmail.com>
References: <CAMBWrQnS4MyrgyGUqr5rhOTm+ss2AYy-vNXjj4+fzqY+cuE=tw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Stan,

RedHat has a bz for what seems like the same problem:
https://bugzilla.redhat.com/show_bug.cgi?id=1552203

.. though there's only mixed reports of success after applying
95da1b3a5aded124dd1bda1e3cdb876184813140 to the server.  Is this a linux
server, and what vintage?  I suspect there's may be a client bug here as
well.

Ben

On 5 Oct 2018, at 2:35, Stan Hu wrote:

> I've been working with two different customers, one running RedHat
> Enterprise Linux 7.3 (3.10.06-693.21.1) and another on Amazon Linux
> (based off CentOS). Independently they hit a problem that may be
> induced by our application where NFS v4.1 gets into a state where the
> network is flooded with TEST_STATEID messages (e.g. 2000+ packets/s)
> with the SEQ4_STATUS_RECALLABLE_STATE_REVOKED bit enabled on all
> server replies. When this happens, NFS is incredibly slow and
> unusable. It doesn't appear to get out of this state without manual
> intervention.
>
> The server appears to return each of these TEST_STATEIDs with NFS4_OK 
> messages.
>
> In a 17-second network trace on one of the NFS client machines, I see
> 18,411 TEST_STATEID requests with 1,362 unique stateid values (based
> off Wireshark's dissected "StateID Other" field).
>
> In another 82-second trace, I see 308,877 TEST_STATEID requests with
> 769 unique stateid values.
>
> A sample except from the NFS client kernel logs shows:
>
> Oct  4 22:05:40 gitlab-cff6b07b kernel: NFS call  test_stateid 
> ffff8807697efe14
> Oct  4 22:05:40 gitlab-cff6b07b kernel: --> nfs41_call_sync_prepare
> data->seq_server ffff880795748800
> Oct  4 22:05:40 gitlab-cff6b07b kernel: --> nfs41_setup_sequence
> Oct  4 22:05:40 gitlab-cff6b07b kernel: --> nfs4_alloc_slot
> used_slots=0000 highest_used=4294967295 max_slots=31
> Oct  4 22:05:40 gitlab-cff6b07b kernel: <-- nfs4_alloc_slot
> used_slots=0001 highest_used=0 slotid=0
> Oct  4 22:05:40 gitlab-cff6b07b kernel: <-- nfs41_setup_sequence
> slotid=0 seqid=150890619
> Oct  4 22:05:40 gitlab-cff6b07b kernel: encode_sequence:
> sessionid=1536619925:3417519922:3:0 seqid=150890619 slotid=0
> max_slotid=0 cache_this=0
> Oct  4 22:05:40 gitlab-cff6b07b kernel:
> nfs41_handle_sequence_flag_errors: "10.44.1.54" (client ID
> 95f5965b3237b3cb) flags=0x00000040
> Oct  4 22:05:40 gitlab-cff6b07b kernel: --> nfs4_alloc_slot
> used_slots=0001 highest_used=0 max_slots=31
> Oct  4 22:05:40 gitlab-cff6b07b kernel: <-- nfs4_alloc_slot
> used_slots=0003 highest_used=1 slotid=1
> Oct  4 22:05:40 gitlab-cff6b07b kernel: nfs4_free_slot: slotid 1
> highest_used_slotid 0
> Oct  4 22:05:40 gitlab-cff6b07b kernel: nfs41_sequence_process: Error
> 0 free the slot
> Oct  4 22:05:40 gitlab-cff6b07b kernel: nfs4_free_slot: slotid 0
> highest_used_slotid 4294967295
> Oct  4 22:05:40 gitlab-cff6b07b kernel: NFS reply test_stateid: 
> succeeded, 0
> Oct  4 22:05:40 gitlab-cff6b07b kernel: NFS call  test_stateid 
> ffff8807697efe14
> <snip>
>
> Then a few minutes later, these -10052 (NFS4ERR_BADSESSION) errors 
> show up:
>
> Oct  4 22:07:42 gitlab-cff6b07b kernel: nfs41_sequence_process: Error
> -10052 free the slot
> Oct  4 22:07:42 gitlab-cff6b07b kernel: nfs4_free_slot: slotid 20
> highest_used_slotid 30
> Oct  4 22:07:42 gitlab-cff6b07b kernel: nfs4_do_handle_exception
> ERROR: -10052 Reset session
> Oct  4 22:07:42 gitlab-cff6b07b kernel: nfs4_schedule_lease_recovery:
> scheduling lease recovery for server 10.44.1.54
> Oct  4 22:07:42 gitlab-cff6b07b kernel: nfs41_sequence_process: Error
> -10052 free the slot
> Oct  4 22:07:42 gitlab-cff6b07b kernel: nfs4_free_slot: slotid 18
> highest_used_slotid 30
> Oct  4 22:07:42 gitlab-cff6b07b kernel: nfs4_do_handle_exception
> ERROR: -10052 Reset session
> Oct  4 22:07:42 gitlab-cff6b07b kernel: nfs4_schedule_lease_recovery:
> scheduling lease recovery for server 10.44.1.54
> Oct  4 22:07:42 gitlab-cff6b07b kernel: nfs41_sequence_process: Error
> -10052 free the slot
> Oct  4 22:07:42 gitlab-cff6b07b kernel: nfs4_free_slot: slotid 4
> highest_used_slotid 30
> Oct  4 22:07:42 gitlab-cff6b07b kernel: nfs4_do_handle_exception
> ERROR: -10052 Reset session
> Oct  4 22:07:42 gitlab-cff6b07b kernel: nfs4_schedule_lease_recovery:
> scheduling lease recovery for server 10.44.1.54
> Oct  4 22:07:42 gitlab-cff6b07b rsyslogd-2177: imjournal: begin to
> drop messages due to rate-limiting
>
> I see some discussion in
> https://www.spinics.net/lists/linux-nfs/msg59800.html perhaps for a
> similar issue.
>
> I'd expect that after some time, the client and server would reconcile
> the proper delegation state, but this doesn't seem to be happening.
> The only way to recover seems to be to stop the application, unmount
> the NFS mount, remount it again, and start the application back up.
>
> I'm wondering a number of things:
>
> 1. Has anyone seen this behavior before?
> 2. Does anyone have any idea what might induce this behavior? I'm
> going to see if I can reproduce this by having a process that has
> 1,000+ open NFS files, blocking network traffic momentarily with
> iptables, and then seeing how the system performs.
> 3. Is there a way to see what open delegations are on the client and 
> the server?
