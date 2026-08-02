Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 6CE2E3BD638
	for <linux-nfs@vger.kernel.org>; Sun,  2 Aug 2026 17:04:45 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1785690287; cv=none; b=EqrfkhxUPaS4gYiLkUTfyP4F4R8B7bRtgTmJomzbSPZhX2jZIiNai6oVbf/8uQtpYj+uAOqA7NRLze8Zro5BJHP4wTH0TuDIrtqoqMHdpHuozqKK3+9BgGO17gQqgjjnGVggUVH8agJniji6bKAbwFJqCiyy7DIO9X0SsvtuRPg=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1785690287; c=relaxed/simple;
	bh=/7aEv2+Nk6nT4mxOivHF9Qx9BfCUtMm2Y1Ttg+ajqAI=;
	h=From:Date:Subject:MIME-Version:Content-Type:Message-Id:References:
	 In-Reply-To:To:Cc; b=c5bXOLe/vq6vSIi/xwHu1GOwy/tRa8giT6crwY/2igh5KKPwxH55MhHbh/lzNEDax0HzLIHzgGlZ2vnjNPHHOMbtdVxqFdSJGzGDiXxBv4bFKlcjxj8ivTGRmVPP5wfGCBY01Tafl9o8NuoNkUt2dsCfmQT02Cq0sR6X6+U10UQ=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=jB4FOmST; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="jB4FOmST"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 662991F00A3F;
	Sun,  2 Aug 2026 17:04:44 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1785690284;
	bh=crV5QZ5XofmJ4Svfv4llooHY830/NttzgZpQC4v8pRU=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=jB4FOmSTlO7yA142XwlBCSpO8Btp6RmkxhCGarAaZgyxNjSeuy9htYc50Rpj9NLVQ
	 RjLKzFqdIFUkk4omPpLrnO9z0jAi3RNQaj41ZbJXz9mQF5WA+LLZWCZK+6wTiB6Bi6
	 mEAFuP/pHDLt74oACFZQyfl8kA+GnjoMlh8cn3FCrJDcmuApCtodO1XV0lZ3/FTqKu
	 T9VMMpI8Cqb6BWRtRblMP3SoZoGDJpffTXt9/yrjZv1GMn9gN5c3XfpzHYaG29CXBt
	 uRWt7PkV5M6VV/AhVLBHviZcskH5eag2vsf5ot78Ku4Mvf4vmicI2G3INcyTW3EbXj
	 GFGu6qS0trtMQ==
From: Chuck Lever <cel@kernel.org>
Date: Sun, 02 Aug 2026 13:04:29 -0400
Subject: [PATCH 2/9] NFSD: Budget the CB_RECALL truncate field
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20260802-nfsd-deleg-destroy-badhandle-v1-2-323aa7196055@kernel.org>
References: <20260802-nfsd-deleg-destroy-badhandle-v1-0-323aa7196055@kernel.org>
In-Reply-To: <20260802-nfsd-deleg-destroy-badhandle-v1-0-323aa7196055@kernel.org>
To: Jeff Layton <jlayton@kernel.org>, NeilBrown <neil@brown.name>, 
 Olga Kornievskaia <okorniev@redhat.com>, Dai Ngo <Dai.Ngo@oracle.com>, 
 Tom Talpey <tom@talpey.com>
Cc: linux-nfs@vger.kernel.org, Chuck Lever <cel@kernel.org>
X-Mailer: b4 0.16-dev-da966
X-Developer-Signature: v=1; a=openpgp-sha256; l=1276; i=cel@kernel.org;
 h=from:subject:message-id; bh=/7aEv2+Nk6nT4mxOivHF9Qx9BfCUtMm2Y1Ttg+ajqAI=;
 b=owEBbQKS/ZANAwAKATNqszNvZn+XAcsmYgBqb3iqWItTfLiVX+N8Bm9vXTbwjGeVOTYOfwxwa
 V4fDbwd5xiJAjMEAAEKAB0WIQQosuWwEobfJDzyPv4zarMzb2Z/lwUCam94qgAKCRAzarMzb2Z/
 lzSoD/0boVYGcIpKCjybMCysZUz5vnANResd0wpR57R0WJhESu/KFpGZMXPBKMVm9kURFxXvQ6b
 VWa72TDi4F+Xz7agi+O90unZkUwJ1JJnVJT7LX0h7RgMKsBVnUh30ZjAbOm4HEHgdhcEPAos9dQ
 22V3L5XEW/6m48HXJ9482JM8vL4R+e0xbjE3h1l4uDLfEvRp3D6u4kRrLr/bLl+YomUgtZwI40i
 4XV/Pp3zQwQywHQS4StvBPqks22y3aB6e1rdghBwyYtCjY/KH8pzMm2NDooarz4v18j1n9tnHa0
 Dk8F0ClMvx3DjrHdA0c95PMWu2BXtFC6kAfPS7+wLsDiz7HYJCQ3/Tto3xCr3C/4HbuYIgG/Ktq
 FNPwH0ylm7hs0K0yWRKAUYdF1M7/fX6umv0TKdDJWWzsvy1qgRUOXotd/r8y+CpuWZMLuj37jqB
 Lo0CbCNjIvBnFxXahCSZBbUvkmI9hzLz0nhrqZPC+xt0eiD4sYmKsceaTWRcmmnX6w0JZAAgza9
 vfvdMyL3p3q4a0U1Zp/EclfKbb7pahC9B56Uim+tyHZlblfBehL0m8GEFbjTxMLqvzQXCiJj+4h
 cPc8x3e7y7P2wnqrTPTy78SEa9Kk7bhl0f2sDGbtvGte/5o2sDRVuudc2MfoLhU4uO8dMkdz8+U
 IYpcm/XnHxbonPQ==
X-Developer-Key: i=cel@kernel.org; a=openpgp;
 fpr=28B2E5B01286DF243CF23EFE336AB3336F667F97

NFS4_enc_cb_recall_sz counts the CB_RECALL opcode, the stateid, and the
file handle. encode_cb_recall4args() also emits the truncate field, so
the macro falls one XDR word short.

NFSD_CB_MAX_REQ_SZ derives from this macro, so the minimum
ca_maxrequestsize a client must advertise rises by four bytes.

The field has been unbudgeted since the macro was written. Neither
consumer of the macro justifies a backport. rq_callsize covers
p_arglen with two credential slacks. The only client affected is one
whose ca_maxrequestsize falls inside those four bytes.

Signed-off-by: Chuck Lever <cel@kernel.org>
---
 fs/nfsd/xdr4cb.h | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/fs/nfsd/xdr4cb.h b/fs/nfsd/xdr4cb.h
index 04d3e321a972..a7c8dc355d1a 100644
--- a/fs/nfsd/xdr4cb.h
+++ b/fs/nfsd/xdr4cb.h
@@ -19,8 +19,8 @@
 #define enc_stateid_sz			(NFS4_STATEID_SIZE >> 2)
 #define NFS4_enc_cb_recall_sz		(cb_compound_enc_hdr_sz +       \
 					cb_sequence_enc_sz +            \
-					1 + enc_stateid_sz +            \
-					enc_nfs4_fh_sz)
+					op_enc_sz + enc_stateid_sz +    \
+					1 + enc_nfs4_fh_sz)
 
 #define NFS4_dec_cb_recall_sz		(cb_compound_dec_hdr_sz  +      \
 					cb_sequence_dec_sz +            \

-- 
2.54.0

