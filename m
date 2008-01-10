From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: major NFSv4 client regression (-rc7)
Date: Thu, 10 Jan 2008 12:49:41 -0800
Message-ID: <20080110124941.a6709808.akpm@linux-foundation.org>
References: <20080110204119.GA714@havoc.gtf.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: Trond.Myklebust@netapp.com, linux-nfs@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Jeff Garzik <jeff@garzik.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:41348 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753437AbYAJUvB (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 10 Jan 2008 15:51:01 -0500
In-Reply-To: <20080110204119.GA714-oTNwCEtKUwI/11+TDStg7g@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 10 Jan 2008 15:41:19 -0500
Jeff Garzik <jeff@garzik.org> wrote:

> 
> Server:		Linux 2.6.24-rc6 (x86-64/Fedora 8)
> Good client:	Linux 2.6.24-rc6-ge697789d (x86-64/Fedora 7)
> Bad client:	Linux 2.6.24-rc7-gfd0b45df (x86-64/Fedora 7)
> Situation:	home dir via NFS
> 
> My home setup is a standard homedir-over-NFS setup, using NFSv4 on both
> client and server.  I just rebooted into the latest upstream kernel, and
> I am getting NFS client hangs all over the place:
> 
> 	[jgarzik@core firefox]$ cat profiles.ini 
> 
> 	hangs here, for 15 minutes so far and counting...
> 	('core' is the client machine)
> 
> and I first noticed this when firefox and thunderbird were hanging, when
> I tried to start them after rebooting into the latest kernel.  stracing
> firefox yielding a hang in open:
> 
> 	("/g" is the NFS-mounted volume)
> 
> 	access("/usr/lib64/firefox-2.0.0.10/updates", F_OK) = -1 ENOENT (No such file or directory)
> 	access("/g/g/.mozilla/firefox", F_OK)   = 0
> 	access("/g/g/.mozilla/firefox", F_OK)   = 0
> 	stat("/g/g/.mozilla/firefox/profiles.ini", {st_mode=S_IFREG|0664, st_size=94, ...}) = 0
> 	open("/g/g/.mozilla/firefox/profiles.ini", O_RDONLY
> 
> 	hangs here, for 20 minutes so far and counting...
> 
> As you can see from the trace, and as I can report simply by being able
> to send this message, SOME file accesses over NFS work just fine.
> 
> Accessing the file works when logged into the server, so its not disk
> corruption or something like that.
> 
> Neither client nor server have anything interesting in dmesg -- in fact
> nothing in dmesg beyond the normal boot messages have been printed.
> 
> Let me know what info I can provide...  This is a 100% reproducible
> regression, and this latest NFS client revision has made my local
> NFS-over-homedir setup completely unusable.  I am forced to return to
> the known working client (Linux 2.6.24-rc6-ge697789d) just to run basic
> apps.
> 

Presumably something in this lot:




Begin forwarded message:

Date: Wed, 02 Jan 2008 22:03:36 -0500
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-nfs@vger.kernel.org
Subject: [GIT] More NFS client fixes for 2.6.24-rc6


Hi Linus,

Please pull from the repository at

   git pull git://git.linux-nfs.org/pub/linux/nfs-2.6.git

This will update the following files through the appended changesets.

  Cheers,
    Trond

----
 fs/nfs/nfs4proc.c              |   34 ++++++++++++++++++++--------------
 fs/nfs/nfs4renewd.c            |    2 --
 fs/nfs/super.c                 |   12 +++++++++++-
 net/sunrpc/auth_gss/auth_gss.c |    2 +-
 4 files changed, 32 insertions(+), 18 deletions(-)

commit 361562e89f02db8fdca32a2dfc546a74f5d883d9
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Wed Jan 2 16:27:16 2008 -0500

    NFSv4: Fix open_to_lock_owner sequenceid allocation...
    
    NFSv4 file locking is currently completely broken since it doesn't respect
    the OPEN sequencing when it is given an unconfirmed lock_owner and needs to
    do an open_to_lock_owner. Worse: it breaks the sunrpc rules by doing a
    GFP_KERNEL allocation inside an rpciod callback.
    
    Fix is to preallocate the open seqid structure in nfs4_alloc_lockdata if we
    see that the lock_owner is unconfirmed.
    Then, in nfs4_lock_prepare() we wait for either the open_seqid, if
    the lock_owner is still unconfirmed, or else fall back to waiting on the
    standard lock_seqid.
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 9073a07d1d987f8d2c919c900ea18ff57d156a34
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Wed Jan 2 15:19:18 2008 -0500

    NFSv4: nfs4_open_confirm must not set the open_owner as confirmed on error
    
    RFC3530 states that the open_owner is confirmed if and only if the client
    sends an OPEN_CONFIRM request with the appropriate sequence id and stateid
    within the lease period.
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 812f85c5715310583459acc4b35e918914e96060
Author: James Morris <jmorris@namei.org>
Date:   Wed Dec 26 11:20:43 2007 +1100

    NFS: add newline to kernel warning message in auth_gss code
    
    Add newline to kernel warning message in gss_create().
    
    Signed-off-by: James Morris <jmorris@namei.org>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 72d740f5d660bb422bab5f72da56678ca2c82d81
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Wed Jan 2 13:52:03 2008 -0500

    NFSv4: Fix circular locking dependency in nfs4_kill_renewd
    
    Erez Zadok reports:
    
    =======================================================
    [ INFO: possible circular locking dependency detected ]
    2.6.24-rc6-unionfs2 #80
    -------------------------------------------------------
    umount.nfs4/4017 is trying to acquire lock:
     (&(&clp->cl_renewd)->work){--..}, at: [<c0223e53>]
    __cancel_work_timer+0x83/0x17f
    
    but task is already holding lock:
     (&clp->cl_sem){----}, at: [<f8879897>] nfs4_kill_renewd+0x17/0x29 [nfs]
    
    which lock already depends on the new lock.
    
    
    the existing dependency chain (in reverse order) is:
    
    -> #1 (&clp->cl_sem){----}:
           [<c0230699>] __lock_acquire+0x9cc/0xb95
           [<c0230c39>] lock_acquire+0x5f/0x78
           [<c0397cb8>] down_read+0x3a/0x4c
           [<f88798e6>] nfs4_renew_state+0x1c/0x1b8 [nfs]
           [<c0223821>] run_workqueue+0xd9/0x1ac
           [<c0224220>] worker_thread+0x7a/0x86
           [<c0226b49>] kthread+0x3b/0x62
           [<c02033a3>] kernel_thread_helper+0x7/0x10
           [<ffffffff>] 0xffffffff
    
    -> #0 (&(&clp->cl_renewd)->work){--..}:
           [<c0230589>] __lock_acquire+0x8bc/0xb95
           [<c0230c39>] lock_acquire+0x5f/0x78
           [<c0223e87>] __cancel_work_timer+0xb7/0x17f
           [<c0223f5a>] cancel_delayed_work_sync+0xb/0xd
           [<f887989e>] nfs4_kill_renewd+0x1e/0x29 [nfs]
           [<f885a8f6>] nfs_free_client+0x37/0x9e [nfs]
           [<f885ab20>] nfs_put_client+0x5d/0x62 [nfs]
           [<f885ab9a>] nfs_free_server+0x75/0xae [nfs]
           [<f8862672>] nfs4_kill_super+0x27/0x2b [nfs]
           [<c0258aab>] deactivate_super+0x3f/0x51
           [<c0269668>] mntput_no_expire+0x42/0x67
           [<c025d0e4>] path_release_on_umount+0x15/0x18
           [<c0269d30>] sys_umount+0x1a3/0x1cb
           [<c0269d71>] sys_oldumount+0x19/0x1b
           [<c02026ca>] sysenter_past_esp+0x5f/0xa5
           [<ffffffff>] 0xffffffff
    
    Looking at the code, it would seem that taking the clp->cl_sem in
    nfs4_kill_renewd is completely redundant, since we're already guaranteed to
    have exclusive access to the nfs_client (we're shutting down).
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 53478daff2c8b494d2af1ede6611f166f81bc393
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Wed Jan 2 13:28:57 2008 -0500

    NFS: Fix a possible Oops in fs/nfs/super.c
    
    Sigh... commit 4584f520e1f773082ef44ff4f8969a5d992b16ec (NFS: Fix NFS
    mountpoint crossing...) had a slight flaw: server can be NULL if sget()
    returned an existing superblock.
    
    Fix the fix by dereferencing s->s_fs_info.
    
    Also add in the same namespace Oops fix for NFSv4 in both the mountpoint
    crossing case, and the referral case.
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index f03d9d5..9e2e1c7 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -741,10 +741,10 @@ static void nfs4_open_confirm_done(struct rpc_task *task, void *calldata)
 	if (data->rpc_status == 0) {
 		memcpy(data->o_res.stateid.data, data->c_res.stateid.data,
 				sizeof(data->o_res.stateid.data));
+		nfs_confirm_seqid(&data->owner->so_seqid, 0);
 		renew_lease(data->o_res.server, data->timestamp);
 		data->rpc_done = 1;
 	}
-	nfs_confirm_seqid(&data->owner->so_seqid, data->rpc_status);
 	nfs_increment_open_seqid(data->rpc_status, data->c_arg.seqid);
 }
 
@@ -759,7 +759,6 @@ static void nfs4_open_confirm_release(void *calldata)
 	/* In case of error, no cleanup! */
 	if (!data->rpc_done)
 		goto out_free;
-	nfs_confirm_seqid(&data->owner->so_seqid, 0);
 	state = nfs4_opendata_to_nfs4_state(data);
 	if (!IS_ERR(state))
 		nfs4_close_state(&data->path, state, data->o_arg.open_flags);
@@ -886,7 +885,6 @@ static void nfs4_open_release(void *calldata)
 	/* In case we need an open_confirm, no cleanup! */
 	if (data->o_res.rflags & NFS4_OPEN_RESULT_CONFIRM)
 		goto out_free;
-	nfs_confirm_seqid(&data->owner->so_seqid, 0);
 	state = nfs4_opendata_to_nfs4_state(data);
 	if (!IS_ERR(state))
 		nfs4_close_state(&data->path, state, data->o_arg.open_flags);
@@ -3333,6 +3331,12 @@ static struct nfs4_lockdata *nfs4_alloc_lockdata(struct file_lock *fl,
 
 	p->arg.fh = NFS_FH(inode);
 	p->arg.fl = &p->fl;
+	if (!(lsp->ls_seqid.flags & NFS_SEQID_CONFIRMED)) {
+		p->arg.open_seqid = nfs_alloc_seqid(&lsp->ls_state->owner->so_seqid);
+		if (p->arg.open_seqid == NULL)
+			goto out_free;
+
+	}
 	p->arg.lock_seqid = nfs_alloc_seqid(&lsp->ls_seqid);
 	if (p->arg.lock_seqid == NULL)
 		goto out_free;
@@ -3345,6 +3349,8 @@ static struct nfs4_lockdata *nfs4_alloc_lockdata(struct file_lock *fl,
 	memcpy(&p->fl, fl, sizeof(p->fl));
 	return p;
 out_free:
+	if (p->arg.open_seqid != NULL)
+		nfs_free_seqid(p->arg.open_seqid);
 	kfree(p);
 	return NULL;
 }
@@ -3361,23 +3367,23 @@ static void nfs4_lock_prepare(struct rpc_task *task, void *calldata)
 		.rpc_cred = sp->so_cred,
 	};
 
-	if (nfs_wait_on_sequence(data->arg.lock_seqid, task) != 0)
-		return;
 	dprintk("%s: begin!\n", __FUNCTION__);
 	/* Do we need to do an open_to_lock_owner? */
 	if (!(data->arg.lock_seqid->sequence->flags & NFS_SEQID_CONFIRMED)) {
-		data->arg.open_seqid = nfs_alloc_seqid(&sp->so_seqid);
-		if (data->arg.open_seqid == NULL) {
-			data->rpc_status = -ENOMEM;
-			task->tk_action = NULL;
-			goto out;
-		}
+		if (nfs_wait_on_sequence(data->arg.open_seqid, task) != 0)
+			return;
 		data->arg.open_stateid = &state->stateid;
 		data->arg.new_lock_owner = 1;
+		/* Retest in case we raced... */
+		if (!(data->arg.lock_seqid->sequence->flags & NFS_SEQID_CONFIRMED))
+			goto do_rpc;
 	}
+	if (nfs_wait_on_sequence(data->arg.lock_seqid, task) != 0)
+		return;
+	data->arg.new_lock_owner = 0;
+do_rpc:	
 	data->timestamp = jiffies;
 	rpc_call_setup(task, &msg, 0);
-out:
 	dprintk("%s: done!, ret = %d\n", __FUNCTION__, data->rpc_status);
 }
 
@@ -3413,8 +3419,6 @@ static void nfs4_lock_release(void *calldata)
 	struct nfs4_lockdata *data = calldata;
 
 	dprintk("%s: begin!\n", __FUNCTION__);
-	if (data->arg.open_seqid != NULL)
-		nfs_free_seqid(data->arg.open_seqid);
 	if (data->cancelled != 0) {
 		struct rpc_task *task;
 		task = nfs4_do_unlck(&data->fl, data->ctx, data->lsp,
@@ -3424,6 +3428,8 @@ static void nfs4_lock_release(void *calldata)
 		dprintk("%s: cancelling lock!\n", __FUNCTION__);
 	} else
 		nfs_free_seqid(data->arg.lock_seqid);
+	if (data->arg.open_seqid != NULL)
+		nfs_free_seqid(data->arg.open_seqid);
 	nfs4_put_lock_state(data->lsp);
 	put_nfs_open_context(data->ctx);
 	kfree(data);
diff --git a/fs/nfs/nfs4renewd.c b/fs/nfs/nfs4renewd.c
index 3ea352d..5e2e4af 100644
--- a/fs/nfs/nfs4renewd.c
+++ b/fs/nfs/nfs4renewd.c
@@ -133,9 +133,7 @@ nfs4_renewd_prepare_shutdown(struct nfs_server *server)
 void
 nfs4_kill_renewd(struct nfs_client *clp)
 {
-	down_read(&clp->cl_sem);
 	cancel_delayed_work_sync(&clp->cl_renewd);
-	up_read(&clp->cl_sem);
 }
 
 /*
diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index ea92920..0b0c72a 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -1475,7 +1475,7 @@ static int nfs_xdev_get_sb(struct file_system_type *fs_type, int flags,
 		error = PTR_ERR(mntroot);
 		goto error_splat_super;
 	}
-	if (mntroot->d_inode->i_op != server->nfs_client->rpc_ops->dir_inode_ops) {
+	if (mntroot->d_inode->i_op != NFS_SB(s)->nfs_client->rpc_ops->dir_inode_ops) {
 		dput(mntroot);
 		error = -ESTALE;
 		goto error_splat_super;
@@ -1826,6 +1826,11 @@ static int nfs4_xdev_get_sb(struct file_system_type *fs_type, int flags,
 		error = PTR_ERR(mntroot);
 		goto error_splat_super;
 	}
+	if (mntroot->d_inode->i_op != NFS_SB(s)->nfs_client->rpc_ops->dir_inode_ops) {
+		dput(mntroot);
+		error = -ESTALE;
+		goto error_splat_super;
+	}
 
 	s->s_flags |= MS_ACTIVE;
 	mnt->mnt_sb = s;
@@ -1900,6 +1905,11 @@ static int nfs4_referral_get_sb(struct file_system_type *fs_type, int flags,
 		error = PTR_ERR(mntroot);
 		goto error_splat_super;
 	}
+	if (mntroot->d_inode->i_op != NFS_SB(s)->nfs_client->rpc_ops->dir_inode_ops) {
+		dput(mntroot);
+		error = -ESTALE;
+		goto error_splat_super;
+	}
 
 	s->s_flags |= MS_ACTIVE;
 	mnt->mnt_sb = s;
diff --git a/net/sunrpc/auth_gss/auth_gss.c b/net/sunrpc/auth_gss/auth_gss.c
index a6e57d1..1f2d85e 100644
--- a/net/sunrpc/auth_gss/auth_gss.c
+++ b/net/sunrpc/auth_gss/auth_gss.c
@@ -625,7 +625,7 @@ gss_create(struct rpc_clnt *clnt, rpc_authflavor_t flavor)
 	err = -EINVAL;
 	gss_auth->mech = gss_mech_get_by_pseudoflavor(flavor);
 	if (!gss_auth->mech) {
-		printk(KERN_WARNING "%s: Pseudoflavor %d not found!",
+		printk(KERN_WARNING "%s: Pseudoflavor %d not found!\n",
 				__FUNCTION__, flavor);
 		goto err_free;
 	}
