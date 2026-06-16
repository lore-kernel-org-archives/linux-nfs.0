Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id AB072466B52;
	Tue, 16 Jun 2026 11:59:33 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1781611174; cv=none; b=cMATgg/6BqaeU7jeZ6eWZpRpAIhOPQiOfpEgqLufYmBpjFII79mfZnTsbK8JjyThsO9r3kIRKNaQubLDjPcuLlUs32FL6DK3YU97ldF5hMpyTa5nu38YfeAyJEVGGMCyHwnPbDvIfOsVfFHnVrikCwZYzlGiJl9JKRDQoFTsLhY=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1781611174; c=relaxed/simple;
	bh=ibSXMgZESy0OsgrUhX+PEpB5dJQkeg7x249DPfRXsNw=;
	h=From:Date:Subject:MIME-Version:Content-Type:Message-Id:References:
	 In-Reply-To:To:Cc; b=ATV8SpSOAyDAfrsr+md4MvJezjXAXEegi0WsTuuusdsPMB1JYjtFEDTNpPmM2ateYj29B03fYb1jN4PWcAeC/MB41ucJwEZW/F1cOoqSKuSLBaWgVtcPFwDwZ9h7EB4y3y9ltqyPCo+pnD7M4wfH/5n1Fh97BDiwC9xFPqBqtsE=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=gRTYQ5L+; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="gRTYQ5L+"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id A11231F00ACA;
	Tue, 16 Jun 2026 11:59:31 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1781611173;
	bh=SaP43mvD4sjJAVuyPEK93f0HcEsMpN/bywX9uTdeQwQ=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=gRTYQ5L++CyXtBXcGrnn5uNUDXUzF0JsErWLP3OXhW6jpf1aGXXcV2sSKHsFeamrz
	 rN9IoeUIg/Ig/HkaG0iuIogHw3nyfHg23rAQUtPF8ue2s0pr9bnS3zdJGwyZ9uQh88
	 4qC0JbIptGbcvbfXoZVjisVRhNa/QgTdJHZICaNxO0VQ/1VZ8uOOCKflsBy08Ofpl0
	 7WqaPtq4EGk6pApjzUEG0S9ypQNhbsM5UOyW9pSJr8SHJMVnIOtLixwD6AMWyHnJiQ
	 jleZyr4XeNIot+z5sako8qnxoDppu7/I5kVZKPeUXMn0U1DCSkjGUIJRP2x8gyYP9U
	 2y95arw8cWRnQ==
From: Jeff Layton <jlayton@kernel.org>
Date: Tue, 16 Jun 2026 07:58:57 -0400
Subject: [PATCH v7 14/20] nfsd: send basic file attributes in CB_NOTIFY
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20260616-dir-deleg-v7-14-6cbc7eac0ade@kernel.org>
References: <20260616-dir-deleg-v7-0-6cbc7eac0ade@kernel.org>
In-Reply-To: <20260616-dir-deleg-v7-0-6cbc7eac0ade@kernel.org>
To: NeilBrown <neil@brown.name>, Olga Kornievskaia <okorniev@redhat.com>, 
 Dai Ngo <Dai.Ngo@oracle.com>, Tom Talpey <tom@talpey.com>, 
 Trond Myklebust <trondmy@kernel.org>, Anna Schumaker <anna@kernel.org>, 
 Jonathan Corbet <corbet@lwn.net>, Shuah Khan <skhan@linuxfoundation.org>, 
 Chuck Lever <cel@kernel.org>
Cc: Steven Rostedt <rostedt@goodmis.org>, 
 Alexander Aring <alex.aring@gmail.com>, Amir Goldstein <amir73il@gmail.com>, 
 Jan Kara <jack@suse.cz>, Alexander Viro <viro@zeniv.linux.org.uk>, 
 Christian Brauner <brauner@kernel.org>, 
 Calum Mackay <calum.mackay@oracle.com>, linux-kernel@vger.kernel.org, 
 linux-doc@vger.kernel.org, linux-nfs@vger.kernel.org, 
 Jeff Layton <jlayton@kernel.org>
X-Mailer: b4 0.14.3
X-Developer-Signature: v=1; a=openpgp-sha256; l=2682; i=jlayton@kernel.org;
 h=from:subject:message-id; bh=ibSXMgZESy0OsgrUhX+PEpB5dJQkeg7x249DPfRXsNw=;
 b=owEBbQKS/ZANAwAKAQAOaEEZVoIVAcsmYgBqMTqH1/BjcI6550sVe8XVra0dw4hmiaq6Nkhr2
 R70jFX24gGJAjMEAAEKAB0WIQRLwNeyRHGyoYTq9dMADmhBGVaCFQUCajE6hwAKCRAADmhBGVaC
 FbDTEADQVkPI4hrI9OyGFMV2wWrrg+PY4IGmi/5xfdWF9UzmaWGqH+Vdc/EIcgSkDOzPm48K0lx
 UuhMQJGOHJz+Azx2rRpxV0xImx9oV/vPwPemSIpvWEJ+bor7ZW1reQhOCJlifRlWFK27qoDmwis
 KsROx+TATht//FIQ9SZTppfkRjjuoyVMz+jNNMqUcjJZsq+bMus7vc3eqFMob7GUvQBCGWidAEv
 GeP7/2sZi63AuF887SxUnF1cwvrzegBvMpTZiNYBtFrDqHfpiBPSKaw51C8liHbKqfCDK9Ma523
 2w4Amr5Jm3E2LUPbJDh2R7jJytb25FItkZkgMRaiCcgdDYq3Th6yG8MfmelOXUdDXkeZ6eysT8c
 S6g3itjWE56ZWfOmSODUBV4F3MTZJjUOi5wmk9I5IFrL8zRefD6QOYjJJzonI3rHU6VFUllbrrO
 kgVHXA1NfGKPDHz3XztqYPwMlWHlamfVLSMvLqQ7inrCDUOULmkITU85gGtQToq1tSbKxOU6gtJ
 BiMVOSD27TSyzjZ2YyiyBJ8+2AUyXsp94pMjKACRuPkJ7Dg19xnjba5f8vk4h0HFib2mKB4bOQe
 YCSvVY9Mft3JMnXIyFsO6uVjshhNte7UAyeI5ye4N5DujS1dqNCLbZrw/3Y02Te6d+E1jdG+J/Y
 OTU9Z3HxA6q1wmw==
X-Developer-Key: i=jlayton@kernel.org; a=openpgp;
 fpr=4BC0D7B24471B2A184EAF5D3000E684119568215

In addition to the filename, send attributes about the inode in a
CB_NOTIFY event. This patch just adds a the basic inode information that
can be acquired via GETATTR.

Signed-off-by: Jeff Layton <jlayton@kernel.org>
---
 fs/nfsd/nfs4xdr.c | 44 ++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 44 insertions(+)

diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index 6f5b0c032d64..90c265ce3846 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -4195,12 +4195,21 @@ nfsd4_encode_fattr4(struct svc_rqst *rqstp, struct xdr_stream *xdr,
 	goto out;
 }
 
+#define CB_NOTIFY_STATX_REQUEST_MASK (STATX_BASIC_STATS   | \
+				      STATX_BTIME	  | \
+				      STATX_CHANGE_COOKIE)
+
 static bool
 nfsd4_setup_notify_entry4(struct notify_entry4 *ne, struct xdr_stream *xdr,
 			  struct dentry *dentry, struct nfs4_delegation *dp,
 			  struct nfsd_file *nf, char *name, u32 namelen)
 {
+	struct path path =  { .mnt = nf->nf_file->f_path.mnt,
+			      .dentry = dentry };
+	struct nfsd4_fattr_args args = { };
 	uint32_t *attrmask;
+	__be32 status;
+	int ret;
 
 	/* Reserve space for attrmask */
 	attrmask = xdr_reserve_space(xdr, 3 * sizeof(uint32_t));
@@ -4211,6 +4220,41 @@ nfsd4_setup_notify_entry4(struct notify_entry4 *ne, struct xdr_stream *xdr,
 	ne->ne_file.len = namelen;
 	ne->ne_attrs.attrmask.element = attrmask;
 
+	/* FIXME: d_find_alias for inode ? */
+	if (!path.dentry || !d_inode(path.dentry))
+		goto noattrs;
+
+	/*
+	 * It is possible that the client was granted a delegation when a file
+	 * was created. Note that we don't issue a CB_GETATTR here since stale
+	 * attributes are presumably ok.
+	 */
+	ret = vfs_getattr(&path, &args.stat, CB_NOTIFY_STATX_REQUEST_MASK, AT_STATX_SYNC_AS_STAT);
+	if (ret)
+		goto noattrs;
+
+	args.change_attr = nfsd4_change_attribute(&args.stat);
+
+	attrmask[0] = FATTR4_WORD0_TYPE | FATTR4_WORD0_CHANGE |
+		      FATTR4_WORD0_SIZE | FATTR4_WORD0_FILEID;
+	attrmask[1] = FATTR4_WORD1_MODE | FATTR4_WORD1_NUMLINKS | FATTR4_WORD1_RAWDEV |
+		      FATTR4_WORD1_SPACE_USED | FATTR4_WORD1_TIME_ACCESS |
+		      FATTR4_WORD1_TIME_METADATA | FATTR4_WORD1_TIME_MODIFY;
+	attrmask[2] = 0;
+
+	if (args.stat.result_mask & STATX_BTIME)
+		attrmask[1] |= FATTR4_WORD1_TIME_CREATE;
+
+	ne->ne_attrs.attrmask.count = 2;
+	ne->ne_attrs.attr_vals.data = (u8 *)xdr->p;
+
+	status = nfsd4_encode_attr_vals(xdr, attrmask, &args);
+	if (status != nfs_ok)
+		goto noattrs;
+
+	ne->ne_attrs.attr_vals.len = (u8 *)xdr->p - ne->ne_attrs.attr_vals.data;
+	return true;
+noattrs:
 	attrmask[0] = 0;
 	attrmask[1] = 0;
 	attrmask[2] = 0;

-- 
2.54.0

