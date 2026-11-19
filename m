Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1795110184;
	b=yUVHLgbJcsU4Vq/OabThoKtBDCxrFDstgkUODYwTnCyW7k+WFc1ePCKbpv/G2NY0AHkg
	 qAWKyHCfuLplfB3h/6rQogo3mK+Gz0jZsa8ENm25Qm+Qb2/bmFTC2646wQnDWGV7REnrq
	 R3AomntamD9qBP0tFdHMzSGOXKGq8Pqdicem3MyhBLcf+v16DUpLKfeNR5bSnBo1bO6i4
	 ckqq7gVgB0DTPpuGv81cVbbQbnp33ETQPvVQIbAED90bWxEgtcwocMPFS0YoQfGzSHFdn
	 g4fvSKUM90gwifBpRiIePlxcsCnK4us2kMwnkxzr8Z84QGi4kavrDr5gT3JxOjg5sMw==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1795110184;
	h=Received:DKIM-Signature:From:Date:Subject:MIME-Version:Content-Type:
	 Content-Transfer-Encoding:Message-Id:X-B4-Tracking:X-Change-ID:To:Cc:
	 X-Mailer:X-Developer-Signature:X-Developer-Key;
	bh=5f2ycr1OVyjtQGD5zgnb0pl7+2ghGM2kcSUNq0kOWUE=;
	b=Vn1jgdace8ClUi7LjLS1wmBq09k2dnP2rxDSsYzDrYLHAzJ4TMxm7+j+FrU+WTchptgf
	 u/Hw6J4qgnva04XeQ/Lv7pGRsCyur7mNDN747rkmLUmoOgm3iIQDBpGnvxrnWQpmFx15u
	 HxluGPWs2k9xisMRV8qN0xIgS5QtLNO8+YzBeg3oc8i+KFrutzNpvNizbTLtLnm7Dw3lE
	 1+xvP9nEsADHoael9BsYecxbInYZkxhZ69udT5P8AGH0aD+u3oIXcqgMzsVIUGI1OrAQZ
	 h3RmZx4skP52H6SlsfEsQyN145ZAB5+HpAuHs5y84BvqIpVJxFImbVtEbwk/oYRcVqw==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=CjgNghN1;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 4C307606A320;
	Thu, 19 Nov 2026 17:43:03 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=CjgNghN1
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 8D29F1F000C6;
	Thu, 19 Nov 2026 17:43:03 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1795110183;
	bh=5f2ycr1OVyjtQGD5zgnb0pl7+2ghGM2kcSUNq0kOWUE=;
	h=From:Date:Subject:To:Cc;
	b=CjgNghN1ANxZdhVQhHdhtZKCMRW1EDaLFD60JddPFn6XZUUNG3Ve7UE2m+c9rVbty
	 n3+Fa170DxP11f9uXRKMo+RU9qSQhEIYI6nUBg2bgfAnQmScKMZdgBpD37EOc2Nfw4
	 OaXrsxPKEs9sDJV0IWHJ4cCY20jmVjhrtYenLeev3qL2A0kdHy7DGlfrZIAgiEb+JD
	 6WKf3u7MGbuAlRi8NYrqQXPZjDkfVs65OGUn3P7Hz4lu1SEME51LBroAjxQ3jehrSK
	 ZJ0w8AkSuMUrhzGrFnrl3t4svClmkSupf1UF/hhDIPzzAvTrwTGYIPauuZujY0r6MH
	 KOp54CH4TZGNg==
From: Jeff Layton <jlayton@kernel.org>
Date: Thu, 19 Nov 2026 09:42:56 -0800
Subject: [PATCH] NFSD: Reject a COPY whose source and destination are the
 same file
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
Message-Id: <20261119-nfsd-copy-same-file-v1-1-ef18e53a00d0@kernel.org>
X-B4-Tracking: v=1; b=H4sIAAAAAAAC/x3MMQqAMAxA0atIZgM2aIteRRzEphrQKg2IIt7d4
 viG/x9QTsIKXfFA4lNU9phhygKmZYwzo/hsoIqsMabFGNTjtB836rgxBlkZqXauamoi8hZyeSQ
 Ocv3XfnjfD7yzDRdlAAAA
X-Change-ID: 20261119-nfsd-copy-same-file-2477054222d6
To: Chuck Lever <cel@kernel.org>, NeilBrown <neil@brown.name>, 
 Olga Kornievskaia <okorniev@redhat.com>, Dai Ngo <Dai.Ngo@oracle.com>, 
 Tom Talpey <tom@talpey.com>, Anna Schumaker <Anna.Schumaker@netapp.com>
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org, 
 Jeff Layton <jlayton@kernel.org>
X-Mailer: b4 0.14.3
X-Developer-Signature: v=1; a=openpgp-sha256; l=2125; i=jlayton@kernel.org;
 h=from:subject:message-id; bh=DUuGEFwqlt4gVcBlnEit+Zpc28czPz0SVBd0vgea6qc=;
 b=owEBbQKS/ZANAwAKAQAOaEEZVoIVAcsmYgBq/zUihO2xqSTRW+8gYHiAvQZZ2r4JXbig3Ibla
 p7C2II6nPSJAjMEAAEKAB0WIQRLwNeyRHGyoYTq9dMADmhBGVaCFQUCav81IgAKCRAADmhBGVaC
 FVCBEACUbPsB8j4g5XD/fLnxgJ2hur9yYETjj7hQ41y8IXuwXHFowJ1jYWOcusfEuCvnEKwIccN
 w/W4drW0TFs7gjQyIdXuHry9eJN5M6T8ThJLFkC/EoFx3ja2ccs8BPrJQTMtu2hoGvjTZlYAzSK
 2SLuQiJxomT20pqzOdY0+20071nQv+UpXgllLOIlW4LNc5QHYBgAmKhRR8aGWqpkL7eh9qY0n3L
 TVWZlf6vYPFHNxrUZP8iC2m9arn4ZMdB/ab4P02apYD7KdNcT+8BeqEQaES/M15O+/19UbvN4yt
 5S3gVesg6KDnMmAMSLhDJFqvWrL0OtxaQwTpV9/DdFMU9aQEVzjAybWWFqcScGgEuz/ocuImUny
 S9UHqjAa0ltRjW9BiyZuMCNTlzAaIERu/feAOujubDuMEI/eKqDhEVJFBJoTXO8pFsi5eEJaPRB
 P8kIxYUS6nnexvwK0Oz9DWSlwyu9bo/CpEpLI6WGdkKjDFPcdvXJm1xtNO6D4naRNAaKLMisRQh
 XYUmgjLTBewfUfuAO4q1EBq0E7j4vd3b7ZP/Ou+k+9D+bPuBoDKozhPfZ8LznIhDfOFNU/GfLRE
 K+B2IBqFaKVRbHWebV9qGL9N+ljPCYV7Tv1dDL04qSOO+rvJXS4ubcQNTTOaqEcU6W+gLkc+/c+
 pfU7DacSOcl3MdA==
X-Developer-Key: i=jlayton@kernel.org; a=openpgp;
 fpr=4BC0D7B24471B2A184EAF5D3000E684119568215

RFC 7862 Section 15.2.3 says that COPY MUST fail with NFS4ERR_INVAL
when SAVED_FH and CURRENT_FH refer to the same file, whatever the
ranges. NFSD never checks for this. A same-file COPY with
non-overlapping ranges succeeds, and one with overlapping ranges fails
only because the VFS rejects it.

The overlap-only rule applies to CLONE (Section 15.13.3), so leave
nfsd4_verify_copy() alone. Instead, check in nfsd4_setup_intra_ssc(),
after both stateids are verified. For an inter-server copy, SAVED_FH
names a file on another server, so that path is not affected.

The Linux client never sends a same-file COPY, so this does not change
its behaviour. Found by pynfs COPY11.

Fixes: 29ae7f9dc21a ("NFSD: Implement the COPY call")
Signed-off-by: Jeff Layton <jlayton@kernel.org>
---
 fs/nfsd/nfs4proc.c | 20 +++++++++++++++++---
 1 file changed, 17 insertions(+), 3 deletions(-)

diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index 9fba2b67cce2..27e9cd7ebf59 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -2107,9 +2107,23 @@ nfsd4_setup_intra_ssc(struct svc_rqst *rqstp,
 		      struct nfsd4_compound_state *cstate,
 		      struct nfsd4_copy *copy)
 {
-	return nfsd4_verify_copy(rqstp, cstate, &copy->cp_src_stateid,
-				 &copy->nf_src, &copy->cp_dst_stateid,
-				 &copy->nf_dst);
+	__be32 status;
+
+	status = nfsd4_verify_copy(rqstp, cstate, &copy->cp_src_stateid,
+				   &copy->nf_src, &copy->cp_dst_stateid,
+				   &copy->nf_dst);
+	if (status)
+		return status;
+
+	/*
+	 * RFC 7862 Section 15.2.3: COPY MUST fail with NFS4ERR_INVAL when
+	 * SAVED_FH and CURRENT_FH refer to the same file, whether or not the
+	 * ranges overlap. The caller releases nf_src and nf_dst.
+	 */
+	if (file_inode(copy->nf_src->nf_file) ==
+	    file_inode(copy->nf_dst->nf_file))
+		return nfserr_inval;
+	return nfs_ok;
 }
 
 static void nfsd4_cb_offload_release(struct nfsd4_callback *cb)

---
base-commit: 00270637d0d956cd6343c41bfd9220ba90360fac
change-id: 20261119-nfsd-copy-same-file-2477054222d6

Best regards,
-- 
Jeff Layton <jlayton@kernel.org>

