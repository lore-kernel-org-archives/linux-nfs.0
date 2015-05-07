Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ie0-f175.google.com ([209.85.223.175]:34601 "EHLO
	mail-ie0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751053AbbEGRE7 convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 7 May 2015 13:04:59 -0400
Received: by iedfl3 with SMTP id fl3so49634472ied.1
        for <linux-nfs@vger.kernel.org>; Thu, 07 May 2015 10:04:58 -0700 (PDT)
MIME-Version: 1.0
Date: Thu, 7 May 2015 13:04:58 -0400
Message-ID: <CAN-5tyG8ukoGJATK1RA85xv9BDikfC1CPP0nc=-80h=BSGV6=w@mail.gmail.com>
Subject: 4.0 NFS client in infinite loop in state recovery after getting BAD_STATEID
From: Olga Kornievskaia <aglo@umich.edu>
To: Trond Myklebust <trond.myklebust@primarydata.com>,
        linux-nfs <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi folks,

Problem:
The upstream nfs4.0 client has problem where it will go into an
infinite loop of re-sending an OPEN when it's trying to recover from
receiving a BAD_STATEID error on an IO operation such READ or WRITE.

How to easily reproduce (by using fault injection):
1. Do nfs4.0 mount to a server.
2. Open a file such that the server gives you a write delegation.
3. Do a write. Have a server return a BAD_STATEID. One way to do so is
by using a python proxy, nfs4proxy, and inject BAD_STATEID error on
WRITE.
4. And off it goes with the loop.

Here’s why….

IO op like WRITE receives a BAD_STATEID.
1. for this error, in async handle error we  call
nfs4_schedule_stateid_recover()
2. that in turn will call nfs4_state_mark_reclaim_nograce() that will
set a RECLAIM_NOGRACE in the state flags.
3. state manager thread will run and call nfs4_do_reclaim() to recover.
4. that will call nfs4_reclaim_open_state()

in that function:

restart:
for open states in state
test if RECLAIM_NOGRACE is set in state flags, if so clear it (it’s
set and we’ll clear it)
check open_stateid (checks if RECOVERY_FAILED is not set) (it’s not)
checks if we have state
calls ops->recover_open()

for nfs4.0, it’ll call nfs40_open_expired()
it’ll call nfs40_clear_delegation_stateid()
it’ll call nfs_finish_clear_delegation_stateid()
it’ll call nfs_remove_bad_delegation()
it’ll call nfs_inode_find_state_and_recover()
it’ll call nfs4_state_mark_reclaim_nograce() **** this will set
RECLAIM_NOGRACE in state flags

we return from recover_open() with status 0
call nfs4_reclaim_locks() returns 0 then
goto restart; **************  what happens is since we reset the flag
in the state flags the whole loop starts again.

Solution:
nfs_remove_bad_delegation() is only called from
nfs_finish_clear_delegation_stateid() which is called from either 4.0
or 4.1 recover open functions in nograce case. In both cases, this is
already state manager doing recovery based on the RECLAIM_NOGRACE flag
set and it's going thru opens that need to be recovered.

I propose to correct the loop by removing the call:
diff --git a/fs/nfs/delegation.c b/fs/nfs/delegation.c
index 4711d04..b322823 100644
--- a/fs/nfs/delegation.c
+++ b/fs/nfs/delegation.c
@@ -632,10 +632,8 @@ void nfs_remove_bad_delegation(struct inode *inode)

        nfs_revoke_delegation(inode);
        delegation = nfs_inode_detach_delegation(inode);
-       if (delegation) {
-               nfs_inode_find_state_and_recover(inode, &delegation->stateid);
+       if (delegation)
                nfs_free_delegation(delegation);
-       }
 }
 EXPORT_SYMBOL_GPL(nfs_remove_bad_delegation);
