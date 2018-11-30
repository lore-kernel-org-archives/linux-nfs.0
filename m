Return-Path: <SRS0=T1LL=OJ=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 296DCC04EB8
	for <linux-nfs@archiver.kernel.org>; Fri, 30 Nov 2018 20:04:12 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id D1F482082F
	for <linux-nfs@archiver.kernel.org>; Fri, 30 Nov 2018 20:04:11 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="WXhg7pVY"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D1F482082F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726781AbeLAHOe (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Sat, 1 Dec 2018 02:14:34 -0500
Received: from mail-ot1-f65.google.com ([209.85.210.65]:46412 "EHLO
        mail-ot1-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1725790AbeLAHOe (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sat, 1 Dec 2018 02:14:34 -0500
Received: by mail-ot1-f65.google.com with SMTP id w25so6191239otm.13;
        Fri, 30 Nov 2018 12:04:10 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references;
        bh=kxRBQRSAxzCTBzKVVhjEpQCdKjT3iYYyHuoGgGevBJ0=;
        b=WXhg7pVY2kvl0EM4tB0VbliP7tMdIzptNPPDDVQxz/NAKtdWzaQa/+vonRR2+k2X8A
         0EORZJbawKtd1QWV0GnR4CweOe1V3EoYTFGoYyRM/XZibjzCSrPSw768ryWGGAtvxzSh
         mEJoJHhLMUCmpZafiF8I8NDiM4KkkmXWIiRczW/gNAC+jKhonYwGFlWayVuF755kOReO
         lu9ZPBPzDmzh85dx1DPc0BHmRprVMp5uAe3mQbrxBDobNwcW+zzim3poc5xH+Nb0UceJ
         NBhvs1tQaAuJPV2Ec+QQEOiucmof4PmN6X8GCFJlNzOOvVkg5ebj5EhdHsS59Vdj1E89
         jXvg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:cc:subject:date:message-id:in-reply-to
         :references;
        bh=kxRBQRSAxzCTBzKVVhjEpQCdKjT3iYYyHuoGgGevBJ0=;
        b=YAEocuN5K+/LjL0DrmfFE+34l0MNLRw0uj+zoB3yO9FmOF8q/0ua18qL7IwftLpcAn
         NM1HpLgEe668pLL9zBKOEpNDRfHKqWN5UFucAfJ5M20j/Yc1WhVn69DrGOxKpf0Nj/yz
         hg6+0S1DG/nZsFiWBNmtD2CFA7wzFEaiJ8hE4hPcTrv9zntC5F/W1v/MWopdY/JQPGot
         Ld4kec3/ogx391vdmhHhNU4TqyESFImMFZyc5/LEPddMMj68C0Keit+TzUnvXS0JhthK
         ecojVHbM7ckarbqUiUDrgD2nijth+ZAT2fhR9RcR9gqUnV8IuGg0JhswPMrGlQEmDJ/v
         5a2A==
X-Gm-Message-State: AA+aEWbttutp3oXEAR3GtUSzF1rFR+Gv4MNFU00FSr4X4XpHyOsEx3dJ
        jZKQwgudSFE/C2vG+8O+ZiU=
X-Google-Smtp-Source: AFSGD/X+3bl5FzT9dVsAGOOlN3beaNHqil8K7PGJoeX2O7j22ZAoXOLvo1/L8c5Lb9u0moPaqyMuiw==
X-Received: by 2002:a9d:7f0d:: with SMTP id j13mr4078139otq.119.1543608249504;
        Fri, 30 Nov 2018 12:04:09 -0800 (PST)
Received: from Olgas-MBP-195.attlocal.net (172-10-226-31.lightspeed.livnmi.sbcglobal.net. [172.10.226.31])
        by smtp.gmail.com with ESMTPSA id q10sm2065289otl.15.2018.11.30.12.04.07
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 30 Nov 2018 12:04:08 -0800 (PST)
From:   Olga Kornievskaia <olga.kornievskaia@gmail.com>
To:     bfields@redhat.com
Cc:     linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org
Subject: [PATCH v2 10/10] NFSD add nfs4 inter ssc to nfsd4_copy
Date:   Fri, 30 Nov 2018 15:03:48 -0500
Message-Id: <20181130200348.59524-11-olga.kornievskaia@gmail.com>
X-Mailer: git-send-email 2.10.1 (Apple Git-78)
In-Reply-To: <20181130200348.59524-1-olga.kornievskaia@gmail.com>
References: <20181130200348.59524-1-olga.kornievskaia@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Given a universal address, mount the source server from the destination
server.  Use an internal mount. Call the NFS client nfs42_ssc_open to
obtain the NFS struct file suitable for nfsd_copy_range.

Ability to do "inter" server-to-server depends on the an nfsd kernel
parameter "inter_copy_offload_enabled".

Signed-off-by: Olga Kornievskaia <kolga@netapp.com>
Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfsd/nfs4proc.c   | 274 +++++++++++++++++++++++++++++++++++++++++++++++----
 fs/nfsd/nfssvc.c     |   6 ++
 fs/nfsd/xdr4.h       |   5 +
 include/linux/nfs4.h |   1 +
 4 files changed, 269 insertions(+), 17 deletions(-)

diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index 2e28254..238c4b7 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -1155,6 +1155,209 @@ void nfsd4_shutdown_copy(struct nfs4_client *clp)
 	while ((copy = nfsd4_get_copy(clp)) != NULL)
 		nfsd4_stop_copy(copy);
 }
+#ifdef CONFIG_NFSD_V4_2_INTER_SSC
+
+extern struct file *nfs42_ssc_open(struct vfsmount *ss_mnt,
+				   struct nfs_fh *src_fh,
+				   nfs4_stateid *stateid);
+extern void nfs42_ssc_close(struct file *filep);
+
+extern void nfs_sb_deactive(struct super_block *sb);
+
+#define NFSD42_INTERSSC_MOUNTOPS "minorversion=2,vers=4,addr=%s"
+
+/**
+ * Support one copy source server for now.
+ */
+static __be32
+nfsd4_interssc_connect(struct nl4_server *nss, struct svc_rqst *rqstp,
+		       struct vfsmount **mount)
+{
+	struct file_system_type *type;
+	struct vfsmount *ss_mnt;
+	struct nfs42_netaddr *naddr;
+	struct sockaddr_storage tmp_addr;
+	size_t tmp_addrlen, match_netid_len = 3;
+	char *startsep = "", *endsep = "", *match_netid = "tcp";
+	char *ipaddr, *dev_name, *raw_data;
+	int len, raw_len, status = -EINVAL;
+
+	naddr = &nss->u.nl4_addr;
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
+
+	raw_len = strlen(NFSD42_INTERSSC_MOUNTOPS) + strlen(ipaddr);
+	raw_data = kzalloc(raw_len, GFP_KERNEL);
+	if (!raw_data)
+		goto out_free_ipaddr;
+
+	snprintf(raw_data, raw_len, NFSD42_INTERSSC_MOUNTOPS, ipaddr);
+
+	status = -ENODEV;
+	type = get_fs_type("nfs");
+	if (!type)
+		goto out_free_rawdata;
+
+	/* Set the server:<export> for the vfs_kern_mount call */
+	dev_name = kzalloc(len + 5, GFP_KERNEL);
+	if (!dev_name)
+		goto out_free_rawdata;
+	snprintf(dev_name, len + 5, "%s%s%s:/", startsep, ipaddr, endsep);
+
+	/* Use an 'internal' mount: MS_KERNMOUNT -> MNT_INTERNAL */
+	ss_mnt = vfs_kern_mount(type, MS_KERNMOUNT, dev_name, raw_data);
+	module_put(type->owner);
+	if (IS_ERR(ss_mnt))
+		goto out_free_devname;
+
+	status = 0;
+	*mount = ss_mnt;
+
+out_free_devname:
+	kfree(dev_name);
+out_free_rawdata:
+	kfree(raw_data);
+out_free_ipaddr:
+	kfree(ipaddr);
+out_err:
+	return status;
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
+static __be32
+nfsd4_setup_inter_ssc(struct svc_rqst *rqstp,
+		      struct nfsd4_compound_state *cstate,
+		      struct nfsd4_copy *copy, struct vfsmount **mount)
+{
+	struct svc_fh *s_fh = NULL;
+	stateid_t *s_stid = &copy->cp_src_stateid;
+	__be32 status = -EINVAL;
+
+	/* Verify the destination stateid and set dst struct file*/
+	status = nfs4_preprocess_stateid_op(rqstp, cstate, &cstate->current_fh,
+					    &copy->cp_dst_stateid,
+					    WR_STATE, &copy->file_dst, NULL,
+					    NULL);
+	if (status)
+		goto out;
+
+	status = nfsd4_interssc_connect(&copy->cp_src, rqstp, mount);
+	if (status)
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
+	status = 0;
+out:
+	return status;
+}
+
+static void
+nfsd4_cleanup_inter_ssc(struct vfsmount *ss_mnt, struct file *src,
+			struct file *dst)
+{
+	nfs42_ssc_close(src);
+	fput(src);
+	fput(dst);
+	mntput(ss_mnt);
+}
+
+#else /* CONFIG_NFSD_V4_2_INTER_SSC */
+
+static __be32
+nfsd4_setup_inter_ssc(struct svc_rqst *rqstp,
+		      struct nfsd4_compound_state *cstate,
+		      struct nfsd4_copy *copy,
+		      struct vfs_mount **mount)
+{
+	*mount = NULL;
+	return -EINVAL;
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
+				   struct nfs_fh *src_fh,
+				   nfs4_stateid *stateid)
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
+				 &copy->file_src, &copy->cp_dst_stateid,
+				 &copy->file_dst, NULL);
+}
+
+static void
+nfsd4_cleanup_intra_ssc(struct file *src, struct file *dst)
+{
+	fput(src);
+	fput(dst);
+}
 
 static void nfsd4_cb_offload_release(struct nfsd4_callback *cb)
 {
@@ -1219,12 +1422,16 @@ static __be32 nfsd4_do_copy(struct nfsd4_copy *copy, bool sync)
 		status = nfs_ok;
 	}
 
-	fput(copy->file_src);
-	fput(copy->file_dst);
+	if (!copy->cp_intra) /* Inter server SSC */
+		nfsd4_cleanup_inter_ssc(copy->ss_mnt, copy->file_src,
+					copy->file_dst);
+	else
+		nfsd4_cleanup_intra_ssc(copy->file_src, copy->file_dst);
+
 	return status;
 }
 
-static void dup_copy_fields(struct nfsd4_copy *src, struct nfsd4_copy *dst)
+static int dup_copy_fields(struct nfsd4_copy *src, struct nfsd4_copy *dst)
 {
 	dst->cp_src_pos = src->cp_src_pos;
 	dst->cp_dst_pos = src->cp_dst_pos;
@@ -1234,8 +1441,17 @@ static void dup_copy_fields(struct nfsd4_copy *src, struct nfsd4_copy *dst)
 	memcpy(&dst->fh, &src->fh, sizeof(src->fh));
 	dst->cp_clp = src->cp_clp;
 	dst->file_dst = get_file(src->file_dst);
-	dst->file_src = get_file(src->file_src);
+	dst->cp_intra = src->cp_intra;
+	if (src->cp_intra) /* for inter, file_src doesn't exist yet */
+		dst->file_src = get_file(src->file_src);
 	memcpy(&dst->cp_stateid, &src->cp_stateid, sizeof(src->cp_stateid));
+	memcpy(&dst->cp_src, &src->cp_src, sizeof(struct nl4_server));
+	memcpy(&dst->stateid, &src->stateid, sizeof(src->stateid));
+	memcpy(&dst->c_fh, &src->c_fh, sizeof(src->c_fh));
+	dst->ss_mnt = src->ss_mnt;
+
+	return 0;
+
 }
 
 static void cleanup_async_copy(struct nfsd4_copy *copy)
@@ -1254,7 +1470,18 @@ static int nfsd4_do_async_copy(void *data)
 	struct nfsd4_copy *copy = (struct nfsd4_copy *)data;
 	struct nfsd4_copy *cb_copy;
 
+	if (!copy->cp_intra) { /* Inter server SSC */
+		copy->file_src = nfs42_ssc_open(copy->ss_mnt, &copy->c_fh,
+					      &copy->stateid);
+		if (IS_ERR(copy->file_src)) {
+			copy->nfserr = nfserr_offload_denied;
+			nfsd4_interssc_disconnect(copy->ss_mnt);
+			goto do_callback;
+		}
+	}
+
 	copy->nfserr = nfsd4_do_copy(copy, 0);
+do_callback:
 	cb_copy = kzalloc(sizeof(struct nfsd4_copy), GFP_KERNEL);
 	if (!cb_copy)
 		goto out;
@@ -1278,11 +1505,20 @@ static int nfsd4_do_async_copy(void *data)
 	__be32 status;
 	struct nfsd4_copy *async_copy = NULL;
 
-	status = nfsd4_verify_copy(rqstp, cstate, &copy->cp_src_stateid,
-				   &copy->file_src, &copy->cp_dst_stateid,
-				   &copy->file_dst, NULL);
-	if (status)
-		goto out;
+	if (!copy->cp_intra) { /* Inter server SSC */
+		if (!inter_copy_offload_enable || copy->cp_synchronous) {
+			status = nfserr_notsupp;
+			goto out;
+		}
+		status = nfsd4_setup_inter_ssc(rqstp, cstate, copy,
+					&copy->ss_mnt);
+		if (status)
+			return nfserr_offload_denied;
+	} else {
+		status = nfsd4_setup_intra_ssc(rqstp, cstate, copy);
+		if (status)
+			return status;
+	}
 
 	copy->cp_clp = cstate->clp;
 	memcpy(&copy->fh, &cstate->current_fh.fh_handle,
@@ -1293,15 +1529,15 @@ static int nfsd4_do_async_copy(void *data)
 		status = nfserrno(-ENOMEM);
 		async_copy = kzalloc(sizeof(struct nfsd4_copy), GFP_KERNEL);
 		if (!async_copy)
-			goto out;
-		if (!nfs4_init_copy_state(nn, copy)) {
-			kfree(async_copy);
-			goto out;
-		}
+			goto out_err;
+		if (!nfs4_init_copy_state(nn, copy))
+			goto out_err;
 		refcount_set(&async_copy->refcount, 1);
 		memcpy(&copy->cp_res.cb_stateid, &copy->cp_stateid,
 			sizeof(copy->cp_stateid));
-		dup_copy_fields(copy, async_copy);
+		status = dup_copy_fields(copy, async_copy);
+		if (status)
+			goto out_err;
 		async_copy->copy_task = kthread_create(nfsd4_do_async_copy,
 				async_copy, "%s", "copy thread");
 		if (IS_ERR(async_copy->copy_task))
@@ -1312,13 +1548,17 @@ static int nfsd4_do_async_copy(void *data)
 		spin_unlock(&async_copy->cp_clp->async_lock);
 		wake_up_process(async_copy->copy_task);
 		status = nfs_ok;
-	} else
+	} else {
 		status = nfsd4_do_copy(copy, 1);
+	}
 out:
 	return status;
 out_err:
 	cleanup_async_copy(async_copy);
-	goto out;
+	status = nfserrno(-ENOMEM);
+	if (!copy->cp_intra)
+		nfsd4_interssc_disconnect(copy->ss_mnt);
+	goto out_err;
 }
 
 struct nfsd4_copy *
diff --git a/fs/nfsd/nfssvc.c b/fs/nfsd/nfssvc.c
index 89cb484..9d254e7 100644
--- a/fs/nfsd/nfssvc.c
+++ b/fs/nfsd/nfssvc.c
@@ -30,6 +30,12 @@
 
 #define NFSDDBG_FACILITY	NFSDDBG_SVC
 
+bool inter_copy_offload_enable;
+EXPORT_SYMBOL_GPL(inter_copy_offload_enable);
+module_param(inter_copy_offload_enable, bool, 0644);
+MODULE_PARM_DESC(inter_copy_offload_enable,
+		 "Enable inter server to server copy offload. Default: false");
+
 extern struct svc_program	nfsd_program;
 static int			nfsd(void *vrqstp);
 
diff --git a/fs/nfsd/xdr4.h b/fs/nfsd/xdr4.h
index fbd18d6..bb2f8e5 100644
--- a/fs/nfsd/xdr4.h
+++ b/fs/nfsd/xdr4.h
@@ -547,7 +547,12 @@ struct nfsd4_copy {
 	struct task_struct	*copy_task;
 	refcount_t		refcount;
 	bool			stopped;
+
+	struct vfsmount		*ss_mnt;
+	struct nfs_fh		c_fh;
+	nfs4_stateid		stateid;
 };
+extern bool inter_copy_offload_enable;
 
 struct nfsd4_seek {
 	/* request */
diff --git a/include/linux/nfs4.h b/include/linux/nfs4.h
index 9e49a6c..fa4b411 100644
--- a/include/linux/nfs4.h
+++ b/include/linux/nfs4.h
@@ -17,6 +17,7 @@
 #include <linux/uidgid.h>
 #include <uapi/linux/nfs4.h>
 #include <linux/sunrpc/msg_prot.h>
+#include <linux/nfs.h>
 
 enum nfs4_acl_whotype {
 	NFS4_ACL_WHO_NAMED = 0,
-- 
1.8.3.1

