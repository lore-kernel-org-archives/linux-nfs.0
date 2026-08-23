Received: from mx0b-00154904.pphosted.com (mx0b-00154904.pphosted.com [148.163.137.20])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 4E0B636920D
	for <linux-nfs@vger.kernel.org>; Sun, 23 Aug 2026 11:33:17 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=148.163.137.20
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1787484799; cv=none; b=DVk38wCDG5TwyGNgbQvO0IzkOTSQ7u/sSZAT+ykI5B7tdgjCBDHOaknVuE0SBiZkQal89RDJw8Pyq08no5s1fObvgzpfYFYjfoCDGjBTIPuK+pRu6QHTr5cKcDtcmWT5k9CRW4yZ1dkQG9LWUjhGDmGm8XtrCB35RERL+3Eu/FA=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1787484799; c=relaxed/simple;
	bh=7JGgsA30Ai3ow7KuE0EsDOera/bbHxze236C5Kx10cA=;
	h=From:To:Cc:Subject:Date:Message-ID:MIME-Version; b=r/6OSBpIC4N+H7CoKupjCGy/LZV6YtNMevpwxObIvLj/r13kT9axxkKWQEcbEDjva9FtU1Pq7orlpKxexghehKCprZoLbdI8kmTpevGBkdLu8ncs+JMqGd92jNH73lkXAb8SYeoEyoNK4fIBrwfnAr8twIKiZHceHfq/0bahFLc=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=dell.com; spf=pass smtp.mailfrom=dell.com; dkim=pass (2048-bit key) header.d=dell.com header.i=@dell.com header.b=nl51xI7V; dkim=pass (2048-bit key) header.d=dell.com header.i=@dell.com header.b=WxUnouEw; arc=none smtp.client-ip=148.163.137.20
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=dell.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=dell.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=dell.com header.i=@dell.com header.b="nl51xI7V";
	dkim=pass (2048-bit key) header.d=dell.com header.i=@dell.com header.b="WxUnouEw"
Received: from pps.filterd (m0170398.ppops.net [127.0.0.1])
	by mx0b-00154904.pphosted.com (8.18.1.11/8.18.1.11) with ESMTP id 67NAA2EE017896
	for <linux-nfs@vger.kernel.org>; Sun, 23 Aug 2026 07:33:11 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=dell.com; h=cc
	:content-transfer-encoding:date:from:message-id:mime-version
	:subject:to; s=smtpout1; bh=Ti35abEh5n+uUg9qgrWVI+E5O4UoV7z2u00q
	CqgX6GI=; b=nl51xI7Vo/L3DqiHCQTZlCpaiwCaKOwEBHp/hInwTlBeYXEiDDaQ
	jvPGQu2+sJAhe3xOetNjtV/YZ0g85SOctx95PzyeEjket31S49BKQV9AEhmb2VYr
	Ml8uqjfQPJEsH9jwAZQcR02LqU0LNmDyxZLkbilUJ29Ibg5mLNV0y6AIwht2UJ60
	ggRaXGsFQJkxQ4YC7xZD7O2UFhIRavRvO0OalOK0dnOfgJoKR5l0GH7Tpx2Ka7cf
	Zr1eoz92FTYZi14lxYFqpMkpgy2U7At4HQu+zXZ+tvyiHbDpJQMDa3uEKVrTfmEZ
	o0wApp5e1Ewo8s17fqVgNoFYQxtwLlLd8g==
Received: from mx0a-00154901.pphosted.com (mx0a-00154901.pphosted.com [67.231.149.39])
	by mx0b-00154904.pphosted.com (PPS) with ESMTPS id 4g7704tjvp-1
	(version=TLSv1.3 cipher=TLS_AES_256_GCM_SHA384 bits=256 verify=NOT)
	for <linux-nfs@vger.kernel.org>; Sun, 23 Aug 2026 07:33:11 -0400 (EDT)
Received: from pps.filterd (m0134746.ppops.net [127.0.0.1])
	by mx0a-00154901.pphosted.com (8.18.1.11/8.18.1.11) with ESMTP id 67NAA80N428130
	for <linux-nfs@vger.kernel.org>; Sun, 23 Aug 2026 07:33:10 -0400
Received: from esapsmtplv09.us.dell.com (esapsmtplv09.us.dell.com [143.166.203.151])
	by mx0a-00154901.pphosted.com (PPS) with ESMTPS id 4g7x3095ew-1
	(version=TLSv1.3 cipher=TLS_AES_256_GCM_SHA384 bits=256 verify=FAIL)
	for <linux-nfs@vger.kernel.org>; Sun, 23 Aug 2026 07:33:10 -0400 (EDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
  d=dell.com; i=@dell.com; q=dns/txt; s=smtpdev1;
  t=1787484791; x=1819020791;
  h=from:to:cc:subject:date:message-id:mime-version:
   content-transfer-encoding;
  bh=Ti35abEh5n+uUg9qgrWVI+E5O4UoV7z2u00qCqgX6GI=;
  b=WxUnouEwoZw2OiGxT4bXV9KXfhkR+yRamZ5thGynW5gubSjRmtk6ACwq
   KCE9wR3GYyBX7wdS5aDEyOXm+F/g0uDaAtclUderHlriT/Yex96VI6zGO
   xBwz0OCIAOaVuFw+WUJ5gXdECco4I2e13JKs+puyA6N+TADQ5NPABxxAi
   Mm54gaCEGSqeSqAIIkdicIuENXwVtbFdz/DZKEGVEnvgC6yZ5dDp167Q7
   TE5W9iNTQ+VDltSj/a+khXuy5T2vfChvbLo+pNsITX1EMu/ZUJpt6LQ+d
   WRsZMLa/C77zO6hQFEq2px8OeDCWxLNPQOWI3HrjBOvX7SGmBlJ7TVypW
   w==;
X-CSE-ConnectionGUID: V7rfXtbRTM6yOMT0MTwhuQ==
X-CSE-MsgGUID: hHYIMv4TTZO4Sxcgd29Zhg==
X-LoopCount0: from 10.17.189.166
X-MS-Exchange-CrossPremises-AuthAs: Internal
Received: from unknown (HELO W-96J1TH4.blr.amer.dell.com) ([10.17.189.166])
  by esapsmtplv09.us.dell.com with ESMTP/TLS/TLS_AES_256_GCM_SHA384; 23 Aug 2026 11:33:07 +0000
From: prabhakar.pujeri@dell.com
To: Chuck Lever <cel@kernel.org>, Jeff Layton <jlayton@kernel.org>
Cc: NeilBrown <neil@brown.name>, Olga Kornievskaia <okorniev@redhat.com>,
        Dai Ngo <Dai.Ngo@oracle.com>, Tom Talpey <tom@talpey.com>,
        Rick Macklem <rmacklem@uoguelph.ca>, linux-nfs@vger.kernel.org,
        Prabhakar Pujeri <prabhakar.pujeri@dell.com>
Subject: [PATCH] nfsd: release POSIX ACLs of unexecuted compound ops
Date: Sun, 23 Aug 2026 11:32:55 +0000
Message-ID: <20260823113255.3417-1-prabhakar.pujeri@dell.com>
X-Mailer: git-send-email 2.53.0
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Proofpoint-Virus-Version: vendor=baseguard
 engine=ICAP:2.0.293,Aquarius:18.0.1176,Hydra:6.1.134,FMLib:17.12.100.49
 definitions=2026-08-23_04,2026-08-21_02,2025-10-01_01
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0
 phishscore=0 bulkscore=0 adultscore=0 malwarescore=0 suspectscore=0
 spamscore=0 priorityscore=1501 impostorscore=0 clxscore=1011
 lowpriorityscore=0 classifier=typeunknown authscore=0 authtc= authcc=
 route=outbound adjust=0 reason=mlx scancount=1 engine=8.22.0-2606150000
 definitions=main-2608230104
X-Proofpoint-Spam-Info: AW1haW4tMjYwODIzMDEwNSBTYWx0ZWRfXxTiD6rEE/LhH
 /md46MOLAsSujhBZJzwJ9YpLnD5tbgf5R3esrCPX6yGrLPwLIRlEpnG12iIRgn/7rTF8KnaW4Fw
 R6SCnmE/BeJhBHZmq1JAj27oPlxke2s=
X-Proofpoint-ORIG-GUID: qBSTsq2H3BM3waFeDmdW-YOVDQY0nkQ0
X-Proofpoint-GUID: qBSTsq2H3BM3waFeDmdW-YOVDQY0nkQ0
X-Authority-Analysis: v=2.4 cv=JpPBas4C c=1 sm=1 tr=0 ts=6a8ada77 cx=c_pps
 a=j0++y401J6f/BxNAf5EDow==:117 a=1BWgYg405ukQaXe9BCXDPw==:17
 a=b3DhMmMkJVNBYjixYE3i3TbOsPs=:19 a=Sv0fKeRqtYgA:10 a=ke5jqHz-1hQA:10
 a=VkNPw1HP01LnGYTKEx00:22 a=6gNNCFAoQcIphELLPWWu:22 a=vUAfKriDyi6VqHAKCLgX:22
 a=iLNU1ar6AAAA:8 a=ktf7JTcnP4ES0ovlpp0A:9 a=gbU3OgOOxF9bX48Letew:22
X-Proofpoint-Spam-Details-Enc: AW1haW4tMjYwODIzMDEwNSBTYWx0ZWRfX8esBOKUH3LNm
 qP2+FNATprTMltBziNgjEWiOYJ62X0CW4UccBpQGnAWLCLphonL/+wiFCwB51da9mT15A+cSoe2
 Vl41/rf+Q6SD65000jCCgeHNh81aEUQN7/42k+x6uZfbq/YOBvV4KkjJ1tBBjqZLTh6aQawL5i9
 iQhv+lrg7okDziA8EwtpBwUJC3FEDT7PjNxuXKX5pM5n1wLMborxViw86HOZDYLUENZBcQdSgQt
 AYGHawLhIZJcTA2VlTdrSzyRqeSnYr4d6b3g6g4ZFX9CNdP6fu46A4lUP2egVXnHkF2BbI/c3hg
 3VPbuKRU8BzK3yJ0E0eeDJ8jn1C7oUun3w8wOPAY70Pyx7wiUiJBrCAuYKnkxyYRwNbjCWSHwKC
 hczzgdo3Q0QY6utUxCPssF2LNTCT+8k98ftALkh4n+y+EEDsD11PDWB6YIXvr4Nix9UvqW5IoxG
 y+loxMpLah3tzqkOTQA==
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 malwarescore=0
 lowpriorityscore=0 bulkscore=0 clxscore=1011 spamscore=0 suspectscore=0
 impostorscore=0 adultscore=0 priorityscore=1501 phishscore=0
 classifier=typeunknown authscore=0 authtc= authcc= route=outbound adjust=0
 reason=mlx scancount=1 engine=8.22.0-2606150000 definitions=main-2608230105

From: Prabhakar Pujeri <prabhakar.pujeri@dell.com>

nfsd4_decode_fattr4() allocates POSIX ACLs while decoding OP_OPEN,
OP_CREATE, and OP_SETATTR. Normally a processed OPEN releases them from
its op_release callback, while CREATE and SETATTR transfer ownership to
struct nfsd_attrs and clear their pointers.

If compound processing stops before a decoded ACL-bearing operation,
nfsd4_release_compoundargs() frees the operation array without dropping
those ACL references. A client can repeat an aborting compound to leak
server memory.

Release ACLs that remain attached to decoded operations when the
compound arguments are destroyed. Clear the OPEN pointers in its release
callback so the final sweep remains idempotent for processed operations;
CREATE and SETATTR already clear theirs when transferring ownership.

The procedure release callback also runs after a hard XDR decode failure.
Keep opcnt limited to fully initialized entries on a truncated operation
number, and clear it when the dynamic operation array cannot be
allocated, so cleanup never walks stale inline entries or beyond the
inline array.

An A/B kmemleak test with 512 crafted NFSv4.2 compounds found 347--349
leaked 64-byte ACL objects without this change and none with it. On the
rebased kernel, 512 runtime-abort and 512 hard-decode compounds completed
without a kmemleak or KASAN report.

Fixes: 5fc51dfc2eb1 ("NFSD: Add support for XDR decoding POSIX draft ACLs")
Signed-off-by: Prabhakar Pujeri <prabhakar.pujeri@dell.com>
---
 fs/nfsd/nfs4proc.c |  2 ++
 fs/nfsd/nfs4xdr.c  | 31 ++++++++++++++++++++++++++++++-
 2 files changed, 32 insertions(+), 1 deletion(-)

diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index 88385a161b4d..3d0404592580 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -800,6 +800,8 @@ nfsd4_open_release(union nfsd4_op_u *u)
 {
 	posix_acl_release(u->open.op_dpacl);
 	posix_acl_release(u->open.op_pacl);
+	u->open.op_dpacl = NULL;
+	u->open.op_pacl = NULL;
 }
 
 /*
diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index a154b02d82b3..6be367998a40 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -2680,6 +2680,7 @@ nfsd4_decode_compound(struct nfsd4_compoundargs *argp)
 		argp->ops = vcalloc(argp->opcnt, sizeof(*argp->ops));
 		if (!argp->ops) {
 			argp->ops = argp->iops;
+			argp->opcnt = 0;
 			return false;
 		}
 	}
@@ -2692,8 +2693,10 @@ nfsd4_decode_compound(struct nfsd4_compoundargs *argp)
 		op->replay = NULL;
 		op->opdesc = NULL;
 
-		if (xdr_stream_decode_u32(argp->xdr, &op->opnum) < 0)
+		if (xdr_stream_decode_u32(argp->xdr, &op->opnum) < 0) {
+			argp->opcnt = i;
 			return false;
+		}
 		if (nfsd4_opnum_in_range(argp, op)) {
 			op->opdesc = OPDESC(op);
 			op->status = nfsd4_dec_ops[op->opnum](argp, &op->u);
@@ -6836,6 +6839,32 @@ void nfsd4_encode_replay(struct xdr_stream *xdr, struct nfsd4_op *op)
 void nfsd4_release_compoundargs(struct svc_rqst *rqstp)
 {
 	struct nfsd4_compoundargs *args = rqstp->rq_argp;
+	unsigned int i;
+
+	/*
+	 * Ops that were decoded but never executed (a later op failed to
+	 * decode, or an earlier op failed at runtime) may still hold
+	 * decoded POSIX ACLs; release them here.  Executed ops have
+	 * already released or NULLed their ACL pointers.
+	 */
+	for (i = 0; i < args->opcnt; i++) {
+		struct nfsd4_op *op = &args->ops[i];
+
+		switch (op->opnum) {
+		case OP_OPEN:
+			posix_acl_release(op->u.open.op_dpacl);
+			posix_acl_release(op->u.open.op_pacl);
+			break;
+		case OP_CREATE:
+			posix_acl_release(op->u.create.cr_dpacl);
+			posix_acl_release(op->u.create.cr_pacl);
+			break;
+		case OP_SETATTR:
+			posix_acl_release(op->u.setattr.sa_dpacl);
+			posix_acl_release(op->u.setattr.sa_pacl);
+			break;
+		}
+	}
 
 	args->opcnt = 0;
 	if (args->ops != args->iops) {

base-commit: 01c2994ccb0197cb44b0db89aacab460110f6347
-- 
2.54.0

