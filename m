Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mailhub.sw.ru ([195.214.232.25]:38440 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751413Ab2K0LJc (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 27 Nov 2012 06:09:32 -0500
Subject: [PATCH 1/2] nfsd: make NFSv4 lease time per net
To: bfields@fieldses.org
From: Stanislav Kinsbursky <skinsbursky@parallels.com>
Cc: linux-nfs@vger.kernel.org, Trond.Myklebust@netapp.com,
        linux-kernel@vger.kernel.org, devel@openvz.org
Date: Tue, 27 Nov 2012 14:11:44 +0300
Message-ID: <20121127111144.10271.97169.stgit@localhost.localdomain>
In-Reply-To: <20121127111007.10271.54338.stgit@localhost.localdomain>
References: <20121127111007.10271.54338.stgit@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Lease time is a part of NFSv4 state engine, which is constructed per network
namespace.

Signed-off-by: Stanislav Kinsbursky <skinsbursky@parallels.com>
---
 fs/nfsd/netns.h        |    2 ++
 fs/nfsd/nfs4callback.c |    8 +++++---
 fs/nfsd/nfs4state.c    |   11 +++++------
 fs/nfsd/nfs4xdr.c      |    4 +++-
 fs/nfsd/nfsctl.c       |    5 ++++-
 fs/nfsd/nfsd.h         |    1 -
 6 files changed, 19 insertions(+), 12 deletions(-)

diff --git a/fs/nfsd/netns.h b/fs/nfsd/netns.h
index 9047706..0c20be8 100644
--- a/fs/nfsd/netns.h
+++ b/fs/nfsd/netns.h
@@ -87,6 +87,8 @@ struct nfsd_net {
 
 	struct file *rec_file;
 	bool in_grace;
+
+	time_t nfsd4_lease;
 };
 
 extern int nfsd_net_id;
diff --git a/fs/nfsd/nfs4callback.c b/fs/nfsd/nfs4callback.c
index 826cc26..99bc85f 100644
--- a/fs/nfsd/nfs4callback.c
+++ b/fs/nfsd/nfs4callback.c
@@ -36,6 +36,7 @@
 #include <linux/slab.h>
 #include "nfsd.h"
 #include "state.h"
+#include "netns.h"
 
 #define NFSDDBG_FACILITY                NFSDDBG_PROC
 
@@ -625,9 +626,10 @@ static const struct rpc_program cb_program = {
 	.pipe_dir_name		= "nfsd4_cb",
 };
 
-static int max_cb_time(void)
+static int max_cb_time(struct net *net)
 {
-	return max(nfsd4_lease/10, (time_t)1) * HZ;
+	struct nfsd_net *nn = net_generic(net, nfsd_net_id);
+	return max(nn->nfsd4_lease/10, (time_t)1) * HZ;
 }
 
 static struct rpc_cred *callback_cred;
@@ -659,7 +661,7 @@ static struct rpc_cred *get_backchannel_cred(struct nfs4_client *clp, struct rpc
 static int setup_callback_client(struct nfs4_client *clp, struct nfs4_cb_conn *conn, struct nfsd4_session *ses)
 {
 	struct rpc_timeout	timeparms = {
-		.to_initval	= max_cb_time(),
+		.to_initval	= max_cb_time(clp->net),
 		.to_retries	= 0,
 	};
 	struct rpc_create_args args = {
diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 93c7882..56b0ebb 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -51,7 +51,6 @@
 #define NFSDDBG_FACILITY                NFSDDBG_PROC
 
 /* Globals */
-time_t nfsd4_lease = 90;     /* default lease time */
 time_t nfsd4_grace = 90;
 
 #define all_ones {{~0,~0},~0}
@@ -3184,7 +3183,7 @@ nfsd4_end_grace(struct nfsd_net *nn)
 	 * to see the (possibly new, possibly shorter) lease time, we
 	 * can safely set the next grace time to the current lease time:
 	 */
-	nfsd4_grace = nfsd4_lease;
+	nfsd4_grace = nn->nfsd4_lease;
 }
 
 static time_t
@@ -3194,9 +3193,9 @@ nfs4_laundromat(struct nfsd_net *nn)
 	struct nfs4_openowner *oo;
 	struct nfs4_delegation *dp;
 	struct list_head *pos, *next, reaplist;
-	time_t cutoff = get_seconds() - nfsd4_lease;
-	time_t t, clientid_val = nfsd4_lease;
-	time_t u, test_val = nfsd4_lease;
+	time_t cutoff = get_seconds() - nn->nfsd4_lease;
+	time_t t, clientid_val = nn->nfsd4_lease;
+	time_t u, test_val = nn->nfsd4_lease;
 
 	nfs4_lock_state();
 
@@ -3245,7 +3244,7 @@ nfs4_laundromat(struct nfsd_net *nn)
 		dp = list_entry (pos, struct nfs4_delegation, dl_recall_lru);
 		unhash_delegation(dp);
 	}
-	test_val = nfsd4_lease;
+	test_val = nn->nfsd4_lease;
 	list_for_each_safe(pos, next, &nn->close_lru) {
 		oo = container_of(pos, struct nfs4_openowner, oo_close_lru);
 		if (time_after((unsigned long)oo->oo_time, (unsigned long)cutoff)) {
diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index 406d0c4..6a5ab39 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -53,6 +53,7 @@
 #include "vfs.h"
 #include "state.h"
 #include "cache.h"
+#include "netns.h"
 
 #define NFSDDBG_FACILITY		NFSDDBG_XDR
 
@@ -2091,6 +2092,7 @@ nfsd4_encode_fattr(struct svc_fh *fhp, struct svc_export *exp,
 		.mnt	= exp->ex_path.mnt,
 		.dentry	= dentry,
 	};
+	struct nfsd_net *nn = net_generic(SVC_NET(rqstp), nfsd_net_id);
 
 	BUG_ON(bmval1 & NFSD_WRITEONLY_ATTRS_WORD1);
 	BUG_ON(bmval0 & ~nfsd_suppattrs0(minorversion));
@@ -2251,7 +2253,7 @@ nfsd4_encode_fattr(struct svc_fh *fhp, struct svc_export *exp,
 	if (bmval0 & FATTR4_WORD0_LEASE_TIME) {
 		if ((buflen -= 4) < 0)
 			goto out_resource;
-		WRITE32(nfsd4_lease);
+		WRITE32(nn->nfsd4_lease);
 	}
 	if (bmval0 & FATTR4_WORD0_RDATTR_ERROR) {
 		if ((buflen -= 4) < 0)
diff --git a/fs/nfsd/nfsctl.c b/fs/nfsd/nfsctl.c
index dab350d..4930981 100644
--- a/fs/nfsd/nfsctl.c
+++ b/fs/nfsd/nfsctl.c
@@ -912,7 +912,8 @@ static ssize_t nfsd4_write_time(struct file *file, char *buf, size_t size, time_
  */
 static ssize_t write_leasetime(struct file *file, char *buf, size_t size)
 {
-	return nfsd4_write_time(file, buf, size, &nfsd4_lease);
+	struct nfsd_net *nn = net_generic(&init_net, nfsd_net_id);
+	return nfsd4_write_time(file, buf, size, &nn->nfsd4_lease);
 }
 
 /**
@@ -1063,6 +1064,7 @@ int nfsd_net_id;
 static __net_init int nfsd_init_net(struct net *net)
 {
 	int retval;
+	struct nfsd_net *nn = net_generic(net, nfsd_net_id);
 
 	retval = nfsd_export_init(net);
 	if (retval)
@@ -1070,6 +1072,7 @@ static __net_init int nfsd_init_net(struct net *net)
 	retval = nfsd_idmap_init(net);
 	if (retval)
 		goto out_idmap_error;
+	nn->nfsd4_lease = 90;	/* default lease time */
 	return 0;
 
 out_idmap_error:
diff --git a/fs/nfsd/nfsd.h b/fs/nfsd/nfsd.h
index d7b210b..a8f7325 100644
--- a/fs/nfsd/nfsd.h
+++ b/fs/nfsd/nfsd.h
@@ -276,7 +276,6 @@ extern struct timeval	nfssvc_boot;
 
 #ifdef CONFIG_NFSD_V4
 
-extern time_t nfsd4_lease;
 extern time_t nfsd4_grace;
 
 /* before processing a COMPOUND operation, we have to check that there

