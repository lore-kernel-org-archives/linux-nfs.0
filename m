From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: Re: major NFSv4 client regression (-rc7)
Date: Thu, 10 Jan 2008 15:51:34 -0500
Message-ID: <1199998294.13775.8.camel@heimdal.trondhjem.org>
References: <20080110204119.GA714@havoc.gtf.org>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-xcpsnVMcrna6VQjIv6xR"
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org,
	Andrew Morton <akpm@linux-foundation.org>
To: Jeff Garzik <jeff@garzik.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:16676 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752558AbYAJUwH (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 10 Jan 2008 15:52:07 -0500
In-Reply-To: <20080110204119.GA714-oTNwCEtKUwI/11+TDStg7g@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


--=-xcpsnVMcrna6VQjIv6xR
Content-Type: text/plain
Content-Transfer-Encoding: 7bit


On Thu, 2008-01-10 at 15:41 -0500, Jeff Garzik wrote:
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

This looks as if it might be the same issue that was reported as bug
9712 in bugzilla (http://bugzilla.kernel.org/show_bug.cgi?id=9712).

The fix is attached. Please could you confirm that it fixes the hang?

Cheers
  Trond

--=-xcpsnVMcrna6VQjIv6xR
Content-Disposition: inline; filename*0=linux-2.6.24-001-fix_locking_deadlock_in_nfs4_lock_prepare.di; filename*1=f
Content-Type: message/rfc822; name=linux-2.6.24-001-fix_locking_deadlock_in_nfs4_lock_prepare.dif

From: Trond Myklebust <Trond.Myklebust@netapp.com>
Date: Tue, 8 Jan 2008 19:26:49 -0500
NFSv4: Give the lock stateid its own sequence queue
Subject: No Subject
Message-Id: <1199998291.13775.7.camel-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Mime-Version: 1.0

Sharing the open sequence queue causes a deadlock when we try to take both
a lock sequence id and and open sequence id.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---

 fs/nfs/nfs4_fs.h   |    1 +
 fs/nfs/nfs4state.c |    5 ++++-
 2 files changed, 5 insertions(+), 1 deletions(-)

diff --git a/fs/nfs/nfs4_fs.h b/fs/nfs/nfs4_fs.h
index b35069a..bd1b9d6 100644
--- a/fs/nfs/nfs4_fs.h
+++ b/fs/nfs/nfs4_fs.h
@@ -115,6 +115,7 @@ struct nfs4_lock_state {
 #define NFS_LOCK_INITIALIZED 1
 	int			ls_flags;
 	struct nfs_seqid_counter	ls_seqid;
+	struct rpc_sequence	ls_sequence;
 	struct nfs_unique_id	ls_id;
 	nfs4_stateid		ls_stateid;
 	atomic_t		ls_count;
diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
index 23a9a36..5a39c6f 100644
--- a/fs/nfs/nfs4state.c
+++ b/fs/nfs/nfs4state.c
@@ -509,7 +509,10 @@ static struct nfs4_lock_state *nfs4_alloc_lock_state(struct nfs4_state *state, f
 	lsp = kzalloc(sizeof(*lsp), GFP_KERNEL);
 	if (lsp == NULL)
 		return NULL;
-	lsp->ls_seqid.sequence = &state->owner->so_sequence;
+	rpc_init_wait_queue(&lsp->ls_sequence.wait, "lock_seqid_waitqueue");
+	spin_lock_init(&lsp->ls_sequence.lock);
+	INIT_LIST_HEAD(&lsp->ls_sequence.list);
+	lsp->ls_seqid.sequence = &lsp->ls_sequence;
 	atomic_set(&lsp->ls_count, 1);
 	lsp->ls_owner = fl_owner;
 	spin_lock(&clp->cl_lock);

--=-xcpsnVMcrna6VQjIv6xR--
