Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=209.85.161.47
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1795191007;
	b=SCebXDVg06AHHu4PwlFnXt9XG1HM+liEFmghdPoc6K1v/YvlyPv5PUU5svmFRW7RMKvn
	 Gb3zg8lx71egm/CDrvk4XAfd/LNAsL0uCyhsQL6CCMncahRfram9WgXIPbYtnKwML8urB
	 9pMGS/2qoisqdH282IOY4pcL6iTHBpLdJ5WH2aHrvWXaY03J9w00n2fgsGPtpnS3mrUrK
	 OTXIR7SgpmIMR0zW/PioxoEQiR4aV3MPxlXNxn+vrloVKWl5RCeBg4gxR+TdKaxpKdctX
	 PJY140nVGmDWheU+MXX+FayWibvB9hmfokNKUg15k2qzqLseC2JiJzI0Wf6vSxE8ZjA==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1795191007;
	h=DMARC-Filter:Received:DKIM-Signature:X-Google-DKIM-Signature:
	 X-Gm-Message-State:X-Gm-Gg:X-Received:Received:From:To:Cc:Subject:
	 Date:Message-ID:X-Mailer:In-Reply-To:References:MIME-Version:
	 Content-Transfer-Encoding;
	bh=QXnbgWHXml08PAhuEl2bRAQtbD+e9+rekNQevuu3mQQ=;
	b=2i7GkN7zS2/HyPfoTss8tpMQgHHZsZ4VBzXZXOTDywoqLwcVn6UVt6kH45u0MA/vGo5p
	 oA4CLktJvjbRnFnoDjac0SXH7+SLLTbP5ddFVwF9icK+HcC7qOpYx35LDTKAiknbiVSO+
	 tPKyz4EZnrZa8p35vdaPiKfWWeBgpKFhZyYX8lhiCOH2bGzYWyJHZWVMxZQJi6JCTNAt5
	 FapfQz0DLVV1PYZX6cY77eKgVAKJmcZ1N5ct9YdynXHCZKyDk/KTDj3weh8+CL4l6g1ju
	 tlWWoxdui2L9X4Ooytg0nKLxCtMkhERBgQzQTZBK9jmQlOnvUklWWJDgvR15Q8OLbKA==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=hammerspace.com;
	spf=pass smtp.mailfrom=hammerspace.com;
	dkim=pass header.d=hammerspace.com header.i=@hammerspace.com header.a=rsa-sha256 header.s=google header.b=U1tBvZTD;
	arc=none smtp.remote-ip=209.85.161.47
Received: from mail-oo1-f47.google.com (mail-oo1-f47.google.com [209.85.161.47])
	(using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128/128 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id F14E560A260C
	for <linux-nfs@vger.kernel.org>; Fri, 20 Nov 2026 16:10:06 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org F14E560A260C
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.a=rsa-sha256 header.s=google header.b=U1tBvZTD
Received: by mail-oo1-f47.google.com with SMTP id 006d021491bc7-702fd86d674so743407eaf.2
        for <linux-nfs@vger.kernel.org>; Fri, 20 Nov 2026 08:10:06 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=hammerspace.com; s=google; t=1795191006; x=1795795806; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=QXnbgWHXml08PAhuEl2bRAQtbD+e9+rekNQevuu3mQQ=;
        b=U1tBvZTDeukkY3R57tnE0XIcgNjySgUI6JLWPjXXeIDT93CWl7IMib18ByxvffWJt9
         Abu9X8fIb0hQhLmJtEIuV4SsuXhYskuY6IoOV2Dw9eksqAa3acUlBEgfnLyi+FO9OEdS
         bXSdDwKx2KQSQEEhyjuWlyiuJshqD3ISnHqx+F3oPXpwUnizKRAHHAFDTXIlBhL3Ml1j
         HpjP+RszYy29PIB9roprjTAMseWXAjbE1wQDtk3YgPLfDjTTzK2wb47E7GVnnp8poKjk
         ydYTNo0mDAVq//7TW7K2nb0hOUlhuQ4e16yVAo5a7O2BHGXjZwcvLb1sFnefz1imJNsJ
         Sk0Q==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1795191006; x=1795795806;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:x-gm-gg:x-gm-message-state:from
         :to:cc:subject:date:message-id:reply-to:content-type;
        bh=QXnbgWHXml08PAhuEl2bRAQtbD+e9+rekNQevuu3mQQ=;
        b=SPpPjC45X9jZRbecZhpLuWdG76ny+MM4T3UmmMG+e8R66hH74EQKw7QLLs5nBaC92A
         caRv6OdDmn64EiofzvJl/PksTH1evxqknv3JZI6SNUi3I6TgTmn97VKruqi+OanOdNJF
         EOvgLAGOJtuaennWiV/OchosmCXEKAwZKGH9sRLsSvX52txXJ/gn3mfhSAyhONZAdxk5
         9tVbnLtPzcHI8K97mifnlAwuS/i43TAMu5Lq4gEMtFBOqu/oEpVfawclmNmQlSKKPOZp
         10epvGcHGDpmJ5ZLRb9SEpYtXSQNM63wao7627lumroJP9DFf+noA1cKSYKLwhfolf2i
         hNVg==
X-Gm-Message-State: APuU4Z96bwbb2YhMS445SoYmuVW5O7EYqYjeuzJRQqSlLiZfu+KK8j2I
	9dm7X2ij4cpVrNwyMzTtZ80jJode8jGafpG6Um8ex0SHETm9+UHlgF/1V4NPjob9ouI=
X-Gm-Gg: AYBFou39B+Yp8BfwLY4mvR5wzu01ZBTolFN1kEia7i64Y59g3D/HSqYu/Jitw6sCjjx
	CKT5sQYSiLUAHmjgBK/FhP8NDw/p54SJetPN8oQdKhU4pFmhYVTAe+9Dfm4Mprkp9GApWT7Ot2o
	NY+Eu+3CkE/v0yFQZD64Dnc0U1aBAjWmU7yTociJ5wCYI7JmP+HO2/Ho+b7qvsj6Jo+VaKRdJgf
	5ycecQDPrgx6p+yQJipOWycdDbhrlv+5aanGFhPGArL1gyC/KH272Oufl0Nz/RPG3ZHhhUwzlGc
	RcRRDRXhkKSsrhEiSMligEs+Nm4V9biSoyzG3BsENEBX88gcqTqoQC0rw6Q0he2aXaOmBXp/x/j
	HOz65msX4q0lk6wF2DYtu+TCZp6dkwZ/KKrl2X/hkOyUmKgB1tf8+UcAJc8zIpFfimP4INyK5kr
	ZGSwSNMOqVcUcVcVg2/6TyvRvkUnKo/MtlAHj2fnNkeiiaWVbPl2AumpEVTjxfK+Zkg9BbWY0Ih
	IdWku0gMoAFEyPhWidZ3+qYnhfAsyYFRfScX7GfUaFZviC1CtZiNK7wGP5LwZL7zVH/KGwav7sA
	As03uUBDaxmC6UxyVvsOwhT9S7SyzFLhgMtS5JvF1t+ekABbWtsZK/5NJDoTnWi5E6/pNjkL1s8
	EPuoiUCLYVM34zWhj//HJjmpTNBYeCdf4qC2ugRh5RFwvKmXiBa58
X-Received: by 2002:a05:6820:c452:10b0:6c4:6699:53b7 with SMTP id 006d021491bc7-71b395c16e8mr2060761eaf.52.1795191005603;
        Fri, 20 Nov 2026 08:10:05 -0800 (PST)
Received: from bcodding.csb.hammerspace.com (196.sub-174-201-28.myvzw.com. [174.201.28.196])
        by smtp.gmail.com with ESMTPSA id 006d021491bc7-71b37ea8472sm2147928eaf.2.2026.11.20.08.10.03
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Fri, 20 Nov 2026 08:10:05 -0800 (PST)
From: Benjamin Coddington <ben.coddington@hammerspace.com>
To: Trond Myklebust <trondmy@kernel.org>,
	Anna Schumaker <anna@kernel.org>,
	Mike Snitzer <snitzer@kernel.org>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v3 5/5] pNFS/flexfiles: use the MDS when the server has no layout to give
Date: Fri, 20 Nov 2026 11:09:56 -0500
Message-ID: <3891ffca2280546efc479acc6ffccce7cb3eb1a0.1795122900.git.bcodding@hammerspace.com>
X-Mailer: git-send-email 2.53.0
In-Reply-To: <cover.1795122899.git.bcodding@hammerspace.com>
References: <cover.1795122899.git.bcodding@hammerspace.com>
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

From: Benjamin Coddington <bcodding@hammerspace.com>

When LAYOUTGET fails with NFS4ERR_LAYOUTUNAVAILABLE, or with
NFS4ERR_TOOSMALL after the retry at the session's maximum reply size,
pnfs_update_layout() sets the layout's fail bit for that iomode and
returns no layout without sending another LAYOUTGET for the next 120
seconds.  If the file's layouts carried FF_FLAGS_NO_IO_THRU_MDS, reads
and writes wait for a layout the whole time, and then send a LAYOUTGET
that can fail the same way.  On a hard mount that repeats for as long
as the server keeps answering that way.

RFC 8435 says that after NFS4ERR_LAYOUTUNAVAILABLE "the I/O is to go to
the metadata server" (section 5.1.1), and that FF_FLAGS_NO_IO_THRU_MDS
is a hint (section 5.1.2).  Send the I/O through the MDS while the fail
bit is set, in ff_layout_inode_no_fallback_to_mds(), which reads,
writes and the resend after a data server error share.  This also lets
a server deal with a data server the client can't use: the client
reports the failure with LAYOUTERROR (or in LAYOUTRETURN) and returns
the layout, and the server can answer the next LAYOUTGET with
NFS4ERR_LAYOUTUNAVAILABLE.

Fixes: 2f007ba074ad ("pNFS/flexfiles: don't read through MDS when previous layout forbid it")
Fixes: 1d62e659c0bf ("NFSv4/flexfiles: honor FF_FLAGS_NO_IO_THRU_MDS in pg_get_mirror_count_write")
Fixes: ec906cf7bee6 ("pNFS/flexfiles: don't reset to MDS for v4 error when previous layout forbid it")
Signed-off-by: Benjamin Coddington <bcodding@hammerspace.com>
---
 fs/nfs/flexfilelayout/flexfilelayout.c | 40 +++++++++++++++-----------
 fs/nfs/internal.h                      |  6 ++--
 fs/nfs/pnfs.c                          | 22 ++++++++++++++
 fs/nfs/pnfs.h                          |  1 +
 4 files changed, 50 insertions(+), 19 deletions(-)

diff --git a/fs/nfs/flexfilelayout/flexfilelayout.c b/fs/nfs/flexfilelayout/flexfilelayout.c
index 4d3ad04775d6..6fc082e97c86 100644
--- a/fs/nfs/flexfilelayout/flexfilelayout.c
+++ b/fs/nfs/flexfilelayout/flexfilelayout.c
@@ -980,10 +980,14 @@ static bool ff_layout_pg_retry_wait(struct nfs_pageio_descriptor *pgio)
 
 /*
  * Returns true if the inode's layouts forbid I/O through the MDS.
+ * FF_FLAGS_NO_IO_THRU_MDS is a hint (RFC 8435, section 5.1.2), so set it
+ * aside while a failed LAYOUTGET for @iomode (NFS4ERR_LAYOUTUNAVAILABLE or
+ * NFS4ERR_TOOSMALL) keeps pnfs_update_layout() from sending another.
  */
 static bool ff_layout_inode_no_fallback_to_mds(struct inode *inode, u32 iomode)
 {
-	return nfs_no_io_thru_mds(inode);
+	return nfs_no_io_thru_mds(inode) &&
+	       !pnfs_layout_get_failed(inode, iomode);
 }
 
 /*
@@ -1141,13 +1145,12 @@ ff_layout_pg_init_read(struct nfs_pageio_descriptor *pgio,
 	}
 	/*
 	 * No segment, and no error to report either: pnfs_update_layout()
-	 * simply has nothing to give (NFS_LAYOUT_BULK_RECALL, a failed
-	 * pnfs_layout_io_test, blocked LAYOUTGETs, a layout being
-	 * returned).  If the server forbids reading this file through the
-	 * MDS there is no fallback to take, so wait for a layout on the
-	 * same terms as the -EAGAIN above.  The layout hdr that carried
-	 * FF_FLAGS_NO_IO_THRU_MDS may itself be gone by now, which is why
-	 * the flag is kept on the inode.
+	 * simply has nothing to give (NFS_LAYOUT_BULK_RECALL, blocked
+	 * LAYOUTGETs, a layout being returned).  If the server forbids
+	 * reading this file through the MDS there is no fallback to take,
+	 * so wait for a layout on the same terms as the -EAGAIN above.  The
+	 * layout hdr that carried FF_FLAGS_NO_IO_THRU_MDS may itself be
+	 * gone by now, which is why the flag is kept on the inode.
 	 */
 	if (!ff_layout_inode_no_fallback_to_mds(pgio->pg_inode, IOMODE_READ))
 		goto out_mds;
@@ -1412,7 +1415,8 @@ static int ff_layout_async_handle_error_v4(struct rpc_task *task,
 					   struct nfs4_state *state,
 					   struct nfs_client *clp,
 					   struct pnfs_layout_segment *lseg,
-					   struct nfs4_deviceid_node *devid)
+					   struct nfs4_deviceid_node *devid,
+					   u32 iomode)
 {
 	struct pnfs_layout_hdr *lo = lseg->pls_layout;
 	struct inode *inode = lo->plh_inode;
@@ -1501,8 +1505,9 @@ static int ff_layout_async_handle_error_v4(struct rpc_task *task,
 		return -NFS4ERR_RESET_TO_PNFS;
 reset:
 	/*
-	 * FF_FLAGS_NO_IO_THRU_MDS: never resend through the MDS.  The
-	 * caller would do so with force_mds set (ff_layout_reset_read(),
+	 * FF_FLAGS_NO_IO_THRU_MDS: don't resend through the MDS (see
+	 * ff_layout_inode_no_fallback_to_mds()).  The caller would do so
+	 * with force_mds set (ff_layout_reset_read(),
 	 * ff_layout_reset_write(hdr, false) -> pnfs_*_done_resend_to_mds()),
 	 * which builds a descriptor out of the plain MDS page ops and so
 	 * consults no layout at all -- this is the last point at which the
@@ -1512,7 +1517,7 @@ static int ff_layout_async_handle_error_v4(struct rpc_task *task,
 	 * pnfs_destroy_layout().  Having done so they can no longer ask the
 	 * layout hdr about the flag, hence the inode.
 	 */
-	if (nfs_no_io_thru_mds(inode)) {
+	if (ff_layout_inode_no_fallback_to_mds(inode, iomode)) {
 		dprintk("%s Retry through pNFS, no MDS fallback. Error %d\n",
 			__func__, task->tk_status);
 		return -NFS4ERR_RESET_TO_PNFS;
@@ -1597,7 +1602,8 @@ static int ff_layout_async_handle_error(struct rpc_task *task,
 					struct nfs4_state *state,
 					struct nfs_client *clp,
 					struct pnfs_layout_segment *lseg,
-					struct nfs4_deviceid_node *devid)
+					struct nfs4_deviceid_node *devid,
+					u32 iomode)
 {
 	int vers = clp->cl_nfs_mod->rpc_vers->number;
 
@@ -1617,7 +1623,7 @@ static int ff_layout_async_handle_error(struct rpc_task *task,
 						       lseg, devid);
 	case 4:
 		return ff_layout_async_handle_error_v4(task, op_status, state,
-						       clp, lseg, devid);
+						       clp, lseg, devid, iomode);
 	default:
 		/* should never happen */
 		WARN_ON_ONCE(1);
@@ -1751,7 +1757,7 @@ static int ff_layout_read_done_cb(struct rpc_task *task,
 	err = ff_layout_async_handle_error(task, hdr->res.op_status,
 					   hdr->args.context->state,
 					   hdr->ds_clp, hdr->lseg,
-					   hdr->ds_dev);
+					   hdr->ds_dev, IOMODE_READ);
 
 	trace_nfs4_pnfs_read(hdr, err);
 	clear_bit(NFS_IOHDR_RESEND_PNFS, &hdr->flags);
@@ -1961,7 +1967,7 @@ static int ff_layout_write_done_cb(struct rpc_task *task,
 	err = ff_layout_async_handle_error(task, hdr->res.op_status,
 					   hdr->args.context->state,
 					   hdr->ds_clp, hdr->lseg,
-					   hdr->ds_dev);
+					   hdr->ds_dev, IOMODE_RW);
 
 	trace_nfs4_pnfs_write(hdr, err);
 	clear_bit(NFS_IOHDR_RESEND_PNFS, &hdr->flags);
@@ -2013,7 +2019,7 @@ static int ff_layout_commit_done_cb(struct rpc_task *task,
 
 	err = ff_layout_async_handle_error(task, data->res.op_status,
 					   NULL, data->ds_clp, data->lseg,
-					   data->ds_dev);
+					   data->ds_dev, IOMODE_RW);
 
 	trace_nfs4_pnfs_commit_ds(data, err);
 	switch (err) {
diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
index 9819c4db3d85..bcbb5996c55c 100644
--- a/fs/nfs/internal.h
+++ b/fs/nfs/internal.h
@@ -558,8 +558,10 @@ static inline bool nfs_file_io_is_buffered(struct nfs_inode *nfsi)
  * thing pnfs_within_mdsthreshold() can ask for is the one thing the
  * layout forbids.  Flexfiles also retries reads and writes that have no
  * layout segment instead of sending them through the MDS, except
- * writeback of a single locked folio (pg_allow_mds).  Servers are
- * assumed to be consistent in their no-fallback policy per file.
+ * writeback of a single locked folio (pg_allow_mds), and unless a
+ * LAYOUTGET for that iomode has failed with NFS4ERR_LAYOUTUNAVAILABLE or
+ * NFS4ERR_TOOSMALL.  Servers are assumed to be consistent in their
+ * no-fallback policy per file.
  */
 #define NFS_INO_NO_IO_THRU_MDS	(30)
 
diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index 14f4a4b12ffd..582fe81fc2d1 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -551,6 +551,28 @@ pnfs_layout_io_test_failed(struct pnfs_layout_hdr *lo, u32 iomode)
 	return true;
 }
 
+/*
+ * Returns true if a LAYOUTGET for @iomode failed with an error, such as
+ * NFS4ERR_LAYOUTUNAVAILABLE, in the last PNFS_LAYOUTGET_RETRY_TIMEOUT.
+ * pnfs_layout_io_test_failed() clears an expired fail bit only when
+ * pnfs_update_layout() gets that far, so check the time here too.
+ */
+bool pnfs_layout_get_failed(struct inode *inode, u32 iomode)
+{
+	struct pnfs_layout_hdr *lo;
+	unsigned long now = jiffies;
+	bool ret = false;
+
+	spin_lock(&inode->i_lock);
+	lo = NFS_I(inode)->layout;
+	if (lo && test_bit(pnfs_iomode_to_fail_bit(iomode), &lo->plh_flags))
+		ret = time_in_range(lo->plh_retry_timestamp,
+				    now - PNFS_LAYOUTGET_RETRY_TIMEOUT, now);
+	spin_unlock(&inode->i_lock);
+	return ret;
+}
+EXPORT_SYMBOL_GPL(pnfs_layout_get_failed);
+
 static void
 pnfs_init_lseg(struct pnfs_layout_hdr *lo, struct pnfs_layout_segment *lseg,
 		const struct pnfs_layout_range *range,
diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
index 2774d4adf4c3..0007a4ca3da9 100644
--- a/fs/nfs/pnfs.h
+++ b/fs/nfs/pnfs.h
@@ -296,6 +296,7 @@ int pnfs_generic_pg_writepages(struct nfs_pageio_descriptor *desc);
 size_t pnfs_generic_pg_test(struct nfs_pageio_descriptor *pgio,
 			    struct nfs_page *prev, struct nfs_page *req);
 void pnfs_set_lo_fail(struct pnfs_layout_segment *lseg);
+bool pnfs_layout_get_failed(struct inode *inode, u32 iomode);
 struct pnfs_layout_segment *pnfs_layout_process(struct nfs4_layoutget *lgp);
 void pnfs_layoutget_free(struct nfs4_layoutget *lgp);
 void pnfs_free_lseg_list(struct list_head *tmp_list);
-- 
2.53.0

