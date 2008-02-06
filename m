From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: Re: (fwd) nfs hang on 2.6.24
Date: Wed, 06 Feb 2008 17:58:19 -0500
Message-ID: <1202338699.8549.42.camel@heimdal.trondhjem.org>
References: <20080205090132.GA8286@stro.at>
	 <1202248931.12271.18.camel@heimdal.trondhjem.org>
	 <003301c86888$ed735a20$0301a8c0@MURTLE>
	 <1202310021.12647.6.camel@heimdal.trondhjem.org>
	 <55598.203.167.214.129.1202337638.squirrel@mail.orcon.net.nz>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-Dyldy4/GG4oXZIKx/oT2"
Cc: linux-nfs@vger.kernel.org, maximilian attems <max-U9r9yeDMy7A@public.gmane.org>
To: Andrew Dixie <andrew-0FSrDVjkvKm9koe0gwxAeg@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:50019 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751267AbYBFW6Y (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 6 Feb 2008 17:58:24 -0500
In-Reply-To: <55598.203.167.214.129.1202337638.squirrel-pmwrj2wvkLORZ0GbGNPwb6VXKuFTiq87@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


--=-Dyldy4/GG4oXZIKx/oT2
Content-Type: text/plain
Content-Transfer-Encoding: 7bit


On Thu, 2008-02-07 at 11:40 +1300, Andrew Dixie wrote:
> >   What is rpciod doing while the machine hangs?
> >   Does 'netstat -t' show an active tcp connection to the server?
> >   Does tcpdump show any traffic going on the wire?
> >   What server are you running against? From the error messages below, I
> > see it is a Linux machine, but which kernel is it running?
> 
> Server is 2.6.18-5 from debian.
> 
> >From /proc/mounts:
> 
> server1:/files /files nfs
> rw,vers=3,rsize=8192,wsize=8192,hard,nointr,proto=tcp,timeo=600,retrans=2,sec=sys,addr=10.64.2.90
> 0 0
> devfile:/srv/linshared_srv /srv nfs
> rw,vers=3,rsize=32768,wsize=32768,hard,nointr,proto=tcp,timeo=600,retrans=2,sec=sys,addr=10.64.2.21
> 0 0
> devfile:/home /home nfs4
> rw,vers=4,rsize=32768,wsize=32768,hard,intr,proto=tcp,timeo=600,retrans=3,sec=sys,addr=10.64.2.21
> 0 0
> 
> The nfs connections went into CLOSE_WAIT:
> tcp        0      0 10.64.2.25:888          10.64.2.21:2049        
> CLOSE_WAIT
> tcp        0      0 10.64.2.25:974          10.64.2.21:2049        
> CLOSE_WAIT
> 
> I can't see any traffic for it attempting to reconnect.
> 
> Below are the rpciod stacktraces from the previous hang.
> Also rpc.idmap looks to be in the middle of something.
> 
> Cheers,
> Andrew
> 
> rpciod/0      S f76f9e7c     0  2663      2
>        f7d7c1f0 00000046 00000002 f76f9e7c f76f9e74 00000000 00000286
> f669bc00
>        f7d7c358 c180a940 00000000 015b37db f669bc00 dfbc8c80 000000ff
> 00000000
>        00000000 00000000 f76f9ebc 00000000 f76f9ec4 c180284c f8c62e85
> c02bc97f
> Call Trace:
>  [<f8c62e85>] rpc_wait_bit_interruptible+0x1a/0x1f [sunrpc]
>  [<c02bc97f>] __wait_on_bit+0x33/0x58
>  [<f8c62e6b>] rpc_wait_bit_interruptible+0x0/0x1f [sunrpc]
>  [<f8c62e6b>] rpc_wait_bit_interruptible+0x0/0x1f [sunrpc]
>  [<c02bca07>] out_of_line_wait_on_bit+0x63/0x6b
>  [<c013545e>] wake_bit_function+0x0/0x3c
>  [<f8c62e19>] __rpc_wait_for_completion_task+0x32/0x39 [sunrpc]
>  [<f8ce1352>] nfs4_wait_for_completion_rpc_task+0x1b/0x2f [nfs]
>  [<f8ce2336>] nfs4_proc_delegreturn+0x116/0x172 [nfs]
>  [<f8c63411>] rpc_async_schedule+0x0/0xa [sunrpc]
>  [<f8ced370>] nfs_do_return_delegation+0xf/0x1d [nfs]
>  [<f8cd135f>] nfs_dentry_iput+0xd/0x49 [nfs]
>  [<c01865d2>] dentry_iput+0x74/0x93
>  [<c018666d>] d_kill+0x2d/0x46
>  [<c0186970>] dput+0xd5/0xdc
>  [<f8ce4016>] nfs4_free_closedata+0x26/0x41 [nfs]
>  [<f8c62c8d>] rpc_release_calldata+0x16/0x20 [sunrpc]
>  [<c013220d>] run_workqueue+0x7d/0x109
>  [<c0132a83>] worker_thread+0x0/0xc5
>  [<c0132b3d>] worker_thread+0xba/0xc5
>  [<c0135429>] autoremove_wake_function+0x0/0x35
>  [<c0135362>] kthread+0x38/0x5e
>  [<c013532a>] kthread+0x0/0x5e
>  [<c0104b0f>] kernel_thread_helper+0x7/0x10

That's the bug right there. rpciod should never be calling a
synchrounous RPC call.

I've already got a fix for this bug against 2.6.24. Could you see if it
applies to your kernel too?

Cheers
  Trond

--=-Dyldy4/GG4oXZIKx/oT2
Content-Disposition: attachment; filename=linux-2.6.24-116-make_asynchronous_delegreturn.dif
Content-Type: message/rfc822; name=linux-2.6.24-116-make_asynchronous_delegreturn.dif

From: Trond Myklebust <Trond.Myklebust@netapp.com>
Date: Thu, 24 Jan 2008 18:14:34 -0500
NFS: Add an asynchronous delegreturn operation for use in nfs_clear_inode
Subject: No Subject
Message-Id: <1202338699.8549.43.camel-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Mime-Version: 1.0

Otherwise, there is a potential deadlock if the last dput() from an NFSv4
close() or other asynchronous operation leads to nfs_clear_inode calling
the synchronous delegreturn.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---

 fs/nfs/delegation.c |   29 +++++++++++++++++++++++++----
 fs/nfs/delegation.h |    3 ++-
 fs/nfs/dir.c        |    1 -
 fs/nfs/inode.c      |    2 +-
 fs/nfs/nfs4proc.c   |   22 +++++++++++++---------
 5 files changed, 41 insertions(+), 16 deletions(-)

diff --git a/fs/nfs/delegation.c b/fs/nfs/delegation.c
index b03dcd8..2dead8d 100644
--- a/fs/nfs/delegation.c
+++ b/fs/nfs/delegation.c
@@ -174,11 +174,11 @@ int nfs_inode_set_delegation(struct inode *inode, struct rpc_cred *cred, struct
 	return status;
 }
 
-static int nfs_do_return_delegation(struct inode *inode, struct nfs_delegation *delegation)
+static int nfs_do_return_delegation(struct inode *inode, struct nfs_delegation *delegation, int issync)
 {
 	int res = 0;
 
-	res = nfs4_proc_delegreturn(inode, delegation->cred, &delegation->stateid);
+	res = nfs4_proc_delegreturn(inode, delegation->cred, &delegation->stateid, issync);
 	nfs_free_delegation(delegation);
 	return res;
 }
@@ -208,7 +208,7 @@ static int __nfs_inode_return_delegation(struct inode *inode, struct nfs_delegat
 	up_read(&clp->cl_sem);
 	nfs_msync_inode(inode);
 
-	return nfs_do_return_delegation(inode, delegation);
+	return nfs_do_return_delegation(inode, delegation, 1);
 }
 
 static struct nfs_delegation *nfs_detach_delegation_locked(struct nfs_inode *nfsi, const nfs4_stateid *stateid)
@@ -228,6 +228,27 @@ nomatch:
 	return NULL;
 }
 
+/*
+ * This function returns the delegation without reclaiming opens
+ * or protecting against delegation reclaims.
+ * It is therefore really only safe to be called from
+ * nfs4_clear_inode()
+ */
+void nfs_inode_return_delegation_noreclaim(struct inode *inode)
+{
+	struct nfs_client *clp = NFS_SERVER(inode)->nfs_client;
+	struct nfs_inode *nfsi = NFS_I(inode);
+	struct nfs_delegation *delegation;
+
+	if (rcu_dereference(nfsi->delegation) != NULL) {
+		spin_lock(&clp->cl_lock);
+		delegation = nfs_detach_delegation_locked(nfsi, NULL);
+		spin_unlock(&clp->cl_lock);
+		if (delegation != NULL)
+			nfs_do_return_delegation(inode, delegation, 0);
+	}
+}
+
 int nfs_inode_return_delegation(struct inode *inode)
 {
 	struct nfs_client *clp = NFS_SERVER(inode)->nfs_client;
@@ -388,7 +409,7 @@ static int recall_thread(void *data)
 	nfs_msync_inode(inode);
 
 	if (delegation != NULL)
-		nfs_do_return_delegation(inode, delegation);
+		nfs_do_return_delegation(inode, delegation, 1);
 	iput(inode);
 	module_put_and_exit(0);
 }
diff --git a/fs/nfs/delegation.h b/fs/nfs/delegation.h
index 5874ce7..f1c5e2a 100644
--- a/fs/nfs/delegation.h
+++ b/fs/nfs/delegation.h
@@ -29,6 +29,7 @@ int nfs_inode_set_delegation(struct inode *inode, struct rpc_cred *cred, struct
 void nfs_inode_reclaim_delegation(struct inode *inode, struct rpc_cred *cred, struct nfs_openres *res);
 int nfs_inode_return_delegation(struct inode *inode);
 int nfs_async_inode_return_delegation(struct inode *inode, const nfs4_stateid *stateid);
+void nfs_inode_return_delegation_noreclaim(struct inode *inode);
 
 struct inode *nfs_delegation_find_inode(struct nfs_client *clp, const struct nfs_fh *fhandle);
 void nfs_return_all_delegations(struct super_block *sb);
@@ -39,7 +40,7 @@ void nfs_delegation_mark_reclaim(struct nfs_client *clp);
 void nfs_delegation_reap_unclaimed(struct nfs_client *clp);
 
 /* NFSv4 delegation-related procedures */
-int nfs4_proc_delegreturn(struct inode *inode, struct rpc_cred *cred, const nfs4_stateid *stateid);
+int nfs4_proc_delegreturn(struct inode *inode, struct rpc_cred *cred, const nfs4_stateid *stateid, int issync);
 int nfs4_open_delegation_recall(struct nfs_open_context *ctx, struct nfs4_state *state, const nfs4_stateid *stateid);
 int nfs4_lock_delegation_recall(struct nfs4_state *state, struct file_lock *fl);
 int nfs4_copy_delegation_stateid(nfs4_stateid *dst, struct inode *inode);
diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
index c578d94..5ca762d 100644
--- a/fs/nfs/dir.c
+++ b/fs/nfs/dir.c
@@ -864,7 +864,6 @@ static int nfs_dentry_delete(struct dentry *dentry)
  */
 static void nfs_dentry_iput(struct dentry *dentry, struct inode *inode)
 {
-	nfs_inode_return_delegation(inode);
 	if (S_ISDIR(inode->i_mode))
 		/* drop any readdir cache as it could easily be old */
 		NFS_I(inode)->cache_validity |= NFS_INO_INVALID_DATA;
diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
index 5d381cf..3f332e5 100644
--- a/fs/nfs/inode.c
+++ b/fs/nfs/inode.c
@@ -1145,7 +1145,7 @@ static int nfs_update_inode(struct inode *inode, struct nfs_fattr *fattr)
 void nfs4_clear_inode(struct inode *inode)
 {
 	/* If we are holding a delegation, return it! */
-	nfs_inode_return_delegation(inode);
+	nfs_inode_return_delegation_noreclaim(inode);
 	/* First call standard NFS clear_inode() code */
 	nfs_clear_inode(inode);
 }
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 89efbcd..5c189bd 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -2991,7 +2991,7 @@ static const struct rpc_call_ops nfs4_delegreturn_ops = {
 	.rpc_release = nfs4_delegreturn_release,
 };
 
-static int _nfs4_proc_delegreturn(struct inode *inode, struct rpc_cred *cred, const nfs4_stateid *stateid)
+static int _nfs4_proc_delegreturn(struct inode *inode, struct rpc_cred *cred, const nfs4_stateid *stateid, int issync)
 {
 	struct nfs4_delegreturndata *data;
 	struct nfs_server *server = NFS_SERVER(inode);
@@ -3006,7 +3006,7 @@ static int _nfs4_proc_delegreturn(struct inode *inode, struct rpc_cred *cred, co
 		.callback_ops = &nfs4_delegreturn_ops,
 		.flags = RPC_TASK_ASYNC,
 	};
-	int status;
+	int status = 0;
 
 	data = kmalloc(sizeof(*data), GFP_KERNEL);
 	if (data == NULL)
@@ -3028,23 +3028,27 @@ static int _nfs4_proc_delegreturn(struct inode *inode, struct rpc_cred *cred, co
 	task = rpc_run_task(&task_setup_data);
 	if (IS_ERR(task))
 		return PTR_ERR(task);
+	if (!issync)
+		goto out;
 	status = nfs4_wait_for_completion_rpc_task(task);
-	if (status == 0) {
-		status = data->rpc_status;
-		if (status == 0)
-			nfs_refresh_inode(inode, &data->fattr);
-	}
+	if (status != 0)
+		goto out;
+	status = data->rpc_status;
+	if (status != 0)
+		goto out;
+	nfs_refresh_inode(inode, &data->fattr);
+out:
 	rpc_put_task(task);
 	return status;
 }
 
-int nfs4_proc_delegreturn(struct inode *inode, struct rpc_cred *cred, const nfs4_stateid *stateid)
+int nfs4_proc_delegreturn(struct inode *inode, struct rpc_cred *cred, const nfs4_stateid *stateid, int issync)
 {
 	struct nfs_server *server = NFS_SERVER(inode);
 	struct nfs4_exception exception = { };
 	int err;
 	do {
-		err = _nfs4_proc_delegreturn(inode, cred, stateid);
+		err = _nfs4_proc_delegreturn(inode, cred, stateid, issync);
 		switch (err) {
 			case -NFS4ERR_STALE_STATEID:
 			case -NFS4ERR_EXPIRED:

--=-Dyldy4/GG4oXZIKx/oT2--
