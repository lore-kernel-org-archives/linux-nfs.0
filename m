Return-Path: <SRS0=nj1J=RK=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B6773C4360F
	for <linux-nfs@archiver.kernel.org>; Thu,  7 Mar 2019 15:28:52 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 8719F20643
	for <linux-nfs@archiver.kernel.org>; Thu,  7 Mar 2019 15:28:52 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="hFHG9dTb"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726351AbfCGP2w (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Thu, 7 Mar 2019 10:28:52 -0500
Received: from mail-it1-f196.google.com ([209.85.166.196]:34906 "EHLO
        mail-it1-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726294AbfCGP2v (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 7 Mar 2019 10:28:51 -0500
Received: by mail-it1-f196.google.com with SMTP id 188so16404852itb.0;
        Thu, 07 Mar 2019 07:28:50 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:subject:from:to:date:message-id:in-reply-to:references
         :user-agent:mime-version:content-transfer-encoding;
        bh=+tux8EQN3BRpNbnxGsrJk4tTPSPJcBuhz3/LrDu1e9Q=;
        b=hFHG9dTbDRgEUQxV+AOCy4Qhf41kMcW1lLaGrLcjzP8YaVxq20q4zgrL+oPmuaT9sy
         iYb7WMpJyBKqxUO0aX2eA5+LCh+P24U/a+P0Tr4llJYtHH7tHQpVVxjQJZK3UNtVXVl0
         6cF9Dq578vNyDrz3s1zev6N0q+jKpePPkkQ1FWkfN+BlEMp+3aUA0Mbk0sXX9PCjND4c
         +G+bp3DgXckXQRP2bPavzkOAlMS41SXkJ4+UI5tZRHI4M4DZz5R74SY2dtgvkIbYnMZE
         KqCRb/fP3+tLfGor/cjclnGrnG97L/Imlq7jfLKTWY8sd+huz5aXy2zQSCSNNzkSY1cK
         iXEg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:sender:subject:from:to:date:message-id
         :in-reply-to:references:user-agent:mime-version
         :content-transfer-encoding;
        bh=+tux8EQN3BRpNbnxGsrJk4tTPSPJcBuhz3/LrDu1e9Q=;
        b=t0NERwJmklV+9UVLM7HcfaIxMBcjTaU/ITQPzj1F/mm4DjYXVkbZ1LpzYQRTpYc/lh
         8qldwGDGUtZaF1sI8/YIyPA59SJiXLMEyDYlccgfYH8bCW0EP/8B5NlRx1dFM3n85jrQ
         eVLjfUo3Rd2RK7q3aesvokioCy1AHCW7fSr7U0FqJZiAHzM7p0MCm8YRbIEdD2ZDuWMe
         RNqf3omgPD678OfcBMVrtRzbHA+SRTP+Ak0i4H5FUEp7affPvAje2DoJ1QxgdOwjgZPF
         Falq7LA4jdIB8PaGqAK6aPUR3AzuCo+noGqEs4jYnBWYNxlwO4acrz8YIPH44qxcAG/S
         h+2A==
X-Gm-Message-State: APjAAAXSmY4a3nyr2LolFCJO00uRocxTfc+Ii3peerOqdYYSK++Ag35R
        XbRRFfcOI5wq4F0oNi0V4akI+xNq
X-Google-Smtp-Source: APXvYqwkCQDOSnOe8W6Vk51R7Gc2EfyTh44i3CTP32ZZ+sAfyBiuWOyTUZ64NqqNwRsfR6VPJ6WT2Q==
X-Received: by 2002:a24:64b:: with SMTP id 72mr5815557itv.53.1551972530044;
        Thu, 07 Mar 2019 07:28:50 -0800 (PST)
Received: from gateway.1015granger.net (c-68-61-232-219.hsd1.mi.comcast.net. [68.61.232.219])
        by smtp.gmail.com with ESMTPSA id x84sm2486373ita.32.2019.03.07.07.28.49
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 07 Mar 2019 07:28:49 -0800 (PST)
Received: from manet.1015granger.net (manet.1015granger.net [192.168.1.51])
        by gateway.1015granger.net (8.14.7/8.14.7) with ESMTP id x27FSn3F007221;
        Thu, 7 Mar 2019 15:28:49 GMT
Subject: [PATCH v2 2/5] NFSD: Prototype support for IMA on NFS (server)
From:   Chuck Lever <chuck.lever@oracle.com>
To:     linux-nfs@vger.kernel.org, linux-integrity@vger.kernel.org
Date:   Thu, 07 Mar 2019 10:28:49 -0500
Message-ID: <20190307152848.11306.9943.stgit@manet.1015granger.net>
In-Reply-To: <20190307151838.11306.94183.stgit@manet.1015granger.net>
References: <20190307151838.11306.94183.stgit@manet.1015granger.net>
User-Agent: StGit/0.17.1-dirty
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Provide code to handle the "security.ima" xattr. The NFS server
converts incoming GETATTR and SETATTR calls to acesses and updates
of the xattr. Even if CONFIG_IMA is disabled, the NFS server can
access and update that extended attribute.

The new FATTR4 bit is made up; meaning we still have to go through a
standards process to allocate a bit that all NFS vendors agree on.
Thus there is no guarantee this prototype will interoperate with
others or with a future standards-based implementation.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 fs/nfsd/nfs4proc.c |    9 +++++++++
 fs/nfsd/nfs4xdr.c  |   49 +++++++++++++++++++++++++++++++++++++++++++------
 fs/nfsd/nfsd.h     |    3 ++-
 fs/nfsd/vfs.c      |   19 +++++++++++++++++++
 fs/nfsd/vfs.h      |    3 +++
 fs/nfsd/xdr4.h     |    3 +++
 fs/xattr.c         |   25 +++++++++++++------------
 7 files changed, 92 insertions(+), 19 deletions(-)

diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index 0cfd257..8851bce 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -979,6 +979,11 @@ static __be32 nfsd4_do_lookupp(struct svc_rqst *rqstp, struct svc_fh *fh)
 				&setattr->sa_label);
 	if (status)
 		goto out;
+	if (setattr->sa_ima.len)
+		status = nfsd4_set_ima_metadata(rqstp, &cstate->current_fh,
+						&setattr->sa_ima);
+	if (status)
+		goto out;
 	status = nfsd_setattr(rqstp, &cstate->current_fh, &setattr->sa_iattr,
 				0, (time_t)0);
 out:
@@ -2135,6 +2140,10 @@ static inline u32 nfsd4_getattr_rsize(struct svc_rqst *rqstp,
 		ret += NFS4_MAXLABELLEN + 12;
 		bmap2 &= ~FATTR4_WORD2_SECURITY_LABEL;
 	}
+	if (bmap2 & FATTR4_WORD2_LINUX_IMA) {
+		ret += NFS4_MAXIMALEN + 4;
+		bmap2 &= ~FATTR4_WORD2_LINUX_IMA;
+	}
 	/*
 	 * Largest of remaining attributes are 16 bytes (e.g.,
 	 * supported_attributes)
diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index 3de42a7..3e8d90c 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -39,6 +39,7 @@
 #include <linux/statfs.h>
 #include <linux/utsname.h>
 #include <linux/pagemap.h>
+#include <linux/xattr.h>
 #include <linux/sunrpc/svcauth_gss.h>
 
 #include "idmap.h"
@@ -318,7 +319,8 @@ static char *savemem(struct nfsd4_compoundargs *argp, __be32 *p, int nbytes)
 static __be32
 nfsd4_decode_fattr(struct nfsd4_compoundargs *argp, u32 *bmval,
 		   struct iattr *iattr, struct nfs4_acl **acl,
-		   struct xdr_netobj *label, int *umask)
+		   struct xdr_netobj *label, int *umask,
+		   struct xdr_netobj *ima)
 {
 	struct timespec ts;
 	int expected_len, len = 0;
@@ -455,7 +457,6 @@ static char *savemem(struct nfsd4_compoundargs *argp, __be32 *p, int nbytes)
 			goto xdr_error;
 		}
 	}
-
 	label->len = 0;
 	if (IS_ENABLED(CONFIG_NFSD_V4_SECURITY_LABEL) &&
 	    bmval[2] & FATTR4_WORD2_SECURITY_LABEL) {
@@ -489,6 +490,21 @@ static char *savemem(struct nfsd4_compoundargs *argp, __be32 *p, int nbytes)
 		*umask = dummy32 & S_IRWXUGO;
 		iattr->ia_valid |= ATTR_MODE;
 	}
+	ima->len = 0;
+	if (bmval[2] & FATTR4_WORD2_LINUX_IMA) {
+		READ_BUF(4);
+		len += 4;
+		dummy32 = be32_to_cpup(p++);
+		READ_BUF(dummy32);
+		if (dummy32 > NFS4_MAXIMALEN)
+			return nfserr_badlabel;
+		len += (XDR_QUADLEN(dummy32) << 2);
+		READMEM(buf, dummy32);
+		ima->len = dummy32;
+		ima->data = svcxdr_dupstr(argp, buf, dummy32);
+		if (!ima->data)
+			return nfserr_jukebox;
+	}
 	if (len != expected_len)
 		goto xdr_error;
 
@@ -684,7 +700,7 @@ static __be32 nfsd4_decode_bind_conn_to_session(struct nfsd4_compoundargs *argp,
 
 	status = nfsd4_decode_fattr(argp, create->cr_bmval, &create->cr_iattr,
 				    &create->cr_acl, &create->cr_label,
-				    &create->cr_umask);
+				    &create->cr_umask, &create->cr_ima);
 	if (status)
 		goto out;
 
@@ -936,7 +952,7 @@ static __be32 nfsd4_decode_opaque(struct nfsd4_compoundargs *argp, struct xdr_ne
 		case NFS4_CREATE_GUARDED:
 			status = nfsd4_decode_fattr(argp, open->op_bmval,
 				&open->op_iattr, &open->op_acl, &open->op_label,
-				&open->op_umask);
+				&open->op_umask, &open->op_ima);
 			if (status)
 				goto out;
 			break;
@@ -951,7 +967,7 @@ static __be32 nfsd4_decode_opaque(struct nfsd4_compoundargs *argp, struct xdr_ne
 			COPYMEM(open->op_verf.data, NFS4_VERIFIER_SIZE);
 			status = nfsd4_decode_fattr(argp, open->op_bmval,
 				&open->op_iattr, &open->op_acl, &open->op_label,
-				&open->op_umask);
+				&open->op_umask, &open->op_ima);
 			if (status)
 				goto out;
 			break;
@@ -1188,7 +1204,8 @@ static __be32 nfsd4_decode_opaque(struct nfsd4_compoundargs *argp, struct xdr_ne
 	if (status)
 		return status;
 	return nfsd4_decode_fattr(argp, setattr->sa_bmval, &setattr->sa_iattr,
-				  &setattr->sa_acl, &setattr->sa_label, NULL);
+				  &setattr->sa_acl, &setattr->sa_label, NULL,
+				  &setattr->sa_ima);
 }
 
 static __be32
@@ -2430,6 +2447,7 @@ static int get_parent_attributes(struct svc_export *exp, struct kstat *stat)
 		.dentry	= dentry,
 	};
 	struct nfsd_net *nn = net_generic(SVC_NET(rqstp), nfsd_net_id);
+	struct xdr_netobj ima = { 0, NULL };
 
 	BUG_ON(bmval1 & NFSD_WRITEONLY_ATTRS_WORD1);
 	BUG_ON(!nfsd_attrs_supported(minorversion, bmval));
@@ -2491,6 +2509,16 @@ static int get_parent_attributes(struct svc_export *exp, struct kstat *stat)
 	}
 #endif /* CONFIG_NFSD_V4_SECURITY_LABEL */
 
+	if (bmval2 & FATTR4_WORD2_LINUX_IMA) {
+		err = vfs_getxattr_alloc(dentry, XATTR_NAME_IMA,
+					 (char **)&ima.data, 0, GFP_KERNEL);
+		if (err == -ENODATA)
+			bmval2 &= ~FATTR4_WORD2_LINUX_IMA;
+		else if (err < 0)
+			goto out_nfserr;
+		ima.len = err;
+	}
+
 	status = nfsd4_encode_bitmap(xdr, bmval0, bmval1, bmval2);
 	if (status)
 		goto out;
@@ -2913,6 +2941,14 @@ static int get_parent_attributes(struct svc_export *exp, struct kstat *stat)
 			goto out;
 	}
 
+	if (bmval2 & FATTR4_WORD2_LINUX_IMA) {
+		p = xdr_reserve_space(xdr,
+				      sizeof(__be32) + xdr_align_size(ima.len));
+		if (!p)
+			goto out_resource;
+		xdr_encode_netobj(p, &ima);
+	}
+
 	attrlen = htonl(xdr->buf->len - attrlen_offset - 4);
 	write_bytes_to_xdr_buf(xdr->buf, attrlen_offset, &attrlen, 4);
 	status = nfs_ok;
@@ -2922,6 +2958,7 @@ static int get_parent_attributes(struct svc_export *exp, struct kstat *stat)
 	if (context)
 		security_release_secctx(context, contextlen);
 #endif /* CONFIG_NFSD_V4_SECURITY_LABEL */
+	kfree(ima.data);
 	kfree(acl);
 	if (tempfh) {
 		fh_put(tempfh);
diff --git a/fs/nfsd/nfsd.h b/fs/nfsd/nfsd.h
index 0668999..c87ff8e 100644
--- a/fs/nfsd/nfsd.h
+++ b/fs/nfsd/nfsd.h
@@ -362,6 +362,7 @@ static inline bool nfsd4_spo_must_allow(struct svc_rqst *rqstp)
 	(NFSD4_1_SUPPORTED_ATTRS_WORD2 | \
 	FATTR4_WORD2_CHANGE_ATTR_TYPE | \
 	FATTR4_WORD2_MODE_UMASK | \
+	FATTR4_WORD2_LINUX_IMA | \
 	NFSD4_2_SECURITY_ATTRS)
 
 extern const u32 nfsd_suppattrs[3][3];
@@ -399,7 +400,7 @@ static inline bool nfsd_attrs_supported(u32 minorversion, const u32 *bmval)
 #define MAYBE_FATTR4_WORD2_SECURITY_LABEL 0
 #endif
 #define NFSD_WRITEABLE_ATTRS_WORD2 \
-	(FATTR4_WORD2_MODE_UMASK \
+	(FATTR4_WORD2_MODE_UMASK | FATTR4_WORD2_LINUX_IMA \
 	| MAYBE_FATTR4_WORD2_SECURITY_LABEL)
 
 #define NFSD_SUPPATTR_EXCLCREAT_WORD0 \
diff --git a/fs/nfsd/vfs.c b/fs/nfsd/vfs.c
index 7dc98e1..3c00072 100644
--- a/fs/nfsd/vfs.c
+++ b/fs/nfsd/vfs.c
@@ -551,6 +551,25 @@ __be32 nfsd4_set_nfs4_label(struct svc_rqst *rqstp, struct svc_fh *fhp,
 }
 #endif
 
+__be32 nfsd4_set_ima_metadata(struct svc_rqst *rqstp, struct svc_fh *fhp,
+			      struct xdr_netobj *ima)
+{
+	struct dentry *dentry;
+	int host_error;
+	__be32 error;
+
+	error = fh_verify(rqstp, fhp, 0 /* S_IFREG */, NFSD_MAY_SATTR);
+	if (error)
+		return error;
+	dentry = fhp->fh_dentry;
+
+	inode_lock(d_inode(dentry));
+	host_error = __vfs_setxattr_noperm(dentry, XATTR_NAME_IMA, ima->data,
+					   ima->len, 0);
+	inode_unlock(d_inode(dentry));
+	return nfserrno(host_error);
+}
+
 __be32 nfsd4_clone_file_range(struct file *src, u64 src_pos, struct file *dst,
 		u64 dst_pos, u64 count)
 {
diff --git a/fs/nfsd/vfs.h b/fs/nfsd/vfs.h
index a7e1073..acfc2b0 100644
--- a/fs/nfsd/vfs.h
+++ b/fs/nfsd/vfs.h
@@ -55,6 +55,9 @@ __be32		nfsd_setattr(struct svc_rqst *, struct svc_fh *,
 #ifdef CONFIG_NFSD_V4
 __be32          nfsd4_set_nfs4_label(struct svc_rqst *, struct svc_fh *,
 		    struct xdr_netobj *);
+__be32		nfsd4_set_ima_metadata(struct svc_rqst *rqstp,
+				       struct svc_fh *fhp,
+				       struct xdr_netobj *ima);
 __be32		nfsd4_vfs_fallocate(struct svc_rqst *, struct svc_fh *,
 				    struct file *, loff_t, loff_t, int);
 __be32		nfsd4_clone_file_range(struct file *, u64, struct file *,
diff --git a/fs/nfsd/xdr4.h b/fs/nfsd/xdr4.h
index feeb6d4..2f3307f 100644
--- a/fs/nfsd/xdr4.h
+++ b/fs/nfsd/xdr4.h
@@ -123,6 +123,7 @@ struct nfsd4_create {
 	struct nfsd4_change_info  cr_cinfo; /* response */
 	struct nfs4_acl *cr_acl;
 	struct xdr_netobj cr_label;
+	struct xdr_netobj cr_ima;
 };
 #define cr_datalen	u.link.datalen
 #define cr_data		u.link.data
@@ -255,6 +256,7 @@ struct nfsd4_open {
 	struct nfs4_clnt_odstate *op_odstate; /* used during processing */
 	struct nfs4_acl *op_acl;
 	struct xdr_netobj op_label;
+	struct xdr_netobj op_ima;
 };
 
 struct nfsd4_open_confirm {
@@ -339,6 +341,7 @@ struct nfsd4_setattr {
 	struct iattr	sa_iattr;           /* request */
 	struct nfs4_acl *sa_acl;
 	struct xdr_netobj sa_label;
+	struct xdr_netobj sa_ima;
 };
 
 struct nfsd4_setclientid {
diff --git a/fs/xattr.c b/fs/xattr.c
index 0d6a6a4..5674be1 100644
--- a/fs/xattr.c
+++ b/fs/xattr.c
@@ -151,20 +151,20 @@
 EXPORT_SYMBOL(__vfs_setxattr);
 
 /**
- *  __vfs_setxattr_noperm - perform setxattr operation without performing
- *  permission checks.
+ * __vfs_setxattr_noperm - perform setxattr operation without performing
+ * permission checks.
  *
- *  @dentry - object to perform setxattr on
- *  @name - xattr name to set
- *  @value - value to set @name to
- *  @size - size of @value
- *  @flags - flags to pass into filesystem operations
+ * @dentry: object to perform setxattr on
+ * @name: xattr name to set
+ * @value: value to set @name to
+ * @size: size of @value
+ * @flags: flags to pass into filesystem operations
  *
- *  returns the result of the internal setxattr or setsecurity operations.
+ * Returns the result of the internal setxattr or setsecurity operations.
  *
- *  This function requires the caller to lock the inode's i_mutex before it
- *  is executed. It also assumes that the caller will make the appropriate
- *  permission checks.
+ * This function requires the caller to lock the inode's i_mutex before it
+ * is executed. It also assumes that the caller will make the appropriate
+ * permission checks.
  */
 int __vfs_setxattr_noperm(struct dentry *dentry, const char *name,
 		const void *value, size_t size, int flags)
@@ -202,7 +202,7 @@ int __vfs_setxattr_noperm(struct dentry *dentry, const char *name,
 
 	return error;
 }
-
+EXPORT_SYMBOL_GPL(__vfs_setxattr_noperm);
 
 int
 vfs_setxattr(struct dentry *dentry, const char *name, const void *value,
@@ -295,6 +295,7 @@ int __vfs_setxattr_noperm(struct dentry *dentry, const char *name,
 	*xattr_value = value;
 	return error;
 }
+EXPORT_SYMBOL_GPL(vfs_getxattr_alloc);
 
 ssize_t
 __vfs_getxattr(struct dentry *dentry, struct inode *inode, const char *name,

