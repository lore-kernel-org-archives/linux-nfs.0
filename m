Received: from fhigh-b3-smtp.messagingengine.com (fhigh-b3-smtp.messagingengine.com [202.12.124.154])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id C65ED32B9BB
	for <linux-nfs@vger.kernel.org>; Fri, 17 Jul 2026 04:33:59 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=202.12.124.154
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1784262842; cv=none; b=pKVSO9CH7BuZOqxh8tP/UmYI+ShbQQwqS98wGBTVhqOpXUNvPr21ROiECqfCPSsT5yTWZuxOPTVlzto3vaIKXGU+r2iSMbmRkBlZSULxsHocOZmgpRKpgfQBO5eAahM22wvTR9KdMTF8ttKkXp3lP0Lx0Fr7otrZzlomuXSlENc=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1784262842; c=relaxed/simple;
	bh=50uUGzwbfWXHwAV0bLMHrouLSJwmbmAO8S30vY0peaE=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=ni5r5vUUxt6vCi7jN2Pc/nvj2EK5NkYpmTGHxVszpBruyk9DL3jkgErAC9LXZ8CTIf3E8H8NDDn7wrAdEeIVJVUbmaiIZ8GGwa1s/ZLt5e6NKUHFTQjggnvmgL4Z5eOdhfQVHovz25ohEcWheGSaVw+YZGZK6JTJOgKeHOX+368=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ownmail.net; spf=pass smtp.mailfrom=ownmail.net; dkim=pass (2048-bit key) header.d=ownmail.net header.i=@ownmail.net header.b=A7aBICeZ; dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b=MWAld6Lg; arc=none smtp.client-ip=202.12.124.154
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ownmail.net
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ownmail.net
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=ownmail.net header.i=@ownmail.net header.b="A7aBICeZ";
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="MWAld6Lg"
Received: from phl-compute-01.internal (phl-compute-01.internal [10.202.2.41])
	by mailfhigh.stl.internal (Postfix) with ESMTP id 2AD057A011F;
	Fri, 17 Jul 2026 00:33:58 -0400 (EDT)
Received: from phl-frontend-04 ([10.202.2.163])
  by phl-compute-01.internal (MEProxy); Fri, 17 Jul 2026 00:33:58 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ownmail.net; h=
	cc:cc:content-transfer-encoding:content-type:date:date:from:from
	:in-reply-to:in-reply-to:message-id:mime-version:references
	:reply-to:reply-to:subject:subject:to:to; s=fm2; t=1784262838;
	 x=1784349238; bh=Fuyzqpvxc8agHaMf/aODtsOj7CWtTNw/eEsqZqAxmJo=; b=
	A7aBICeZ15Bm/jH54UwEWaUSXxDDPF/SHaMCYYF5jNItiy0+VpuMHiEukW/ALWin
	UguiVMkDvZBtJq2LiwBdme1wsCrjQ2sJPARPfRcNB8KGIXgoY6ve2iZJqVadeia2
	GOkZIASAsc/qYo1y/A+VHm/fMXV8U8DYsJtPLa+OR4DPdz74p0/BAF7QYOpNkXe+
	BJTtYZ6TcLOV3fqsRkfSLPjTaV2FVjkpXQsdAq8B8YHqDEc2RtYY6xYhj1oEbjto
	smu7yYI1VZWorkOHHu/t63MLXJbjI2Xi92F9w06VYnDvQPDI7hDtvWSr3FmgAeXj
	FNd3PNJPkUsdReVtF6NZ4Q==
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:cc:content-transfer-encoding
	:content-type:date:date:feedback-id:feedback-id:from:from
	:in-reply-to:in-reply-to:message-id:mime-version:references
	:reply-to:reply-to:subject:subject:to:to:x-me-proxy:x-me-sender
	:x-me-sender:x-sasl-enc; s=fm2; t=1784262838; x=1784349238; bh=F
	uyzqpvxc8agHaMf/aODtsOj7CWtTNw/eEsqZqAxmJo=; b=MWAld6LgSc62fUy6u
	IRzkj9OH9ITPHDXyHS95vV2Naaaayg4BInZ89OYjSlbYXKwh0JTYK8ohD6roY/hO
	lSXdGpma8sJPk9UOGl/lkHhWqKNeL6DWYw1F5Yw0+W+Jubl1F2unaMwZowUL2Hi4
	Bsc7Rf7e4K5fjksRvueikM8rYaEVp/Cy3aQyvd83yJuF1jA54FeWOBkuc+4q0I2t
	RDmA2De0zjvNRWOeRqTBTKSWxTW4nk6obgUE5mcVy+srZOGbmAmPKfjtihc8Fyp1
	9qYL/3dpm5CqdTR2lYvW5gPuu+QguARyzwkTWA/M3BzdmXeAH5Rcz3ovSZwxec23
	69FSA==
X-ME-Sender: <xms:tbBZasGSf8HFRTvDljIMpMSp7zCUOM9cCBJFZ7d-eC_CJpijpagdEA>
    <xme:tbBZatw82vEft8pwGM5gv583EgYmHJYIp95cVggx8MdCz2pbvdnE9l0x_fb6Maf7C
    qqJOstrRkoQCiz67aYrK_H40tfMVqa-yHVmhdBMJmBI2U8bimQ>
X-ME-Received: <xmr:tbBZamkBV9PA_jTB7t4DTxGZDhQRbQ4gNqO8JosQfhF1dahaA_L2VGEe4UmHmbuo4fdaDBr3wRJraJIXLIxefDjiR61sY00>
X-ME-Proxy-Cause: dmFkZTFnEpgNJ5d20c54qdZKAJEfDKeEsLFu4GhQwTmzausBhx9zFB3HjMPveQfQcE55T2
    3sdGUpBuymjivVU+VJmEAia8FhKvCSd9LLXwGKBQ709zK+Kad4BtYxXVFSKV7YP2theml9
    izmgFoMCcN8xPORTs7ZQ9kIFJfoJW1QWJRZ74IDWujCJQ2deXVbGcKTcJGTYqc/Z89vZ5y
    JIbRdmq7skMHvh1OvKbrF1HHuvHJjOP4T5oOhP2yGtB2ieI6XB9e0wVuO5KaJLJxL8cJV9
    qfQQTZaJIPwDUQnxG6t/svyoyevxcmuBvcCJgKPaPIHDu3qX36GGEwWtYiTqpisM71GmeH
    DQQuBrT7ox8SjgPFEqoicwAtyBqVCYkSJJFNdhvhB5Q9DkZq0Rc5GLoMgH0cat4OqRjwEl
    Z8KDw50qT/VvmlbVYkO/frPH/XOB8oaKmo/AEUZikQ+4jW+AxwgJahVLiI5k5YTLIrcmKq
    oAWGR1OzpF3XlGeo0GIt15LEsIzh2fuIM+PReGvwfBkLezxmBxBjsOgEgWioUOqOB+cnLH
    LVq0Uzun1zxrqSEokgOMY/KUlTM540f4ZncaMSoEPNXIKacSeYqUm13Njs/tj9KTWDabd5
    A4P0v2J15L22JxMzxDz75VKVSkRleoUoZB1+pc+9J1OZuByzfw62/1qYnQDA
X-ME-Proxy: <xmx:tbBZaum-kegoLbfaEb4ECnBNkq4RHY3hEKUW5IKtyYUDmj_hgxu-oQ>
    <xmx:tbBZagy-j5ONde9guJb4D_Z01FlyaHDvfx2IRfRhvTmHWvROCQgysg>
    <xmx:tbBZaropC6LUrNgVEigtkBe0dgpRnl-yasJWRbVx9PaFPxA0BiJ7fw>
    <xmx:tbBZan7kg8ga-qM_glvhoR0a4QujVc_5pVWI5KcILxdoZPYHOXhD7Q>
    <xmx:trBZalShyt2Em_PNvVY7KoqeifL4PnulLXecTLCvZdER-gHW9Z1JFSEk>
Feedback-ID: i9d664b8f:Fastmail
Received: by mail.messagingengine.com (Postfix) with ESMTPA; Fri,
 17 Jul 2026 00:33:55 -0400 (EDT)
From: NeilBrown <neilb@ownmail.net>
To: Chuck Lever <chuck.lever@oracle.com>,
	Jeff Layton <jlayton@kernel.org>
Cc: Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <Dai.Ngo@oracle.com>,
	Tom Talpey <tom@talpey.com>,
	linux-nfs@vger.kernel.org
Subject: [PATCH v4 14/18] nfsd: move some code out of the d_really_is_negative() branch in nfsd4_create_file()
Date: Fri, 17 Jul 2026 14:31:12 +1000
Message-ID: <20260717043242.1865905-15-neilb@ownmail.net>
X-Mailer: git-send-email 2.50.0.107.gf914562f5916.dirty
In-Reply-To: <20260717043242.1865905-1-neilb@ownmail.net>
References: <20260717043242.1865905-1-neilb@ownmail.net>
Reply-To: NeilBrown <neil@brown.name>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

From: NeilBrown <neil@brown.name>

The benefit of this code movement isn't immediately obvious, but it will
make it easier to switch to using vfs_lookup_open().

One immediate benefit is that common code in the d_is_positive() branch
can be discarded.

Reviewed-by: Jeff Layton <jlayton@kernel.org>
Signed-off-by: NeilBrown <neil@brown.name>
---
 fs/nfsd/nfs4proc.c | 73 ++++++++++++++++++----------------------------
 1 file changed, 28 insertions(+), 45 deletions(-)

diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index c3bec447a43e..7a67e1385b76 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -220,7 +220,11 @@ nfsd4_create_file(struct svc_rqst *rqstp, struct svc_fh *fhp,
 		.na_iattr	= iap,
 		.na_seclabel	= &open->op_label,
 	};
+	int oflags = O_CREAT | O_LARGEFILE;
 	struct dentry *parent, *child = ERR_PTR(-EINVAL);
+	struct path path = {
+		.mnt = fhp->fh_export->ex_path.mnt,
+	};
 	__u32 v_mtime, v_atime;
 	struct inode *inode;
 	__be32 status, create_status;
@@ -266,6 +270,24 @@ nfsd4_create_file(struct svc_rqst *rqstp, struct svc_fh *fhp,
 	if (!IS_POSIXACL(inode))
 		iap->ia_mode &= ~current_umask();
 
+	/*
+	 * For the EXCLUSIVE modes we do our own uniqueness tests
+	 * so don't want O_EXCL.
+	 */
+	if (open->op_createmode == NFS4_CREATE_GUARDED)
+		oflags |= O_EXCL;
+
+	switch (open->op_share_access & NFS4_SHARE_ACCESS_BOTH) {
+	case NFS4_SHARE_ACCESS_WRITE:
+		oflags |= O_WRONLY;
+		break;
+	case NFS4_SHARE_ACCESS_BOTH:
+		oflags |= O_RDWR;
+		break;
+	default:
+		oflags |= O_RDONLY;
+	}
+
 	if (!is_create_with_attrs(open)) {
 		/* No attrs to check */
 	} else if (open->op_acl) {
@@ -322,27 +344,13 @@ nfsd4_create_file(struct svc_rqst *rqstp, struct svc_fh *fhp,
 		status = nfserrno(PTR_ERR(child));
 		goto out;
 	}
+	path.dentry = child;
 
 	if (d_really_is_positive(child)) {
 		/*
 		 * open the file so that we consistently have a valid
 		 * op_filp and consequently a valid ->f_path.dentry.
 		 */
-		struct path path = {.mnt = fhp->fh_export->ex_path.mnt,
-				    .dentry = child,
-		};
-		unsigned int oflags = O_LARGEFILE;
-
-		switch (open->op_share_access & NFS4_SHARE_ACCESS_BOTH) {
-		case NFS4_SHARE_ACCESS_WRITE:
-			oflags |= O_WRONLY;
-			break;
-		case NFS4_SHARE_ACCESS_BOTH:
-			oflags |= O_RDWR;
-			break;
-		default:
-			oflags |= O_RDONLY;
-		}
 
 		status = nfsd_check_obj_isreg(child, cstate->minorversion);
 		if (status == nfs_ok) {
@@ -356,39 +364,14 @@ nfsd4_create_file(struct svc_rqst *rqstp, struct svc_fh *fhp,
 	} else if (create_status) {
 		status = create_status;
 	} else {
-		struct file *filp;
-		struct path path;
-		int oflags;
-
-		oflags = O_CREAT | O_LARGEFILE;
-		/*
-		 * For the EXCLUSIVE modes we do our own uniqueness tests
-		 * so don't want O_EXCL.
-		 */
-		if (open->op_createmode == NFS4_CREATE_GUARDED)
-			oflags |= O_EXCL;
-
-		switch (open->op_share_access & NFS4_SHARE_ACCESS_BOTH) {
-		case NFS4_SHARE_ACCESS_WRITE:
-			oflags |= O_WRONLY;
-			break;
-		case NFS4_SHARE_ACCESS_BOTH:
-			oflags |= O_RDWR;
-			break;
-		default:
-			oflags |= O_RDONLY;
-		}
-
-		path.mnt = fhp->fh_export->ex_path.mnt;
-		path.dentry = child;
-		filp = dentry_create(&path, oflags, open->op_iattr.ia_mode,
-				     current_cred());
+		open->op_filp = dentry_create(&path, oflags, open->op_iattr.ia_mode,
+					      current_cred());
 		child = path.dentry;
 
-		if (IS_ERR(filp)) {
-			status = nfserrno(PTR_ERR(filp));
+		if (IS_ERR(open->op_filp)) {
+			status = nfserrno(PTR_ERR(open->op_filp));
+			open->op_filp = NULL;
 		} else {
-			open->op_filp = filp;
 			open->op_created = open->op_filp->f_mode & FMODE_CREATED;
 		}
 	}
-- 
2.50.0.107.gf914562f5916.dirty

