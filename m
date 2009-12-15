From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: Re: null dereference in nfs4_begin_drain_session
Date: Tue, 15 Dec 2009 17:52:20 -0500
Message-ID: <1260917540.3219.2.camel@localhost>
References: <20091215222449.GD8686@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: linux-nfs@vger.kernel.org
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:55012 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933855AbZLOWxK convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 15 Dec 2009 17:53:10 -0500
In-Reply-To: <20091215222449.GD8686@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 2009-12-15 at 17:24 -0500, J. Bruce Fields wrote: 
> I got this just now on a test client running a branch including (among
> other stuff) your 72211dbe727f7c1451aa5adfcbd1197b090eb276.  Looks like
> it was trying to run cthon tests over v4.0.  Anything known?  Let me
> know if you want anything more.
> 
> --b.
> 
> BUG: unable to handle kernel NULL pointer dereference at 00000088
> IP: [<c105b2bb>] __lock_acquire+0x21b/0x1880
> *pde = 00000000 
> Oops: 0000 [#1] PREEMPT 
> last sysfs file: /sys/kernel/uevent_seqnum
> Modules linked in:
> 
> Pid: 3137, comm: 192.168.122.129 Not tainted 2.6.32-07559-g0adf9c1 #553 /
> EIP: 0060:[<c105b2bb>] EFLAGS: 00010046 CPU: 0
> EIP is at __lock_acquire+0x21b/0x1880
> EAX: 00000084 EBX: c6be42a0 ECX: 00000000 EDX: 00000001
> ESI: 00000002 EDI: 00000000 EBP: c6bfff10 ESP: c6bffe9c
>  DS: 007b ES: 007b FS: 0000 GS: 0000 SS: 0068
> Process 192.168.122.129 (pid: 3137, ti=c6bfe000 task=c6be42a0 task.ti=c6bfe000)
> Stack:
>  00000046 00000046 00000000 00000000 00000000 00000000 00000000 c1b8a3e0
> <0> c6bfff0c c1ead970 c6be4760 00000041 c20d6b48 00000084 00000000 00000000
> <0> 00000000 00000000 0000094d 00000000 c1b8a3e0 c6bfff40 c10277f8 c6bfff00
> Call Trace:
>  [<c10277f8>] ? update_curr+0x208/0x270
>  [<c105c99e>] ? lock_acquire+0x7e/0x110
>  [<c120a628>] ? nfs4_begin_drain_session+0x28/0x80
>  [<c188f5d2>] ? _raw_spin_lock+0x42/0x50
>  [<c120a628>] ? nfs4_begin_drain_session+0x28/0x80
>  [<c120a628>] ? nfs4_begin_drain_session+0x28/0x80
>  [<c120b1e0>] ? nfs4_run_state_manager+0x0/0x430
>  [<c120b3e7>] ? nfs4_run_state_manager+0x207/0x430
>  [<c120b1e0>] ? nfs4_run_state_manager+0x0/0x430
>  [<c104ae54>] ? kthread+0x74/0x80
>  [<c104ade0>] ? kthread+0x0/0x80
>  [<c100333b>] ? kernel_thread_helper+0x7/0x10
> Code: fe ff ff e8 e8 ff 47 00 85 c0 74 dc 83 3d 20 0d 2a c2 00 75 d3 b8 75 6f a7 c1 ba b6 0a 00 00 e8 6c 2b fd ff 31 c0 eb c2 8b 45 c0 <8b> 40 04 85 c0 89 45 c8 0f 84 2b fe ff ff a1 c0 76 c7 c1 85 c0 
> EIP: [<c105b2bb>] __lock_acquire+0x21b/0x1880 SS:ESP 0068:c6bffe9c
> CR2: 0000000000000088
> ---[ end trace 93dafd3a9c985071 ]---
> note: 192.168.122.129[3137] exited with preempt_count 1
> 

The following patch should suffice to fix this...

Cheers
  Trond
----------------------------------------------------------------------------------------------------- 
commit 380454126f1357db9270f9d1ca05dfe1a6e4ad47
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Tue Dec 15 17:36:57 2009 -0500

    NFSv4: Fix a regression in the NFSv4 state manager
    
    Commit 5601a00d671fe89f9b087513244abcd08ad67e7d (nfs: run state manager
    in privileged mode) introduces a regression in the NFSv4 code when
    compiled with CONFIG_NFS_V4_1. The calls to nfs4_end_drain_session()
    from the main loop in nfs4_state_manager() Oops due to the lack of an
    NFSv4.1 session when running NFSv4.0.
    
    The fix is to move those two calls back into nfs41_init_clientid() and
    nfs4_reset_session().
    
    The calls to nfs4_end_drain_session() that remain inside
    nfs4_state_manager() are safe, since the NFSv4.0 code will never set the
    NFS4CLNT_SESSION_DRAINING bit.
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
index 18e8b26..6d263ed 100644
--- a/fs/nfs/nfs4state.c
+++ b/fs/nfs/nfs4state.c
@@ -176,6 +176,7 @@ int nfs41_init_clientid(struct nfs_client *clp, struct rpc_cred *cred)
 {
 	int status;
 
+	nfs4_begin_drain_session(clp);
 	status = nfs4_proc_exchange_id(clp, cred);
 	if (status != 0)
 		goto out;
@@ -1274,6 +1275,7 @@ static int nfs4_reset_session(struct nfs_client *clp)
 {
 	int status;
 
+	nfs4_begin_drain_session(clp);
 	status = nfs4_proc_destroy_session(clp->cl_session);
 	if (status && status != -NFS4ERR_BADSESSION &&
 	    status != -NFS4ERR_DEADSESSION) {
@@ -1299,7 +1301,6 @@ out:
 
 #else /* CONFIG_NFS_V4_1 */
 static int nfs4_reset_session(struct nfs_client *clp) { return 0; }
-static int nfs4_begin_drain_session(struct nfs_client *clp) { return 0; }
 static int nfs4_end_drain_session(struct nfs_client *clp) { return 0; }
 #endif /* CONFIG_NFS_V4_1 */
 
@@ -1332,7 +1333,6 @@ static void nfs4_state_manager(struct nfs_client *clp)
 	for(;;) {
 		if (test_and_clear_bit(NFS4CLNT_LEASE_EXPIRED, &clp->cl_state)) {
 			/* We're going to have to re-establish a clientid */
-			nfs4_begin_drain_session(clp);
 			status = nfs4_reclaim_lease(clp);
 			if (status) {
 				nfs4_set_lease_expired(clp, status);
@@ -1359,7 +1359,6 @@ static void nfs4_state_manager(struct nfs_client *clp)
 		/* Initialize or reset the session */
 		if (test_and_clear_bit(NFS4CLNT_SESSION_RESET, &clp->cl_state)
 		   && nfs4_has_session(clp)) {
-			nfs4_begin_drain_session(clp);
 			status = nfs4_reset_session(clp);
 			if (test_bit(NFS4CLNT_LEASE_EXPIRED, &clp->cl_state))
 				continue;

