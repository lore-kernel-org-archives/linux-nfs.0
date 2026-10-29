Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793275546;
	b=cE+2m1g6saVuqqTW1gZ/fQ0LoZIbMnINDk5InnpGIqwHZyTXrEowzR1Bb879iRq7MiWi
	 arqMX3haA7T/fMsxx2uL8hvzcOsj1f9zyneMrcV2qlCLy2Z3JDCaH02Xw0JqgVPJf5Fr7
	 oeR+/6HR7XaiOtqFHgdX6tUY5Cg5J4jSmfOcwXCBnC7A7XbRvxsoZU+mex4pWE2WBFdlC
	 m+fddfhpAmXfPpWME9q+bHSvo0mwGY5E6T/VO1D5OEVNzE/ag/NxMn57RKkqoyBLQ6Jax
	 fQVitNQiCr9fRBv0L1cEYMH/11HbiLZ64bzn6VDl18B0dfLYJJA3lYGz7qYb54VK70g==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793275546;
	h=Received:DKIM-Signature:From:Date:Subject:MIME-Version:Content-Type:
	 Content-Transfer-Encoding:Message-Id:References:In-Reply-To:To:Cc:
	 X-Mailer:X-Developer-Signature:X-Developer-Key;
	bh=Xp5Z6NBRUna+X+Nwp4QLQcBmqe140nsg4kc2CEFfGXU=;
	b=MpgnaJKYW8/t968d+i+UEx8hW1y7/4QdkJCLgsZiqRnIWnbsX4VSRzlK2dFwNh1HmCsM
	 i8vbtM5qwOcxQ4xmKaJw7b5MewUZcX7nOZbODu7wFsTkVXFZXGDZzLsu27qz9xRdNgErh
	 IsYx+Unxn5RohTdY4/SW/8aBujTPp/nAzpLAPsM/bLqyrCEfiZOsrvCw+1bEs+f5DaRyJ
	 tkhOcFpK4x4+2fdu5dCWMtOVyraVMU+8RnksWXjCyrUuQAar0Frsg6N2h0WW6NTylnaGn
	 2bvoKqnvSqfrOx5jERsmDUPCwnTduD0nJGA+pHjBoFr4ZUGx4QL0c1buMtSyXFLaEnw==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=DSBGjcZM;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id E0F96606A31A;
	Thu, 29 Oct 2026 12:05:45 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=DSBGjcZM
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 2E78B1F031E1;
	Thu, 29 Oct 2026 12:05:44 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1793275545;
	bh=Xp5Z6NBRUna+X+Nwp4QLQcBmqe140nsg4kc2CEFfGXU=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=DSBGjcZMksQW+jZTOZrOQfMChlkK72ylhLwqFrvZfW5jk/ax5rZbUeSbN0TgFfF3y
	 cxuN4jcYH77zMYS+JxhUuX2rIP/q5yFKxrjLvayXGsA6IDKRCA9LCjSku9vBKhME+j
	 bWjwr+mMxR+OE+PUuBo3pW6su9+PMohl06MR2wzBOM8gaVU+QvM0NdSoy7VJgGN49j
	 ufGpHqWRYpVw8JxGKmJQKLFh4crx9u1AbKaMOxmHX/BIVUOvXZiizye4mSSx3JgUWq
	 e8n/Mim2P4mKnGFLOL2FS7dnLGaxERn/C7Dk6BQgibOuxwvH1NNffN5WoKj5hN0aHj
	 ffrj2pICXijnQ==
From: Jeff Layton <jlayton@kernel.org>
Date: Thu, 29 Oct 2026 08:05:18 -0400
Subject: [PATCH v2 5/6] NFSD: Count the storage reads of each export's
 READs
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
Message-Id: <20261029-export-iomode-v2-5-fe8ec6251a36@kernel.org>
References: <20261029-export-iomode-v2-0-fe8ec6251a36@kernel.org>
In-Reply-To: <20261029-export-iomode-v2-0-fe8ec6251a36@kernel.org>
To: Donald Hunter <donald.hunter@gmail.com>, 
 Jakub Kicinski <kuba@kernel.org>, "David S. Miller" <davem@davemloft.net>, 
 Eric Dumazet <edumazet@kernel.org>, Paolo Abeni <pabeni@redhat.com>, 
 Simon Horman <horms@kernel.org>, Chuck Lever <cel@kernel.org>, 
 NeilBrown <neil@brown.name>, Olga Kornievskaia <okorniev@redhat.com>, 
 Dai Ngo <Dai.Ngo@oracle.com>, Tom Talpey <tom@talpey.com>, 
 Trond Myklebust <trondmy@kernel.org>, Anna Schumaker <anna@kernel.org>, 
 Jonathan Corbet <corbet@lwn.net>, Shuah Khan <skhan@linuxfoundation.org>, 
 Randy Dunlap <rdunlap@infradead.org>
Cc: Steve Dickson <steved@redhat.com>, netdev@vger.kernel.org, 
 linux-kernel@vger.kernel.org, linux-nfs@vger.kernel.org, 
 linux-doc@vger.kernel.org, Jeff Layton <jlayton@kernel.org>
X-Mailer: b4 0.14.3
X-Developer-Signature: v=1; a=openpgp-sha256; l=6660; i=jlayton@kernel.org;
 h=from:subject:message-id; bh=dQERPU3OneW2TFDnT8M0DRvQJt9QKP7O5oyeTHTbcLA=;
 b=owEBbQKS/ZANAwAKAQAOaEEZVoIVAcsmYgBq4zaOIU2AclDnmrsC/bX1K5gWNN64Ftl8rvy5d
 b2zmDR7r3aJAjMEAAEKAB0WIQRLwNeyRHGyoYTq9dMADmhBGVaCFQUCauM2jgAKCRAADmhBGVaC
 FWy4EACTGnea+ZxGQRS3EiAhcdUdwKOhLrUuzsnopDjRJsckN6DxxLtmZFnf2rCv5r1OISsPose
 i2z4ysEH+dfTXuUZg6wCAPUustABlM7l9fMf5DkR/j65FhWYXehkggHtlupaibInCkyrEhiaZFj
 EbW28N+Qy1LeK3QJGK53lTg7WRrj7scyCdVnr1b0nORHOY7S4DLyK6SMXDcSoj/+9AjxPdimdGZ
 2N096LuXIU44pqXI3O1m0anWVyOJa3PRYx+a6XR0T4Mtdg+Tfh2AIdi1xf+39o1dKWMsqc6Zx6V
 KyirMFLavFUumSZH4L8p7GqczCBv6M6buQL8zVs9QDbicHbjT24ZjYR/IzSHhpdqEbsNdwBcp04
 pxxTQMGJUMEB/63Fudypf0LooMV8+bJYViGnWGkjrePCL2L4tjXkniXyVlBnzI3AyzK2cJeoeHW
 Z9z1K5Y8buNFWhRwBa6YPuIlpKE3vdQmsubv9Sb1IWkxZARo6/9uvpMdi5UH4ns42hKy6T2BbC8
 s/MH/YwqA13ROubrkh3FRXHZgN/8UZpI00N9UXFVFDi8zWiEukW+wF5q22hjihwFazfh8IrwW1B
 Rcui/xuLBgK8pkg7GBO9VgJGSP17mF30piAZgJ+c5djYVRFQt0v8XOfyqdS064TU/yjHHICmLrb
 3FWUeQT47Z1kiQQ==
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
index 2b83f2836b0e..3971bcee4214 100644
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
index b9306a360c19..dcff16618edf 100644
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
index 779ad3a61172..a8cf41e4dfea 100644
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

