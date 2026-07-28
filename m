Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 09150392C36
	for <linux-nfs@vger.kernel.org>; Tue, 28 Jul 2026 16:59:16 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1785257958; cv=none; b=F5SfKejE7xMO6TQA4ystq4Q92K/peVoatIs5sWk6L+RNaVOJtXPAysxmHzKDgVQfFIw7/izWZK34+l4f7S9xT+pxq8pkSR/NysP0wMhCfMCNT/fjV+XoyLDj/KBBcmO+oTc6Hg/E9nZ2lP9yJ2KtS8jVPA68qFikC0ZM4O18ay0=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1785257958; c=relaxed/simple;
	bh=9yxKKw1AbvpXv0+1asikklpm/hp5/xfxWDPal66XPy0=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=ugKzVwINzqiV0Bulak+bmPEdxgyS8KPhIjJSrO8uKPamJ8N9fkzPe1cY+2Nr2wQCejmErgiiC4tyHrqzpiIpXCqB1segzwAZjyXr62r5gREyfQjOKVvphWkecPWyWQZ9W5Vc6F0AnVK4KkuiBPyIDW4cw3pVqWYV6SR0V3ilY/0=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=FE9cSjXl; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="FE9cSjXl"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 2C5E61F00A3E;
	Tue, 28 Jul 2026 16:59:16 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1785257956;
	bh=jo8acNkZBwVCV8NzBrhhIpz+95OvLgm8jMSmOcXCHZs=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=FE9cSjXlVDbaCmsCJ5tIgEI8qLGJC22BMEBWlqlnFqTrKdQt/9fllKHvar4+T7OVX
	 InZ/mLK82xHggLtqUB88XBcAsMtaknPmRjcVW9tUiCA1s7wV+9Aw4Us7IF8W58Tdk0
	 Yvhjn3imXHOG+JhYFZRpGs42QDFC5oGj4QNB8Bd2wXggJgKLRbtqoW5Z9Hu7g6M+Eq
	 E/stj8mrNboxV6V6WTm5AJKRw8QYUZ1GnwGSDld8MD5NF1dFPJUrO1z0lhi44mTPWn
	 KgD/w+bGc12+sOEtciUENqBT7ZzmOyoyl/AKxqiEp+T2psx3RmHhnVFL3Q8UMicsYk
	 ces7LH8AAho6Q==
From: Chuck Lever <cel@kernel.org>
To: NeilBrown <neil@brown.name>,
	Jeff Layton <jlayton@kernel.org>,
	Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <dai.ngo@oracle.com>,
	Tom Talpey <tom@talpey.com>
Cc: <linux-nfs@vger.kernel.org>
Subject: [PATCH v2 4/5] NFSD: Name the fh_maxsize value that carries no NFS version
Date: Tue, 28 Jul 2026 12:59:10 -0400
Message-ID: <20260728165911.462534-5-cel@kernel.org>
X-Mailer: git-send-email 2.54.0
In-Reply-To: <20260728165911.462534-1-cel@kernel.org>
References: <20260728165911.462534-1-cel@kernel.org>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

nfsd_set_fh_dentry() selects behavior specific to an NFS protocol
version by matching fh_maxsize against NFS_FHSIZE, NFS3_FHSIZE, or
NFS4_FHSIZE. A filehandle that reaches NFSD outside an NFS request has
no such version. nlm_fopen() opts out of the switch by passing a bare
0, which matches no arm, and the literal says nothing about why, so an
adjacent comment has to carry it.

Signed-off-by: Chuck Lever <cel@kernel.org>
---
 fs/nfsd/lockd.c |  3 +--
 fs/nfsd/nfsfh.c |  2 ++
 fs/nfsd/nfsfh.h | 14 ++++++++++++++
 3 files changed, 17 insertions(+), 2 deletions(-)

diff --git a/fs/nfsd/lockd.c b/fs/nfsd/lockd.c
index f5a4f352f8ab..5ec0f5456063 100644
--- a/fs/nfsd/lockd.c
+++ b/fs/nfsd/lockd.c
@@ -34,8 +34,7 @@ static int nlm_fopen(struct svc_rqst *rqstp, struct nfs_fh *f,
 	int		access;
 	struct svc_fh	fh;
 
-	/* must initialize before using! but maxsize doesn't matter */
-	fh_init(&fh,0);
+	fh_init(&fh, NFSD_FHSIZE_UNSPEC);
 	fh.fh_handle.fh_size = f->size;
 	memcpy(&fh.fh_handle.fh_raw, f->data, f->size);
 	fh.fh_export = NULL;
diff --git a/fs/nfsd/nfsfh.c b/fs/nfsd/nfsfh.c
index fd721a5a6b37..b1f3c22af525 100644
--- a/fs/nfsd/nfsfh.c
+++ b/fs/nfsd/nfsfh.c
@@ -335,6 +335,8 @@ static __be32 nfsd_set_fh_dentry(struct svc_rqst *rqstp, struct net *net,
 	}
 
 	switch (fhp->fh_maxsize) {
+	case NFSD_FHSIZE_UNSPEC:
+		break;
 	case NFS4_FHSIZE:
 		if (dentry->d_sb->s_export_op->flags & EXPORT_OP_NOATOMIC_ATTR)
 			fhp->fh_no_atomic_attr = true;
diff --git a/fs/nfsd/nfsfh.h b/fs/nfsd/nfsfh.h
index ab15b59ac7b3..7d8e3f015307 100644
--- a/fs/nfsd/nfsfh.h
+++ b/fs/nfsd/nfsfh.h
@@ -246,6 +246,20 @@ fh_copy_shallow(struct knfsd_fh *dst, const struct knfsd_fh *src)
 	memcpy(&dst->fh_raw, &src->fh_raw, src->fh_size);
 }
 
+#define NFSD_FHSIZE_UNSPEC	0
+
+/**
+ * fh_init - Prepare a file handle for fh_compose() or fh_verify()
+ * @fhp: File handle to initialize
+ * @maxsize: Largest file handle, in bytes, to build in @fhp
+ *
+ * @maxsize bounds the handle fh_compose() may build: NFS_FHSIZE,
+ * NFS3_FHSIZE, and NFS4_FHSIZE additionally select version-specific
+ * handling in fh_verify(). Callers that only verify an incoming
+ * handle pass NFSD_FHSIZE_UNSPEC, which cannot be composed.
+ *
+ * Return: @fhp
+ */
 static __inline__ struct svc_fh *
 fh_init(struct svc_fh *fhp, int maxsize)
 {
-- 
2.54.0

