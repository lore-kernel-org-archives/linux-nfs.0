Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx143.netapp.com ([216.240.21.24]:13112 "EHLO mx143.netapp.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1755135AbcHSR00 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 19 Aug 2016 13:26:26 -0400
From: <andros@netapp.com>
To: <trondmy.myklebust@primarydata.com>
CC: <anna.schumaker@netapp.com>, <bfields@fieldses.org>,
        <linux-nfs@vger.kernel.org>, Andy Adamson <andros@netapp.com>
Subject: [PATCH Version-2 11/12] NFSD add nfs4 inter ssc to nfsd4_copy
Date: Fri, 19 Aug 2016 13:25:11 -0400
Message-ID: <1471627512-4102-12-git-send-email-andros@netapp.com>
In-Reply-To: <1471627512-4102-1-git-send-email-andros@netapp.com>
References: <1471627512-4102-1-git-send-email-andros@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

Given a universal address, mount the source server from the destination
server.  Use an internal mount. Call the NFS client nfs42_ssc_open to
obtain the NFS struct file suitable for nfsd_copy_range.

Add Kconfig dependencies for inter server to server copy

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfsd/Kconfig      |  10 ++
 fs/nfsd/nfs4proc.c   | 272 +++++++++++++++++++++++++++++++++++++++++++++++++--
 include/linux/nfs4.h |   4 +
 3 files changed, 276 insertions(+), 10 deletions(-)

diff --git a/fs/nfsd/Kconfig b/fs/nfsd/Kconfig
index 47febcf..56c4943 100644
--- a/fs/nfsd/Kconfig
+++ b/fs/nfsd/Kconfig
@@ -130,6 +130,16 @@ config NFSD_FLEXFILELAYOUT
 
 	  If unsure, say N.
 
+config NFSD_V4_2_INTER_SSC
+	bool "NFSv4.2 inter server to server COPY"
+	depends on NFSD_V4 && NFS_V4_1 && NFS_V4_2
+	help
+	  This option enables support for NFSv4.2 inter server to
+	  server copy where the destination server calls the NFSv4.2
+	  client to read the data to copy from the source server.
+
+	  If unsure, say N.
+
 config NFSD_V4_SECURITY_LABEL
 	bool "Provide Security Label support for NFSv4 server"
 	depends on NFSD_V4 && SECURITY
diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index 8e9bae6..220db84 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -1086,16 +1086,237 @@ out:
 	return status;
 }
 
+#ifdef CONFIG_NFSD_V4_2_INTER_SSC
+
+#define NFSD42_INTERSSC_RAWDATA "minorversion=1,vers=4,addr=%s,clientaddr=%s"
+
+/**
+ * Support one copy source server for now.
+ */
+static struct nfs42_inter_ssc *
+nfsd4_interssc_connect(struct nl4_servers *nss, struct svc_rqst *rqstp)
+{
+	struct file_system_type *type;
+	struct nfs42_inter_ssc *isp;
+	struct nfs42_netaddr *naddr;
+	struct sockaddr_storage tmp_addr;
+	size_t tmp_addrlen, match_netid_len = 3;
+	char *startsep = "", *endsep = "", *match_netid = "tcp";
+	char *ipaddr, *ipaddr2, *raw_data;
+	int len, raw_len, status = -EINVAL;
+
+	/* Currently support for one NL4_NETADDR source server */
+	if (nss->nl_svr->nl4_type != NL4_NETADDR) {
+		WARN(nss->nl_svr->nl4_type != NL4_NETADDR,
+			"nfsd4_copy src server not NL4_NETADDR\n");
+		goto out_err;
+	}
+
+	naddr = &nss->nl_svr->u.nl4_addr;
+
+	tmp_addrlen = rpc_uaddr2sockaddr(SVC_NET(rqstp), naddr->na_uaddr,
+					naddr->na_uaddr_len,
+					(struct sockaddr *)&tmp_addr,
+					sizeof(tmp_addr));
+	if (tmp_addrlen == 0)
+		goto out_err;
+
+	if (tmp_addr.ss_family == AF_INET6) {
+		startsep = "[";
+		endsep = "]";
+		match_netid = "tcp6";
+		match_netid_len = 4;
+	}
+
+	if (naddr->na_netid_len != match_netid_len ||
+	    strncmp(naddr->na_netid, match_netid, naddr->na_netid_len))
+		goto out_err;
+
+	/* Freed in nfsd4_interssc_disconnect */
+	status = -ENOMEM;
+	isp = kzalloc(sizeof(*isp), GFP_KERNEL);
+	if (unlikely(!isp))
+		goto out_err;
+
+	/* Construct the raw data for the vfs_kern_mount call */
+	len = RPC_MAX_ADDRBUFLEN + 1;
+	ipaddr = kzalloc(len, GFP_KERNEL);
+	if (!ipaddr)
+		goto out_free_isp;
+
+	rpc_ntop((struct sockaddr *)&tmp_addr, ipaddr, len);
+
+	/* 2 for ipv6 endsep and startsep. 3 for ":/" and trailing '/0'*/
+	ipaddr2 = kzalloc(len + 5, GFP_KERNEL);
+	if (!ipaddr2)
+		goto out_free_ipaddr;
+
+	rpc_ntop((struct sockaddr *)&rqstp->rq_daddr, ipaddr2, len + 5);
+
+	raw_len = strlen(NFSD42_INTERSSC_RAWDATA) + strlen(ipaddr) +
+			strlen(ipaddr2);
+	raw_data = kzalloc(raw_len, GFP_KERNEL);
+	if (!raw_data)
+		goto out_free_ipaddr2;
+
+	snprintf(raw_data, raw_len, NFSD42_INTERSSC_RAWDATA, ipaddr,
+		 ipaddr2);
+
+	status = -ENODEV;
+	type = get_fs_type("nfs");
+	if (!type)
+		goto out_free_rawdata;
+
+	/* Set the server:<export> for the vfs_kerne_mount call */
+	memset(ipaddr2, 0, len + 5);
+	snprintf(ipaddr2, len + 5, "%s%s%s:/", startsep, ipaddr, endsep);
+
+	dprintk("%s  Raw mount data:  %s server:export %s\n", __func__,
+		raw_data, ipaddr2);
+
+	/* Use an 'internal' mount: MS_KERNMOUNT -> MNT_INTERNAL */
+	isp->sc_root_mnt = vfs_kern_mount(type, MS_KERNMOUNT, ipaddr2,
+					raw_data);
+	if (IS_ERR(isp->sc_root_mnt)) {
+		status = PTR_ERR(isp->sc_root_mnt);
+		goto out_free_rawdata;
+	}
+
+	isp->sc_mnt_dentry = isp->sc_root_mnt->mnt_root;
+
+	kfree(raw_data);
+	kfree(ipaddr2);
+	kfree(ipaddr);
+
+	return isp;
+
+out_free_rawdata:
+	kfree(raw_data);
+out_free_ipaddr2:
+	kfree(ipaddr2);
+out_free_ipaddr:
+	kfree(ipaddr);
+out_free_isp:
+	kfree(isp);
+out_err:
+	dprintk("--> %s ERROR %d\n", __func__, status);
+	return ERR_PTR(status);
+}
+
+static void
+nfsd4_interssc_disconnect(struct nfs42_inter_ssc *ssc)
+{
+	struct super_block *sb = ssc->sc_mnt_dentry->d_inode->i_sb;
+
+	mntput(ssc->sc_root_mnt);
+	deactivate_super(sb);
+
+	/* Allocated in nfsd4_interssc_connect */
+	kfree(ssc);
+}
+
+/**
+ * nfsd4_setup_inter_ssc
+ *
+ * Verify COPY destination stateid.
+ * Connect to the source server with NFSv4.1.
+ * Create the source struct file for nfsd_copy_range.
+ * Called with COPY cstate:
+ *    SAVED_FH: source filehandle
+ *    CURRENT_FH: destination filehandle
+ *
+ * Returns errno (not nfserrxxx)
+ */
+static struct nfs42_inter_ssc *
+nfsd4_setup_inter_ssc(struct svc_rqst *rqstp,
+			struct nfsd4_compound_state *cstate,
+			struct nfsd4_copy *copy, struct file **src,
+			struct file **dst)
+{
+	struct svc_fh *s_fh = NULL;
+	stateid_t *s_stid = &copy->cp_src_stateid;
+	struct nfs_fh fh;
+	nfs4_stateid stateid;
+	struct file *filp;
+	struct nfs42_inter_ssc *sclp;
+	__be32 status;
+
+	/* Verify the destination stateid and set dst struct file*/
+	status = nfs4_preprocess_stateid_op(rqstp, cstate, &cstate->current_fh,
+					&copy->cp_dst_stateid,
+					WR_STATE, dst, NULL);
+	if (status) {
+		sclp = ERR_PTR(be32_to_cpu(status));
+		goto out;
+	}
+
+	/* Inter copy source fh is always stale */
+	CLEAR_CSTATE_FLAG(cstate, IS_STALE_FH);
+
+	sclp = nfsd4_interssc_connect(&copy->cp_src, rqstp);
+	if (IS_ERR(sclp))
+		goto out;
+
+	s_fh = &cstate->save_fh;
+
+	fh.size = s_fh->fh_handle.fh_size;
+	memcpy(fh.data, &s_fh->fh_handle.fh_base, fh.size);
+	stateid.seqid = s_stid->si_generation;
+	memcpy(stateid.other, (void *)&s_stid->si_opaque,
+		sizeof(stateid_opaque_t));
+
+	filp =  nfs42_ssc_open(sclp, &fh, &stateid);
+	if (IS_ERR(filp)) {
+		nfsd4_interssc_disconnect(sclp);
+		return ERR_CAST(filp);
+	}
+	*src = filp;
+out:
+	return sclp;
+}
+
+static void
+nfsd4_cleanup_inter_ssc(struct nfs42_inter_ssc *sclp, struct file *src,
+			struct file *dst)
+{
+	/* "close" the src file. One dput for the READ */
+	dput(src->f_path.dentry);
+	src->f_op->release(src->f_inode, src);
+	fput(dst);
+
+	nfsd4_interssc_disconnect(sclp);
+
+}
+
+#else /* CONFIG_NFSD_V4_2_INTER_SSC */
+
+static struct nfs42_inter_ssc *
+nfsd4_setup_inter_ssc(struct svc_rqst *rqstp,
+			struct nfsd4_compound_state *cstate,
+			struct nfsd4_copy *copy, struct file **src,
+			struct file **dst)
+{
+	return ERR_PTR(-EINVAL);
+}
+
+static void
+nfsd4_cleanup_inter_ssc(struct nfs42_inter_ssc *sclp, struct file *src,
+			struct file *dst)
+{
+}
+
+#endif /* CONFIG_NFSD_V4_2_INTER_SSC */
+
 static __be32
-nfsd4_copy(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
-		struct nfsd4_copy *copy)
+nfsd4_setup_intra_ssc(struct svc_rqst *rqstp,
+		      struct nfsd4_compound_state *cstate,
+		      struct nfsd4_copy *copy, struct file **src,
+		      struct file **dst)
 {
-	struct file *src, *dst;
 	__be32 status;
-	ssize_t bytes;
 
-	status = nfsd4_verify_copy(rqstp, cstate, &copy->cp_src_stateid, &src,
-				   &copy->cp_dst_stateid, &dst);
+	status = nfsd4_verify_copy(rqstp, cstate, &copy->cp_src_stateid, src,
+				   &copy->cp_dst_stateid, dst);
 	if (status)
 		goto out;
 
@@ -1103,7 +1324,37 @@ nfsd4_copy(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 	if (HAS_CSTATE_FLAG(cstate, IS_STALE_FH)) {
 		CLEAR_CSTATE_FLAG(cstate, IS_STALE_FH);
 		cstate->status = nfserr_copy_stalefh;
-		goto out_put;
+	}
+out:
+	return status;
+}
+
+static void
+nfsd4_cleanup_intra_ssc(struct file *src, struct file *dst)
+{
+	fput(src);
+	fput(dst);
+}
+
+static __be32
+nfsd4_copy(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
+	struct nfsd4_copy *copy)
+{
+	struct nfs42_inter_ssc *sclp = NULL;
+	struct file *src, *dst;
+	__be32 status;
+	ssize_t bytes;
+
+	if (copy->cp_src.nl_nsvr > 0) { /* Inter server SSC */
+		sclp = nfsd4_setup_inter_ssc(rqstp, cstate, copy, &src, &dst);
+		if (IS_ERR(sclp)) {
+			status = nfserrno(PTR_ERR(sclp));
+			goto out;
+		}
+	} else {
+		status = nfsd4_setup_intra_ssc(rqstp, cstate, copy, &src, &dst);
+		if (status)
+			goto out;
 	}
 
 	bytes = nfsd_copy_file_range(src, copy->cp_src_pos,
@@ -1120,9 +1371,10 @@ nfsd4_copy(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 		status = nfs_ok;
 	}
 
-out_put:
-	fput(src);
-	fput(dst);
+	if (copy->cp_src.nl_nsvr > 0)   /* Inter server SSC */
+		nfsd4_cleanup_inter_ssc(sclp, src, dst);
+	else
+		nfsd4_cleanup_intra_ssc(src, dst);
 out:
 	return status;
 }
diff --git a/include/linux/nfs4.h b/include/linux/nfs4.h
index 3764885..4e61fae 100644
--- a/include/linux/nfs4.h
+++ b/include/linux/nfs4.h
@@ -15,6 +15,7 @@
 #include <linux/list.h>
 #include <linux/uidgid.h>
 #include <uapi/linux/nfs4.h>
+#include <linux/nfs.h>
 #include <linux/sunrpc/msg_prot.h>
 
 enum nfs4_acl_whotype {
@@ -693,4 +694,7 @@ struct nl4_servers {
 	struct nl4_server	*nl_svr;
 };
 
+extern struct file *nfs42_ssc_open(struct nfs42_inter_ssc *ssc,
+				struct nfs_fh *src_fh, nfs4_stateid *stateid);
+
 #endif
-- 
1.8.3.1

