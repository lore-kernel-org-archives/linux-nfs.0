From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [Bug 13330] New: nfs4 NULL pointer dereference in
 _nfs4_do_setlk
Date: Thu, 21 May 2009 17:03:22 -0400
Message-ID: <1242939802.22947.17.camel@heimdal.trondhjem.org>
References: <bug-13330-104@http.bugzilla.kernel.org/>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-uH/c7OWLnMmSptY9STxJ"
Cc: Rich Ercolani <rercola-YxllIAoeIHiVc3sceRu5cw@public.gmane.org>, Rince <rincebrain@gmail.com>,
	Alan Cox <alan@lxorguk.ukuu.org.uk>, linux-nfs@vger.kernel.org
To: bugzilla-daemon-590EEB7GvNiWaY/ihj7yzEB+6BGkLq7r@public.gmane.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-out2.uio.no ([129.240.10.58]:36440 "EHLO mail-out2.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753786AbZEUVD2 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 21 May 2009 17:03:28 -0400
In-Reply-To: <bug-13330-104-V0hAGp6uBxO456/isadD/XN4h3HLQggn@public.gmane.org/>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


--=-uH/c7OWLnMmSptY9STxJ
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

On Sun, 2009-05-17 at 04:44 +0000, bugzilla-daemon-590EEB7GvNiWaY/ihj7yzEB+6BGkLq7r@public.gmane.org
wrote:
> http://bugzilla.kernel.org/show_bug.cgi?id=13330
> 
>            Summary: nfs4 NULL pointer dereference in _nfs4_do_setlk
>            Product: File System
>            Version: 2.5
>     Kernel Version: 2.6.30-rc4
>           Platform: All
>         OS/Version: Linux
>               Tree: Mainline
>             Status: NEW
>           Severity: high
>           Priority: P1
>          Component: NFS
>         AssignedTo: trond.myklebust@fys.uio.no
>         ReportedBy: rercola-YxllIAoeIHiVc3sceRu5cw@public.gmane.org
>         Regression: No
> 
> 
> Created an attachment (id=21380)
>  --> (http://bugzilla.kernel.org/attachment.cgi?id=21380)
> NFSv4 BUG ON log
> 
> My NFS server rebooted.
> 
> The machine with the kernel in question, one of many clients, spit out the
> attached error in dmesg, and all NFS activity on the machine blocked forever,
> necessitating a reboot.
> 
> This is not true on any of the other NFS clients on the network, which vary
> between 2.6.18 and 2.6.27, so it may be A) 64-bit specific somehow (the rest
> are 32-bit), B) recently introduced, or C) recently exposed by some existing
> bad behavior in NFS recovery being removed.
> 
> Machine was "vanilla" 2.6.30-rc4 (with commits
> b827e496c893de0c0f142abfaeb8730a2fd6b37f and
> 7fdf523067666b0eaff330f362401ee50ce187c4 added), 64-bit. NFSv4 mounted with
> rw,nosuid,nodev,noatime,hard,intr,nolock,sloppy,rsize=8192,wsize=8192,tcp,timeo=600.
> 
> I'll try reproducing this on latest GIT shortly, but it's hard to reproduce
> (since it only occurs after the NFS server reboots, and not even consistently
> then), so I don't know when I'll be able to report back that it occurs or not.

Switching to email...

I'm having trouble reproducing this, and staring at the code itself
isn't helping (as far as I can see, the locking using nfsi->rwsem should
work).

Could you therefore please try the attached patch?

Cheers
  Trond



--=-uH/c7OWLnMmSptY9STxJ
Content-Description: NFSv4: Fix an Oops in the lock recovery code
Content-Type: application/mbox
Content-Disposition: inline; filename="linux-2.6.30-007-fix_nfsv4_setlock_oops.dif"
Content-Transfer-Encoding: 7bit

>From caf847c39d71151b1205278d154fd0bdc6126703 Mon Sep 17 00:00:00 2001
From: Trond Myklebust <Trond.Myklebust@netapp.com>
Date: Thu, 21 May 2009 13:13:29 -0400
Subject: [PATCH] NFSv4: Fix an Oops in the lock recovery code

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 fs/nfs/nfs4proc.c  |   29 ++++++++++++++---------------
 fs/nfs/nfs4state.c |    2 --
 2 files changed, 14 insertions(+), 17 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index d1c390e..c376d70 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -3123,9 +3123,6 @@ static int _nfs4_proc_getlk(struct nfs4_state *state, int cmd, struct file_lock
 	int status;
 
 	arg.lock_owner.clientid = clp->cl_clientid;
-	status = nfs4_set_lock_state(state, request);
-	if (status != 0)
-		goto out;
 	lsp = request->fl_u.nfs4_fl.owner;
 	arg.lock_owner.id = lsp->ls_id.id;
 	status = rpc_call_sync(server->client, &msg, 0);
@@ -3137,7 +3134,6 @@ static int _nfs4_proc_getlk(struct nfs4_state *state, int cmd, struct file_lock
 			status = 0;
 	}
 	request->fl_ops->fl_release_private(request);
-out:
 	return status;
 }
 
@@ -3303,8 +3299,11 @@ static int nfs4_proc_unlck(struct nfs4_state *state, int cmd, struct file_lock *
 	int status = 0;
 	unsigned char fl_flags = request->fl_flags;
 
-	status = nfs4_set_lock_state(state, request);
 	/* Unlock _before_ we do the RPC call */
+	BUG_ON(request->fl_ops == NULL);
+	BUG_ON(request->fl_u.nfs4_fl.owner == NULL);
+	BUG_ON(nfs_file_open_context(request->fl_file)->state == NULL);
+
 	request->fl_flags |= FL_EXISTS;
 	down_read(&nfsi->rwsem);
 	if (do_vfs_lock(request->fl_file, request) == -ENOENT) {
@@ -3471,6 +3470,10 @@ static int _nfs4_do_setlk(struct nfs4_state *state, int cmd, struct file_lock *f
 	int ret;
 
 	dprintk("%s: begin!\n", __func__);
+	BUG_ON(fl->fl_ops == NULL);
+	BUG_ON(fl->fl_u.nfs4_fl.owner == NULL);
+	BUG_ON(nfs_file_open_context(fl->fl_file)->state == NULL);
+
 	data = nfs4_alloc_lockdata(fl, nfs_file_open_context(fl->fl_file),
 			fl->fl_u.nfs4_fl.owner);
 	if (data == NULL)
@@ -3521,9 +3524,6 @@ static int nfs4_lock_expired(struct nfs4_state *state, struct file_lock *request
 	struct nfs4_exception exception = { };
 	int err;
 
-	err = nfs4_set_lock_state(state, request);
-	if (err != 0)
-		return err;
 	do {
 		if (test_bit(NFS_DELEGATED_STATE, &state->flags) != 0)
 			return 0;
@@ -3542,9 +3542,6 @@ static int _nfs4_proc_setlk(struct nfs4_state *state, int cmd, struct file_lock
 	int status;
 
 	/* Is this a delegated open? */
-	status = nfs4_set_lock_state(state, request);
-	if (status != 0)
-		goto out;
 	request->fl_flags |= FL_ACCESS;
 	status = do_vfs_lock(request->fl_file, request);
 	if (status < 0)
@@ -3599,6 +3596,11 @@ nfs4_proc_lock(struct file *filp, int cmd, struct file_lock *request)
 	if (request->fl_start < 0 || request->fl_end < 0)
 		return -EINVAL;
 
+	BUG_ON(request->fl_ops != NULL);
+	status = nfs4_set_lock_state(state, request);
+	if (status != 0)
+		goto out;
+
 	if (IS_GETLK(cmd))
 		return nfs4_proc_getlk(state, F_GETLK, request);
 
@@ -3617,6 +3619,7 @@ nfs4_proc_lock(struct file *filp, int cmd, struct file_lock *request)
 		if (signalled())
 			break;
 	} while(status < 0);
+out:
 	return status;
 }
 
@@ -3626,16 +3629,12 @@ int nfs4_lock_delegation_recall(struct nfs4_state *state, struct file_lock *fl)
 	struct nfs4_exception exception = { };
 	int err;
 
-	err = nfs4_set_lock_state(state, fl);
-	if (err != 0)
-		goto out;
 	do {
 		err = _nfs4_do_setlk(state, F_SETLK, fl, 0);
 		if (err != -NFS4ERR_DELAY)
 			break;
 		err = nfs4_handle_exception(server, err, &exception);
 	} while (exception.retry);
-out:
 	return err;
 }
 
diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
index 0298e90..fff4e61 100644
--- a/fs/nfs/nfs4state.c
+++ b/fs/nfs/nfs4state.c
@@ -643,8 +643,6 @@ int nfs4_set_lock_state(struct nfs4_state *state, struct file_lock *fl)
 {
 	struct nfs4_lock_state *lsp;
 
-	if (fl->fl_ops != NULL)
-		return 0;
 	lsp = nfs4_get_lock_state(state, fl->fl_owner);
 	if (lsp == NULL)
 		return -ENOMEM;
-- 
1.6.0.4


--=-uH/c7OWLnMmSptY9STxJ--

