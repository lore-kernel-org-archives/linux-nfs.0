Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx144.netapp.com ([216.240.21.25]:7620 "EHLO mx144.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932425AbbCQWlW (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 17 Mar 2015 18:41:22 -0400
From: <andros@netapp.com>
To: <bfields@fieldses.org>
CC: <trond.myklebust@primarydata.com>, <anna.schumaker@netapp.com>,
        <linux-nfs@vger.kernel.org>, Andy Adamson <andros@netapp.com>
Subject: [PATCH RFC 10/10] NFSD nfs4 inter ssc copy
Date: Tue, 17 Mar 2015 18:31:38 -0400
Message-ID: <1426631498-14772-11-git-send-email-andros@netapp.com>
In-Reply-To: <1426631498-14772-1-git-send-email-andros@netapp.com>
References: <1426631498-14772-1-git-send-email-andros@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

registration of inter-ssc client module
call ssc_connect
call ssc_open
call scc_disconnect

Note: do not unload the nfs42-interserver-copy module at disconnect.

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfsd/nfs4proc.c | 141 ++++++++++++++++++++++++++++++++++++++++++++++++++---
 1 file changed, 133 insertions(+), 8 deletions(-)

diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index 5299631..0c21197 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -47,6 +47,8 @@
 #include "pnfs.h"
 #include "trace.h"
 
+#include <linux/nfs4intercopy.h>
+
 #ifdef CONFIG_NFSD_V4_SECURITY_LABEL
 #include <linux/security.h>
 
@@ -1070,6 +1072,35 @@ nfsd4_verify_copy(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 	return status;
 }
 
+/**
+ * ripped off from __svc_print_addr
+ */
+static void
+nfsd4_set_clientip(const struct sockaddr *addr, char *buf)
+{
+	const struct sockaddr_in *sin = (const struct sockaddr_in *)addr;
+	const struct sockaddr_in6 *sin6 = (const struct sockaddr_in6 *)addr;
+
+	switch (addr->sa_family) {
+	case AF_INET:
+		snprintf(buf, RPC_MAX_ADDRBUFLEN, "%pI4", &sin->sin_addr);
+		break;
+
+	case AF_INET6:
+		snprintf(buf, RPC_MAX_ADDRBUFLEN, "%pI6", &sin6->sin6_addr);
+		break;
+	}
+}
+
+static void
+nfsd4_addr_2_nfs42_netaddr(struct nfsd4_addr *src, struct nfs42_netaddr *dst)
+{
+	dst->na_netid_len = src->na_netid_len;
+	memcpy(dst->na_netid, src->na_netid_val, dst->na_netid_len);
+	dst->na_uaddr_len = src->na_uaddr_len;
+	memcpy(dst->na_uaddr, src->na_uaddr_val, dst->na_uaddr_len);
+}
+
 static __be32
 nfsd4_copy(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 		struct nfsd4_copy *copy)
@@ -1077,16 +1108,90 @@ nfsd4_copy(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 	ssize_t bytes;
 	__be32 status;
 	struct file *src = NULL, *dst = NULL;
+	char *fh_data = NULL, *st_data = NULL;
+	struct nfs42_inter_ssc_ops *issc_ops = NULL;
+	struct nfs42_ssc_client *sclp = NULL;
 
-	status = nfsd4_verify_copy(rqstp, cstate, copy, &src, &dst);
-	if (status)
-		return status;
+	if (copy->cp_nsrc > 0) { /* Inter server SSC */
+		struct nfs42_netaddr naddr;
+		char clientip[RPC_MAX_ADDRBUFLEN] = {0,};
+		struct svc_fh *s_fh = NULL;
+		stateid_t *s_stid = &copy->cp_src_stateid;
+		u32 version = 42;
 
-	/* Intra copy source fh is stale */
-	if (HAS_CSTATE_FLAG(cstate, IS_STALE_FH)) {
+		dprintk("%s INTER SSC\n", __func__);
+
+		/* Only verify the destination stateid */
+		status = nfs4_preprocess_stateid_op(SVC_NET(rqstp), cstate,
+						&cstate->current_fh,
+						&copy->cp_dst_stateid,
+						WR_STATE, &dst);
+		if (status)
+			return status;
+
+		/* Inter copy source fh is always stale */
 		CLEAR_CSTATE_FLAG(cstate, IS_STALE_FH);
-		cstate->status = nfserr_copy_stalefh;
-		goto out;
+
+		status = -EINVAL;
+		/* Currently support for one NL4_NETADDR source server */
+		if (copy->cp_src.nl4_type != NL4_NETADDR) {
+			WARN(copy->cp_src.nl4_type != NL4_NETADDR,
+				"nfsd4_copy src server not NL4_NETADDR\n");
+			goto out;
+		}
+
+		set_ssc_module(&issc_ops, version);
+		dprintk("%s set_ssc_module issc_ops %p \n", __func__,
+			issc_ops);
+		if (issc_ops == NULL)
+			goto out;
+
+		nfsd4_set_clientip((const struct sockaddr *)&rqstp->rq_daddr,
+				clientip);
+
+		printk("%s clientip %s\n", __func__, clientip);
+		nfsd4_addr_2_nfs42_netaddr(&copy->cp_src.nl4_addr, &naddr);
+
+		sclp = issc_ops->ssc_connect(&naddr, SVC_NET(rqstp), clientip);
+		dprintk("%s sclp %p\n", __func__, sclp);
+		if (sclp == NULL)
+			goto out;
+
+		s_fh = &cstate->save_fh;
+		status = -ENOMEM;
+		fh_data = kzalloc(NFS_MAXFHSIZE, GFP_KERNEL);
+		if (fh_data == NULL)
+			goto out;
+		st_data = kzalloc(sizeof(stateid_opaque_t), GFP_KERNEL);
+		if (st_data == NULL) {
+			kfree(fh_data);
+			goto out;
+		}
+
+		status = 0;
+		memcpy(fh_data, &s_fh->fh_handle.fh_base,
+			s_fh->fh_handle.fh_size);
+		memcpy(st_data, (void *)&s_stid->si_opaque,
+			sizeof(stateid_opaque_t));
+
+		src =  issc_ops->ssc_open(sclp,
+					s_fh->fh_handle.fh_size, fh_data,
+					s_stid->si_generation, st_data);
+
+		dprintk("%s FILEP src %p\n", __func__, src);
+	} else {
+		dprintk("%s INTRA SSC\n", __func__);
+
+		status = nfsd4_verify_copy(rqstp, cstate, copy, &src, &dst);
+		if (status)
+			return status;
+
+		/* Intra copy source fh is stale */
+		if (HAS_CSTATE_FLAG(cstate, IS_STALE_FH)) {
+			CLEAR_CSTATE_FLAG(cstate, IS_STALE_FH);
+			cstate->status = nfserr_copy_stalefh;
+			goto out;
+		}
 	}
 
 	bytes = nfsd_copy_range(src, copy->cp_src_pos,
@@ -1104,8 +1209,28 @@ nfsd4_copy(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 		status = nfs_ok;
 	}
 
-	fput(src);
+	if (copy->cp_nsrc > 0) { /* Inter server SSC */
+
+		dprintk("%s BEFORE src f_count %ld d_cound %d\n", __func__,
+			atomic_long_read(&src->f_count),
+			d_count(src->f_path.dentry));
+
+		/* One for the READ */
+		dput(src->f_path.dentry);
+
+		if (issc_ops && sclp)
+			/* Frees sclp */
+			issc_ops->ssc_disconnect(sclp, src);
+
+		kfree(st_data);
+		kfree(fh_data);
+	} else { 		/* Intra server SSC */
+		fput(src); /* XXXX check when fput is needed */
+	}
+
+	/* XXX is this needed for Intra copy?
 	fput(dst);
+	*/
 out:
 	return status;
 }
-- 
1.8.3.1

