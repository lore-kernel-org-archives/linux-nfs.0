Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.bugwerft.de ([212.112.241.193]:36952 "EHLO
	mail.bugwerft.de" rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org
	with ESMTP id S1760102Ab1EOQTO (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 15 May 2011 12:19:14 -0400
From: Daniel Mack <zonque@gmail.com>
To: linux-nfs@vger.kernel.org
Cc: Daniel Mack <zonque@gmail.com>,
        Trond Myklebust <Trond.Myklebust@netapp.com>,
        "J. Bruce Fields" <bfields@fieldses.org>, Neil Brown <neilb@suse.de>
Subject: [PATCH] nfs/nfsd: make local functions static
Date: Sun, 15 May 2011 18:10:04 +0200
Message-Id: <1305475804-4594-1-git-send-email-zonque@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

This also fixes a number of sparse warnings.

Signed-off-by: Daniel Mack <zonque@gmail.com>
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: J. Bruce Fields <bfields@fieldses.org>
Cc: Neil Brown <neilb@suse.de>
---
 fs/nfs/callback.c   |    2 +-
 fs/nfs/client.c     |    2 +-
 fs/nfs/nfs4proc.c   |   16 ++++++++--------
 fs/nfsd/nfs3xdr.c   |    2 +-
 fs/nfsd/nfs4state.c |    4 ++--
 fs/nfsd/nfs4xdr.c   |    2 +-
 6 files changed, 14 insertions(+), 14 deletions(-)

diff --git a/fs/nfs/callback.c b/fs/nfs/callback.c
index e3d2942..5d1153a 100644
--- a/fs/nfs/callback.c
+++ b/fs/nfs/callback.c
@@ -101,7 +101,7 @@ nfs4_callback_svc(void *vrqstp)
 /*
  * Prepare to bring up the NFSv4 callback service
  */
-struct svc_rqst *
+static struct svc_rqst *
 nfs4_callback_up(struct svc_serv *serv)
 {
 	int ret;
diff --git a/fs/nfs/client.c b/fs/nfs/client.c
index 139be96..e35f02e 100644
--- a/fs/nfs/client.c
+++ b/fs/nfs/client.c
@@ -425,7 +425,7 @@ static int nfs_sockaddr_cmp(const struct sockaddr *sa1,
 }
 
 /* Common match routine for v4.0 and v4.1 callback services */
-bool
+static bool
 nfs4_cb_match_client(const struct sockaddr *addr, struct nfs_client *clp,
 		     u32 minorversion)
 {
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index cf1b339..fa398c5 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -4593,7 +4593,7 @@ static void nfs4_release_lockowner_release(void *calldata)
 	kfree(calldata);
 }
 
-const struct rpc_call_ops nfs4_release_lockowner_ops = {
+static const struct rpc_call_ops nfs4_release_lockowner_ops = {
 	.rpc_release = nfs4_release_lockowner_release,
 };
 
@@ -4721,7 +4721,7 @@ static int _nfs4_proc_secinfo(struct inode *dir, const struct qstr *name, struct
 	return status;
 }
 
-int nfs4_proc_secinfo(struct inode *dir, const struct qstr *name, struct nfs4_secinfo_flavors *flavors)
+static int nfs4_proc_secinfo(struct inode *dir, const struct qstr *name, struct nfs4_secinfo_flavors *flavors)
 {
 	struct nfs4_exception exception = { };
 	int err;
@@ -5799,7 +5799,7 @@ out:
 }
 #endif /* CONFIG_NFS_V4_1 */
 
-struct nfs4_state_recovery_ops nfs40_reboot_recovery_ops = {
+static struct nfs4_state_recovery_ops nfs40_reboot_recovery_ops = {
 	.owner_flag_bit = NFS_OWNER_RECLAIM_REBOOT,
 	.state_flag_bit	= NFS_STATE_RECLAIM_REBOOT,
 	.recover_open	= nfs4_open_reclaim,
@@ -5809,7 +5809,7 @@ struct nfs4_state_recovery_ops nfs40_reboot_recovery_ops = {
 };
 
 #if defined(CONFIG_NFS_V4_1)
-struct nfs4_state_recovery_ops nfs41_reboot_recovery_ops = {
+static struct nfs4_state_recovery_ops nfs41_reboot_recovery_ops = {
 	.owner_flag_bit = NFS_OWNER_RECLAIM_REBOOT,
 	.state_flag_bit	= NFS_STATE_RECLAIM_REBOOT,
 	.recover_open	= nfs4_open_reclaim,
@@ -5820,7 +5820,7 @@ struct nfs4_state_recovery_ops nfs41_reboot_recovery_ops = {
 };
 #endif /* CONFIG_NFS_V4_1 */
 
-struct nfs4_state_recovery_ops nfs40_nograce_recovery_ops = {
+static struct nfs4_state_recovery_ops nfs40_nograce_recovery_ops = {
 	.owner_flag_bit = NFS_OWNER_RECLAIM_NOGRACE,
 	.state_flag_bit	= NFS_STATE_RECLAIM_NOGRACE,
 	.recover_open	= nfs4_open_expired,
@@ -5830,7 +5830,7 @@ struct nfs4_state_recovery_ops nfs40_nograce_recovery_ops = {
 };
 
 #if defined(CONFIG_NFS_V4_1)
-struct nfs4_state_recovery_ops nfs41_nograce_recovery_ops = {
+static struct nfs4_state_recovery_ops nfs41_nograce_recovery_ops = {
 	.owner_flag_bit = NFS_OWNER_RECLAIM_NOGRACE,
 	.state_flag_bit	= NFS_STATE_RECLAIM_NOGRACE,
 	.recover_open	= nfs4_open_expired,
@@ -5840,14 +5840,14 @@ struct nfs4_state_recovery_ops nfs41_nograce_recovery_ops = {
 };
 #endif /* CONFIG_NFS_V4_1 */
 
-struct nfs4_state_maintenance_ops nfs40_state_renewal_ops = {
+static struct nfs4_state_maintenance_ops nfs40_state_renewal_ops = {
 	.sched_state_renewal = nfs4_proc_async_renew,
 	.get_state_renewal_cred_locked = nfs4_get_renew_cred_locked,
 	.renew_lease = nfs4_proc_renew,
 };
 
 #if defined(CONFIG_NFS_V4_1)
-struct nfs4_state_maintenance_ops nfs41_state_renewal_ops = {
+static struct nfs4_state_maintenance_ops nfs41_state_renewal_ops = {
 	.sched_state_renewal = nfs41_proc_async_sequence,
 	.get_state_renewal_cred_locked = nfs4_get_machine_cred_locked,
 	.renew_lease = nfs4_proc_sequence,
diff --git a/fs/nfsd/nfs3xdr.c b/fs/nfsd/nfs3xdr.c
index ad48fac..08c6e36 100644
--- a/fs/nfsd/nfs3xdr.c
+++ b/fs/nfsd/nfs3xdr.c
@@ -842,7 +842,7 @@ out:
 	return rv;
 }
 
-__be32 *encode_entryplus_baggage(struct nfsd3_readdirres *cd, __be32 *p, const char *name, int namlen)
+static __be32 *encode_entryplus_baggage(struct nfsd3_readdirres *cd, __be32 *p, const char *name, int namlen)
 {
 	struct svc_fh	fh;
 	int err;
diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 4cf04e1..35f559b 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -2462,7 +2462,7 @@ find_delegation_file(struct nfs4_file *fp, stateid_t *stid)
 	return NULL;
 }
 
-int share_access_to_flags(u32 share_access)
+static int share_access_to_flags(u32 share_access)
 {
 	share_access &= ~NFS4_SHARE_WANT_MASK;
 
@@ -2882,7 +2882,7 @@ out:
 	return status;
 }
 
-struct lock_manager nfsd4_manager = {
+static struct lock_manager nfsd4_manager = {
 };
 
 static void
diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index c6766af..125b276 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -3120,7 +3120,7 @@ nfsd4_encode_destroy_session(struct nfsd4_compoundres *resp, int nfserr,
 	return nfserr;
 }
 
-__be32
+static __be32
 nfsd4_encode_sequence(struct nfsd4_compoundres *resp, int nfserr,
 		      struct nfsd4_sequence *seq)
 {
-- 
1.7.1

