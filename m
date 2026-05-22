Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 04E7637DE9E;
	Fri, 22 May 2026 19:42:53 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1779478978; cv=none; b=f0uyQNcBs6VzgSud1Mf3zMplzA0fzjyYFxtFzOcPrNFIGryw9/yutqKJT8vswLJFUPBOeV94VtTaw4uBk0lqw8y6Bz0q+9fp72A9sw6OM4ERZf4zSkhkotDXj/w6MqnmVjLBIcTzZ3FMKSSQaCYpy5q8MxWRgedaNOfzfZm1d2c=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1779478978; c=relaxed/simple;
	bh=WtCsTt7GqWI6wIG7UjJHamJhQxbCqTdMWHwIGmCs/cc=;
	h=From:Date:Subject:MIME-Version:Content-Type:Message-Id:References:
	 In-Reply-To:To:Cc; b=aTO1kEqih2On3XMqRJNQ9qeOOadxrC5RAtpca9K+O+dwgDAK5GuYFmCYjRG8fRMfVM5F0vHfhL+t8v/hVaGeH60OBonGiVyWuTyoHvPjNLXA8L3pAhbeaiUWAtnGx72Uf4vWkLqEcJwA31ufMqzFVgpTLtFzAL9bBYTyNAb5QCo=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=F2OD3lls; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="F2OD3lls"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id A38211F00ADE;
	Fri, 22 May 2026 19:42:51 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1779478973;
	bh=pO+8xSv0vMbVLlIOVu1sUSgwIlOn2Ujffy4e7uLZjPY=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=F2OD3llsM+BfPC5qK7lnR9q1wkDsqN1v9QYtKD7koZmY14Wnac7UnmlcQqVZEn3T9
	 D7LMDkKthoOgNHWNMCNV5I4XRQFHfK4cWXP1LDsjKmcxMl395b+GqY3StRBfV6i5+P
	 Pde5VZSghSm4nPmnEZ2w9qeM//P5Q84ywJEulcQsCRbCSjt/pPaFZPjABOWg1/mro0
	 HVXXyg/yA+RO4o4C1QXSmajSzmAcZc5xUGz21570YLyT0b4yjGrWADe9Gh9nXqfEe6
	 8u/H+fBF7dzT5GXaNOY5B2cmNk2eKytQOL/lyk4FTlqhGiuTLx8+kSCC2IFKjr/wQ8
	 Bqamr6U7SWEhw==
From: Jeff Layton <jlayton@kernel.org>
Date: Fri, 22 May 2026 15:42:17 -0400
Subject: [PATCH v5 12/21] nfsd: apply the notify mask to the delegation
 when requested
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20260522-dir-deleg-v5-12-542cddfad576@kernel.org>
References: <20260522-dir-deleg-v5-0-542cddfad576@kernel.org>
In-Reply-To: <20260522-dir-deleg-v5-0-542cddfad576@kernel.org>
To: Chuck Lever <chuck.lever@oracle.com>, NeilBrown <neil@brown.name>, 
 Olga Kornievskaia <okorniev@redhat.com>, Dai Ngo <Dai.Ngo@oracle.com>, 
 Tom Talpey <tom@talpey.com>, Trond Myklebust <trondmy@kernel.org>, 
 Anna Schumaker <anna@kernel.org>, Jonathan Corbet <corbet@lwn.net>, 
 Shuah Khan <skhan@linuxfoundation.org>
Cc: Steven Rostedt <rostedt@goodmis.org>, 
 Alexander Aring <alex.aring@gmail.com>, Amir Goldstein <amir73il@gmail.com>, 
 Jan Kara <jack@suse.cz>, Alexander Viro <viro@zeniv.linux.org.uk>, 
 Christian Brauner <brauner@kernel.org>, 
 Calum Mackay <calum.mackay@oracle.com>, linux-kernel@vger.kernel.org, 
 linux-doc@vger.kernel.org, linux-nfs@vger.kernel.org, 
 Jeff Layton <jlayton@kernel.org>
X-Mailer: b4 0.14.3
X-Developer-Signature: v=1; a=openpgp-sha256; l=1720; i=jlayton@kernel.org;
 h=from:subject:message-id; bh=WtCsTt7GqWI6wIG7UjJHamJhQxbCqTdMWHwIGmCs/cc=;
 b=owEBbQKS/ZANAwAKAQAOaEEZVoIVAcsmYgBqELGg1F9tddsm0RtgjBxOa/CNGAXc7dyF2CeQW
 A0ASdjs3tOJAjMEAAEKAB0WIQRLwNeyRHGyoYTq9dMADmhBGVaCFQUCahCxoAAKCRAADmhBGVaC
 FdN1D/0RtcRsFtifUyIkdME38Wpl8Hb/38wBnJ7oEnCfjEQHWqws6gK3azMiIyvo7VuZqcd4Nkm
 ohoF9U5w6I8wbP6sIZO83XD9J3xTLIqOR1NrlUm+1cVfQDLwQZSkYnG5VYha4zcR0GOK9HBxgoX
 f7qQ+I5+5abGN4J5qW4+gVtdUKVXZyouWIEVrAwV6INDKthodrgXZDrmHwNObV6OWWvk6mlvRSl
 FH78PfZ9oRfER5zlFebvs5EpWDE0qZ8bCjIUNWlrk6Fsiw7L8wenvX/Qq1SnmAPVzQvB2Y6E7RW
 cKRk+FWNnDJVsK1rYhx3m4PVUqGy4gWaAVQuPXF8acVC548fdn6cFSsws36wy0ovnGOG+nD4ykx
 hUkLya2EaPlsg81izFrwiHHck7AgBya4KAqT/nznhsbSGVF9aBgJErMnpIjSwgVjZXL7zW5lxnL
 HMxp/UMIAEQEzcoNJPfY4wxp8SsgrCM055NOasx/UCwV9zf0cchFPR8gGpSQ4Z0NiTfdSsw1ZhP
 62DuFww8hC3hz5dEXYRYfF4baXjHjEW9a3Su21CgNi/lKdHlI1eHBaCmSQuv3DyaJSJjLeDs8jV
 6R7B3ldvq4NeGHOTMmM85tVLmmk8I8MBmZJ3CTXMyNsrqRJqL+tn+Sv1J7VdD2M8/r1k1LRNHvH
 UUZtrRGtu8kL54g==
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
index 8561540ab2db..30f338f90acd 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -2521,12 +2521,18 @@ nfsd4_verify(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
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
@@ -2535,6 +2541,12 @@ nfsd4_get_dir_delegation(struct svc_rqst *rqstp,
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

