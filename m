Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qy0-f174.google.com ([209.85.216.174]:52081 "EHLO
	mail-qy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753803Ab2AWUBr (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 23 Jan 2012 15:01:47 -0500
Received: by mail-qy0-f174.google.com with SMTP id f13so1753141qcs.19
        for <linux-nfs@vger.kernel.org>; Mon, 23 Jan 2012 12:01:47 -0800 (PST)
MIME-Version: 1.0
From: Jeff Layton <jlayton@redhat.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v4 6/6] nfsd: get boot generation number from upcall instead of boot_time
Date: Mon, 23 Jan 2012 15:01:07 -0500
Message-Id: <1327348867-699-7-git-send-email-jlayton@redhat.com>
In-Reply-To: <1327348867-699-1-git-send-email-jlayton@redhat.com>
References: <1327348867-699-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Replace boot_time as a mechanism for generating clientids with a
number that we upcall for from stable storage. If the upcall is
not available, then call get_seconds() to set it similarly to
how we do this today.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 fs/nfsd/nfs4recover.c |   41 ++++++++++++++++++++++++++++++++++++-----
 fs/nfsd/nfs4state.c   |   19 +++++++++++++------
 fs/nfsd/state.h       |    2 +-
 3 files changed, 50 insertions(+), 12 deletions(-)

diff --git a/fs/nfsd/nfs4recover.c b/fs/nfsd/nfs4recover.c
index 7ef9327..1477dc5 100644
--- a/fs/nfsd/nfs4recover.c
+++ b/fs/nfsd/nfs4recover.c
@@ -50,7 +50,7 @@
 
 /* Declarations */
 struct nfsd4_client_tracking_ops {
-	int (*init)(void);
+	int (*init)(uint32_t *);
 	void (*exit)(void);
 	void (*create)(struct nfs4_client *);
 	void (*remove)(struct nfs4_client *);
@@ -409,7 +409,7 @@ nfsd4_init_recdir(void)
 }
 
 static int
-nfsd4_load_reboot_recovery_data(void)
+nfsd4_load_reboot_recovery_data(uint32_t *boot_gen)
 {
 	int status;
 
@@ -420,6 +420,8 @@ nfsd4_load_reboot_recovery_data(void)
 	nfs4_unlock_state();
 	if (status)
 		printk(KERN_ERR "NFSD: Failure reading reboot recovery data\n");
+	else
+		*boot_gen = (uint32_t)get_seconds();
 	return status;
 }
 
@@ -689,6 +691,35 @@ free_cld_upcall(struct cld_upcall *victim)
 	kfree(victim);
 }
 
+static int
+nfsd4_cld_init(uint32_t *boot_gen)
+{
+	int ret;
+	struct cld_upcall *cup;
+
+	ret = nfsd4_init_cld_pipe();
+	if (ret)
+		return ret;
+
+	/* upcall for boot gen */
+	cup = alloc_cld_upcall();
+	if (!cup)
+		return -ENOMEM;
+
+	cup->cu_msg.cm_cmd = Cld_Init;
+
+	ret = cld_pipe_upcall(&cup->cu_msg);
+	if (!ret) {
+		ret = cup->cu_msg.cm_status;
+		if (!ret)
+			*boot_gen = cup->cu_msg.cm_u.cm_generation;
+	}
+
+	free_cld_upcall(cup);
+	return ret;
+
+}
+
 /* Ask daemon to create a new record */
 static void
 nfsd4_cld_create(struct nfs4_client *clp)
@@ -781,7 +812,7 @@ out_err:
 }
 
 static struct nfsd4_client_tracking_ops nfsd4_cld_tracking_ops = {
-	.init		= nfsd4_init_cld_pipe,
+	.init		= nfsd4_cld_init,
 	.exit		= nfsd4_remove_cld_pipe,
 	.create		= nfsd4_cld_create,
 	.check		= nfsd4_cld_check,
@@ -789,7 +820,7 @@ static struct nfsd4_client_tracking_ops nfsd4_cld_tracking_ops = {
 };
 
 int
-nfsd4_client_tracking_init(void)
+nfsd4_client_tracking_init(uint32_t *boot_gen)
 {
 	int status;
 	struct path path;
@@ -808,7 +839,7 @@ nfsd4_client_tracking_init(void)
 	if (!client_tracking_ops->init)
 		return 0;
 
-	status = client_tracking_ops->init();
+	status = client_tracking_ops->init(boot_gen);
 	if (status) {
 		printk(KERN_WARNING "NFSD: Unable to initialize client "
 				    "recovery tracking! (%d)\n", status);
diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 971a117..47e4981 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -49,6 +49,7 @@
 time_t nfsd4_lease = 90;     /* default lease time */
 time_t nfsd4_grace = 90;
 static time_t boot_time;
+static uint32_t boot_gen;
 
 #define all_ones {{~0,~0},~0}
 static const stateid_t one_stateid = {
@@ -975,10 +976,10 @@ renew_client(struct nfs4_client *clp)
 static int
 STALE_CLIENTID(clientid_t *clid)
 {
-	if (clid->cl_boot == boot_time)
+	if (clid->cl_boot == boot_gen)
 		return 0;
-	dprintk("NFSD stale clientid (%08x/%08x) boot_time %08lx\n",
-		clid->cl_boot, clid->cl_id, boot_time);
+	dprintk("NFSD stale clientid (%08x/%08x) boot_gen %08x\n",
+		clid->cl_boot, clid->cl_id, boot_gen);
 	return 1;
 }
 
@@ -1132,7 +1133,7 @@ static void gen_clid(struct nfs4_client *clp)
 {
 	static u32 current_clientid = 1;
 
-	clp->cl_clientid.cl_boot = boot_time;
+	clp->cl_clientid.cl_boot = boot_gen;
 	clp->cl_clientid.cl_id = current_clientid++; 
 }
 
@@ -3175,7 +3176,7 @@ static inline __be32 nfs4_check_fh(struct svc_fh *fhp, struct nfs4_ol_stateid *s
 static int
 STALE_STATEID(stateid_t *stateid)
 {
-	if (stateid->si_opaque.so_clid.cl_boot == boot_time)
+	if (stateid->si_opaque.so_clid.cl_boot == boot_gen)
 		return 0;
 	dprintk("NFSD: stale stateid " STATEID_FMT "!\n",
 		STATEID_VAL(stateid));
@@ -4630,7 +4631,13 @@ out_free_laundry:
 int
 nfs4_state_start(void)
 {
-	nfsd4_client_tracking_init();
+	int ret;
+
+	ret = nfsd4_client_tracking_init(&boot_gen);
+
+	/* if init fails, then we still need to set boot_gen */
+	if (ret)
+		boot_gen = (uint32_t)get_seconds();
 	return __nfs4_state_start();
 }
 
diff --git a/fs/nfsd/state.h b/fs/nfsd/state.h
index 0f9a0ac..dd1f688 100644
--- a/fs/nfsd/state.h
+++ b/fs/nfsd/state.h
@@ -487,7 +487,7 @@ extern __be32 nfs4_validate_stateid(struct nfs4_client *, stateid_t *);
 extern void nfsd4_purge_closed_stateid(struct nfs4_stateowner *);
 
 /* nfs4recover operations */
-extern int nfsd4_client_tracking_init(void);
+extern int nfsd4_client_tracking_init(uint32_t *boot_gen);
 extern void nfsd4_client_tracking_exit(void);
 extern void nfsd4_client_record_create(struct nfs4_client *clp);
 extern void nfsd4_client_record_remove(struct nfs4_client *clp);
-- 
1.7.7.5

