Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qg0-f44.google.com ([209.85.192.44]:41391 "EHLO
	mail-qg0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752531AbaKCQkq (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 3 Nov 2014 11:40:46 -0500
Received: by mail-qg0-f44.google.com with SMTP id q107so8931723qgd.17
        for <linux-nfs@vger.kernel.org>; Mon, 03 Nov 2014 08:40:45 -0800 (PST)
From: Ming Chen <mchen@cs.stonybrook.edu>
To: linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org
Cc: bfields@fieldses.org, trond.myklebust@primarydata.com,
        ezk@fsl.cs.stonybrook.edu, nfs-ganesha-devel@lists.sourceforge.net,
        Ming Chen <mchen@cs.stonybrook.edu>
Subject: [PATCH] nfs: avoid nfs_wait_on_seqid() for NFSv4.1
Date: Mon,  3 Nov 2014 11:39:26 -0500
Message-Id: <1415032766-15673-1-git-send-email-mchen@cs.stonybrook.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

seqid, introduced in NFSv4.0, requires state-changing operations be performed
synchronously, and thus limits parallelism. NFSv4.1 supports "unlimited
parallelism" by using sessions and slots; seqid is no longer used and must be
ignored by NFSv4.1 server. However, the current nfs client always call
nfs_wait_on_seqid() no matter the version is 4.0 or 4.1.

nfs_wait_on_seqid() can be very slow in high-latency network. Using the
Filebench file server workload and the following systemtap script, we measured
the "Seqid_waitqueue" introduced an average 344ms delay in a 10ms-rtt network.

global sleep_count;
global sleep_time;
global sleep_duration;

// called in '__rpc_sleep_on_priority()'
probe kernel.trace("rpc_task_sleep") {
        name = kernel_string($q->name);
        sleep_time[name, $task] = gettimeofday_us();
}

// called in '__rpc_do_wake_up_task()'
probe kernel.trace("rpc_task_wakeup") {
        name = kernel_string($q->name);
        now = gettimeofday_us();
        old = sleep_time[name, $task];
        if (old) {
                sleep_count[name] += 1;
                sleep_duration[name] += now - old;
                delete sleep_time[name, $task];
        }
}

probe end {
        foreach (name in sleep_count) {
                printf("\"%s\" -- sleep count: %d; sleep time: %ld us\n",
                                name, sleep_count[name],
                                sleep_duration[name] / sleep_count[name]);
        }
}

Systemtap output:
        "xprt_pending" -- sleep count: 20051; sleep time: 10453 us
        "xprt_sending" -- sleep count: 2489; sleep time: 43 us
        "ForeChannel Slot table" -- sleep count: 37; sleep time: 731 us
        "Seqid_waitqueue" -- sleep count: 7428; sleep time: 343774 us

This patch avoids the unnecessary nfs_wait_on_seqid() operations for NFSv4.1.
It improves the speed of the Filebench file server workload from 175 ops/sec
to 1550 ops/sec.

This patch is based on 3.18-rc3, and has been tested in 3.14.17 and 3.18-rc3.

Signed-off-by: Ming Chen <mchen@cs.stonybrook.edu>
---
 fs/nfs/nfs4proc.c | 15 ++++++++++-----
 1 file changed, 10 insertions(+), 5 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 405bd95..be06010 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -1778,7 +1778,8 @@ static void nfs4_open_prepare(struct rpc_task *task, void *calldata)
 	struct nfs4_state_owner *sp = data->owner;
 	struct nfs_client *clp = sp->so_server->nfs_client;
 
-	if (nfs_wait_on_sequence(data->o_arg.seqid, task) != 0)
+	if (!nfs4_get_session(sp->so_server) &&
+	    nfs_wait_on_sequence(data->o_arg.seqid, task) != 0)
 		goto out_wait;
 	/*
 	 * Check if we still need to send an OPEN call, or if we can use
@@ -2617,7 +2618,8 @@ static void nfs4_close_prepare(struct rpc_task *task, void *data)
 	int call_close = 0;
 
 	dprintk("%s: begin!\n", __func__);
-	if (nfs_wait_on_sequence(calldata->arg.seqid, task) != 0)
+	if (!nfs4_get_session(state->owner->so_server) &&
+	    nfs_wait_on_sequence(calldata->arg.seqid, task) != 0)
 		goto out_wait;
 
 	task->tk_msg.rpc_proc = &nfs4_procedures[NFSPROC4_CLNT_OPEN_DOWNGRADE];
@@ -5399,7 +5401,8 @@ static void nfs4_locku_prepare(struct rpc_task *task, void *data)
 {
 	struct nfs4_unlockdata *calldata = data;
 
-	if (nfs_wait_on_sequence(calldata->arg.seqid, task) != 0)
+	if (!nfs4_get_session(calldata->server) &&
+	    nfs_wait_on_sequence(calldata->arg.seqid, task) != 0)
 		goto out_wait;
 	if (test_bit(NFS_LOCK_INITIALIZED, &calldata->lsp->ls_flags) == 0) {
 		/* Note: exit _without_ running nfs4_locku_done */
@@ -5566,11 +5569,13 @@ static void nfs4_lock_prepare(struct rpc_task *task, void *calldata)
 	struct nfs4_state *state = data->lsp->ls_state;
 
 	dprintk("%s: begin!\n", __func__);
-	if (nfs_wait_on_sequence(data->arg.lock_seqid, task) != 0)
+	if (!nfs4_get_session(data->server) &&
+	    nfs_wait_on_sequence(data->arg.lock_seqid, task) != 0)
 		goto out_wait;
 	/* Do we need to do an open_to_lock_owner? */
 	if (!(data->arg.lock_seqid->sequence->flags & NFS_SEQID_CONFIRMED)) {
-		if (nfs_wait_on_sequence(data->arg.open_seqid, task) != 0) {
+		if (!nfs4_get_session(data->server) &&
+		    nfs_wait_on_sequence(data->arg.open_seqid, task) != 0) {
 			goto out_release_lock_seqid;
 		}
 		data->arg.open_stateid = &state->open_stateid;
-- 
1.8.1.2

