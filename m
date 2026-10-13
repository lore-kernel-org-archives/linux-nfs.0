Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id A2EBC502769
	for <linux-nfs@vger.kernel.org>; Tue, 13 Oct 2026 12:50:00 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1791895802; cv=none; b=VbBuW2+gH9JFlomtXnxrcipOLTTwN7qqa4JPmwlh89j8HLl4tzAcFJBTghZm3bPFqtJnYBeFftTn2Ue2x63CfB6RODRlhvRRPtVHM7EzzLvgMQOhQZT0FHOrebBQ6QuNIbX4Kde2B8cu2BU8bzw3/9w1bcFzgbDFxQn9gKx0afY=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1791895802; c=relaxed/simple;
	bh=4Du7Z/Vw8r/Ol9u3nWb0CyORFTL68tgU3gmWRMgWGVc=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=R2qtW/08/YFzSsPmHpmxE415Y98NljzDqNKcRHMi7uvObFr2vZ9IWzSQnU9BY5/hzxBFQB5GW3fBA34MEW+g1UUoi7WwzDLgOAOA6AA6M9oap+9AHQf+FV1I8mJPfgmmdFYVqrtYoKfjW/ZIBYFu4PAtHhRJdtEqiR8wprHK7Yc=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=Kc8TR+CA; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="Kc8TR+CA"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id CBF821F00899;
	Tue, 13 Oct 2026 12:49:59 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1791895800;
	bh=FJNFy3afFxPfa6EfNQ+c5fXwGQmOY//C5AuIpfLWgDM=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=Kc8TR+CA13/apRB0Nl3vw9gSYj7ytyP3N8dI8NpfvdUv04vOpTrroleKBFI6kgH/6
	 2sJVIy14wRWGw9/7eEWviKSWcid84HIMFqVSkT+ifBdq1E6k/4dmIgB1KGHgLQFFTq
	 I3lEbU0h0qcYPSUrafKODXlihaXF1SzZx7b1D6K+yu52ZY1kdqp1ylP1qRnTnMTyqx
	 wddbBfU+rv5a0X7RdySe8uzLlXmIzl8h40a8ZPCazAbPW48kkk+GNPRNrUh13bcDxk
	 O/gabxsN5VhB4DUZ0f3knCfgSBVSxsyUuhB41RiqhJ8s9t97e5awstqAcRrIa89pv3
	 GYn4hflH8gh3Q==
From: Chuck Lever <cel@kernel.org>
To: NeilBrown <neil@brown.name>,
	Jeff Layton <jlayton@kernel.org>,
	Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <dai.ngo@oracle.com>,
	Tom Talpey <tom@talpey.com>
Cc: <linux-nfs@vger.kernel.org>
Subject: [PATCH v3 34/34] SUNRPC: Remove svc_fill_symlink_pathname()
Date: Tue, 13 Oct 2026 08:49:55 -0400
Message-ID: <20261013124955.316849-5-cel@kernel.org>
X-Mailer: git-send-email 2.55.0
In-Reply-To: <20261013124955.316849-1-cel@kernel.org>
References: <20261013124955.316849-1-cel@kernel.org>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

The NFSv2 and NFSv3 SYMLINK procedures copy the target pathname out
of a struct xdr_buf with nfsd_symlink_target(), so
svc_fill_symlink_pathname() has no callers left. Remove it.

Signed-off-by: Chuck Lever <cel@kernel.org>
---
 include/linux/sunrpc/svc.h |  3 ---
 net/sunrpc/svc.c           | 50 --------------------------------------
 2 files changed, 53 deletions(-)

diff --git a/include/linux/sunrpc/svc.h b/include/linux/sunrpc/svc.h
index a47f05fc6a12..a7039ec035fa 100644
--- a/include/linux/sunrpc/svc.h
+++ b/include/linux/sunrpc/svc.h
@@ -492,9 +492,6 @@ const char *	   svc_proc_name(const struct svc_rqst *rqstp);
 int		   svc_encode_result_payload(struct svc_rqst *rqstp,
 					     unsigned int offset,
 					     unsigned int length);
-char		  *svc_fill_symlink_pathname(struct svc_rqst *rqstp,
-					     struct kvec *first, void *p,
-					     size_t total);
 __be32		   svc_generic_init_request(struct svc_rqst *rqstp,
 					    const struct svc_program *progp,
 					    struct svc_process_info *procinfo);
diff --git a/net/sunrpc/svc.c b/net/sunrpc/svc.c
index 7e23af94a719..5c21ec585cd0 100644
--- a/net/sunrpc/svc.c
+++ b/net/sunrpc/svc.c
@@ -1883,53 +1883,3 @@ int svc_encode_result_payload(struct svc_rqst *rqstp, unsigned int offset,
 							   length);
 }
 EXPORT_SYMBOL_GPL(svc_encode_result_payload);
-
-/**
- * svc_fill_symlink_pathname - Construct pathname argument for VFS symlink call
- * @rqstp: svc_rqst to operate on
- * @first: buffer containing first section of pathname
- * @p: buffer containing remaining section of pathname
- * @total: total length of the pathname argument
- *
- * The VFS symlink API demands a NUL-terminated pathname in mapped memory.
- * Returns pointer to a NUL-terminated string, or an ERR_PTR. Caller must free
- * the returned string.
- */
-char *svc_fill_symlink_pathname(struct svc_rqst *rqstp, struct kvec *first,
-				void *p, size_t total)
-{
-	size_t len, remaining;
-	char *result, *dst;
-
-	result = kmalloc(total + 1, GFP_KERNEL);
-	if (!result)
-		return ERR_PTR(-ESERVERFAULT);
-
-	dst = result;
-	remaining = total;
-
-	len = min_t(size_t, total, first->iov_len);
-	if (len) {
-		memcpy(dst, first->iov_base, len);
-		dst += len;
-		remaining -= len;
-	}
-
-	if (remaining) {
-		len = min_t(size_t, remaining, PAGE_SIZE);
-		memcpy(dst, p, len);
-		dst += len;
-	}
-
-	*dst = '\0';
-
-	/* Sanity check: Linux doesn't allow the pathname argument to
-	 * contain a NUL byte.
-	 */
-	if (strlen(result) != total) {
-		kfree(result);
-		return ERR_PTR(-EINVAL);
-	}
-	return result;
-}
-EXPORT_SYMBOL_GPL(svc_fill_symlink_pathname);
-- 
2.55.0

