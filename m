From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: What is the purpose of those put_rpccred() statements?
Date: Fri, 23 Oct 2009 16:09:10 -0400
Message-ID: <1256328550.3238.52.camel@heimdal.trondhjem.org>
References: <1256327771.3238.51.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain
Cc: William Andros Adamson <andros@netapp.com>,
	linux-nfs@vger.kernel.org
To: Benny Halevy <bhalevy@panasas.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-out1.uio.no ([129.240.10.57]:45836 "EHLO mail-out1.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753139AbZJWUJM (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 23 Oct 2009 16:09:12 -0400
In-Reply-To: <1256327771.3238.51.camel-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 2009-10-23 at 15:56 -0400, Trond Myklebust wrote:
> I'm finding a bunch of random calls of the form
>    put_rpccred(task->tk_msg.rpc_cred);
> 
> in functions like nfs4_renew_done(), nfs41_sequence_call_done() with
> apparently no corresponding get_rpccred(). Could you please enlighten me
> what they are all about? They're not mentioned at all in the changelogs
> of commits 29fba38b, and fc01cea9...
> 
> Trond
--------------------------------------------------------------------
NFSv4: Fix two unbalanced put_rpccred() issues.

From: Trond Myklebust <Trond.Myklebust@netapp.com>

Commits 29fba38b (nfs41: lease renewal) and fc01cea9 (nfs41: sequence
operation) introduce a couple of put_rpccred() calls on credentials for
which there is no corresponding get_rpccred().

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---

 fs/nfs/nfs4proc.c |    4 ----
 1 files changed, 0 insertions(+), 4 deletions(-)


diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 65c2527..ff37454 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -3065,9 +3065,6 @@ static void nfs4_renew_done(struct rpc_task *task, void *data)
 	if (time_before(clp->cl_last_renewal,timestamp))
 		clp->cl_last_renewal = timestamp;
 	spin_unlock(&clp->cl_lock);
-	dprintk("%s calling put_rpccred on rpc_cred %p\n", __func__,
-				task->tk_msg.rpc_cred);
-	put_rpccred(task->tk_msg.rpc_cred);
 }
 
 static const struct rpc_call_ops nfs4_renew_ops = {
@@ -4882,7 +4879,6 @@ void nfs41_sequence_call_done(struct rpc_task *task, void *data)
 	nfs41_sequence_free_slot(clp, task->tk_msg.rpc_resp);
 	dprintk("%s rpc_cred %p\n", __func__, task->tk_msg.rpc_cred);
 
-	put_rpccred(task->tk_msg.rpc_cred);
 	kfree(task->tk_msg.rpc_argp);
 	kfree(task->tk_msg.rpc_resp);
 


