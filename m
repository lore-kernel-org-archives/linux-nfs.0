Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:19812 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754664Ab3CSNHx (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 19 Mar 2013 09:07:53 -0400
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 09/11] NFSv4.1: Add xdr support for CLAIM_FH and CLAIM_DELEG_CUR_FH opens
Date: Tue, 19 Mar 2013 09:07:41 -0400
Message-Id: <1363698463-3681-9-git-send-email-Trond.Myklebust@netapp.com>
In-Reply-To: <1363698463-3681-8-git-send-email-Trond.Myklebust@netapp.com>
References: <1363698463-3681-1-git-send-email-Trond.Myklebust@netapp.com>
 <1363698463-3681-2-git-send-email-Trond.Myklebust@netapp.com>
 <1363698463-3681-3-git-send-email-Trond.Myklebust@netapp.com>
 <1363698463-3681-4-git-send-email-Trond.Myklebust@netapp.com>
 <1363698463-3681-5-git-send-email-Trond.Myklebust@netapp.com>
 <1363698463-3681-6-git-send-email-Trond.Myklebust@netapp.com>
 <1363698463-3681-7-git-send-email-Trond.Myklebust@netapp.com>
 <1363698463-3681-8-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 fs/nfs/nfs4xdr.c | 23 +++++++++++++++++++++++
 1 file changed, 23 insertions(+)

diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index 9d32877..650fa32 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -1459,6 +1459,23 @@ static inline void encode_claim_delegate_cur(struct xdr_stream *xdr, const struc
 	encode_string(xdr, name->len, name->name);
 }
 
+static inline void encode_claim_fh(struct xdr_stream *xdr)
+{
+	__be32 *p;
+
+	p = reserve_space(xdr, 4);
+	*p = cpu_to_be32(NFS4_OPEN_CLAIM_FH);
+}
+
+static inline void encode_claim_delegate_cur_fh(struct xdr_stream *xdr, const nfs4_stateid *stateid)
+{
+	__be32 *p;
+
+	p = reserve_space(xdr, 4);
+	*p = cpu_to_be32(NFS4_OPEN_CLAIM_DELEG_CUR_FH);
+	encode_nfs4_stateid(xdr, stateid);
+}
+
 static void encode_open(struct xdr_stream *xdr, const struct nfs_openargs *arg, struct compound_hdr *hdr)
 {
 	encode_op_hdr(xdr, OP_OPEN, decode_open_maxsz, hdr);
@@ -1474,6 +1491,12 @@ static void encode_open(struct xdr_stream *xdr, const struct nfs_openargs *arg,
 	case NFS4_OPEN_CLAIM_DELEGATE_CUR:
 		encode_claim_delegate_cur(xdr, arg->name, &arg->u.delegation);
 		break;
+	case NFS4_OPEN_CLAIM_FH:
+		encode_claim_fh(xdr);
+		break;
+	case NFS4_OPEN_CLAIM_DELEG_CUR_FH:
+		encode_claim_delegate_cur_fh(xdr, &arg->u.delegation);
+		break;
 	default:
 		BUG();
 	}
-- 
1.8.1.4

