Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-bk0-f46.google.com ([209.85.214.46]:49839 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752209Ab2GZMAB (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 26 Jul 2012 08:00:01 -0400
Received: by bkwj10 with SMTP id j10so1219641bkw.19
        for <linux-nfs@vger.kernel.org>; Thu, 26 Jul 2012 04:59:59 -0700 (PDT)
From: Benny Halevy <bhalevy@tonian.com>
To: linux-nfs@vger.kernel.org
Cc: Lev Solomonov <solo@tonian.com>, Benny Halevy <bhalevy@tonian.com>
Subject: [PATCH] pnfs: mimic vanilla nfs4 stateid allocation in pNFS
Date: Thu, 26 Jul 2012 14:59:52 +0300
Message-Id: <1343303992-28062-1-git-send-email-bhalevy@tonian.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Lev Solomonov <solo@tonian.com>

when pNFS layout state allocation code was originally introduced in
54655510b8c2a04ddbadd532f3d639b9277aa288, get_new_stid() used to do idr
preallocation in-situ. however, this preallocation was subsequently
factored out upstream in 996e09385c364f97a89648b401409521e2a3a094 into
nfs4_alloc_stid(). this lead to pNFS code occasionally failing to obtain
an ID from stateids idr in alloc_init_layout_state(), resulting in
BUG_ON-s akin to:
    kernel BUG at fs/nfsd/nfs4state.c:273!
    invalid opcode: 0000 [#1] SMP
    CPU 0
        <snip>
    Process nfsd (pid: 9969, threadinfo ffff88003a96a000, task
    ffff880038b30000)
        <snip>
    Call Trace:
    [<ffffffffa0105006>] nfs4_process_layout_stateid+0xea/0x1d8 [nfsd]
    [<ffffffff814ccd53>] ? _raw_spin_unlock+0x28/0x3b
    [<ffffffffa0105ccf>] nfs4_pnfs_get_layout+0x1a0/0x742 [nfsd]
    [<ffffffff8108c6bc>] ? trace_hardirqs_on_caller+0x121/0x158
    [<ffffffffa00f3b3c>] nfsd4_encode_layoutget+0xd7/0x18e [nfsd]
    [<ffffffffa00fa4a7>] nfsd4_encode_operation+0x57/0x7a [nfsd]
    [<ffffffffa00f0c6b>] nfsd4_proc_compound+0x39d/0x484 [nfsd]
    [<ffffffffa00e389c>] nfsd_dispatch+0xe7/0x1cc [nfsd]
    [<ffffffffa0073045>] svc_process_common+0x2d4/0x4d5 [sunrpc]
    [<ffffffffa0073458>] svc_process+0x10f/0x12d [sunrpc]
    [<ffffffffa00e3143>] nfsd+0x104/0x15e [nfsd]
    [<ffffffffa00e303f>] ? nfsd_get_default_max_blksize+0x3f/0x3f [nfsd]
    [<ffffffff8105cf3f>] kthread+0xaf/0xb7
    [<ffffffff8108c6bc>] ? trace_hardirqs_on_caller+0x121/0x158
    [<ffffffff814d4ff4>] kernel_thread_helper+0x4/0x10
    [<ffffffff810673e3>] ? finish_task_switch+0x4a/0xd0
    [<ffffffff814cd134>] ? retint_restore_args+0x13/0x13
    [<ffffffff8105ce90>] ? __init_kthread_worker+0x5a/0x5a
    [<ffffffff814d4ff0>] ? gs_change+0x13/0x13
        <snip>
    RIP  [<ffffffffa00fc0f3>] nfsd4_init_stid+0x3c/0x64 [nfsd]

this patch makes layout handling code pass through the same state
allocation code as the rest of nfs4. this required a small rearrangement
of struct nfs4_layout_state fields due to the peculiar way the upstream
nfs4 code handles state allocations ("nfs4_alloc_stid" may be a bit of a
misnomer since it allocates more than just state *id*).

Signed-off-by: Lev Solomonov <solo@tonian.com>
Signed-off-by: Benny Halevy <bhalevy@tonian.com>
---
 fs/nfsd/nfs4pnfsd.c | 2 +-
 fs/nfsd/nfs4state.c | 2 +-
 fs/nfsd/pnfsd.h     | 7 ++++++-
 fs/nfsd/state.h     | 1 +
 4 files changed, 9 insertions(+), 3 deletions(-)

diff --git a/fs/nfsd/nfs4pnfsd.c b/fs/nfsd/nfs4pnfsd.c
index 11bccdf..509b260 100644
--- a/fs/nfsd/nfs4pnfsd.c
+++ b/fs/nfsd/nfs4pnfsd.c
@@ -152,7 +152,7 @@ void pnfs_clear_device_notify(struct nfs4_client *clp)
 {
 	struct nfs4_layout_state *new;
 
-	new = kmem_cache_alloc(layout_state_slab, GFP_KERNEL);
+	new = layoutstateid(nfs4_alloc_stid(clp, layout_state_slab));
 	if (!new)
 		return new;
 	kref_init(&new->ls_ref);
diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index e5d4bc4..b884281 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -302,7 +302,7 @@ void nfsd4_init_stid(struct nfs4_stid *stid, struct nfs4_client *cl, unsigned ch
 	s->si_generation = 0;
 }
 
-static struct nfs4_stid *nfs4_alloc_stid(struct nfs4_client *cl, struct kmem_cache *slab)
+struct nfs4_stid *nfs4_alloc_stid(struct nfs4_client *cl, struct kmem_cache *slab)
 {
 	struct idr *stateids = &cl->cl_stateids;
 
diff --git a/fs/nfsd/pnfsd.h b/fs/nfsd/pnfsd.h
index e960fd3..35859ff 100644
--- a/fs/nfsd/pnfsd.h
+++ b/fs/nfsd/pnfsd.h
@@ -42,8 +42,8 @@
 
 /* outstanding layout stateid */
 struct nfs4_layout_state {
+	struct nfs4_stid	ls_stid; /* must be first field */
 	struct kref		ls_ref;
-	struct nfs4_stid	ls_stid;
 	struct list_head	ls_perfile;
 	bool			ls_roc;
 };
@@ -134,6 +134,11 @@ int nfsd_device_notify_cb(struct super_block *,
 void pnfs_set_device_notify(clientid_t *, unsigned int types);
 void pnfs_clear_device_notify(struct nfs4_client *);
 
+static inline struct nfs4_layout_state *layoutstateid(struct nfs4_stid *s)
+{
+	return container_of(s, struct nfs4_layout_state, ls_stid);
+}
+
 #if defined(CONFIG_PNFSD_LOCAL_EXPORT)
 extern struct sockaddr_storage pnfsd_lexp_addr;
 extern size_t pnfs_lexp_addr_len;
diff --git a/fs/nfsd/state.h b/fs/nfsd/state.h
index c1eb396..b3af6bc 100644
--- a/fs/nfsd/state.h
+++ b/fs/nfsd/state.h
@@ -507,6 +507,7 @@ extern __be32 nfs4_preprocess_stateid_op(struct nfsd4_compound_state *cstate,
 extern void put_nfs4_file(struct nfs4_file *);
 extern void get_nfs4_file(struct nfs4_file *);
 extern struct nfs4_client *find_confirmed_client(clientid_t *);
+extern struct nfs4_stid *nfs4_alloc_stid(struct nfs4_client *cl, struct kmem_cache *slab);
 extern void nfsd4_init_stid(struct nfs4_stid *, struct nfs4_client *, unsigned char type);
 extern void nfsd4_unhash_stid(struct nfs4_stid *);
 extern struct nfs4_stid *find_stateid(struct nfs4_client *, stateid_t *);
-- 
1.7.11.2

