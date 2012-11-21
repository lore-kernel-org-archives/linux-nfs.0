Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:65252 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754206Ab2KVSnY (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 22 Nov 2012 13:43:24 -0500
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 00/20] NFSv4.1: Add support for session dynamic slot management
Date: Wed, 21 Nov 2012 17:42:59 -0500
Message-Id: <1353537799-60488-1-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This patch series adds support for session dynamic slot management
in accordance with Section 2.10.6.1 of RFC5661.

By tracking the sr_target_highest_slotid and sr_highest_slotid in the
server's replies to our SEQUENCE operations, we can figure out when
it is safe to increase the number of RPC requests that go in parallel
to the server, and when we should decrease that number.


Trond Myklebust (20):
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

 fs/nfs/callback.h         |   2 +-
 fs/nfs/callback_proc.c    |  15 +--
 fs/nfs/callback_xdr.c     |   2 +-
 fs/nfs/nfs4_fs.h          |   6 +-
 fs/nfs/nfs4proc.c         | 316 ++++++++++++++++++++++++++++++++--------------
 fs/nfs/nfs4state.c        |  52 +-------
 fs/nfs/nfs4xdr.c          |  37 +++---
 include/linux/nfs_fs_sb.h |  11 +-
 include/linux/nfs_xdr.h   |  12 +-
 9 files changed, 275 insertions(+), 178 deletions(-)

-- 
1.7.11.7

