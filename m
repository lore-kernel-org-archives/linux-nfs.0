Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:54714 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S936080AbdJQOqQ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 17 Oct 2017 10:46:16 -0400
From: Benjamin Coddington <bcodding@redhat.com>
To: Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 0/3] NFSv4.1: OPEN and CLOSE/DOWNGRADE race
Date: Tue, 17 Oct 2017 10:46:12 -0400
Message-Id: <cover.1508248965.git.bcodding@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

While running generic/089 on v4.1, I noticed the client was doing a lot of
unexpected state recovery.  Some investigation shows the following exchange
on the wire:

Client                  Server
----------              ----------
OPEN1 (owner A)  ->
OPEN2 (owner A)  ->
                    <-  OPEN1 response: state A1
                    <-  OPEN2 response: state A2
CLOSE (state A2)->
                    <-  CLOSE response: state A3
LOCK (state A1) ->
                    <-  LOCK response: NFS4ERR_BAD_STATEID

Observation of the client's tracepoints show that the first OPEN's response
is not handled by the client until after the second OPEN then CLOSE of the
state.  Since both OPENs are done with CLAIM_FH, we have references to the
nfs4_state on the opendata, so it sticks around around, and we incorrectly
transition the nfs4_state back to NFS_OPEN_STATE with the first OPEN's
sequence number.

I investigated various ways of bringing back partial sequencing to OPENs
with the same owner or OPENs and CLOSE, but I didn't like bringing back the
allocations and extra checks for the sequence ids.

I then looked at detecting this race by "noticing" holes in the state's
sequence number and keeping a count of the holes on the state, so a CLOSE
could be deferred until all OPENs complete, but this seemed to be too much
machinery to add to the state handling logic.

I finally ended up deciding to have the first OPEN retry if it loses the
race updating the state.  Doing that, unfortunately, means that I needed to
move a bunch of code around so that if nfs_need_update_stateid() == false,
the OPEN can be re-sent.  The end result nets a few less lines of code.

This race still exists, however, and will occur more rarely on generic/089 if
we are using CLAIM_NULL because there is still a way for the first OPEN's
response to allocate a new nfs4_state with the old stateid and sequence
number long after that state has been closed and its nfs4_state cleaned up
by the second OPEN and CLOSE.  Fixing that may require creating a record of
"pending opens" that can be used to either defer the CLOSE, or retry the
losing OPEN.  Another way may be to keep closed nfs4_state around for a bit
to detect this race, and cleanup of closed states can be batched later.
This set doesn't try to fix that race since it is rarely seen.

Patches 1 and 2 just open-code __update_open_stateid and
nfs_set_open_state_locked respectively.  They should not change any
behavior.  Patch 3 causes the OPEN to be retried if the stateid should not
be updated.

Comments and critique are welcome;  I'd very much like to know if there's
any desire to fix this race for both cases.

Ben

Benjamin Coddington (3):
  NFSv4: Move __update_open_stateid() into update_open_stateid()
  NFSv4: Move nfs_set_open_stateid_locked into update_open_stateid()
  NFSv4.1: Detect and retry after OPEN and CLOSE/DOWNGRADE race

 fs/nfs/nfs4proc.c | 118 ++++++++++++++++++++++++++----------------------------
 1 file changed, 56 insertions(+), 62 deletions(-)

-- 
2.9.3

