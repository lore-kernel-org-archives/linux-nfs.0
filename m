Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx141.netapp.com ([216.240.21.12]:1216 "EHLO mx141.netapp.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752433AbdI1RaK (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 28 Sep 2017 13:30:10 -0400
From: Olga Kornievskaia <kolga@netapp.com>
To: <bfields@redhat.com>
CC: <linux-nfs@vger.kernel.org>
Subject: [PATCH v4 8/8] NFSD add nfs4 inter ssc to nfsd4_copy
Date: Thu, 28 Sep 2017 13:30:02 -0400
Message-ID: <20170928173002.50818-9-kolga@netapp.com>
In-Reply-To: <20170928173002.50818-1-kolga@netapp.com>
References: <20170928173002.50818-1-kolga@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Given a universal address, mount the source server from the destination
server.  Use an internal mount. Call the NFS client nfs42_ssc_open to
obtain the NFS struct file suitable for nfsd_copy_range.

Signed-off-by: Andy Adamson <andros@netapp.com>
Signed-off-by: Olga Kornievskaia <kolga@netapp.com>
---
 fs/nfsd/nfs4proc.c   | 297 +++++++++++++++++++++++++++++++++++++++++++++++----
 fs/nfsd/xdr4.h       |   4 +
 include/linux/nfs4.h |   1 +
 3 files changed, 283 insertions(+), 19 deletions(-)

diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index 18d1de4..8389639 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -1110,6 +1110,230 @@ static int fill_in_write_vector(struct kvec *vec, struct nfsd4_write *write)
 out:
 	return status;
 }
+
+#ifdef CONFIG_NFSD_V4_2_INTER_SSC
+
+extern struct file *nfs42_ssc_open(struct vfsmount *ss_mnt,
+				   struct nfs_fh *src_fh,
+				   nfs4_stateid *stateid);
+extern void nfs42_ssc_close(struct file *filep);
+
+extern void nfs_sb_deactive(struct super_block *sb);
+
+#define NFSD42_INTERSSC_MOUNTOPS "minorversion=2,vers=4,addr=%s,clientaddr=%s"
+
+/**
+ * Support one copy source server for now.
+ */
+static struct vfsmount *
+nfsd4_interssc_connect(struct nl4_server *nss, struct svc_rqst *rqstp)
+{
+	struct file_system_type *type;
+	struct vfsmount *ss_mnt;
+	struct nfs42_netaddr *naddr;
+	struct sockaddr_storage tmp_addr;
+	size_t tmp_addrlen, match_netid_len = 3;
+	char *startsep = "", *endsep = "", *match_netid = "tcp";
+	char *ipaddr, *ipaddr2, *raw_data;
+	int len, raw_len, status = -EINVAL;
+
+	/* Currently support only NL4_NETADDR source server */
+	if (nss->nl4_type != NL4_NETADDR) {
+		WARN(nss->nl4_type != NL4_NETADDR,
+			"nfsd4_copy src server not NL4_NETADDR\n");
+		goto out_err;
+	}
+
+	naddr = &nss->u.nl4_addr;
+
+	tmp_addrlen = rpc_uaddr2sockaddr(SVC_NET(rqstp), naddr->addr,
+					 naddr->addr_len,
+					 (struct sockaddr *)&tmp_addr,
+					 sizeof(tmp_addr));
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
+	if (naddr->netid_len != match_netid_len ||
+		strncmp(naddr->netid, match_netid, naddr->netid_len))
+		goto out_err;
+
+	/* Construct the raw data for the vfs_kern_mount call */
+	len = RPC_MAX_ADDRBUFLEN + 1;
+	ipaddr = kzalloc(len, GFP_KERNEL);
+	if (!ipaddr)
+		goto out_err;
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
+	raw_len = strlen(NFSD42_INTERSSC_MOUNTOPS) + strlen(ipaddr) +
+			strlen(ipaddr2);
+	raw_data = kzalloc(raw_len, GFP_KERNEL);
+	if (!raw_data)
+		goto out_free_ipaddr2;
+
+	snprintf(raw_data, raw_len, NFSD42_INTERSSC_MOUNTOPS, ipaddr,
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
+	ss_mnt = vfs_kern_mount(type, MS_KERNMOUNT, ipaddr2, raw_data);
+	if (IS_ERR(ss_mnt)) {
+		status = PTR_ERR(ss_mnt);
+		goto out_free_rawdata;
+	}
+
+	kfree(raw_data);
+	kfree(ipaddr2);
+	kfree(ipaddr);
+
+	return ss_mnt;
+
+out_free_rawdata:
+	kfree(raw_data);
+out_free_ipaddr2:
+	kfree(ipaddr2);
+out_free_ipaddr:
+	kfree(ipaddr);
+out_err:
+	dprintk("--> %s ERROR %d\n", __func__, status);
+	return ERR_PTR(status);
+}
+
+static void
+nfsd4_interssc_disconnect(struct vfsmount *ss_mnt)
+{
+	nfs_sb_deactive(ss_mnt->mnt_sb);
+	mntput(ss_mnt);
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
+static struct vfsmount *
+nfsd4_setup_inter_ssc(struct svc_rqst *rqstp,
+		      struct nfsd4_compound_state *cstate,
+		      struct nfsd4_copy *copy)
+{
+	struct svc_fh *s_fh = NULL;
+	stateid_t *s_stid = &copy->cp_src_stateid;
+	struct vfsmount *ss_mnt;
+	__be32 status;
+
+	/* Verify the destination stateid and set dst struct file*/
+	status = nfs4_preprocess_stateid_op(rqstp, cstate, &cstate->current_fh,
+					    &copy->cp_dst_stateid,
+					    WR_STATE, &copy->fh_dst, NULL,
+					    &copy->stid);
+	if (status) {
+		ss_mnt = ERR_PTR(be32_to_cpu(status));
+		goto out;
+	}
+
+	ss_mnt = nfsd4_interssc_connect(copy->cp_src, rqstp);
+	if (IS_ERR(ss_mnt))
+		goto out;
+
+	s_fh = &cstate->save_fh;
+
+	copy->c_fh.size = s_fh->fh_handle.fh_size;
+	memcpy(copy->c_fh.data, &s_fh->fh_handle.fh_base, copy->c_fh.size);
+	copy->stateid.seqid = s_stid->si_generation;
+	memcpy(copy->stateid.other, (void *)&s_stid->si_opaque,
+	       sizeof(stateid_opaque_t));
+
+out:
+	return ss_mnt;
+}
+
+static void
+nfsd4_cleanup_inter_ssc(struct vfsmount *ss_mnt, struct file *src,
+			struct file *dst)
+{
+	nfs42_ssc_close(src);
+	fput(src);
+	fput(dst);
+}
+
+#else /* CONFIG_NFSD_V4_2_INTER_SSC */
+
+static struct vfsmount *
+nfsd4_setup_inter_ssc(struct svc_rqst *rqstp,
+		      struct nfsd4_compound_state *cstate,
+		      struct nfsd4_copy *copy)
+{
+	return ERR_PTR(-EINVAL);
+}
+
+static void
+nfsd4_cleanup_inter_ssc(struct vfsmount *ss_mnt, struct file *src,
+			struct file *dst)
+{
+}
+
+static void
+nfsd4_interssc_disconnect(struct vfsmount *ss_mnt)
+{
+}
+
+static struct file *nfs42_ssc_open(struct vfsmount *ss_mnt,
+			    struct nfs_fh *src_fh,
+			    nfs4_stateid *stateid)
+{
+	return NULL;
+}
+#endif /* CONFIG_NFSD_V4_2_INTER_SSC */
+
+static __be32
+nfsd4_setup_intra_ssc(struct svc_rqst *rqstp,
+		      struct nfsd4_compound_state *cstate,
+		      struct nfsd4_copy *copy)
+{
+	return nfsd4_verify_copy(rqstp, cstate, &copy->cp_src_stateid,
+				 &copy->fh_src, &copy->cp_dst_stateid,
+				 &copy->fh_dst, &copy->stid);
+}
+
+static void
+nfsd4_cleanup_intra_ssc(struct file *src, struct file *dst)
+{
+	fput(src);
+	fput(dst);
+}
+
 static void nfsd4_cb_offload_release(struct nfsd4_callback *cb)
 {
 	struct nfsd4_copy *copy = container_of(cb, struct nfsd4_copy, cp_cb);
@@ -1179,12 +1403,16 @@ static int nfsd4_do_copy(struct nfsd4_copy *copy, bool sync)
 	else
 		status = nfsd4_init_copy_res(copy, sync);
 
-	fput(copy->fh_src);
-	fput(copy->fh_dst);
+	if (copy->cp_src)   /* Inter server SSC */
+		nfsd4_cleanup_inter_ssc(copy->ss_mnt, copy->fh_src,
+				copy->fh_dst);
+	else
+		nfsd4_cleanup_intra_ssc(copy->fh_src, copy->fh_dst);
+
 	return status;
 }
 
-static void dup_copy_fields(struct nfsd4_copy *src, struct nfsd4_copy *dst)
+static int dup_copy_fields(struct nfsd4_copy *src, struct nfsd4_copy *dst)
 {
 	memcpy(&dst->cp_src_stateid, &src->cp_src_stateid, sizeof(stateid_t));
 	memcpy(&dst->cp_dst_stateid, &src->cp_dst_stateid, sizeof(stateid_t));
@@ -1203,6 +1431,17 @@ static void dup_copy_fields(struct nfsd4_copy *src, struct nfsd4_copy *dst)
 	dst->net = src->net;
 	dst->stid = src->stid;
 	dst->cps = src->cps;
+	if (src->cp_src) {
+		dst->cp_src = kmalloc(sizeof(struct nl4_server), GFP_KERNEL);
+		if (!dst->cp_src)
+			return -ENOMEM;
+		memcpy(dst->cp_src, src->cp_src, sizeof(struct nl4_server));
+	}
+	memcpy(&dst->stateid, &src->stateid, sizeof(src->stateid));
+	memcpy(&dst->c_fh, &src->c_fh, sizeof(src->c_fh));
+	dst->ss_mnt = src->ss_mnt;
+
+	return 0;
 }
 
 static void nfsd4_do_async_copy(struct work_struct *work)
@@ -1214,11 +1453,22 @@ static void nfsd4_do_async_copy(struct work_struct *work)
 	if (test_bit(NFSD4_CLIENT_COPY_KILL, &copy->cp_clp->cl_flags))
 		goto out;
 
+	if (copy->cp_src) { /* Inter server SSC */
+		copy->fh_src = nfs42_ssc_open(copy->ss_mnt, &copy->c_fh,
+						&copy->stateid);
+		if (IS_ERR(copy->fh_src)) {
+			copy->nfserr = nfserr_offload_denied;
+			nfsd4_interssc_disconnect(copy->ss_mnt);
+			goto do_callback;
+		}
+	}
+
 	copy->nfserr = nfsd4_do_copy(copy, 0);
 
 	if (copy->cps->cp_cancelled)
 		goto out;
 
+do_callback:
 	cb_copy = kzalloc(sizeof(struct nfsd4_copy), GFP_KERNEL);
 	if (!cb_copy)
 		goto out;
@@ -1233,6 +1483,7 @@ static void nfsd4_do_async_copy(struct work_struct *work)
 	list_del(&copy->cps->cp_list);
 	nfs4_free_cp_state(copy->cps);
 	nfs4_put_stid(copy->stid);
+	kfree(copy->cp_src);
 	kfree(copy);
 }
 
@@ -1242,12 +1493,19 @@ static void nfsd4_do_async_copy(struct work_struct *work)
 {
 	struct nfsd4_copy *copy = &u->copy;
 	__be32 status;
+	struct nfsd4_copy *async_copy;
 
-	status = nfsd4_verify_copy(rqstp, cstate, &copy->cp_src_stateid,
-				   &copy->fh_src, &copy->cp_dst_stateid,
-				   &copy->fh_dst, &copy->stid);
-	if (status)
-		goto out;
+	if (copy->cp_src) { /* Inter server SSC */
+		copy->ss_mnt = nfsd4_setup_inter_ssc(rqstp, cstate, copy);
+		if (IS_ERR(copy->ss_mnt)) {
+			status = nfserr_offload_denied;
+			goto out;
+		}
+	} else {
+		status = nfsd4_setup_intra_ssc(rqstp, cstate, copy);
+		if (status)
+			goto out;
+	}
 
 	copy->cp_clp = cstate->clp;
 	memcpy(&copy->fh, &cstate->current_fh.fh_handle,
@@ -1255,28 +1513,24 @@ static void nfsd4_do_async_copy(struct work_struct *work)
 	copy->net = SVC_NET(rqstp);
 	if (!copy->cp_synchronous) {
 		struct nfsd_net *nn = net_generic(SVC_NET(rqstp), nfsd_net_id);
-		struct nfsd4_copy *async_copy;
 
 		status = nfsd4_init_copy_res(copy, 0);
 		async_copy = kzalloc(sizeof(struct nfsd4_copy), GFP_KERNEL);
-		if (!async_copy) {
-			status = nfserrno(-ENOMEM);
-			goto out;
-		}
+		if (!async_copy)
+			goto out_err;
 		copy->cps = nfs4_alloc_init_cp_state(nn, nn->nfsd4_lease,
 							copy->stid);
-		if (!copy->cps) {
-			status = nfserrno(-ENOMEM);
-			kfree(async_copy);
-			goto out;
-		}
+		if (!copy->cps)
+			goto out_err;
 		/* take a reference on the parent stateid so it's not
 		 * not freed by the copy compound
 		 */
 		atomic_inc(&copy->stid->sc_count);
 		memcpy(&copy->cp_res.cb_stateid, &copy->cps->cp_stateid,
 			sizeof(copy->cps->cp_stateid));
-		dup_copy_fields(copy, async_copy);
+		status = dup_copy_fields(copy, async_copy);
+		if (status)
+			goto out_err;
 		INIT_WORK(&async_copy->cp_work, nfsd4_do_async_copy);
 		queue_work(copy_wq, &async_copy->cp_work);
 	} else {
@@ -1284,6 +1538,11 @@ static void nfsd4_do_async_copy(struct work_struct *work)
 	}
 out:
 	return status;
+out_err:
+	kfree(async_copy);
+	status = nfserrno(-ENOMEM);
+	nfsd4_interssc_disconnect(copy->ss_mnt);
+	goto out;
 }
 
 static __be32
diff --git a/fs/nfsd/xdr4.h b/fs/nfsd/xdr4.h
index 82d714b..e00ed6b 100644
--- a/fs/nfsd/xdr4.h
+++ b/fs/nfsd/xdr4.h
@@ -540,6 +540,10 @@ struct nfsd4_copy {
 	struct net              *net;
 	struct nfs4_stid        *stid;
 	struct nfs4_cp_state	*cps;
+
+	struct vfsmount		*ss_mnt;
+	struct nfs_fh		c_fh;
+	nfs4_stateid		stateid;
 };
 
 struct nfsd4_seek {
diff --git a/include/linux/nfs4.h b/include/linux/nfs4.h
index aff3121..627bf9f 100644
--- a/include/linux/nfs4.h
+++ b/include/linux/nfs4.h
@@ -16,6 +16,7 @@
 #include <linux/uidgid.h>
 #include <uapi/linux/nfs4.h>
 #include <linux/sunrpc/msg_prot.h>
+#include <linux/nfs.h>
 
 enum nfs4_acl_whotype {
 	NFS4_ACL_WHO_NAMED = 0,
-- 
1.8.3.1

