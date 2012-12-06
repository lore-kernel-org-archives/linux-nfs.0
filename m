Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mailhub.sw.ru ([195.214.232.25]:35093 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754975Ab2LFLWp (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 6 Dec 2012 06:22:45 -0500
Subject: [PATCH 3/8] nfsd: make NFSd service boot time per-net
To: bfields@fieldses.org
From: Stanislav Kinsbursky <skinsbursky@parallels.com>
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org, devel@openvz.org
Date: Thu, 06 Dec 2012 14:23:19 +0300
Message-ID: <20121206112319.29559.16664.stgit@localhost.localdomain>
In-Reply-To: <20121206111903.29559.4853.stgit@localhost.localdomain>
References: <20121206111903.29559.4853.stgit@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

All is simple: NFSd service can be started in diffent moments of time in
different network environments. So, it's "boot time" have to be assigned per
net.

Signed-off-by: Stanislav Kinsbursky <skinsbursky@parallels.com>
---
 fs/nfsd/netns.h    |    5 +++++
 fs/nfsd/nfs3xdr.c  |   14 ++++++++++----
 fs/nfsd/nfs4proc.c |   11 ++++++-----
 fs/nfsd/nfsd.h     |    5 -----
 fs/nfsd/nfssvc.c   |    4 ++--
 5 files changed, 23 insertions(+), 16 deletions(-)

diff --git a/fs/nfsd/netns.h b/fs/nfsd/netns.h
index da8741b..8acfb17 100644
--- a/fs/nfsd/netns.h
+++ b/fs/nfsd/netns.h
@@ -94,6 +94,11 @@ struct nfsd_net {
 	time_t nfsd4_grace;
 
 	bool nfsd_net_up;
+
+	/*
+	 * Time of server startup
+	 */
+	struct timeval nfssvc_boot;
 };
 
 extern int nfsd_net_id;
diff --git a/fs/nfsd/nfs3xdr.c b/fs/nfsd/nfs3xdr.c
index 43f46cd..2b8618d 100644
--- a/fs/nfsd/nfs3xdr.c
+++ b/fs/nfsd/nfs3xdr.c
@@ -7,8 +7,10 @@
  */
 
 #include <linux/namei.h>
+#include <linux/sunrpc/svc_xprt.h>
 #include "xdr3.h"
 #include "auth.h"
+#include "netns.h"
 
 #define NFSDDBG_FACILITY		NFSDDBG_XDR
 
@@ -720,12 +722,14 @@ int
 nfs3svc_encode_writeres(struct svc_rqst *rqstp, __be32 *p,
 					struct nfsd3_writeres *resp)
 {
+	struct nfsd_net *nn = net_generic(SVC_NET(rqstp), nfsd_net_id);
+
 	p = encode_wcc_data(rqstp, p, &resp->fh);
 	if (resp->status == 0) {
 		*p++ = htonl(resp->count);
 		*p++ = htonl(resp->committed);
-		*p++ = htonl(nfssvc_boot.tv_sec);
-		*p++ = htonl(nfssvc_boot.tv_usec);
+		*p++ = htonl(nn->nfssvc_boot.tv_sec);
+		*p++ = htonl(nn->nfssvc_boot.tv_usec);
 	}
 	return xdr_ressize_check(rqstp, p);
 }
@@ -1082,11 +1086,13 @@ int
 nfs3svc_encode_commitres(struct svc_rqst *rqstp, __be32 *p,
 					struct nfsd3_commitres *resp)
 {
+	struct nfsd_net *nn = net_generic(SVC_NET(rqstp), nfsd_net_id);
+
 	p = encode_wcc_data(rqstp, p, &resp->fh);
 	/* Write verifier */
 	if (resp->status == 0) {
-		*p++ = htonl(nfssvc_boot.tv_sec);
-		*p++ = htonl(nfssvc_boot.tv_usec);
+		*p++ = htonl(nn->nfssvc_boot.tv_sec);
+		*p++ = htonl(nn->nfssvc_boot.tv_usec);
 	}
 	return xdr_ressize_check(rqstp, p);
 }
diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index 87d24e5..14406ae 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -495,12 +495,13 @@ nfsd4_access(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 			   &access->ac_supported);
 }
 
-static void gen_boot_verifier(nfs4_verifier *verifier)
+static void gen_boot_verifier(nfs4_verifier *verifier, struct net *net)
 {
 	__be32 verf[2];
+	struct nfsd_net *nn = net_generic(net, nfsd_net_id);
 
-	verf[0] = (__be32)nfssvc_boot.tv_sec;
-	verf[1] = (__be32)nfssvc_boot.tv_usec;
+	verf[0] = (__be32)nn->nfssvc_boot.tv_sec;
+	verf[1] = (__be32)nn->nfssvc_boot.tv_usec;
 	memcpy(verifier->data, verf, sizeof(verifier->data));
 }
 
@@ -508,7 +509,7 @@ static __be32
 nfsd4_commit(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 	     struct nfsd4_commit *commit)
 {
-	gen_boot_verifier(&commit->co_verf);
+	gen_boot_verifier(&commit->co_verf, SVC_NET(rqstp));
 	return nfsd_commit(rqstp, &cstate->current_fh, commit->co_offset,
 			     commit->co_count);
 }
@@ -928,7 +929,7 @@ nfsd4_write(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 
 	cnt = write->wr_buflen;
 	write->wr_how_written = write->wr_stable_how;
-	gen_boot_verifier(&write->wr_verifier);
+	gen_boot_verifier(&write->wr_verifier, SVC_NET(rqstp));
 
 	nvecs = fill_in_write_vector(rqstp->rq_vec, write);
 	WARN_ON_ONCE(nvecs > ARRAY_SIZE(rqstp->rq_vec));
diff --git a/fs/nfsd/nfsd.h b/fs/nfsd/nfsd.h
index 18f9996..71ba60d 100644
--- a/fs/nfsd/nfsd.h
+++ b/fs/nfsd/nfsd.h
@@ -269,11 +269,6 @@ void		nfsd_lockd_shutdown(void);
 /* Check for dir entries '.' and '..' */
 #define isdotent(n, l)	(l < 3 && n[0] == '.' && (l == 1 || n[1] == '.'))
 
-/*
- * Time of server startup
- */
-extern struct timeval	nfssvc_boot;
-
 #ifdef CONFIG_NFSD_V4
 
 /* before processing a COMPOUND operation, we have to check that there
diff --git a/fs/nfsd/nfssvc.c b/fs/nfsd/nfssvc.c
index 6e17efd..40992cd 100644
--- a/fs/nfsd/nfssvc.c
+++ b/fs/nfsd/nfssvc.c
@@ -27,7 +27,6 @@
 
 extern struct svc_program	nfsd_program;
 static int			nfsd(void *vrqstp);
-struct timeval			nfssvc_boot;
 
 /*
  * nfsd_mutex protects nfsd_serv -- both the pointer itself and the members
@@ -367,6 +366,7 @@ static int nfsd_get_default_max_blksize(void)
 int nfsd_create_serv(struct net *net)
 {
 	int error;
+	struct nfsd_net *nn = net_generic(net, nfsd_net_id);
 
 	WARN_ON(!mutex_is_locked(&nfsd_mutex));
 	if (nfsd_serv) {
@@ -388,7 +388,7 @@ int nfsd_create_serv(struct net *net)
 	}
 
 	set_max_drc();
-	do_gettimeofday(&nfssvc_boot);		/* record boot time */
+	do_gettimeofday(&nn->nfssvc_boot);		/* record boot time */
 	return 0;
 }
 

