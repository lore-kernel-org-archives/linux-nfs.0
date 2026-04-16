Received: from smtp.kernel.org (aws-us-west-2-korg-mail-1.web.codeaurora.org [10.30.226.201])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 096913ED5D6;
	Thu, 16 Apr 2026 17:35:58 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=10.30.226.201
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1776360958; cv=none; b=Q21b1xrESpQK26yRg2yq5Tkb7bti2096EOycFJdQZM0JmMzgj7L/f92ni7v66dKORpgIZ5i+IjtCt+wd+i6cvDKqQZGIJ3D9D6z3y0i+zU9iS9r3TLHD9Wp3HXvMoQ9i2rFSixNBVfCp6L+jMXvZHAssXLJr0m4XPT8y+S0QgvQ=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1776360958; c=relaxed/simple;
	bh=FUFtdaMMYDWs09R3VPMt65ogwXEM4SC5NUOnEAc330c=;
	h=From:Date:Subject:MIME-Version:Content-Type:Message-Id:References:
	 In-Reply-To:To:Cc; b=fU5S7q5KXl90jSuQbk3MZRaitVbbasaibP3gfqg/XfHzWYRo5h6df4AVQTBiGF+ZxO2qd3zs7cOq7je+PV0T2eBAh2iP1tJLcsCHkyLHjSc+pG79qdBWpVP2ucuedCJtRyqqjsVQ3R7d6+TaDD8C3bZeuKy5qblBkx1A6w/S9J8=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=gcaV3nTB; arc=none smtp.client-ip=10.30.226.201
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="gcaV3nTB"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 389A4C2BCB7;
	Thu, 16 Apr 2026 17:35:57 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=k20201202; t=1776360957;
	bh=FUFtdaMMYDWs09R3VPMt65ogwXEM4SC5NUOnEAc330c=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc:From;
	b=gcaV3nTBm3Z4zkmnFhXIJ8DDusob2ODgZp5yXE5oco/xd7wJNCX7F5LxRd/QVqkCb
	 p43KJ6u2g1cnebMf3DEZ7eL1TDT2yvyQ0jhsnqAhV78hU6YSlNKAiIuUA0SSta4jwK
	 003+9OxNkv8E0b9Csm7bWQisMF3PjY9KQTK4up3FQjgF8ULZe41zjvUwyhDdlGw1Mr
	 XJfHD+WY+raD89BAvU4IIaSVSM3yRnBzOTAoMmJudDckq3B644JNR5alIV9++deHpP
	 z7eJkhuN/EWXUaY3xlBgo9JjPN2DbIOr2U8efVWYvp8nLFNaIyYMYgFSUtaI3MVdlZ
	 ezvAV1XUOeHBw==
From: Jeff Layton <jlayton@kernel.org>
Date: Thu, 16 Apr 2026 10:35:26 -0700
Subject: [PATCH v2 25/28] nfsd: add the filehandle to returned attributes
 in CB_NOTIFY
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20260416-dir-deleg-v2-25-851426a550f6@kernel.org>
References: <20260416-dir-deleg-v2-0-851426a550f6@kernel.org>
In-Reply-To: <20260416-dir-deleg-v2-0-851426a550f6@kernel.org>
To: Alexander Viro <viro@zeniv.linux.org.uk>, 
 Christian Brauner <brauner@kernel.org>, Jan Kara <jack@suse.cz>, 
 Chuck Lever <chuck.lever@oracle.com>, 
 Alexander Aring <alex.aring@gmail.com>, 
 Steven Rostedt <rostedt@goodmis.org>, 
 Masami Hiramatsu <mhiramat@kernel.org>, 
 Mathieu Desnoyers <mathieu.desnoyers@efficios.com>, 
 Jonathan Corbet <corbet@lwn.net>, Shuah Khan <skhan@linuxfoundation.org>, 
 NeilBrown <neil@brown.name>, Olga Kornievskaia <okorniev@redhat.com>, 
 Dai Ngo <Dai.Ngo@oracle.com>, Tom Talpey <tom@talpey.com>, 
 Trond Myklebust <trondmy@kernel.org>, Anna Schumaker <anna@kernel.org>, 
 Amir Goldstein <amir73il@gmail.com>
Cc: Calum Mackay <calum.mackay@oracle.com>, linux-fsdevel@vger.kernel.org, 
 linux-kernel@vger.kernel.org, linux-trace-kernel@vger.kernel.org, 
 linux-doc@vger.kernel.org, linux-nfs@vger.kernel.org, 
 Jeff Layton <jlayton@kernel.org>
X-Mailer: b4 0.14.3
X-Developer-Signature: v=1; a=openpgp-sha256; l=2618; i=jlayton@kernel.org;
 h=from:subject:message-id; bh=FUFtdaMMYDWs09R3VPMt65ogwXEM4SC5NUOnEAc330c=;
 b=owEBbQKS/ZANAwAKAQAOaEEZVoIVAcsmYgBp4R3o16+8svz8DEDAcO3+LdFZtIPx7pE/ZcLSY
 yIAWjLxeJ6JAjMEAAEKAB0WIQRLwNeyRHGyoYTq9dMADmhBGVaCFQUCaeEd6AAKCRAADmhBGVaC
 FYwVEADWmFQetkV24KsDm1FfchcFrwzzjxcSX07myIPSISVO8GSCc/hOv/ByHSbzrNIrViw6Y8o
 kfQzYT0JLQC3YF+4K8AXx117hw/25VJ0We+HARjpSrXVu1hy+ChdgwKcFdUXM7BUdUbi04UE1gq
 aj+M9hSNip/SWakW219myqEfiBS+qumYwiyYpoLdlC+OP7wQKeqK0wwXgrBjz+cjFXsPZ7xRGe4
 v86Y9HTUDFGQ+nA4sDl3VIq9djF4flo2ctUl3aX6wX3uprskzHA73yZiLJUXoZD516GhAm3Qzjx
 r8v92fgzwzPK+dATlupB2atSpedP1bDV+trGYWtLLvZJ9Srb/VdutSmoxGVADvM/S4lO2VI8vKQ
 n03Pzy8ojyY5OPqUeG4mu/rHoug+ZdKAX8mrSxNT3dfo5HNYCGXKPhd9DxSDYvq++c+dFfSVNCs
 mqg2Wo1kNvEF7w/9YRk/zPdHY9sRHmZfDeh5iy7+J8Vupu2izj5muly8ljwYYqfSUQbGGWKxim0
 zxjDmXh7hdANz4FK8NX5uJGEZ/dJbDqkssCKnA+J/rb/EkH5UBfj+OgBievtwTe/bE85RVuGhDB
 7ofuk187S6ncow39BhnCbL/vgG8YNENyC15lGqFFe9uqnZ5UAdplHIpl0rAMFID3jKO3X8OzHW5
 9zDDMtCrO54sZ9w==
X-Developer-Key: i=jlayton@kernel.org; a=openpgp;
 fpr=4BC0D7B24471B2A184EAF5D3000E684119568215

nfsd's usual fh_compose routine requires a svc_export and fills out a
svc_fh. In the context of a CB_NOTIFY there is no such export to
consult.

Add a new routine that composes a filehandle with only a parent
filehandle and nfs4_file. Use that to fill out the fhandle field in the
nfsd4_fattr_args.

Signed-off-by: Jeff Layton <jlayton@kernel.org>
---
 fs/nfsd/nfs4xdr.c | 37 +++++++++++++++++++++++++++++++++++++
 1 file changed, 37 insertions(+)

diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index a9cdf7a3f8b3..5d7d8545c904 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -4109,6 +4109,39 @@ nfsd4_encode_fattr4(struct svc_rqst *rqstp, struct xdr_stream *xdr,
 	goto out;
 }
 
+static bool
+setup_notify_fhandle(struct dentry *dentry, struct nfs4_file *fi,
+		     struct nfsd_file *nf, struct nfsd4_fattr_args *args)
+{
+	int fileid_type, fsid_len, maxsize, flags = 0;
+	struct knfsd_fh *fhp = &args->fhandle;
+	struct inode *inode = d_inode(dentry);
+	struct inode *parent = NULL;
+	struct fid *fid;
+
+	fsid_len = key_len(fi->fi_fhandle.fh_fsid_type);
+	fhp->fh_size = 4 + fsid_len;
+
+	/* Copy first 4 bytes + fsid */
+	memcpy(&fhp->fh_raw, &fi->fi_fhandle.fh_raw, fhp->fh_size);
+
+	fid = (struct fid *)(fh_fsid(fhp) + fsid_len/4);
+	maxsize = (NFS4_FHSIZE - fhp->fh_size)/4;
+
+	if (fi->fi_connectable && !S_ISDIR(inode->i_mode)) {
+		parent = d_inode(nf->nf_file->f_path.dentry);
+		flags = EXPORT_FH_CONNECTABLE;
+	}
+
+	fileid_type = exportfs_encode_inode_fh(inode, fid, &maxsize, parent, flags);
+	if (fileid_type < 0)
+		return false;
+
+	fhp->fh_fileid_type = fileid_type;
+	fhp->fh_size += maxsize * 4;
+	return true;
+}
+
 #define CB_NOTIFY_STATX_REQUEST_MASK (STATX_BASIC_STATS   | \
 				      STATX_BTIME	  | \
 				      STATX_CHANGE_COOKIE)
@@ -4118,6 +4151,7 @@ nfsd4_setup_notify_entry4(struct notify_entry4 *ne, struct xdr_stream *xdr,
 			  struct dentry *dentry, struct nfs4_delegation *dp,
 			  struct nfsd_file *nf, char *name, u32 namelen)
 {
+	struct nfs4_file *fi = dp->dl_stid.sc_file;
 	struct path path =  { .mnt = nf->nf_file->f_path.mnt,
 			      .dentry = dentry };
 	struct nfsd4_fattr_args args = { };
@@ -4156,6 +4190,9 @@ nfsd4_setup_notify_entry4(struct notify_entry4 *ne, struct xdr_stream *xdr,
 		      FATTR4_WORD1_TIME_METADATA | FATTR4_WORD1_TIME_MODIFY;
 	attrmask[2] = 0;
 
+	if (setup_notify_fhandle(dentry, fi, nf, &args))
+		attrmask[0] |= FATTR4_WORD0_FILEHANDLE;
+
 	if (args.stat.result_mask & STATX_BTIME)
 		attrmask[1] |= FATTR4_WORD1_TIME_CREATE;
 

-- 
2.53.0

