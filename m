Received: from mail-yx1-f53.google.com (mail-yx1-f53.google.com [74.125.224.53])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id AE80F3BFAEB
	for <linux-nfs@vger.kernel.org>; Mon, 17 Aug 2026 21:10:15 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=74.125.224.53
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1787001017; cv=none; b=HWgGjvkG7S7FPA889ljbwrXZX+dtC41q/9MjDti8Rz6QiCGlxaAeEEwKInxhLsj3QFjJtXCQEJj9cAJ4JP/GArv/F7pzY2hghn6Ld0mMOlJEjCsj/ibkbthmHA6yd5DqggMFCoNEaE2E/ejmx4nxAiPww/f+/7dIdATTst/xfvo=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1787001017; c=relaxed/simple;
	bh=RoSaEceyAXt0a2jERSEKHUlXg0QFu9GRSAc4zHO+CJw=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=TANMlJZprZQ6idseDzLky+5GfsoAxvcQaO9FqvH1MdZrFjHC1GEMkpDD589fvKAWFK6o2gk4gdva0zLnQLnrU9c++mODxPk85PtO1B29X3rkFwWkc7R3d3YZJMN7Si6HyU0Hoz8oE+nLOmHX4zmtnRwkC9L0m+ysSyckGLDQbfM=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=truenas.com; spf=pass smtp.mailfrom=truenas.com; dkim=pass (2048-bit key) header.d=truenas.com header.i=@truenas.com header.b=nizUOLBw; arc=none smtp.client-ip=74.125.224.53
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=truenas.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=truenas.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=truenas.com header.i=@truenas.com header.b="nizUOLBw"
Received: by mail-yx1-f53.google.com with SMTP id 956f58d0204a3-66bee06ff74so4982280d50.0
        for <linux-nfs@vger.kernel.org>; Mon, 17 Aug 2026 14:10:15 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=truenas.com; s=google; t=1787001015; x=1787605815; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=FvBK6ZpAfTbuqAjnmwnCQ5nqGqNLY8VU1KNOajANLY0=;
        b=nizUOLBwWWmYOh3bhbmABLA6my7Yh3Wj4TtqinsVqNFL+uwYv7M3Xk/1v7f9y98NWd
         nrrifAA5xZHetw4MgziNJ+nzQ3gXal1J0135+KYQxO53jkB5j8Djf63+0wxPCe6VvM96
         EhcU7I4ql1In/Fuq8Ev/ITzXdytyxW5fWnY4qCvZ28GTzNz2a7KmmWm9JlJfoJ3djWjB
         oDuNaHLqkAbktShL4lUvX05vTkWrtVOFke9QKWV+uv9jSx343+EGit01HIKOf72MbKZj
         pbaOMGSou8SKoCyVravAV4NiV8EEbx9BT2tzAbHTb197uKcEzIRhEK877J4Y5nS5Z3ZF
         HPSg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20251104; t=1787001015; x=1787605815;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:x-gm-gg:x-gm-message-state:from
         :to:cc:subject:date:message-id:reply-to:content-type;
        bh=FvBK6ZpAfTbuqAjnmwnCQ5nqGqNLY8VU1KNOajANLY0=;
        b=AGR1YTnwOLXpmb2B1PCBnn8J4JLfsXUL6XHJ4EbDhWr82aAYAXZX5vQZ8aDr5PM2TW
         K4e/IPuYQerDFs1fsiW4GPn6IGlH93kC9POiPcBcE24OHaE6lqH3cmVl2DTOLjpXd6Ge
         4XCs+Pg9r9SNCPO05hpUSxcP4zGVsWN4iJ8Z/6GwBSV2lOYr0Uy+fM/9O4YeiO9gMF9I
         515JcxHl0XWw83mSKwz0MMpYpxe+PMJ/1Nl2h4MbRdu+HvkFKdK4TSbf3SnM2R4ew23j
         3Krc3VA65UxRdoJcxJgzosdASPx0EFEZUVJjab/lnKpnfuMHfXLiO+uv+/8hxDeKSGQU
         8e6g==
X-Forwarded-Encrypted: i=1; AHgh+RogPxh+OLTmMQjhvdai80QTVvMaWUD/abp8AH+R8Ny9ssyeuNGSGE/wXm1zHb/ZnNXFuvOY2KFbPnc=@vger.kernel.org
X-Gm-Message-State: AOJu0YzA53KACBmSc7JI3iQYbW2ivHQBd3r7/puV33yyE5kPLkW2SEce
	0FfAchD2NWJYX/znsLAhaulXFQ2otU301GbGmqklA6LHRLBbwxG8kxCHtCSkIpBlxw==
X-Gm-Gg: AR+sD13zSx1y2bl+CtsEWTw9vlo3ZYISs1fo01qNAAE4BO/lyduUeNtVThMhUwH5HcV
	dzJOip7Neqado4K1rXU2VQOuqwPKQyf3paQ3giKvbmFP+VYF7CLqjvc202xjCbQfRZTP7+61YWQ
	Xg/Xca4OwOgmvaidoege+ktmXvQ2iw0Enlu8RnVmyieuvPmmApPtFR7cMnEak4gQnBKPTWhwxNW
	FmICpCjSunCH7ubXXYOQ3zIMOXYgq+2Gv6LrxhrZREHYPW92kuURbKIZpv7S19eQw69pC/RtQ88
	CAbglgAZZF3RUvlLFXZthEo7RRywoK3mZRk6DWDlhQC7jCtjy5fbtgEP2Nm3cuVRbviSeugORo4
	utY+5lTFkcTVt+O+cg4mNp16LHEUGSuwkXEOS2tV8F1PV6HuLt4uG3Vi674fBeM3qR9LdrxMqA8
	w6/zKUL6XYLh7TDuY29tuyi/Fbz30xfxBJEn8IKYKIMI85kX3p6U0=
X-Received: by 2002:a05:690e:169d:b0:667:d824:b781 with SMTP id 956f58d0204a3-66c72b812f7mr10833886d50.19.1787001014547;
        Mon, 17 Aug 2026 14:10:14 -0700 (PDT)
Received: from hamza-PC ([2400:adc1:158:c700::1])
        by smtp.gmail.com with ESMTPSA id 00721157ae682-840f25bed4csm9533557b3.29.2026.08.17.14.10.10
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Mon, 17 Aug 2026 14:10:14 -0700 (PDT)
From: Ameer Hamza <ameer.hamza@truenas.com>
To: cel@kernel.org,
	jlayton@kernel.org,
	neil@brown.name,
	okorniev@redhat.com,
	Dai.Ngo@oracle.com,
	tom@talpey.com
Cc: trondmy@kernel.org,
	anna@kernel.org,
	linux-nfs@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	alexander.motin@truenas.com,
	caleb.stjohn@truenas.com,
	ameer.hamza@truenas.com
Subject: [PATCH 1/2] NFSD: Use nfsd_iter_read() when ->splice_read is not zero-copy
Date: Tue, 18 Aug 2026 02:08:10 +0500
Message-ID: <20260817210811.3984663-2-ameer.hamza@truenas.com>
X-Mailer: git-send-email 2.53.0
In-Reply-To: <20260817210811.3984663-1-ameer.hamza@truenas.com>
References: <20260817210811.3984663-1-ameer.hamza@truenas.com>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

For some files splicing a READ cannot avoid a copy: gfs2, kernfs
and the cifs direct-I/O modes use copy_splice_read() as their
->splice_read, and the VFS substitutes it for DAX files.
copy_splice_read() allocates a fresh page for every page of
payload and reads into it; nfsd_splice_actor() then installs
those pages in rq_respages, displacing Reply pages the thread
already owns. Both sets of pages are then freed.

Route these READs through nfsd_iter_read() instead. It performs
the same single copy, but into the thread's own Reply pages, so
the per-READ allocation and the displacement both disappear. On
its own this is not expected to raise throughput; it changes
which pages a Reply is built from so that the next patch can
recycle them.

9p and ceph fall back to copy_splice_read() only inside their
own ->splice_read methods, which nfsd_splice_read_is_zero_copy()
cannot detect, so they keep the splice path. nfsd_iter_read() is
the path sec=krb5i, sec=krb5p and nfsd_disable_splice_read READs
already take, and is unchanged here; the one visible difference
is that an fsnotify watcher now sees two access events per READ
instead of one, the extra one from vfs_iocb_iter_read().

Assisted-by: Claude:claude-fable-5
Signed-off-by: Ameer Hamza <ameer.hamza@truenas.com>
---
 fs/nfsd/nfs4xdr.c |  4 ++--
 fs/nfsd/vfs.c     |  5 ++++-
 fs/nfsd/vfs.h     | 29 +++++++++++++++++++++++++++++
 3 files changed, 35 insertions(+), 3 deletions(-)

diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index 7d1b2d6f57f20..07a4bd8feb764 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -5369,7 +5369,7 @@ nfsd4_encode_read(struct nfsd4_compoundres *resp, __be32 nfserr,
 	maxcount = min_t(unsigned long, read->rd_length,
 			 (xdr->buf->buflen - xdr->buf->len));
 
-	if (file->f_op->splice_read && splice_ok)
+	if (nfsd_splice_read_is_zero_copy(file) && splice_ok)
 		nfserr = nfsd4_encode_splice_read(resp, read, file, maxcount);
 	else
 		nfserr = nfsd4_encode_readv(resp, read, maxcount);
@@ -6267,7 +6267,7 @@ nfsd4_encode_read_plus_data(struct nfsd4_compoundres *resp,
 	maxcount = min_t(unsigned long, read->rd_length,
 			 (xdr->buf->buflen - xdr->buf->len));
 
-	if (file->f_op->splice_read && splice_ok)
+	if (nfsd_splice_read_is_zero_copy(file) && splice_ok)
 		nfserr = nfsd4_encode_splice_read(resp, read, file, maxcount);
 	else
 		nfserr = nfsd4_encode_readv(resp, read, maxcount);
diff --git a/fs/nfsd/vfs.c b/fs/nfsd/vfs.c
index f9131827d391e..1a5fec4cf73d3 100644
--- a/fs/nfsd/vfs.c
+++ b/fs/nfsd/vfs.c
@@ -1176,6 +1176,9 @@ nfsd_direct_read(struct svc_rqst *rqstp, struct svc_fh *fhp,
  *
  * Some filesystems or situations cannot use nfsd_splice_read. This
  * function is the slightly less-performant fallback for those cases.
+ * It is also the preferred path where splicing would copy anyway
+ * (see nfsd_splice_read_is_zero_copy()), because the copy then
+ * lands directly in Reply pages nfsd already owns.
  *
  * Returns nfs_ok on success, otherwise an nfserr stat value is
  * returned.
@@ -1576,7 +1579,7 @@ __be32 nfsd_read(struct svc_rqst *rqstp, struct svc_fh *fhp,
 		return err;
 
 	file = nf->nf_file;
-	if (file->f_op->splice_read && nfsd_read_splice_ok(rqstp))
+	if (nfsd_splice_read_is_zero_copy(file) && nfsd_read_splice_ok(rqstp))
 		err = nfsd_splice_read(rqstp, fhp, file, offset, count, eof);
 	else
 		err = nfsd_iter_read(rqstp, fhp, nf, offset, count, 0, eof);
diff --git a/fs/nfsd/vfs.h b/fs/nfsd/vfs.h
index f0cb184643f2f..70bd3c6fc1880 100644
--- a/fs/nfsd/vfs.h
+++ b/fs/nfsd/vfs.h
@@ -149,6 +149,35 @@ __be32		nfsd_iter_read(struct svc_rqst *rqstp, struct svc_fh *fhp,
 				unsigned long *count, unsigned int base,
 				u32 *eof);
 bool		nfsd_read_splice_ok(struct svc_rqst *rqstp);
+
+/**
+ * nfsd_splice_read_is_zero_copy - check whether splice can avoid a data copy
+ * @file: file to be read from
+ *
+ * copy_splice_read() reads via ->read_iter into freshly allocated
+ * pages, exactly as nfsd_iter_read() does into pages nfsd already
+ * holds. Filesystems that implement ->splice_read with it gain
+ * nothing from the splice path, and neither do DAX files, for
+ * which the VFS substitutes copy_splice_read() no matter what
+ * the filesystem registered. The VFS substitutes it for O_DIRECT
+ * files as well, but nfsd never opens files O_DIRECT.
+ *
+ * The test is one-sided: a filesystem's own ->splice_read method
+ * may fall back to copy_splice_read() internally, as ceph and 9p
+ * do, and that cannot be detected here.
+ *
+ * Return values:
+ *   %true: splicing from @file is not known to copy
+ *   %false: splicing from @file would copy, or is not supported
+ *           at all; use nfsd_iter_read()
+ */
+static inline bool nfsd_splice_read_is_zero_copy(const struct file *file)
+{
+	return file->f_op->splice_read &&
+	       file->f_op->splice_read != copy_splice_read &&
+	       !IS_DAX(file_inode(file));
+}
+
 __be32		nfsd_read(struct svc_rqst *rqstp, struct svc_fh *fhp,
 				loff_t offset, unsigned long *count,
 				u32 *eof);
-- 
2.53.0

