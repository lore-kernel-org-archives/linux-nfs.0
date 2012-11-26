Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:10285 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755445Ab2KZUQy (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 26 Nov 2012 15:16:54 -0500
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH v2 00/27] NFSv4.1: Add support for session dynamic slot management
Date: Mon, 26 Nov 2012 15:16:17 -0500
Message-Id: <1353961005-63874-1-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This patch series adds support for session dynamic slot management
in accordance with Section 2.10.6.1 of RFC5661.

By tracking the sr_target_highest_slotid and sr_highest_slotid in the
server's replies to our SEQUENCE operations, we can figure out when
it is safe to increase the number of RPC requests that go in parallel
to the server, and when we should decrease that number.

Changes w.r.t v1:

 - Retry slot allocation within 1/4 second if an allocation failed due
   to an OOM condition
 - Move NFSv4.1 session handling into a separate file, fs/nfs/nfs4session.c
 - Increase the slot table size limit to 1024


Trond Myklebust (28):
  NFSv4.1: Handle session reset and bind_conn_to_session before lease
    check
  NFSv4.1: Don't confuse CREATE_SESSION arguments and results
  NFSv4.1: Adjust CREATE_SESSION arguments when mounting a new
    filesystem
  NFSv4.1: We must bump the clientid sequence number after
    CREATE_SESSION
  NFSv4.1: nfs4_alloc_slots doesn't need zeroing
  NFSv4.1: clean up nfs4_recall_slot to use nfs4_alloc_slots
  NFSv4.1: Shrink struct nfs4_sequence_res by moving sr_renewal_time
  NFSv4.1: Shrink struct nfs4_sequence_res by moving the session
    pointer
  NFSv4.1: Label each entry in the session slot tables with its slot
    number
  NFSv4.1: Simplify struct nfs4_sequence_args too
  NFSv4.1: Simplify slot allocation
  NFSv4.1: Clean up nfs4_free_slot
  NFSv4.1: Ensure that the client tracks the server
    target_highest_slotid
  NFSv4.1: Reset the sequence number for slots that have been
    deallocated
  NFSv4.1: Fix nfs4_callback_recallslot to work with dynamic slot
    allocation
  NFSv4.1: Don't confuse target_highest_slotid and max_slots in
    cb_recall_slot
  NFSv4.1: Allow the server to recall all but one slot
  NFSv4.1: Support dynamic resizing of the session slot table
  NFSv4.1: Allow SEQUENCE to resize the slot table on the fly
  NFSv4.1: Remove the state manager code to resize the slot table
  NFSv4.1: CB_RECALL_SLOT must schedule a sequence op after updating
    targets
  NFSv4.1: If slot allocation fails due to OOM, retry more quickly
  NFSv4.1: Clean up session draining
  NFSv4: Move nfs4_wait_clnt_recover and
    nfs4_client_recover_expired_lease
  NFSv4.1: Cleanup move session slot management to fs/nfs/nfs4session.c
  Remove unused function slot_idx
  NFSv4.1: Move slot table and session struct definitions to
    nfs4session.h
  NFSv4.1: Set the maximum slot table size to 1024 slots

 fs/nfs/Makefile            |   2 +-
 fs/nfs/callback.h          |   4 +-
 fs/nfs/callback_proc.c     |  16 +-
 fs/nfs/callback_xdr.c      |   5 +-
 fs/nfs/internal.h          |  23 ---
 fs/nfs/nfs4_fs.h           |  21 +--
 fs/nfs/nfs4client.c        |   1 +
 fs/nfs/nfs4filelayout.c    |   1 +
 fs/nfs/nfs4filelayoutdev.c |   1 +
 fs/nfs/nfs4proc.c          | 418 +++++--------------------------------------
 fs/nfs/nfs4session.c       | 436 +++++++++++++++++++++++++++++++++++++++++++++
 fs/nfs/nfs4session.h       | 136 ++++++++++++++
 fs/nfs/nfs4state.c         | 104 +++++------
 fs/nfs/nfs4xdr.c           |  38 ++--
 fs/nfs/super.c             |   1 +
 include/linux/nfs_fs_sb.h  |  47 -----
 include/linux/nfs_xdr.h    |  13 +-
 17 files changed, 710 insertions(+), 557 deletions(-)
 create mode 100644 fs/nfs/nfs4session.c
 create mode 100644 fs/nfs/nfs4session.h

-- 
1.7.11.7

