Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id AF2424C900D;
	Thu, 11 Jun 2026 17:50:53 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1781200258; cv=none; b=tMN9YtnzaRefH0yVRPoNMcDs330mJHyUex+Kl+ZQxE+ae0TraFaIb3xTy+wPLH5VRpa22aC+COm1GVFNfQjQ+vnfq0AoRNkacmQBQxmtT1gP6joRaRrBzabqC/2NuTTlz8RGJ8/mAQzbfnzGm26NJR71Af/Py0GCiW68EABI2EI=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1781200258; c=relaxed/simple;
	bh=802r4p+1lz5i5jQlOrwFPXxz63QK2Wr4Z/HExsacQjc=;
	h=From:Date:Subject:MIME-Version:Content-Type:Message-Id:References:
	 In-Reply-To:To:Cc; b=oeylPE7OhlIWPHM6Y/QBh4TXEvgqoSSu6OD/O/oXLk0TdClMrBJXbPo144qDvS+qH6Cz6BYM+wboSGGVioQK13HpvMbQBJ73VolZSD2/s9pBT6Rs3jbSBzVyBo+Zctz4KuzjnMOTRDPe6sLhRR+klreMIL0Az2WZs39V+sOXyfM=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=fIjgw4+e; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="fIjgw4+e"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 504F11F0089B;
	Thu, 11 Jun 2026 17:50:51 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1781200253;
	bh=miYBZIfyo1Ir05EQXD379kBMccvvIIFxC/NAks/UKAs=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=fIjgw4+eXOeIQrn5Xg403U8kaqrrUQ9x6mgA0iaqEnv35n5j3uiZrqEhq3E8bwgcb
	 3YWiAcWpf35YwbkoJkwRiTPK/U8fNrhOc7dYXAeq8Mv9EOY4VNqzzDg/P1vEyp05Np
	 8ouGnUlWNOrdQ5+8nDqLl5/nbRnmADkP3+oznxwgLoJvK/OalHFAWl1uhc0CtiQfJt
	 09qh2qUnjBrJRQ4vA8QgOoX/rOe30igRtYrjGajHOdugigJsT78Bi2K7lqByJ5DCkt
	 zRAN6vIQ6kWlkI+kkY1F3koxcZA3UpEg+57OBaSBK9mturYCOdRjEC1CE7vFTBdd53
	 PTBqGUzpv04gg==
From: Jeff Layton <jlayton@kernel.org>
Date: Thu, 11 Jun 2026 13:50:17 -0400
Subject: [PATCH v6 11/20] nfsd: apply the notify mask to the delegation
 when requested
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20260611-dir-deleg-v6-11-4c45080e5f3f@kernel.org>
References: <20260611-dir-deleg-v6-0-4c45080e5f3f@kernel.org>
In-Reply-To: <20260611-dir-deleg-v6-0-4c45080e5f3f@kernel.org>
To: NeilBrown <neil@brown.name>, Olga Kornievskaia <okorniev@redhat.com>, 
 Dai Ngo <Dai.Ngo@oracle.com>, Tom Talpey <tom@talpey.com>, 
 Trond Myklebust <trondmy@kernel.org>, Anna Schumaker <anna@kernel.org>, 
 Jonathan Corbet <corbet@lwn.net>, Shuah Khan <skhan@linuxfoundation.org>, 
 Chuck Lever <cel@kernel.org>
Cc: Steven Rostedt <rostedt@goodmis.org>, 
 Alexander Aring <alex.aring@gmail.com>, Amir Goldstein <amir73il@gmail.com>, 
 Jan Kara <jack@suse.cz>, Alexander Viro <viro@zeniv.linux.org.uk>, 
 Christian Brauner <brauner@kernel.org>, 
 Calum Mackay <calum.mackay@oracle.com>, linux-kernel@vger.kernel.org, 
 linux-doc@vger.kernel.org, linux-nfs@vger.kernel.org, 
 Jeff Layton <jlayton@kernel.org>
X-Mailer: b4 0.14.3
X-Developer-Signature: v=1; a=openpgp-sha256; l=1720; i=jlayton@kernel.org;
 h=from:subject:message-id; bh=802r4p+1lz5i5jQlOrwFPXxz63QK2Wr4Z/HExsacQjc=;
 b=owEBbQKS/ZANAwAKAQAOaEEZVoIVAcsmYgBqKvVhSEkNhvFe4tdhj1qAHb2xP21odVdtxsOg2
 AAtNQXPsWiJAjMEAAEKAB0WIQRLwNeyRHGyoYTq9dMADmhBGVaCFQUCair1YQAKCRAADmhBGVaC
 FaWaEADR+7D0Jlgc7HJIo9Un89DX/bKM9pYZ6iAj0pu3uHn6wT13/F/l69KekieIA/dEV+zrT1T
 X0YgbH+UxsThnKsrgERoUi8MkzVra/PfwgkUc3SRqpXv4Gq2qNLH87R6rCSQ7gMI39LAXmr2BaR
 7uOQ+Fmfaymbvk1MrjE9E4B6u4ZJZ6umebr03iVs/GJoQTFWNgzdrB/0PVkL48bTHlHh/SKgHSq
 7NOSmuedIyY0NesTbA4mbM2TXH6c7Ar4vR7rpDMxtruJ+OcYp5LeZ6IevDzt+TCq7DSDsYR+9h4
 k8T4IbfrRwXpJqn2AIK2OV2nXCbU1NQDZrNFFn6Kf06tgI5+CXgjeM3YplHYgCt1e8ZlfdhPhoC
 2cHSQtYGou7mTcp965vwHE4JNqg8RaFfiG5EE5g38WRFsmwfnYDkGnuXVAZOVmwWMQLVcvDVR/t
 CcIF4UM+PNPThONCqcNMpIm+ZKVPjTJiI6rh0H0ty/AEuBDcXKKtE0Gi7evUzVMYx+3QlBYl0Uv
 M4Qg36OV7wHBfPmkiSEep7ZC28uvMPEJ7fUTNX6r5ZekTeIbLySx7Hhbcy8rNwAVbhp8KTaW/vo
 B5ymplToOjdmNWac7PQriw12heM7FhkG42wQQUHskDe8PfktqOhH4shWE3mTVrYvMGF1ee+1ylT
 l+aKAAveuJJU/Gw==
X-Developer-Key: i=jlayton@kernel.org; a=openpgp;
 fpr=4BC0D7B24471B2A184EAF5D3000E684119568215

If the client requests a directory delegation with notifications
enabled, set the appropriate return mask in gddr_notification[0]. This
will ensure the lease acquisition sets the appropriate ignore mask.

If the client doesn't set NOTIFY4_GFLAG_EXTEND, then don't offer any
notifications, as nfsd won't provide directory offset information, and
"classic" notifications require them.

Signed-off-by: Jeff Layton <jlayton@kernel.org>
---
 fs/nfsd/nfs4proc.c | 12 ++++++++++++
 1 file changed, 12 insertions(+)

diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index 0c37d7c6d28c..29f7339dc220 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -2530,12 +2530,18 @@ nfsd4_verify(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 	return status == nfserr_same ? nfs_ok : status;
 }
 
+#define SUPPORTED_NOTIFY_MASK	(BIT(NOTIFY4_REMOVE_ENTRY) |	\
+				 BIT(NOTIFY4_ADD_ENTRY) |	\
+				 BIT(NOTIFY4_RENAME_ENTRY) |	\
+				 BIT(NOTIFY4_GFLAG_EXTEND))
+
 static __be32
 nfsd4_get_dir_delegation(struct svc_rqst *rqstp,
 			 struct nfsd4_compound_state *cstate,
 			 union nfsd4_op_u *u)
 {
 	struct nfsd4_get_dir_delegation *gdd = &u->get_dir_delegation;
+	u32 requested = gdd->gdda_notification_types[0];
 	struct nfs4_delegation *dd;
 	struct nfsd_file *nf;
 	__be32 status;
@@ -2544,6 +2550,12 @@ nfsd4_get_dir_delegation(struct svc_rqst *rqstp,
 	if (status != nfs_ok)
 		return status;
 
+	/* No notifications if you don't set NOTIFY4_GFLAG_EXTEND! */
+	if (!(requested & BIT(NOTIFY4_GFLAG_EXTEND)))
+		requested = 0;
+
+	gdd->gddr_notification[0] = requested & SUPPORTED_NOTIFY_MASK;
+
 	/*
 	 * RFC 8881, section 18.39.3 says:
 	 *

-- 
2.54.0

