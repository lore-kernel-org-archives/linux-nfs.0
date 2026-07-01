Received: from mail-qk1-f169.google.com (mail-qk1-f169.google.com [209.85.222.169])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id B01CC3A5422
	for <linux-nfs@vger.kernel.org>; Wed,  1 Jul 2026 20:43:42 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.222.169
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1782938624; cv=none; b=S8NltqiiYGimG5LDIlIqN8Q1J/ZC+Q2pOjVPVPETGiNfj90h86/o/0IrA4VZjoFcyitZer4XfJAJVWIpY/0ojWbBbK4ahw5i3n2jAz88N5uKI4IabpLF+RqRucQ8QtT3s2bDmDqAxmrlg81lAUgtchVDJqBYf56yDydz9oWu55M=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1782938624; c=relaxed/simple;
	bh=GWCOViPw8GAHxBEIdt7oqj0KESgJZT5nBrrwnsUi4V8=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=Xp7K/OxySKZ1JjfAdJWjC3GNFl32xmv/jBuxLiz79U+SDu9xG3F2oK7/+hYMnl34PqUFzRIty560I0TmXuiHtPXkVI9ZuWqIF6YMASMt3p8qBx9Qzd+qgKqFclHceXTrGrzvS867nFxyI5C1nMzYv5eB0F+Iy0mlEVbjtTh8AoY=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=hammerspace.com; spf=pass smtp.mailfrom=hammerspace.com; dkim=pass (2048-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b=H0tC6dWH; arc=none smtp.client-ip=209.85.222.169
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b="H0tC6dWH"
Received: by mail-qk1-f169.google.com with SMTP id af79cd13be357-92e54f8c051so56618285a.3
        for <linux-nfs@vger.kernel.org>; Wed, 01 Jul 2026 13:43:42 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=hammerspace.com; s=google; t=1782938621; x=1783543421; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:sender:from:to:cc:subject:date
         :message-id:reply-to;
        bh=6GotUsygMNdOaBXRsCZhol7+3hqsFNxl8cEm4hrCWhE=;
        b=H0tC6dWHvn/o6C7lMmCfujw1qgRgrJrdts3+NlCylpoboh+0B3BOTZDZUiLAqP3vbZ
         9FaO+3vv8lAlFaMz1uQhlmly9UVbPYk9Wml/t6Iv8R0GT5+w2BsY3k6phVK5hHBAAMJV
         jdLBjuXBg2RAtsnF7VDxvVHqC5/OscrMmffltOBhUym2ipdjknBH1HOtofUEWm4qUbwb
         pxbVfns4bEE9CdndxP0SDKGeK+Qh13WPDd/MaaNW+46rbKW25EJf4VvDUD/vx2x09BwT
         /iu+awVKREQVocA7kt/z5WR4wPrGhvg9zse/p4z1dOPWUti0W/P/cG7Y2FFKHLj/Eu9z
         AFig==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20251104; t=1782938622; x=1783543422;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:sender:x-gm-gg
         :x-gm-message-state:from:to:cc:subject:date:message-id:reply-to;
        bh=6GotUsygMNdOaBXRsCZhol7+3hqsFNxl8cEm4hrCWhE=;
        b=ReYmANEBUC0KvkosyQbtcoasjVcN+7KdvMsHlSdG9nt0qMVH0vIriGNBiRiiQNi7vl
         VoiEHhRQoPMC9UaQ6g14ySyAYanWKDIaiHzPA8iMbz4sz/IPx3topbERIQsHm8HKNx7g
         zaWs4YU48gQ6KzElj9cH9cw8japwTdAjHEE0iU4F9kixEAcpfScrQclCfMqFtqvYVSEp
         ZKx1PhMctorYx7sqTKrfshOEPTmDkfA2imSn8lRclXMtBY5O+i5CHod/QY14hSNEIjyv
         jntZPnTNphIYnzsg3J/S3amRiCy4OuCssnY/CpdRo+OqFuVKgUykAQR6rEzGr+I8mPaR
         de0g==
X-Forwarded-Encrypted: i=1; AFNElJ/O0r7SvjSXURepDP/fxq7MDTzGN5XEm+5V2RglYJ/pkg5AOloM1+OzCjBayKmzOXAw+epPxcLnTGM=@vger.kernel.org
X-Gm-Message-State: AOJu0YwuV2NzUujsnV2r9a7cqTImMx5nD3Z+yLitwiIhZHdxaAqKvzFj
	tAT22/sGkV0faqOpQqJyO+Zz4+ME24qrrEaKDcIgyj3kmJ8VkZaHmaAxwv0nPEp+lBo=
X-Gm-Gg: AfdE7ckfShnv5y1I1uzTfviQQLhVqhjUNCQkjBUWQCV4x0lKTXVYp1fiqKnC+lOM5IX
	FFqgjr4ofbZD2eZYAxbhfVjVX6GBb7VcPgYQYd4XoC5r4cYzf+TyzNsdnWTkYBjRjL/lbKxTsFf
	p6Hsrgwa9tnf5r47GAcCBoNcMXfD8nxDAYmt4msNBTlgbwLezOfLc+giZv6PZgeUM72vLty39JQ
	GwisSe3HWCa2XTjho/8hG5zhTK1si7SHVkT0vBbqzOOhn2iQgiPcjs6tGUtqM3R7w5MsmjjSmLS
	QW2tQsjqFw6Ivbf9aovlyzDt051QGf4mkID0ojMeP0p5D7CBpSEIOHXfWCaeHKuDL51jWe/oUnG
	cTPNOTTGfwpXzGSsZxrPl0IILAeGa9eCDf0pOzkeTVXHdNN7Nc48KA86c4DtJxYfAiea1VRC/Kb
	eqUF5NNQNiKwLI+M+ySKEG7E3rvokVHFoXzfMW7B9k9qp7VcLbzRA6tvGeDg5phIMPV24Qug/jf
	iVadw==
X-Received: by 2002:a05:620a:d88:b0:92e:6533:26ef with SMTP id af79cd13be357-92e784cd85fmr517898285a.46.1782938621282;
        Wed, 01 Jul 2026 13:43:41 -0700 (PDT)
Received: from localhost (pool-68-160-167-46.bstnma.fios.verizon.net. [68.160.167.46])
        by smtp.gmail.com with ESMTPSA id af79cd13be357-92e80161816sm37549885a.22.2026.07.01.13.43.40
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Wed, 01 Jul 2026 13:43:40 -0700 (PDT)
Sender: Mike Snitzer <mike.snitzer@hammerspace.com>
From: Mike Snitzer <snitzer@hammerspace.com>
X-Google-Original-From: Mike Snitzer <snitzer@kernel.org>
To: Trond Myklebust <trondmy@kernel.org>,
	Anna Schumaker <anna@kernel.org>
Cc: Tom Haynes <loghyr@hammerspace.com>,
	Chuck Lever <cel@kernel.org>,
	linux-nfs@vger.kernel.org
Subject: [PATCH v3 2/6] nfs4.2: request UNCACHEABLE_FILE_DATA only for regular files
Date: Wed,  1 Jul 2026 16:43:33 -0400
Message-ID: <20260701204337.54314-3-snitzer@kernel.org>
X-Mailer: git-send-email 2.44.0
In-Reply-To: <20260701204337.54314-1-snitzer@kernel.org>
References: <20260701204337.54314-1-snitzer@kernel.org>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

The UNCACHEABLE_FILE_DATA attribute applies only to regular files
(NF4REG); per draft-ietf-nfsv4-uncacheable-files a server MUST reject a
query of it on any other object type with NFS4ERR_INVAL.  The previous
commit decodes and tracks the attribute but does not gate it: the bit
rides in the per-server attribute bitmask (server->attr_bitmask) and in
the generic getattr request bitmap (nfs4_fattr_bitmap), so it would be
requested for non-regular objects too -- e.g. a plain directory GETATTR,
a LOOKUP that resolves to a directory, or a CREATE (which only ever makes
non-regular objects).  A strict server would fail those compounds.

Gate the client accordingly:

 - Only set NFS_INO_INVALID_UNCACHEABLE_FILE_DATA on regular-file inodes,
   so the attribute is never (re)requested for directories or other
   non-regular objects via the delegation GETATTR or nfs4_bitmask_set()
   refresh paths.

 - Gate the request by object type at the single choke point
   nfs4_bitmap_copy_adjust(), which clears
   FATTR4_WORD2_UNCACHEABLE_FILE_DATA unless the target inode is a
   regular file (a NULL inode -- unknown object type -- clears it too).
   This already covers GETATTR, SETATTR and LINK; route LOOKUP, LOOKUPP
   and CREATE through it as well.

The bit is kept in server->attr_bitmask (it is server-supported, and OPEN
still requests it via its regular-file-only open_bitmap), so no bespoke
per-data-file bitmask plumbing is needed.  The remaining getattr-bearing
compounds are already safe: ACCESS, DELEGRETURN, WRITE, CLOSE and
LAYOUTCOMMIT use server->cache_consistency_bitmask (no word2 attributes)
or operate on regular files; READDIR does not encode the bit; and
LOOKUP_ROOT, FSINFO, STATFS and PATHCONF use fixed bitmaps without it.

Signed-off-by: Mike Snitzer <snitzer@kernel.org>
Assisted-by: Claude:claude-opus-4-8
---
 fs/nfs/inode.c    |  6 ++++--
 fs/nfs/nfs4proc.c | 37 ++++++++++++++++++++++++++++++++++---
 2 files changed, 38 insertions(+), 5 deletions(-)

diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
index 68a1d97d9560..bb6e58123341 100644
--- a/fs/nfs/inode.c
+++ b/fs/nfs/inode.c
@@ -565,7 +565,8 @@ nfs_fhget(struct super_block *sb, struct nfs_fh *fh, struct nfs_fattr *fattr)
 		if (fattr->valid & NFS_ATTR_FATTR_UNCACHEABLE_FILE_DATA)
 			nfsi->uncacheable_file_data =
 				fattr->aux_flags & NFS_AUX_UNCACHEABLE_FILE_DATA;
-		else if (fattr_supported & NFS_ATTR_FATTR_UNCACHEABLE_FILE_DATA)
+		else if (S_ISREG(inode->i_mode) &&
+			 (fattr_supported & NFS_ATTR_FATTR_UNCACHEABLE_FILE_DATA))
 			nfs_set_cache_invalid(inode, NFS_INO_INVALID_UNCACHEABLE_FILE_DATA);
 
 		nfs_setsecurity(inode, fattr);
@@ -2473,7 +2474,8 @@ static int nfs_update_inode(struct inode *inode, struct nfs_fattr *fattr)
 	if (fattr->valid & NFS_ATTR_FATTR_UNCACHEABLE_FILE_DATA)
 		nfsi->uncacheable_file_data =
 				fattr->aux_flags & NFS_AUX_UNCACHEABLE_FILE_DATA;
-	else if (fattr_supported & NFS_ATTR_FATTR_UNCACHEABLE_FILE_DATA)
+	else if (S_ISREG(inode->i_mode) &&
+		 (fattr_supported & NFS_ATTR_FATTR_UNCACHEABLE_FILE_DATA))
 		nfsi->cache_validity |=
 			save_cache_validity & NFS_INO_INVALID_UNCACHEABLE_FILE_DATA;
 
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index ad03b8518c14..a0d088cd47ac 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -308,6 +308,15 @@ static void nfs4_bitmap_copy_adjust(__u32 *dst, const __u32 *src,
 	unsigned long cache_validity;
 
 	memcpy(dst, src, NFS4_BITMASK_SZ*sizeof(*dst));
+	/*
+	 * The uncacheable_file_data attribute applies only to regular files
+	 * (NF4REG); a server must reject a query of it on any other object
+	 * type with NFS4ERR_INVAL.  Never request it unless the target is
+	 * known to be a regular file (callers with an unknown object type,
+	 * e.g. LOOKUP, pass a NULL inode).
+	 */
+	if (!inode || !S_ISREG(inode->i_mode))
+		dst[2] &= ~FATTR4_WORD2_UNCACHEABLE_FILE_DATA;
 	if (!inode || !nfs_have_read_or_write_delegation(inode))
 		return;
 
@@ -4598,6 +4607,7 @@ static int _nfs4_proc_lookup(struct rpc_clnt *clnt, struct inode *dir,
 		.rpc_resp = &res,
 	};
 	unsigned short task_flags = 0;
+	__u32 bitmask[NFS4_BITMASK_SZ];
 
 	if (nfs_server_capable(dir, NFS_CAP_MOVEABLE))
 		task_flags = RPC_TASK_MOVEABLE;
@@ -4606,7 +4616,13 @@ static int _nfs4_proc_lookup(struct rpc_clnt *clnt, struct inode *dir,
 	if (nfs_lookup_is_soft_revalidate(dentry))
 		task_flags |= RPC_TASK_TIMEOUT;
 
-	args.bitmask = nfs4_bitmask(server, fattr->label);
+	/*
+	 * The looked-up object's type is unknown here, so gate out the
+	 * regular-file-only uncacheable_file_data attribute (NULL inode).
+	 */
+	nfs4_bitmap_copy_adjust(bitmask, nfs4_bitmask(server, fattr->label),
+				NULL, 0);
+	args.bitmask = bitmask;
 
 	nfs_fattr_init(fattr);
 
@@ -4720,13 +4736,20 @@ static int _nfs4_proc_lookupp(struct inode *inode,
 		.rpc_resp = &res,
 	};
 	unsigned short task_flags = 0;
+	__u32 bitmask[NFS4_BITMASK_SZ];
 
 	if (server->flags & NFS_MOUNT_SOFTREVAL)
 		task_flags |= RPC_TASK_TIMEOUT;
 	if (server->caps & NFS_CAP_MOVEABLE)
 		task_flags |= RPC_TASK_MOVEABLE;
 
-	args.bitmask = nfs4_bitmask(server, fattr->label);
+	/*
+	 * The looked-up object's type is unknown here, so gate out the
+	 * regular-file-only uncacheable_file_data attribute (NULL inode).
+	 */
+	nfs4_bitmap_copy_adjust(bitmask, nfs4_bitmask(server, fattr->label),
+				NULL, 0);
+	args.bitmask = bitmask;
 
 	nfs_fattr_init(fattr);
 	nfs4_init_sequence(server->nfs_client, &args.seq_args, &res.seq_res, 0, 0);
@@ -5141,6 +5164,7 @@ struct nfs4_createdata {
 	struct nfs4_create_res res;
 	struct nfs_fh fh;
 	struct nfs_fattr fattr;
+	u32 bitmask[NFS4_BITMASK_SZ];
 };
 
 static struct nfs4_createdata *nfs4_alloc_createdata(struct inode *dir,
@@ -5164,7 +5188,14 @@ static struct nfs4_createdata *nfs4_alloc_createdata(struct inode *dir,
 		data->arg.name = name;
 		data->arg.attrs = sattr;
 		data->arg.ftype = ftype;
-		data->arg.bitmask = nfs4_bitmask(server, data->fattr.label);
+		/*
+		 * CREATE only makes non-regular objects, so gate out the
+		 * regular-file-only uncacheable_file_data attribute (NULL inode).
+		 */
+		nfs4_bitmap_copy_adjust(data->bitmask,
+					nfs4_bitmask(server, data->fattr.label),
+					NULL, 0);
+		data->arg.bitmask = data->bitmask;
 		data->arg.umask = current_umask();
 		data->res.server = server;
 		data->res.fh = &data->fh;
-- 
2.47.3

