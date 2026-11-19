Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1795113242;
	b=vO/T8Vh/tUcWddhODeTKh/i8OOnlc5yz6fgK7UVAmZFev5S0kM9df+Z9OVWbt77qSBuL
	 dwMu6P8TxDDYtV5TQhKwLp2JJj02sTPqk6T7rGTjGzvu7aVPEe+ho6aBPfPSbTsASZgKb
	 SX5Gc2IUWJg85ujblbsUQJ2jtrXJ2EjME1HFXYZd4sy39ZJCrimCUoNFaZ4gZeM3wKkiT
	 lNUkF4gDo1n1jGolnOnm7hx35tw2ZK69Yu7AdZpIGrQACYQWYW8MY8mB57yFUAJhCvtD3
	 aI60hG3Czm7UxRQ147oIO61TA0hGLAPeIta5eZl+U+XE7C4aKpqOFvll5CTiTZD+GTg==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1795113242;
	h=Received:DKIM-Signature:From:Date:Subject:MIME-Version:Content-Type:
	 Content-Transfer-Encoding:Message-Id:References:In-Reply-To:To:Cc:
	 X-Mailer:X-Developer-Signature:X-Developer-Key;
	bh=VMsYh+cFWAaf9TlbvGPzbJ644hZHGiTMaPoUd31Ceyk=;
	b=u267r/ELDUEB9RnajdljOkgbQI2gxgXq65Kb5zV15es+sjobFBejjXiJJUTwGDlItDus
	 B6yMhBiAw97JzEYypkVs8VT5Qn3iMNmkV+pEpxCdGnWl3dAJy/hvTGD2t1YybOrmpLuYY
	 fh0KPWEUoCI39H/VXuVS4s36IrI42updGAb7sG6A9C/uF9cqxwG8VwoyfIXp0nD5BERTg
	 rWmQA75XiRxDxGmqf/mpFvzFoJ8BPtf89H7E94AaCd8jUJl9uzCJuwItzOUSzrIkpiBFc
	 8qfdeK7tMYmh/LIA/3ZJHL0PQPTg4EZ2/xCcCJuWfMcuM6jP9qKgZk5LnmPnK31vdkw==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=WrupZ94E;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 850CF606A337
	for <linux-nfs@vger.kernel.org>; Thu, 19 Nov 2026 18:34:02 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=WrupZ94E
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 10A441F000CA;
	Thu, 19 Nov 2026 18:34:02 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1795113242;
	bh=VMsYh+cFWAaf9TlbvGPzbJ644hZHGiTMaPoUd31Ceyk=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=WrupZ94EvHn9fd8iAJligqk0q6TyUwtC+iP5wwqnAauVeGnL3JgLJVNakIfafcrBs
	 V08cOJaSeFm0qs2j99mP6+3qAKXW8HAxxXxhdODihoGc+XibHNBjmIcXzy90SCZO+U
	 jjxEEDWIuFfiPP1reWDgQhSYRNl7AcSWxVBQ+NPURggbUuyxk+S4hhn3jgrg9sLXcc
	 KuQJYfYny2WD++CfMiNZBaXNLhMYruXX5OFevpGn/JEN+dRqAAUR3mV+EFiCG6UAdg
	 7cXKdOC9Hv/CYKv0o91//j1cHHR2qWSziBiU5c1PUlgxKFVZB+4kZGwQGudtF32QNs
	 EhNNCVGMefgYw==
From: Chuck Lever <cel@kernel.org>
Date: Thu, 19 Nov 2026 13:33:54 -0500
Subject: [PATCH 4/4] NFSD: Remove the svc_rqst argument from
 proc_layoutcommit
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
Message-Id: <20261119-blocklayout-decode-stream-v1-4-d71322f42c28@kernel.org>
References: <20261119-blocklayout-decode-stream-v1-0-d71322f42c28@kernel.org>
In-Reply-To: <20261119-blocklayout-decode-stream-v1-0-d71322f42c28@kernel.org>
To: Chuck Lever <cel@kernel.org>, Christoph Hellwig <hch@lst.de>, 
 Jeff Layton <jlayton@kernel.org>, NeilBrown <neil@brown.name>, 
 Olga Kornievskaia <okorniev@redhat.com>, Dai Ngo <Dai.Ngo@oracle.com>, 
 Tom Talpey <tom@talpey.com>, Sergey Bashirov <sergeybashirov@gmail.com>, 
 Konstantin Evtushenko <koevtushenko@yandex.com>
Cc: linux-nfs@vger.kernel.org
X-Mailer: b4 0.17-dev-9c833
X-Developer-Signature: v=1; a=openpgp-sha256; l=3219; i=cel@kernel.org;
 h=from:subject:message-id; bh=d0LAXiTTXiErMKIieXWelhfte7YjWBVshjj+gA6yitQ=;
 b=owEBbQKS/ZANAwAKATNqszNvZn+XAcsmYgBq/0EX2I8Y+SR5hUTlA6WageZfdhYJ1lVWqNxLJ
 xNyNLIlm/aJAjMEAAEKAB0WIQQosuWwEobfJDzyPv4zarMzb2Z/lwUCav9BFwAKCRAzarMzb2Z/
 l+jND/9eliHOZWtbn6/eiSHbE5yOmftXh3rXsxEItdOjWSZ22RZWKFqX0rkhueP06CPvez4qoOx
 gctmFC1JKmrTjbE6ndfh+OW6lLRl81Eakdi13USy6N9VCJZb7/Pg2xcwa6tbbM8FkluUZsKSYBd
 Hd/7IOxb40QhjdyWHgjzB3tQoSs9guK88ZvhvOyUHP3wyk3skLkCon4tYMAILrwFiI4HlSy2y+y
 rkhuZUdHtoso9pZw5cY+AmfmzT5Qck6nIca02O5VTYjEZkDVQMKQxdl046Y3XsmDuAzd2j3POE3
 oACRvYDpa7qafD3HytV4M1tM3yQyaleu2rwLXtdH+aEl9DHD4ASN2r5VtYhXJ4GQxrUlFBRn1U6
 Z+xDoeU3XR1iVCH1x8R6LjTG9PT4rQGB+05LOx+Hfv5HLqXZQe+Zzp/WuBrnjKVWheWbmzQQt4y
 hDw38deZSRo8VRqTAyMp3w3YWvdjeV+XeRIJx37IrgieFYBOSCEd+YdsR/n45Cq0aOn+zlPoBMN
 Pz+wN3s8lHW9PQgvs0N13S/oOrGmcK5cBZ80ZXB7UwaqastyW5Zo4+Jgj1RK3lI7s+dVl5NokvJ
 lOepwFTJNexHHr+N30M5qSqxzDVkQ90V3pySLZBU51pwne0/QezLRzN6hgfjE58coa2rNxfqfNZ
 9e0653VYM9DeMUQ==
X-Developer-Key: i=cel@kernel.org; a=openpgp;
 fpr=28B2E5B01286DF243CF23EFE336AB3336F667F97

Commit f963cf2b91a3 ("NFSD: Implement large extent array support in
pNFS") added an svc_rqst argument to the proc_layoutcommit layout
operation so the block and SCSI layout drivers could decode the
layoutupdate4 body with rq_arg_stream. Those drivers decode from a
local xdr_stream, and no proc_layoutcommit implementation reads the
svc_rqst. Leaving the argument in place invites a layout driver to
borrow rq_arg again.

Remove the svc_rqst argument from the operation and from its three
implementations.

Signed-off-by: Chuck Lever <cel@kernel.org>
---
 fs/nfsd/blocklayout.c    | 8 ++++----
 fs/nfsd/flexfilelayout.c | 4 ++--
 fs/nfsd/nfs4proc.c       | 2 +-
 fs/nfsd/pnfs.h           | 3 +--
 4 files changed, 8 insertions(+), 9 deletions(-)

diff --git a/fs/nfsd/blocklayout.c b/fs/nfsd/blocklayout.c
index c3b614b25278..23f2365787eb 100644
--- a/fs/nfsd/blocklayout.c
+++ b/fs/nfsd/blocklayout.c
@@ -266,8 +266,8 @@ nfsd4_block_proc_getdeviceinfo(struct super_block *sb,
 }
 
 static __be32
-nfsd4_block_proc_layoutcommit(struct inode *inode, struct svc_rqst *rqstp,
-		struct nfsd4_layoutcommit *lcp)
+nfsd4_block_proc_layoutcommit(struct inode *inode,
+			      struct nfsd4_layoutcommit *lcp)
 {
 	__be32 scratch[XDR_QUADLEN(NFS4_DEVICEID4_SIZE)];
 	struct xdr_stream xdr;
@@ -461,8 +461,8 @@ nfsd4_scsi_proc_getdeviceinfo(struct super_block *sb,
 	return nfserrno(nfsd4_block_get_device_info_scsi(sb, clp, gdp));
 }
 static __be32
-nfsd4_scsi_proc_layoutcommit(struct inode *inode, struct svc_rqst *rqstp,
-		struct nfsd4_layoutcommit *lcp)
+nfsd4_scsi_proc_layoutcommit(struct inode *inode,
+			     struct nfsd4_layoutcommit *lcp)
 {
 	__be32 scratch[XDR_QUADLEN(NFS4_DEVICEID4_SIZE)];
 	struct xdr_stream xdr;
diff --git a/fs/nfsd/flexfilelayout.c b/fs/nfsd/flexfilelayout.c
index 0deb913493a3..c97caeec4024 100644
--- a/fs/nfsd/flexfilelayout.c
+++ b/fs/nfsd/flexfilelayout.c
@@ -130,8 +130,8 @@ nfsd4_ff_proc_getdeviceinfo(struct super_block *sb, struct svc_rqst *rqstp,
 }
 
 static __be32
-nfsd4_ff_proc_layoutcommit(struct inode *inode, struct svc_rqst *rqstp,
-		struct nfsd4_layoutcommit *lcp)
+nfsd4_ff_proc_layoutcommit(struct inode *inode,
+			   struct nfsd4_layoutcommit *lcp)
 {
 	return nfs_ok;
 }
diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index 71d6a473c1bc..2f25acb1ac92 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -3119,7 +3119,7 @@ nfsd4_layoutcommit(struct svc_rqst *rqstp,
 		mutex_unlock(&ls->ls_mutex);
 	}
 
-	nfserr = ops->proc_layoutcommit(inode, rqstp, lcp);
+	nfserr = ops->proc_layoutcommit(inode, lcp);
 
 	if (!lcp->lc_reclaim) {
 		nfsd4_file_mark_deleg_written(ls->ls_stid.sc_file);
diff --git a/fs/nfsd/pnfs.h b/fs/nfsd/pnfs.h
index e5f2e11c880a..a3d558ccdbdf 100644
--- a/fs/nfsd/pnfs.h
+++ b/fs/nfsd/pnfs.h
@@ -38,8 +38,7 @@ struct nfsd4_layout_ops {
 			const struct nfsd4_layoutget *lgp);
 
 	__be32 (*proc_layoutcommit)(struct inode *inode,
-			struct svc_rqst *rqstp,
-			struct nfsd4_layoutcommit *lcp);
+				    struct nfsd4_layoutcommit *lcp);
 
 	bool (*fence_client)(struct nfs4_layout_stateid *ls,
 			     struct nfsd_file *file);

-- 
2.56.0

