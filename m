Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f170.google.com ([209.85.223.170]:35477 "EHLO
	mail-io0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752107AbbINXyh convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 14 Sep 2015 19:54:37 -0400
Received: by ioiz6 with SMTP id z6so183868229ioi.2
        for <linux-nfs@vger.kernel.org>; Mon, 14 Sep 2015 16:54:37 -0700 (PDT)
MIME-Version: 1.0
Date: Mon, 14 Sep 2015 19:54:36 -0400
Message-ID: <CAN-5tyF_cHmiPvEqv8N8S_J-TBymOZV+-A0Vh+GCnP3czFB-wg@mail.gmail.com>
Subject: Failing to send a CLOSE if file is opened WRONLY and server reboots
 on a 4.x mount
From: Olga Kornievskaia <aglo@umich.edu>
To: linux-nfs <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

A test case is as the description says:
open(foobar, O_WRONLY);
sleep()  --> reboot the server
close(foobar)

The bug is because in nfs4state.c in nfs4_reclaim_open_state() a few
line before going to restart, there is
clear_bit(NFS4CLNT_RECLAIM_NOGRACE, &state->flags).

NFS4CLNT_RECLAIM_NOGRACE is a flag for the client states not open
owner states. Value of NFS4CLNT_RECLAIM_NOGRACE is 4 which is the
value of NFS_O_WRONLY_STATE in nfs4_state->flags. So clearing it wipes
out state and when we go to close it, “call_close” doesn’t get set as
state flag is not set and CLOSE doesn’t go on the wire.

That line was introduced to fix an infinite loop for OPEN recovery
upon receiving a BAD_STATEID error: commit e8d975e73. I have tested
injecting BAD_STATEID error using the patch below and the code
recovers without problems. However, I'm not sure the clearing of the
bit is needed any more. I have tested for infinite loop by reverting
the patch and didn't hit the infinite loop.

diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
index da73bc4..5db3246 100644
--- a/fs/nfs/nfs4state.c
+++ b/fs/nfs/nfs4state.c
@@ -1481,7 +1481,7 @@ restart:
                                        spin_unlock(&state->state_lock);
                                }
                                nfs4_put_open_state(state);
-                               clear_bit(NFS4CLNT_RECLAIM_NOGRACE,
+                               clear_bit(NFS_STATE_RECLAIM_NOGRACE,
                                        &state->flags);
                                spin_lock(&sp->so_lock);
                                goto restart;
