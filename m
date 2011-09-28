Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:65318 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751372Ab1I1Btc (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 27 Sep 2011 21:49:32 -0400
Date: Tue, 27 Sep 2011 21:49:31 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: Bryan Schumaker <bjschuma@netapp.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH 03/25] nfsd4: extend state lock over seqid replay logic
Message-ID: <20110928014930.GA18571@pad.fieldses.org>
References: <1316000721-3289-1-git-send-email-bfields@redhat.com>
 <1316000721-3289-4-git-send-email-bfields@redhat.com>
 <4E82001C.5030005@netapp.com>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <4E82001C.5030005@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Tue, Sep 27, 2011 at 12:55:56PM -0400, Bryan Schumaker wrote:
> I'm getting the following warning that I was able to bisect to this patch:

I suspect this may fix it.  (Untested.)

--b.

commit 8da87285a245c82d23183414cec7069f18721afd
Author: J. Bruce Fields <bfields@redhat.com>
Date:   Tue Sep 27 21:42:29 2011 -0400

    nfsd4: fix state lock usage in LOCKU
    
    In commit 5ec094c1096ab3bb795651855d53f18daa26afde "nfsd4: extend state
    lock over seqid replay logic" I modified the exit logic of all the
    seqid-based procedures except nfsd4_locku().  Fix the oversight.
    
    The result of the bug was a double-unlock while handling the LOCKU
    procedure, and a warning like:
    
    [  142.150014] WARNING: at kernel/mutex-debug.c:78 debug_mutex_unlock+0xda/0xe0()
    ...
    [  142.152927] Pid: 742, comm: nfsd Not tainted 3.1.0-rc1-SLIM+ #9
    [  142.152927] Call Trace:
    [  142.152927]  [<ffffffff8105fa4f>] warn_slowpath_common+0x7f/0xc0
    [  142.152927]  [<ffffffff8105faaa>] warn_slowpath_null+0x1a/0x20
    [  142.152927]  [<ffffffff810960ca>] debug_mutex_unlock+0xda/0xe0
    [  142.152927]  [<ffffffff813e4200>] __mutex_unlock_slowpath+0x80/0x140
    [  142.152927]  [<ffffffff813e42ce>] mutex_unlock+0xe/0x10
    [  142.152927]  [<ffffffffa03bd3f5>] nfs4_lock_state+0x35/0x40 [nfsd]
    [  142.152927]  [<ffffffffa03b0b71>] nfsd4_proc_compound+0x2a1/0x690
    [nfsd]
    [  142.152927]  [<ffffffffa039f9fb>] nfsd_dispatch+0xeb/0x230 [nfsd]
    [  142.152927]  [<ffffffffa02b1055>] svc_process_common+0x345/0x690
    [sunrpc]
    [  142.152927]  [<ffffffff81058d10>] ? try_to_wake_up+0x280/0x280
    [  142.152927]  [<ffffffffa02b16e2>] svc_process+0x102/0x150 [sunrpc]
    [  142.152927]  [<ffffffffa039f0bd>] nfsd+0xbd/0x160 [nfsd]
    [  142.152927]  [<ffffffffa039f000>] ? 0xffffffffa039efff
    [  142.152927]  [<ffffffff8108230c>] kthread+0x8c/0xa0
    [  142.152927]  [<ffffffff813e8694>] kernel_thread_helper+0x4/0x10
    [  142.152927]  [<ffffffff81082280>] ? kthread_worker_fn+0x190/0x190
    [  142.152927]  [<ffffffff813e8690>] ? gs_change+0x13/0x13
    
    Reported-by: Bryan Schumaker <bjschuma@netapp.com>
    Signed-off-by: J. Bruce Fields <bfields@redhat.com>

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 752c0f8..9daf254 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -4199,7 +4199,8 @@ nfsd4_locku(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 	memcpy(&locku->lu_stateid, &stp->st_stid.sc_stateid, sizeof(stateid_t));
 
 out:
-	nfs4_unlock_state();
+	if (!cstate->replay_owner)
+		nfs4_unlock_state();
 	return status;
 
 out_nfserr:
