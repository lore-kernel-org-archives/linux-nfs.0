Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793119544;
	b=vT+biiHu1Cr8MRSTZxODR/YP2TaB0OUl/VKwGGcVK3zcL7CKbnHvQyrkMvM2OkbCXQG7
	 DBn6Q3I3PLQYnGL1CcJ3eC3PVJSOSKCN+WvplCVIpp5emx5craiYgj9ad8fzfyqUzKOIL
	 ran/C8Nzt3XVDwzGnqyUMrUKxjTXz773Nx9PI3AmqAeJxEjw4s1SG4BqSP6/fi83K1QXn
	 moFEOVyqpyoaBGJf929CJvUz2eJLGeA0LMrcGKbWPL0jyw7zEwcKTcusQMZKNeTpQ6Qnf
	 IqKHZril5dbOkOZRFQhTgxf86NXGqysywBmXK0juKqrUDuvjL6Wlt2fdBiNMS2x9HGg==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793119544;
	h=Received:DKIM-Signature:From:Date:Subject:MIME-Version:Content-Type:
	 Content-Transfer-Encoding:Message-Id:References:In-Reply-To:To:Cc:
	 X-Mailer:X-Developer-Signature:X-Developer-Key;
	bh=SGnAeEJtwr9Yoy5Zw0n4C0o33tupYb4DQ6IAzxJuSiE=;
	b=mUMuer31msrL3QyYyu9O0uPIXNi916n+PvnwvEb5bPQVZ4iN2ktXb3SDdjU6g9WyFXwp
	 CSPHrndi7bRL3izS3I+D/umhoAT698jKo+aoFqGHN9F8doDPEHooFbQD2UzRyAu4v5GeN
	 4pob8JoYcOyGf1OUBCBotaDeQ5KedmKh7tp7Srk+dGmaJbXzSTcg3rdK5D5yyFnneesAD
	 iT2ZlbjJPY8mNI1TIbY4RsiQ/dyxwSP4iz4UjjumRopsoAPRHjGvbIUqTscqmRjentEh5
	 HW2uN1RGm2uftIjNuBe6/yH/JPMl2BLk6vYf/a3W7a4NuuMeUpV18nIpkbkf/rh4LiQ==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=mVh4d5W0;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 5E23360A262D;
	Tue, 27 Oct 2026 16:45:44 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=mVh4d5W0
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 573741F01825;
	Tue, 27 Oct 2026 16:45:42 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1793119544;
	bh=SGnAeEJtwr9Yoy5Zw0n4C0o33tupYb4DQ6IAzxJuSiE=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=mVh4d5W0q4Dbf1L7ffg8IJI3s/8B3BCfat2ocxBjVPHVwPzCqNsgCy2Qc7yhg9GA+
	 1Olfeymkr4eLb+cEmJDcWLPMslXiMG6W5yRzPSbdVIPkwBuXCXUWozP7FWe30qTQvq
	 HTVS41x0XGWacsp7YTfKXv0z3eY/zrnyjTsW84wLsUPBDKF6YnNUBMwg9QzHQbZV/9
	 e/PwGuCL6SPRRZDnKlgrkIYs8P5haYobnLjLjmcraV0paHgkCmIkCn4sca3z1txoM2
	 gzcEluzh8EqtK2CLHmuyhqfJrcqYPM77RM+3VJreoXnTiMU+fqnVqSevjRfPrA5mdq
	 ODjYMshCX6u9A==
From: Jeff Layton <jlayton@kernel.org>
Date: Tue, 27 Oct 2026 12:45:28 -0400
Subject: [PATCH 5/6] NFSD: Count the storage reads of each export's READs
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20261027-export-iomode-v1-5-262ed932a036@kernel.org>
References: <20261027-export-iomode-v1-0-262ed932a036@kernel.org>
In-Reply-To: <20261027-export-iomode-v1-0-262ed932a036@kernel.org>
To: Chuck Lever <cel@kernel.org>, NeilBrown <neil@brown.name>, 
 Olga Kornievskaia <okorniev@redhat.com>, Dai Ngo <Dai.Ngo@oracle.com>, 
 Tom Talpey <tom@talpey.com>, Trond Myklebust <trondmy@kernel.org>, 
 Anna Schumaker <anna@kernel.org>, Jonathan Corbet <corbet@lwn.net>, 
 Shuah Khan <skhan@linuxfoundation.org>, 
 Randy Dunlap <rdunlap@infradead.org>, Mike Snitzer <snitzer@kernel.org>, 
 Donald Hunter <donald.hunter@gmail.com>, Jakub Kicinski <kuba@kernel.org>, 
 "David S. Miller" <davem@davemloft.net>, Eric Dumazet <edumazet@kernel.org>, 
 Paolo Abeni <pabeni@redhat.com>, Simon Horman <horms@kernel.org>
Cc: Steve Dickson <steved@redhat.com>, netdev@vger.kernel.org, 
 linux-kernel@vger.kernel.org, linux-nfs@vger.kernel.org, 
 linux-doc@vger.kernel.org, Jeff Layton <jlayton@kernel.org>
X-Mailer: b4 0.14.3
X-Developer-Signature: v=1; a=openpgp-sha256; l=6660; i=jlayton@kernel.org;
 h=from:subject:message-id; bh=YyvZ3RTnwx2CgAAHzAXV0kbOQl3h6kIgIkXemtzl1+0=;
 b=owEBbQKS/ZANAwAKAQAOaEEZVoIVAcsmYgBq4NUsgf+8x5ooF0dVWUfXQzgbWcCY9EoV6iLgs
 NywwZdVsTmJAjMEAAEKAB0WIQRLwNeyRHGyoYTq9dMADmhBGVaCFQUCauDVLAAKCRAADmhBGVaC
 FULWEACgRdyzE3dSy5htdNdRZF8RGMVDjHtXuTn6AvJUgpiEFvdzbV0HES6ghyDsqRWGquoIE9Y
 7BjaSoZ/xAzvSziMT3rQwMtNgQHJuBqCppr2QwkrrzXbGNvqO688WfDK06x9xXhK9Gn8jJln9EW
 9GN0iCTZpp4r43N1WfBjOurOV6Q0WkHNWo2XIZF/GPXbeRn9T9FlSN0vr31Llvj3E1YVz4/BlFH
 nYyr7Y7lS3RY70LuazJRtzqmln76Ju4bvHVJZ1a7q+hYTzZE/chdPnNBK4QCSdPI4dJkmqlv4Vs
 b1e7UFa/5XIps7yixEILKIwBpOPAzvv7Np0DTxxxcNpCMvr8PWQbo059O4EAkJA/7VX3qvGHoei
 JZ/Jw8KFpBGrE19XRz18YWhQiaXshiKIXJVi3DRZril6ahVWIaG0Z2WzTFjOiZzQNxYaadVw3wK
 IMDUv6fQzoqDA2FAdtBYagV0UxuG1odVnnyElJWw09Vyr/2Yg70wCQ38Nm5t9K6RQNHCee3Z1m3
 fKOtUTePB46cCPMHZuhK2vBd8+/zscYLvJQitH22QHGH2dvNUPWeuOICvLgPP3/jIMcj8i4WkfT
 Hzz0012Y0uJ00LCBUBjB1tJLCeO4AH4YUFAfBv/I72m1+B3d66FYHFY7S8aYU9otNQO9hn+MhWo
 dLPLmL3/fgCfgFA==
X-Developer-Key: i=jlayton@kernel.org; a=openpgp;
 fpr=4BC0D7B24471B2A184EAF5D3000E684119568215

The page cache miss ratio of an export is the best indicator of the IO
mode that suits it, but NFSD reports only the bytes that READ returned.
Comparing that with the reads of the block device is approximate: the
device can hold other exports or local data, the count includes every
user of the device, and btrfs can span devices.

submit_bio() charges read bytes to the submitting task. Take a snapshot
of current->ioac.read_bytes when a READ starts, and add the difference
to a new io_read_storage counter of the export when it finishes. This
includes the readahead that the READ started and the metadata that it
needed, and works the same for buffered, dontcache, direct and splice
reads. export_stats shows the counter only with
CONFIG_TASK_IO_ACCOUNTING, so a missing counter means it is not
available.

Signed-off-by: Jeff Layton <jlayton@kernel.org>
---
 fs/nfsd/export.c |  4 ++++
 fs/nfsd/export.h |  1 +
 fs/nfsd/stats.h  | 33 +++++++++++++++++++++++++++++++++
 fs/nfsd/vfs.c    | 20 ++++++++++++++------
 4 files changed, 52 insertions(+), 6 deletions(-)

diff --git a/fs/nfsd/export.c b/fs/nfsd/export.c
index 640973d02b6c..ac2d71a9c562 100644
--- a/fs/nfsd/export.c
+++ b/fs/nfsd/export.c
@@ -1675,6 +1675,10 @@ static int svc_export_show(struct seq_file *m,
 			   export_stats_sum(stats, EXP_STATS_IO_READ));
 		seq_printf(m, "\tio_write: %lld\n",
 			   export_stats_sum(stats, EXP_STATS_IO_WRITE));
+		if (IS_ENABLED(CONFIG_TASK_IO_ACCOUNTING))
+			seq_printf(m, "\tio_read_storage: %lld\n",
+				   export_stats_sum(stats,
+						    EXP_STATS_IO_READ_STORAGE));
 		seq_putc(m, '\n');
 		return 0;
 	}
diff --git a/fs/nfsd/export.h b/fs/nfsd/export.h
index 70842782629f..8ecd43894bec 100644
--- a/fs/nfsd/export.h
+++ b/fs/nfsd/export.h
@@ -53,6 +53,7 @@ enum {
 	EXP_STATS_FH_STALE,
 	EXP_STATS_IO_READ,
 	EXP_STATS_IO_WRITE,
+	EXP_STATS_IO_READ_STORAGE,
 	EXP_STATS_COUNTERS_NUM
 };
 
diff --git a/fs/nfsd/stats.h b/fs/nfsd/stats.h
index aabfbb1a9c71..d88d2229a4c7 100644
--- a/fs/nfsd/stats.h
+++ b/fs/nfsd/stats.h
@@ -9,6 +9,7 @@
 
 #include <uapi/linux/nfsd/stats.h>
 #include <linux/percpu_counter.h>
+#include <linux/sched.h>
 
 #include "export.h"
 #include "netns.h"
@@ -97,6 +98,38 @@ static inline void nfsd_stats_io_write_add(struct nfsd_net *nn,
 					 amount);
 }
 
+/**
+ * nfsd_storage_read_bytes - bytes the current task has read from storage
+ *
+ * submit_bio() charges read bytes to the submitting task, so the change
+ * across a READ is what that READ, including the readahead it starts,
+ * read from storage instead of the page cache.
+ *
+ * Return: the task's storage read byte count, or zero without
+ * CONFIG_TASK_IO_ACCOUNTING.
+ */
+static inline u64 nfsd_storage_read_bytes(void)
+{
+#ifdef CONFIG_TASK_IO_ACCOUNTING
+	return current->ioac.read_bytes;
+#else
+	return 0;
+#endif
+}
+
+/**
+ * nfsd_stats_io_read_storage_add - Count storage bytes read for an NFS READ
+ * @exp: target export
+ * @amount: byte count
+ */
+static inline void nfsd_stats_io_read_storage_add(struct svc_export *exp,
+						  s64 amount)
+{
+	if (exp && exp->ex_stats && amount > 0)
+		percpu_counter_add_local(&exp->ex_stats->counter[EXP_STATS_IO_READ_STORAGE],
+					 amount);
+}
+
 static inline void nfsd_stats_payload_misses_inc(struct nfsd_net *nn)
 {
 	percpu_counter_inc(&nn->counter[NFSD_STATS_PAYLOAD_MISSES]);
diff --git a/fs/nfsd/vfs.c b/fs/nfsd/vfs.c
index 15613b6df290..50ef96292003 100644
--- a/fs/nfsd/vfs.c
+++ b/fs/nfsd/vfs.c
@@ -1113,8 +1113,11 @@ static u32 nfsd_eof_on_read(struct file *file, loff_t offset, ssize_t len,
 
 static __be32 nfsd_finish_read(struct svc_rqst *rqstp, struct svc_fh *fhp,
 			       struct file *file, loff_t offset,
-			       unsigned long *count, u32 *eof, ssize_t host_err)
+			       unsigned long *count, u32 *eof, ssize_t host_err,
+			       u64 storage_start)
 {
+	nfsd_stats_io_read_storage_add(fhp->fh_export,
+				       nfsd_storage_read_bytes() - storage_start);
 	if (host_err >= 0) {
 		struct nfsd_net *nn = net_generic(SVC_NET(rqstp), nfsd_net_id);
 
@@ -1145,12 +1148,14 @@ __be32 nfsd_splice_read(struct svc_rqst *rqstp, struct svc_fh *fhp,
 			struct file *file, loff_t offset, unsigned long *count,
 			u32 *eof)
 {
+	u64 storage_start = nfsd_storage_read_bytes();
 	ssize_t host_err;
 
 	trace_nfsd_read_splice(rqstp, fhp, offset, *count);
 	host_err = vfs_splice_to_actor(file, offset, *count,
 				       nfsd_direct_splice_actor, rqstp);
-	return nfsd_finish_read(rqstp, fhp, file, offset, count, eof, host_err);
+	return nfsd_finish_read(rqstp, fhp, file, offset, count, eof, host_err,
+				storage_start);
 }
 
 /*
@@ -1168,7 +1173,7 @@ __be32 nfsd_splice_read(struct svc_rqst *rqstp, struct svc_fh *fhp,
 static noinline_for_stack __be32
 nfsd_direct_read(struct svc_rqst *rqstp, struct svc_fh *fhp,
 		 struct nfsd_file *nf, loff_t offset, unsigned long *count,
-		 struct page **page, u32 *eof)
+		 struct page **page, u32 *eof, u64 storage_start)
 {
 	u64 dio_start, dio_end;
 	unsigned long v, total;
@@ -1226,7 +1231,7 @@ nfsd_direct_read(struct svc_rqst *rqstp, struct svc_fh *fhp,
 	}
 
 	return nfsd_finish_read(rqstp, fhp, nf->nf_file, offset, count,
-				eof, host_err);
+				eof, host_err, storage_start);
 }
 
 static bool nfsd_direct_read_ok(struct svc_rqst *rqstp, struct svc_fh *fhp,
@@ -1324,6 +1329,7 @@ __be32 nfsd_iter_read(struct svc_rqst *rqstp, struct svc_fh *fhp,
 	struct page **page = buf->pages + (buf->page_len >> PAGE_SHIFT);
 	unsigned int base = buf->page_len & ~PAGE_MASK;
 	struct file *file = nf->nf_file;
+	u64 storage_start = nfsd_storage_read_bytes();
 	unsigned long v, total;
 	struct iov_iter iter;
 	struct kiocb kiocb;
@@ -1338,7 +1344,8 @@ __be32 nfsd_iter_read(struct svc_rqst *rqstp, struct svc_fh *fhp,
 	case NFSD_IO_DIRECT:
 		if (nfsd_direct_read_ok(rqstp, fhp, nf, offset, *count))
 			return nfsd_direct_read(rqstp, fhp, nf, offset,
-						count, page, eof);
+						count, page, eof,
+						storage_start);
 		fallthrough;
 	case NFSD_IO_DONTCACHE:
 		if (file->f_op->fop_flags & FOP_DONTCACHE)
@@ -1367,7 +1374,8 @@ __be32 nfsd_iter_read(struct svc_rqst *rqstp, struct svc_fh *fhp,
 				  kiocb.ki_flags);
 	iov_iter_bvec(&iter, ITER_DEST, rqstp->rq_bvec, v, *count - total);
 	host_err = vfs_iocb_iter_read(file, &kiocb, &iter);
-	return nfsd_finish_read(rqstp, fhp, file, offset, count, eof, host_err);
+	return nfsd_finish_read(rqstp, fhp, file, offset, count, eof, host_err,
+				storage_start);
 }
 
 /*

-- 
2.56.0

