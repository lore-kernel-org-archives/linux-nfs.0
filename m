Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1795113242;
	b=iPGpoxOaTVPWlSMIxp+y71nLNbTSVGlpA9THnMYXw1IxOvfaYAUYPajDH5xg7NGz+FYi
	 zZL7S4IvQHf7AbvdHhmuvBBJkip+RrqIJ6apjVwt+qvNRblKqW8kdSjO+b88A0PANKcaC
	 g6yc/X0CGMTcw2OaDgHsXSIrtjBOAXPTOsOJqv3iGBhD/4/F3RsJhb/NswGO7VUH52lSs
	 xBGpq7EcSSnw8K+6TAT/FZ/9uL/IvYTtGTZzZlHnZ3oK/0oQGytqaYEuRP9cqIjR06wkM
	 v2eU+CVEtYqEVOwP9EEMsh6QCRWvoGr5p0ycjhkAwuYVr1s7sjSR2GKgJpqigaf/T4Q==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1795113242;
	h=Received:DKIM-Signature:From:Date:Subject:MIME-Version:Content-Type:
	 Content-Transfer-Encoding:Message-Id:References:In-Reply-To:To:Cc:
	 X-Mailer:X-Developer-Signature:X-Developer-Key;
	bh=y+BRdjbWePXcFfBeBjuGk2GD8grx25SqTlJu+hOoWEk=;
	b=wLkaReNTrIhHhYmo3toHG9l/AYWLOMJ3C/gD6Or3RQdN4EOVdQ15D18vT+urYIaJMHth
	 q+YMz62bwiYwPGvRDTTL7er0sH1kk6C8rm4JSyADGVdbAwXIzmMMIzscbIL0KUxJgU8jW
	 Ovika3gPFFXZgrkrewZw7I55O+wbBo/cwAEHiCNDhmqz950D4kPiEGQVmch6u8zNTNB0B
	 BH6mxzD7a0lDYifqusCaPzZb4MMNu6A1GtJZqlAP2GK4ilkp7xXAHSlkaSwGb8s4ub24J
	 Tc6GeL8rvBJVhBZN4GQVcKzeU7ENkCvtGbns+fGkzX6J0QYy3f1fOr8cBMTwkaPPAtw==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=M6jh9KJY;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 11A8C606A33B
	for <linux-nfs@vger.kernel.org>; Thu, 19 Nov 2026 18:34:02 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=M6jh9KJY
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 963301F000C5;
	Thu, 19 Nov 2026 18:34:01 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1795113241;
	bh=y+BRdjbWePXcFfBeBjuGk2GD8grx25SqTlJu+hOoWEk=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=M6jh9KJYtdD7FloJUUMBU9GLSdlj192tGzVlbsqHqfm6b100CyDku32+oAAxr8hDL
	 8AzfgFw+MwFpSeck990C1PBxbdtGJlsh4Hk8r/5XFsOUDZoSn02WFMR4acjQZs6NJw
	 S8zDh2Mokk8MY7cOuA3IWNXq3QcHTofH1ly3nrFlRZ1EMRkHfC7URyA5hKhapQLlcE
	 FFXYDrwckDzM9EIurx2uo6FM02A71tfEg4b22HNij0lthYE09HqFXa7YuV0mHltMGT
	 qagiv38iKBon/iQkUn55N+KLgj6pUQixZYXy/gwu3uAdKFtgvRE5T2g/CL59RIPmst
	 7dNwPa1hUJtYQ==
From: Chuck Lever <cel@kernel.org>
Date: Thu, 19 Nov 2026 13:33:53 -0500
Subject: [PATCH 3/4] NFSD: Decode block and SCSI layoutupdates from a local
 xdr_stream
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
Message-Id: <20261119-blocklayout-decode-stream-v1-3-d71322f42c28@kernel.org>
References: <20261119-blocklayout-decode-stream-v1-0-d71322f42c28@kernel.org>
In-Reply-To: <20261119-blocklayout-decode-stream-v1-0-d71322f42c28@kernel.org>
To: Chuck Lever <cel@kernel.org>, Christoph Hellwig <hch@lst.de>, 
 Jeff Layton <jlayton@kernel.org>, NeilBrown <neil@brown.name>, 
 Olga Kornievskaia <okorniev@redhat.com>, Dai Ngo <Dai.Ngo@oracle.com>, 
 Tom Talpey <tom@talpey.com>, Sergey Bashirov <sergeybashirov@gmail.com>, 
 Konstantin Evtushenko <koevtushenko@yandex.com>
Cc: linux-nfs@vger.kernel.org
X-Mailer: b4 0.17-dev-9c833
X-Developer-Signature: v=1; a=openpgp-sha256; l=2555; i=cel@kernel.org;
 h=from:subject:message-id; bh=IPTHdNNxB7HoF+b15HWZBhCwHCmYX8PdpxsPgJOFwYg=;
 b=owEBbQKS/ZANAwAKATNqszNvZn+XAcsmYgBq/0EX4FutmPH2H6ZW1RB3paNue1WK+CZl0Pi1E
 tPSFG1ddVCJAjMEAAEKAB0WIQQosuWwEobfJDzyPv4zarMzb2Z/lwUCav9BFwAKCRAzarMzb2Z/
 lyHXD/0ZBF40v2gFSCZ8hLYMWo6WaclsPpQyDTAiTKYEi4e6b35cy8y/QmbhIev6erI40vTIVa8
 rJKsXiEXz1h2meU4JxjvCcRiIMODyC5axlgPBTYf21NGKpdrAVNi7Ys9JqwIrexcvhr5uQEd2V+
 yOIYaTdMnqfVj0H4oJHf/6/OtdaCLdVCoo54HHTq3E1rvQiBzZxuqJZbyHAI5HTjAiPC8XhZ/PS
 wsqlV9krkeHLdoMx/XqyuWK1I2dnHhdcoYQ0qt1CPSAAUfxKnAB/smc4EgCyZnoLKmunwYQ89rk
 pvKI0sdL9TZgnRN6RIuM/Cj4eEYzJnP1GlC4qshjijuQ1tDWze7ZPwnAx6m7qC4yOJt8gRB0w6A
 EQTxoC9u6ChTAN+IHv5ZcEnaegc4CRPwaSYCgy+RBkm0OQtgvxt1Wb3ss1X/DIawYqaxuMzYSPR
 7tAX+7WDBWJ3YLUvkx5Zh7FugFsWmw3VrPdBAo1wiEMbAKURhihpbJlludCWms8OUYIfG1soy4e
 D4yP5qxDY4X/ziHsdSLGrILY+nltgRC4tN6kRjpboOVGMstv8TzKXYPOffO/RJu/q2rtZI7akmn
 kn+lcGLCsH2FgQww+ChEIrzFNTAS+aFXYGgEb+xiZ81UptTHS+CQ1/IuKalXyoqFK7hOb35MBhW
 55hipmrPUIEE4Yw==
X-Developer-Key: i=cel@kernel.org; a=openpgp;
 fpr=28B2E5B01286DF243CF23EFE336AB3336F667F97

nfsd4_decode_layoutupdate4() leaves the body of a layoutupdate4
undecoded in lc_up_layout. nfsd4_block_proc_layoutcommit() and
nfsd4_scsi_proc_layoutcommit() decode that body during the pc_func
step by overwriting rqstp->rq_arg and re-initializing
rq_arg_stream. Nothing reads those fields after pc_decode today,
but the svc_rqst should be free to keep state in them until the
request completes.

Decode the layoutupdate4 body from an xdr_stream and scratch
buffer on the stack instead, leaving rq_arg and rq_arg_stream
untouched. Decoding layoutupdate4 during the pc_decode step would
be a better design, but that larger change is outside the scope
of this patch.

Signed-off-by: Chuck Lever <cel@kernel.org>
---
 fs/nfsd/blocklayout.c | 22 ++++++++++++++--------
 1 file changed, 14 insertions(+), 8 deletions(-)

diff --git a/fs/nfsd/blocklayout.c b/fs/nfsd/blocklayout.c
index 06564f247795..c3b614b25278 100644
--- a/fs/nfsd/blocklayout.c
+++ b/fs/nfsd/blocklayout.c
@@ -269,15 +269,18 @@ static __be32
 nfsd4_block_proc_layoutcommit(struct inode *inode, struct svc_rqst *rqstp,
 		struct nfsd4_layoutcommit *lcp)
 {
+	__be32 scratch[XDR_QUADLEN(NFS4_DEVICEID4_SIZE)];
+	struct xdr_stream xdr;
 	struct iomap *iomaps;
 	int nr_iomaps;
 	__be32 nfserr;
 
-	rqstp->rq_arg = lcp->lc_up_layout;
-	svcxdr_init_decode(rqstp);
+	xdr_init_decode(&xdr, &lcp->lc_up_layout, NULL, NULL);
+	xdr_set_scratch_buffer(&xdr, scratch, sizeof(scratch));
 
-	nfserr = nfsd4_block_decode_layoutupdate(&rqstp->rq_arg_stream,
-			&iomaps, &nr_iomaps, i_blocksize(inode));
+	nfserr = nfsd4_block_decode_layoutupdate(&xdr, &iomaps, &nr_iomaps,
+						 i_blocksize(inode));
+	xdr_finish_decode(&xdr);
 	if (nfserr != nfs_ok)
 		return nfserr;
 
@@ -461,15 +464,18 @@ static __be32
 nfsd4_scsi_proc_layoutcommit(struct inode *inode, struct svc_rqst *rqstp,
 		struct nfsd4_layoutcommit *lcp)
 {
+	__be32 scratch[XDR_QUADLEN(NFS4_DEVICEID4_SIZE)];
+	struct xdr_stream xdr;
 	struct iomap *iomaps;
 	int nr_iomaps;
 	__be32 nfserr;
 
-	rqstp->rq_arg = lcp->lc_up_layout;
-	svcxdr_init_decode(rqstp);
+	xdr_init_decode(&xdr, &lcp->lc_up_layout, NULL, NULL);
+	xdr_set_scratch_buffer(&xdr, scratch, sizeof(scratch));
 
-	nfserr = nfsd4_scsi_decode_layoutupdate(&rqstp->rq_arg_stream,
-			&iomaps, &nr_iomaps, i_blocksize(inode));
+	nfserr = nfsd4_scsi_decode_layoutupdate(&xdr, &iomaps, &nr_iomaps,
+						i_blocksize(inode));
+	xdr_finish_decode(&xdr);
 	if (nfserr != nfs_ok)
 		return nfserr;
 

-- 
2.56.0

